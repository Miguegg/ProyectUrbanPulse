-- =====================================================================
-- UrbanPulse · Esquema reducido (entidades del modelo de dominio, §4 del PDF)
-- Pegar entero en Supabase > SQL Editor > Run. Borra lo anterior y lo vuelve a crear.
--
-- Convenciones (Spring Data JPA / Hibernate):
--   * PK INTEGER IDENTITY  -> Integer + @GeneratedValue(strategy = GenerationType.IDENTITY)
--                             (status_change, assignment, notification, external_observation,
--                              incident_asset: tablas internas o de alto volumen)
--   * PK UUID (v7)         -> java.util.UUID + @Id @UuidGenerator(style = UuidGenerator.Style.VERSION_7)
--                             (app_user, incident, attachment, urban_asset, urban_context,
--                              knowledge_document: se exponen en URLs/API o cruzan servicios)
--                             Las FK hacia estas tablas tambien son UUID.
--   * Enumerados VARCHAR + CHECK -> enums Java con @Enumerated(EnumType.STRING)
--   * TIMESTAMPTZ -> LocalDateTime
--   * JSONB -> String + @JdbcTypeCode(SqlTypes.JSON)
--   * Las transiciones de estado de la incidencia se validan en Java (enum IncidentStatus).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 0. Borrado de lo anterior (solo objetos de UrbanPulse; no toca nada más)
-- ---------------------------------------------------------------------

DROP VIEW IF EXISTS v_incident_stats_monthly, v_incident_overview CASCADE;

DROP TABLE IF EXISTS
    -- esquema reducido
    urban_context_observation, urban_context, external_observation, incident_asset, urban_asset,
    notification, assignment, attachment, status_change, knowledge_document, incident, app_user,
    -- esquema extendido anterior
    audit_log, knowledge_document_version, urban_context_item, incident_comment,
    incident_duplicate_candidate, incident_priority_history, assisted_suggestion, ml_model,
    incident_status_change, incident_status_transition, incident_status, data_source,
    neighborhood, district, category, notification_preference, team_member, team, user_role,
    role, department
    CASCADE;

DROP FUNCTION IF EXISTS
    set_updated_at(),
    forbid_update_delete(),
    check_incident_status_transition(),
    uuid_v7(),
    distance_m(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION);


-- ---------------------------------------------------------------------
-- 0b. uuid_v7(): UUID ordenable por tiempo (48 primeros bits = milisegundos Unix)
--     Hibernate genera el UUIDv7 desde Java (@UuidGenerator); este DEFAULT cubre
--     los INSERT manuales (SQL Editor, seeds, scripts). En Postgres 18+ se puede
--     sustituir por el uuidv7() nativo.
-- ---------------------------------------------------------------------

CREATE OR REPLACE FUNCTION uuid_v7() RETURNS UUID
LANGUAGE sql VOLATILE AS $$
SELECT encode(
               set_bit(set_bit(
                               overlay(uuid_send(gen_random_uuid())
                                   placing substring(int8send((extract(epoch FROM clock_timestamp()) * 1000)::BIGINT) FROM 3)
                    FROM 1 FOR 6),
                               52, 1), 53, 1),
               'hex')::UUID;
$$;


-- ---------------------------------------------------------------------
-- 1. User
-- ---------------------------------------------------------------------

-- "user" es palabra reservada en PostgreSQL -> @Table(name = "app_user")
CREATE TABLE app_user (
                          id            UUID PRIMARY KEY DEFAULT uuid_v7(),
                          email         VARCHAR(254) NOT NULL,
                          password_hash VARCHAR(255) NOT NULL,                      -- BCrypt
                          full_name     VARCHAR(150) NOT NULL,
                          phone         VARCHAR(30),
                          role          VARCHAR(20)  NOT NULL CHECK (role IN
                                                                     ('CITIZEN', 'OPERATOR', 'TECHNICIAN', 'ADMIN', 'ANALYST')),
                          department    VARCHAR(20)  CHECK (department IN          -- solo personal municipal
                                                            ('MOBILITY', 'CLEANING', 'PARKS', 'INFRASTRUCTURE', 'LIGHTING', 'WATER')),
                          active        BOOLEAN      NOT NULL DEFAULT TRUE,
                          created_at    TIMESTAMPTZ  NOT NULL DEFAULT now(),
                          CONSTRAINT ck_app_user_department CHECK (role <> 'CITIZEN' OR department IS NULL)
);
CREATE UNIQUE INDEX ux_app_user_email ON app_user (lower(email));


-- ---------------------------------------------------------------------
-- 2. Incident (entidad central)
-- ---------------------------------------------------------------------

CREATE TABLE incident (
                          id                     UUID PRIMARY KEY DEFAULT uuid_v7(),
                          title                  VARCHAR(200) NOT NULL,
                          description            TEXT         NOT NULL,
                          category               VARCHAR(30)  CHECK (category IN (             -- opcional (RF03)
                                                                                  'STREET_LIGHTING', 'TRAFFIC_LIGHTS', 'ROAD_SIGNS', 'ROADS_AND_SIDEWALKS',
                                                                                  'STREET_FURNITURE', 'WASTE_CONTAINERS', 'STREET_CLEANING', 'TREES',
                                                                                  'GREEN_AREAS', 'WATER_AND_FOUNTAINS', 'PUBLIC_TRANSPORT', 'OTHER')),
                          status                 VARCHAR(20)  NOT NULL DEFAULT 'REPORTED' CHECK (status IN (
                                                                                                            'REPORTED', 'VALIDATED', 'REJECTED', 'ASSIGNED',
                                                                                                            'IN_PROGRESS', 'RESOLVED', 'REOPENED', 'CLOSED')),
                          priority               VARCHAR(10)  CHECK (priority IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
                          priority_justification TEXT,                                          -- RF10

    -- Localización (RF04, RF21)
                          latitude               DOUBLE PRECISION NOT NULL CHECK (latitude BETWEEN -90 AND 90),
                          longitude              DOUBLE PRECISION NOT NULL CHECK (longitude BETWEEN -180 AND 180),
                          location_accuracy_m    DOUBLE PRECISION CHECK (location_accuracy_m >= 0),
                          address                VARCHAR(300),                                  -- dirección normalizada
                          neighborhood           VARCHAR(150),                                  -- barrio
                          district               VARCHAR(30)  CHECK (district IN (
                                                                                  'CENTRO', 'ESTE', 'CIUDAD_JARDIN', 'BAILEN_MIRAFLORES', 'PALMA_PALMILLA',
                                                                                  'CRUZ_DE_HUMILLADERO', 'CARRETERA_DE_CADIZ', 'CHURRIANA', 'CAMPANILLAS',
                                                                                  'PUERTO_DE_LA_TORRE', 'TEATINOS_UNIVERSIDAD')),

                          reporter_id            UUID         NOT NULL REFERENCES app_user (id),

    -- Marcas temporales
                          reported_at            TIMESTAMPTZ  NOT NULL DEFAULT now(),
                          updated_at             TIMESTAMPTZ  NOT NULL DEFAULT now(),
                          resolved_at            TIMESTAMPTZ,
                          closed_at              TIMESTAMPTZ
);
CREATE INDEX ix_incident_status   ON incident (status, reported_at DESC);
CREATE INDEX ix_incident_reporter ON incident (reporter_id);
CREATE INDEX ix_incident_district ON incident (district);
CREATE INDEX ix_incident_category ON incident (category);


-- ---------------------------------------------------------------------
-- 3. StatusChange: transición auditable con actor, instante, motivo y datos (RF12)
-- ---------------------------------------------------------------------

CREATE TABLE status_change (
                               id            INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
                               incident_id   UUID        NOT NULL REFERENCES incident (id) ON DELETE CASCADE,
                               from_status   VARCHAR(20) CHECK (from_status IN (                     -- NULL en el alta
                                                                                'REPORTED', 'VALIDATED', 'REJECTED', 'ASSIGNED',
                                                                                'IN_PROGRESS', 'RESOLVED', 'REOPENED', 'CLOSED')),
                               to_status     VARCHAR(20) NOT NULL CHECK (to_status IN (
                                                                                       'REPORTED', 'VALIDATED', 'REJECTED', 'ASSIGNED',
                                                                                       'IN_PROGRESS', 'RESOLVED', 'REOPENED', 'CLOSED')),
                               changed_by_id UUID        REFERENCES app_user (id),                   -- NULL = sistema
                               changed_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
                               reason        TEXT,
                               data          JSONB,                                                  -- datos asociados
                               CONSTRAINT ck_status_change_reason CHECK (                            -- motivo obligatorio (RF09)
                                   to_status NOT IN ('REJECTED', 'REOPENED') OR (reason IS NOT NULL AND btrim(reason) <> ''))
);
CREATE INDEX ix_status_change_incident ON status_change (incident_id, changed_at);


-- ---------------------------------------------------------------------
-- 4. Attachment: el fichero vive fuera de la BD (p. ej. Supabase Storage) (RF05)
-- ---------------------------------------------------------------------

CREATE TABLE attachment (
                            id             UUID PRIMARY KEY DEFAULT uuid_v7(),
                            incident_id    UUID         NOT NULL REFERENCES incident (id) ON DELETE CASCADE,
                            uploaded_by_id UUID         NOT NULL REFERENCES app_user (id),
                            file_name      VARCHAR(255) NOT NULL,
                            content_type   VARCHAR(100) NOT NULL,                                 -- MIME
                            size_bytes     BIGINT       NOT NULL CHECK (size_bytes > 0),
                            storage_path   VARCHAR(500) NOT NULL UNIQUE,                          -- ruta en el almacenamiento
                            uploaded_at    TIMESTAMPTZ  NOT NULL DEFAULT now()
);
CREATE INDEX ix_attachment_incident ON attachment (incident_id);


-- ---------------------------------------------------------------------
-- 5. Assignment: relación temporal incidencia - departamento - técnico (RF11)
-- ---------------------------------------------------------------------

CREATE TABLE assignment (
                            id             INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
                            incident_id    UUID        NOT NULL REFERENCES incident (id) ON DELETE CASCADE,
                            department     VARCHAR(20) NOT NULL CHECK (department IN
                                                                       ('MOBILITY', 'CLEANING', 'PARKS', 'INFRASTRUCTURE', 'LIGHTING', 'WATER')),
                            technician_id  UUID        REFERENCES app_user (id),
                            assigned_by_id UUID        REFERENCES app_user (id),                  -- NULL = automática
                            status         VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN
                                                                                         ('PENDING', 'ACCEPTED', 'DECLINED', 'COMPLETED', 'CANCELLED')),
                            notes          TEXT,
                            assigned_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
                            ended_at       TIMESTAMPTZ,
                            CONSTRAINT ck_assignment_open CHECK ((status IN ('PENDING', 'ACCEPTED')) = (ended_at IS NULL))
);
-- Como mucho una asignación abierta por incidencia
CREATE UNIQUE INDEX ux_assignment_open ON assignment (incident_id) WHERE ended_at IS NULL;
CREATE INDEX ix_assignment_technician ON assignment (technician_id) WHERE ended_at IS NULL;


-- ---------------------------------------------------------------------
-- 6. UrbanAsset y su relación con Incident (RF22)
-- ---------------------------------------------------------------------

CREATE TABLE urban_asset (
                             id          UUID PRIMARY KEY DEFAULT uuid_v7(),
                             asset_type  VARCHAR(20)  NOT NULL CHECK (asset_type IN (
                                                                                     'TRAFFIC_LIGHT', 'CONTAINER', 'FOUNTAIN', 'BUS_STOP', 'PARKING',
                                                                                     'GREEN_AREA', 'STREET_LIGHT', 'TREE', 'OTHER')),
                             source      VARCHAR(20)  NOT NULL CHECK (source IN
                                                                      ('MALAGA_OPEN_DATA', 'AEMET', 'OPENSTREETMAP', 'MANUAL', 'OTHER')),
                             external_id VARCHAR(100),                                             -- id en la fuente (p. ej. 3948)
                             name        VARCHAR(200),
                             latitude    DOUBLE PRECISION NOT NULL CHECK (latitude BETWEEN -90 AND 90),
                             longitude   DOUBLE PRECISION NOT NULL CHECK (longitude BETWEEN -180 AND 180),
                             geometry    JSONB,                                                    -- GeoJSON si no es un punto
                             metadata    JSONB,
                             created_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),
                             CONSTRAINT uq_urban_asset_source UNIQUE (source, external_id)
);
CREATE INDEX ix_urban_asset_location ON urban_asset (latitude, longitude);

-- Asociación explícita, inferida por proximidad o confirmada por un operador.
-- Puede haber varios candidatos por incidencia, pero solo uno CONFIRMED.
CREATE TABLE incident_asset (
                                id          INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
                                incident_id UUID        NOT NULL REFERENCES incident (id) ON DELETE CASCADE,
                                asset_id    UUID        NOT NULL REFERENCES urban_asset (id),
                                link_type   VARCHAR(20) NOT NULL CHECK (link_type IN ('EXPLICIT', 'INFERRED', 'CONFIRMED')),
                                distance_m  DOUBLE PRECISION CHECK (distance_m >= 0),
                                confidence  DOUBLE PRECISION CHECK (confidence BETWEEN 0 AND 1),
                                created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
                                CONSTRAINT uq_incident_asset UNIQUE (incident_id, asset_id)
);
CREATE UNIQUE INDEX ux_incident_asset_confirmed ON incident_asset (incident_id) WHERE link_type = 'CONFIRMED';
CREATE INDEX ix_incident_asset_asset ON incident_asset (asset_id);


-- ---------------------------------------------------------------------
-- 7. ExternalObservation y UrbanContext (RF23-RF26)
-- ---------------------------------------------------------------------

-- Dato normalizado con fuente, instante de observación, instante de ingesta, unidad y calidad
CREATE TABLE external_observation (
                                      id            INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
                                      source        VARCHAR(20)  NOT NULL CHECK (source IN
                                                                                 ('MALAGA_OPEN_DATA', 'AEMET', 'OPENSTREETMAP', 'MANUAL', 'OTHER')),
                                      context_type  VARCHAR(20)  NOT NULL CHECK (context_type IN
                                                                                 ('WEATHER', 'TRAFFIC', 'MOBILITY', 'EVENT', 'ENVIRONMENT', 'DEMOGRAPHY', 'SPATIAL')),
                                      variable      VARCHAR(100) NOT NULL,                                  -- 'temperature', 'traffic_intensity'...
                                      value_numeric DOUBLE PRECISION,
                                      value_text    TEXT,
                                      unit          VARCHAR(30),                                            -- '°C', 'mm', 'veh/h'...
                                      quality       VARCHAR(20)  NOT NULL CHECK (quality IN ('VALID', 'ESTIMATED', 'SUSPECT', 'INVALID')),
                                      observed_at   TIMESTAMPTZ  NOT NULL,
                                      ingested_at   TIMESTAMPTZ  NOT NULL DEFAULT now(),
                                      valid_until   TIMESTAMPTZ,                                            -- caducidad
                                      latitude      DOUBLE PRECISION,
                                      longitude     DOUBLE PRECISION,
                                      district      VARCHAR(30)  CHECK (district IN (
                                                                                     'CENTRO', 'ESTE', 'CIUDAD_JARDIN', 'BAILEN_MIRAFLORES', 'PALMA_PALMILLA',
                                                                                     'CRUZ_DE_HUMILLADERO', 'CARRETERA_DE_CADIZ', 'CHURRIANA', 'CAMPANILLAS',
                                                                                     'PUERTO_DE_LA_TORRE', 'TEATINOS_UNIVERSIDAD')),
                                      CONSTRAINT ck_observation_value CHECK (value_numeric IS NOT NULL OR value_text IS NOT NULL),
                                      CONSTRAINT ck_observation_validity CHECK (valid_until IS NULL OR valid_until >= observed_at)
);
CREATE INDEX ix_observation_type_time ON external_observation (context_type, observed_at DESC);
CREATE INDEX ix_observation_district_time ON external_observation (district, observed_at DESC);

-- Contexto urbano de una incidencia o de una zona en un instante (reproducible)
CREATE TABLE urban_context (
                               id             UUID PRIMARY KEY DEFAULT uuid_v7(),
                               incident_id    UUID        REFERENCES incident (id) ON DELETE CASCADE,
                               district       VARCHAR(30) CHECK (district IN (                       -- contexto de zona (RF17)
                                                                              'CENTRO', 'ESTE', 'CIUDAD_JARDIN', 'BAILEN_MIRAFLORES', 'PALMA_PALMILLA',
                                                                              'CRUZ_DE_HUMILLADERO', 'CARRETERA_DE_CADIZ', 'CHURRIANA', 'CAMPANILLAS',
                                                                              'PUERTO_DE_LA_TORRE', 'TEATINOS_UNIVERSIDAD')),
                               reference_time TIMESTAMPTZ NOT NULL,                                  -- p. ej. el instante del reporte
                               status         VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN
                                                                                            ('PENDING', 'COMPLETE', 'PARTIAL', 'FAILED')),     -- PARTIAL = alguna fuente caída (RF26)
                               summary        TEXT,                                                  -- lo que ve el operador (RF24)
                               created_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
                               CONSTRAINT ck_urban_context_scope CHECK (incident_id IS NOT NULL OR district IS NOT NULL)
);
CREATE INDEX ix_urban_context_incident ON urban_context (incident_id);

-- Relación N:M: qué observaciones forman cada contexto (@ManyToMany en UrbanContext)
CREATE TABLE urban_context_observation (
                                           context_id     UUID    NOT NULL REFERENCES urban_context (id) ON DELETE CASCADE,
                                           observation_id INTEGER NOT NULL REFERENCES external_observation (id) ON DELETE CASCADE,
                                           PRIMARY KEY (context_id, observation_id)
);
CREATE INDEX ix_context_observation_observation ON urban_context_observation (observation_id);


-- ---------------------------------------------------------------------
-- 8. Notification: comunicación derivada de un evento y su estado de entrega (RF14)
-- ---------------------------------------------------------------------

CREATE TABLE notification (
                              id           INTEGER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
                              recipient_id UUID        NOT NULL REFERENCES app_user (id) ON DELETE CASCADE,
                              incident_id  UUID        REFERENCES incident (id) ON DELETE CASCADE,
                              event        VARCHAR(30) NOT NULL CHECK (event IN
                                                                       ('INCIDENT_CREATED', 'STATUS_CHANGED', 'INCIDENT_ASSIGNED', 'INFO_REQUESTED')),
                              channel      VARCHAR(10) NOT NULL CHECK (channel IN ('EMAIL', 'SMS', 'PUSH', 'IN_APP')),
                              message      TEXT        NOT NULL,
                              status       VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN
                                                                                         ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'READ')),
                              created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
                              sent_at      TIMESTAMPTZ,
                              read_at      TIMESTAMPTZ
);
CREATE INDEX ix_notification_recipient ON notification (recipient_id, created_at DESC);
CREATE INDEX ix_notification_pending ON notification (created_at) WHERE status = 'PENDING';


-- ---------------------------------------------------------------------
-- 9. KnowledgeDocument: procedimiento o normativa versionada para RAG
-- ---------------------------------------------------------------------

CREATE TABLE knowledge_document (
                                    id             UUID PRIMARY KEY DEFAULT uuid_v7(),
                                    code           VARCHAR(50)  NOT NULL,                                 -- igual en todas las versiones
                                    version_number INTEGER      NOT NULL DEFAULT 1 CHECK (version_number > 0),
                                    title          VARCHAR(300) NOT NULL,
                                    doc_type       VARCHAR(20)  NOT NULL CHECK (doc_type IN ('PROCEDURE', 'REGULATION', 'ORDINANCE', 'GUIDE')),
                                    storage_path   VARCHAR(500),                                          -- fichero en el almacenamiento
                                    source_url     VARCHAR(500),
                                    effective_from DATE,
                                    indexed_at     TIMESTAMPTZ,                                           -- NULL = aún no indexado para RAG
                                    created_at     TIMESTAMPTZ  NOT NULL DEFAULT now(),
                                    CONSTRAINT uq_knowledge_document_version UNIQUE (code, version_number),
                                    CONSTRAINT ck_knowledge_document_file CHECK (storage_path IS NOT NULL OR source_url IS NOT NULL)
);


-- ---------------------------------------------------------------------
-- 10. Row Level Security (Supabase)
-- Sin políticas = la API REST pública de Supabase no ve estas tablas.
-- Spring Boot conecta como postgres (dueño de las tablas) y no le afecta.
-- ---------------------------------------------------------------------

ALTER TABLE app_user                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE incident                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE status_change             ENABLE ROW LEVEL SECURITY;
ALTER TABLE attachment                ENABLE ROW LEVEL SECURITY;
ALTER TABLE assignment                ENABLE ROW LEVEL SECURITY;
ALTER TABLE urban_asset               ENABLE ROW LEVEL SECURITY;
ALTER TABLE incident_asset            ENABLE ROW LEVEL SECURITY;
ALTER TABLE external_observation      ENABLE ROW LEVEL SECURITY;
ALTER TABLE urban_context             ENABLE ROW LEVEL SECURITY;
ALTER TABLE urban_context_observation ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification              ENABLE ROW LEVEL SECURITY;
ALTER TABLE knowledge_document        ENABLE ROW LEVEL SECURITY;