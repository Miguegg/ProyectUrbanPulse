-- =====================================================================
-- UrbanPulse · Datos de prueba
--
-- Local:   npx supabase db reset   (aplica la migración y después este seed)
-- Remota:  pegar en Supabase > SQL Editor > Run
--
-- Vacía las tablas antes de insertar, así que se puede ejecutar varias veces.
--
-- IDs: las tablas con PK UUID (app_user, incident, attachment, urban_asset, urban_context,
-- knowledge_document) usan UUID fijos con el formato 00000000-0000-7TTT-8000-NNNNNNNNNNNN, donde
-- TTT identifica la tabla (001 usuario, 002 incidencia, 003 adjunto, 004 activo, 005 contexto,
-- 006 documento) y N es el numero de fila que aparece en los comentarios (-- 1, -- 2...).
-- Las demás tablas siguen con IDENTITY entero.
-- Todos los usuarios tienen la contraseña de prueba "urbanpulse" (hash BCrypt con
-- pgcrypto, que viene activado en Supabase; compatible con BCryptPasswordEncoder).
-- =====================================================================

TRUNCATE app_user, incident, status_change, attachment, assignment, urban_asset, incident_asset,
         external_observation, urban_context, urban_context_observation, notification, knowledge_document
RESTART IDENTITY CASCADE;


-- ---------------------------------------------------------------------
-- Usuarios (10; UUID ...-7001-8000-0000000000NN, NN = 01..10)
-- ---------------------------------------------------------------------

INSERT INTO app_user (id, email, password_hash, full_name, phone, role, department, active) VALUES
                                                                                                ('00000000-0000-7001-8000-000000000001', 'admin@urbanpulse.test',        extensions.crypt('urbanpulse', extensions.gen_salt('bf', 10)), 'Laura Martín',     '600000001', 'ADMIN',      NULL,             TRUE),  -- 1
                                                                                                ('00000000-0000-7001-8000-000000000002', 'carlos.ruiz@urbanpulse.test',  extensions.crypt('urbanpulse', extensions.gen_salt('bf', 10)), 'Carlos Ruiz',      '600000002', 'OPERATOR',   'MOBILITY',       TRUE),  -- 2
                                                                                                ('00000000-0000-7001-8000-000000000003', 'marta.gomez@urbanpulse.test',  extensions.crypt('urbanpulse', extensions.gen_salt('bf', 10)), 'Marta Gómez',      '600000003', 'OPERATOR',   'CLEANING',       TRUE),  -- 3
                                                                                                ('00000000-0000-7001-8000-000000000004', 'javier.lopez@urbanpulse.test', extensions.crypt('urbanpulse', extensions.gen_salt('bf', 10)), 'Javier López',     '600000004', 'TECHNICIAN', 'MOBILITY',       TRUE),  -- 4
                                                                                                ('00000000-0000-7001-8000-000000000005', 'ana.torres@urbanpulse.test',   extensions.crypt('urbanpulse', extensions.gen_salt('bf', 10)), 'Ana Torres',       '600000005', 'TECHNICIAN', 'PARKS',          TRUE),  -- 5
                                                                                                ('00000000-0000-7001-8000-000000000006', 'raul.moreno@urbanpulse.test',  extensions.crypt('urbanpulse', extensions.gen_salt('bf', 10)), 'Raúl Moreno',      '600000006', 'TECHNICIAN', 'INFRASTRUCTURE', TRUE),  -- 6
                                                                                                ('00000000-0000-7001-8000-000000000007', 'pablo.serrano@urbanpulse.test',extensions.crypt('urbanpulse', extensions.gen_salt('bf', 10)), 'Pablo Serrano',    '600000007', 'ANALYST',    NULL,             TRUE),  -- 7
                                                                                                ('00000000-0000-7001-8000-000000000008', 'lucia.fernandez@correo.test',  extensions.crypt('urbanpulse', extensions.gen_salt('bf', 10)), 'Lucía Fernández',  '611111111', 'CITIZEN',    NULL,             TRUE),  -- 8
                                                                                                ('00000000-0000-7001-8000-000000000009', 'sergio.navarro@correo.test',   extensions.crypt('urbanpulse', extensions.gen_salt('bf', 10)), 'Sergio Navarro',   NULL,        'CITIZEN',    NULL,             TRUE),  -- 9
                                                                                                ('00000000-0000-7001-8000-000000000010', 'elena.castillo@correo.test',   extensions.crypt('urbanpulse', extensions.gen_salt('bf', 10)), 'Elena Castillo',   NULL,        'CITIZEN',    NULL,             FALSE); -- 10 (desactivada)


-- ---------------------------------------------------------------------
-- Incidencias (9; UUID ...-7002-...): una en cada estado del ciclo de vida
-- ---------------------------------------------------------------------

INSERT INTO incident (id, title, description, category, status, priority, priority_justification,
                      latitude, longitude, location_accuracy_m, address, neighborhood, district,
                      reporter_id, reported_at, updated_at, resolved_at, closed_at) VALUES
                                                                                        -- 1 IN_PROGRESS
                                                                                        ('00000000-0000-7002-8000-000000000001', 'Semáforo apagado en la Alameda',
                                                                                         'El semáforo del cruce de la Alameda Principal con calle Larios está apagado desde esta mañana.',
                                                                                         'TRAFFIC_LIGHTS', 'IN_PROGRESS', 'HIGH', 'Cruce con mucho tráfico peatonal y rodado en hora punta',
                                                                                         36.7180, -4.4219, 8, 'Alameda Principal, Málaga', 'Centro Histórico', 'CENTRO',
                                                                                         '00000000-0000-7001-8000-000000000008', now() - interval '2 days 5 hours', now() - interval '1 day 20 hours', NULL, NULL),
                                                                                        -- 2 ASSIGNED
                                                                                        ('00000000-0000-7002-8000-000000000002', 'Contenedor desbordado en Huelin',
                                                                                         'El contenedor de orgánico lleva dos días sin recogerse y hay bolsas por el suelo.',
                                                                                         'WASTE_CONTAINERS', 'ASSIGNED', 'MEDIUM', 'Suciedad en zona peatonal muy transitada',
                                                                                         36.7005, -4.4390, 12, 'Paseo Marítimo Antonio Machado, Málaga', 'Huelin', 'CARRETERA_DE_CADIZ',
                                                                                         '00000000-0000-7001-8000-000000000009', now() - interval '1 day 9 hours', now() - interval '1 day 6 hours', NULL, NULL),
                                                                                        -- 3 RESOLVED
                                                                                        ('00000000-0000-7002-8000-000000000003', 'Árbol caído en el Paseo Marítimo',
                                                                                         'Una palmera se ha caído con el viento y bloquea parte del paseo y un carril.',
                                                                                         'TREES', 'RESOLVED', 'CRITICAL', 'Obstaculiza el paseo y la calzada; riesgo para peatones y vehículos',
                                                                                         36.7200, -4.4020, 6, 'Paseo Marítimo Pablo Ruiz Picasso, Málaga', 'La Caleta', 'ESTE',
                                                                                         '00000000-0000-7001-8000-000000000008', now() - interval '5 days', now() - interval '4 days 18 hours', now() - interval '4 days 18 hours', NULL),
                                                                                        -- 4 REPORTED (recién llegada)
                                                                                        ('00000000-0000-7002-8000-000000000004', 'Farola fundida en Teatinos',
                                                                                         'La farola frente al número 12 no se enciende por la noche.',
                                                                                         'STREET_LIGHTING', 'REPORTED', NULL, NULL,
                                                                                         36.7157, -4.4730, 15, 'Bulevar Louis Pasteur, Málaga', 'Teatinos', 'TEATINOS_UNIVERSIDAD',
                                                                                         '00000000-0000-7001-8000-000000000009', now() - interval '3 hours', now() - interval '3 hours', NULL, NULL),
                                                                                        -- 5 VALIDATED
                                                                                        ('00000000-0000-7002-8000-000000000005', 'Bache grande en la calzada',
                                                                                         'Hay un bache profundo en el carril derecho que obliga a los coches a esquivarlo.',
                                                                                         'ROADS_AND_SIDEWALKS', 'VALIDATED', 'MEDIUM', 'Bache de unos 40 cm en carril de circulación',
                                                                                         36.7180, -4.4390, 10, 'Avenida de Andalucía, Málaga', 'Carranque', 'CRUZ_DE_HUMILLADERO',
                                                                                         '00000000-0000-7001-8000-000000000008', now() - interval '1 day 2 hours', now() - interval '1 day', NULL, NULL),
                                                                                        -- 6 REPORTED (con dos activos candidatos)
                                                                                        ('00000000-0000-7002-8000-000000000006', 'Pintadas en la parada del autobús',
                                                                                         'La marquesina de la parada tiene pintadas en el cristal y el panel de horarios.',
                                                                                         'PUBLIC_TRANSPORT', 'REPORTED', NULL, NULL,
                                                                                         36.7175, -4.4231, 20, 'Alameda Principal, Málaga', 'Centro Histórico', 'CENTRO',
                                                                                         '00000000-0000-7001-8000-000000000009', now() - interval '6 hours', now() - interval '6 hours', NULL, NULL),
                                                                                        -- 7 REJECTED (sin dirección: la geocodificación no respondió)
                                                                                        ('00000000-0000-7002-8000-000000000007', 'Fuente sin agua en Ciudad Jardín',
                                                                                         'La fuente de la plaza lleva todo el día sin agua.',
                                                                                         'WATER_AND_FOUNTAINS', 'REJECTED', NULL, NULL,
                                                                                         36.7398, -4.4268, 30, NULL, 'Ciudad Jardín', 'CIUDAD_JARDIN',
                                                                                         '00000000-0000-7001-8000-000000000008', now() - interval '3 days', now() - interval '2 days 22 hours', NULL, NULL),
                                                                                        -- 8 CLOSED
                                                                                        ('00000000-0000-7002-8000-000000000008', 'Banco roto en la zona verde',
                                                                                         'Faltan dos tablones del banco y sobresalen tornillos.',
                                                                                         'STREET_FURNITURE', 'CLOSED', 'LOW', 'Sin riesgo inmediato; zona poco transitada',
                                                                                         36.7335, -4.4385, 9, 'Avenida Doctor Gálvez Moll, Málaga', 'La Palmilla', 'PALMA_PALMILLA',
                                                                                         '00000000-0000-7001-8000-000000000009', now() - interval '12 days', now() - interval '1 day', now() - interval '8 days', now() - interval '1 day'),
                                                                                        -- 9 REOPENED
                                                                                        ('00000000-0000-7002-8000-000000000009', 'Señal de stop tapada por ramas',
                                                                                         'Las ramas de un árbol tapan la señal de stop y no se ve al llegar al cruce.',
                                                                                         'ROAD_SIGNS', 'REOPENED', 'MEDIUM', 'Visibilidad reducida en un cruce',
                                                                                         36.6660, -4.4990, 25, NULL, 'Churriana', 'CHURRIANA',
                                                                                         '00000000-0000-7001-8000-000000000008', now() - interval '7 days', now() - interval '2 hours', NULL, NULL);


-- ---------------------------------------------------------------------
-- Historial de estados (coherente con el ciclo de vida)
-- ---------------------------------------------------------------------

INSERT INTO status_change (incident_id, from_status, to_status, changed_by_id, changed_at, reason, data) VALUES
                                                                                                             ('00000000-0000-7002-8000-000000000001', NULL,          'REPORTED',    '00000000-0000-7001-8000-000000000008', now() - interval '2 days 5 hours',            NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000001', 'REPORTED',    'VALIDATED',   '00000000-0000-7001-8000-000000000002', now() - interval '2 days 4 hours',            NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000001', 'VALIDATED',   'ASSIGNED',    '00000000-0000-7001-8000-000000000002', now() - interval '2 days 3 hours',            NULL, '{"department": "MOBILITY", "technicianId": "00000000-0000-7001-8000-000000000004"}'),
                                                                                                             ('00000000-0000-7002-8000-000000000001', 'ASSIGNED',    'IN_PROGRESS', '00000000-0000-7001-8000-000000000004', now() - interval '1 day 20 hours',            NULL, NULL),

                                                                                                             ('00000000-0000-7002-8000-000000000002', NULL,          'REPORTED',    '00000000-0000-7001-8000-000000000009', now() - interval '1 day 9 hours',             NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000002', 'REPORTED',    'VALIDATED',   '00000000-0000-7001-8000-000000000003', now() - interval '1 day 7 hours',             NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000002', 'VALIDATED',   'ASSIGNED',    '00000000-0000-7001-8000-000000000003', now() - interval '1 day 6 hours',             NULL, '{"department": "CLEANING"}'),

                                                                                                             ('00000000-0000-7002-8000-000000000003', NULL,          'REPORTED',    '00000000-0000-7001-8000-000000000008', now() - interval '5 days',                    NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000003', 'REPORTED',    'VALIDATED',   '00000000-0000-7001-8000-000000000002', now() - interval '4 days 23 hours 40 minutes', NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000003', 'VALIDATED',   'ASSIGNED',    '00000000-0000-7001-8000-000000000002', now() - interval '4 days 23 hours 30 minutes', NULL, '{"department": "PARKS", "technicianId": "00000000-0000-7001-8000-000000000005"}'),
                                                                                                             ('00000000-0000-7002-8000-000000000003', 'ASSIGNED',    'IN_PROGRESS', '00000000-0000-7001-8000-000000000005', now() - interval '4 days 22 hours',           NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000003', 'IN_PROGRESS', 'RESOLVED',    '00000000-0000-7001-8000-000000000005', now() - interval '4 days 18 hours',           'Palmera retirada y zona limpia', NULL),

                                                                                                             ('00000000-0000-7002-8000-000000000004', NULL,          'REPORTED',    '00000000-0000-7001-8000-000000000009', now() - interval '3 hours',                   NULL, NULL),

                                                                                                             ('00000000-0000-7002-8000-000000000005', NULL,          'REPORTED',    '00000000-0000-7001-8000-000000000008', now() - interval '1 day 2 hours',             NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000005', 'REPORTED',    'VALIDATED',   '00000000-0000-7001-8000-000000000002', now() - interval '1 day',                     NULL, NULL),

                                                                                                             ('00000000-0000-7002-8000-000000000006', NULL,          'REPORTED',    '00000000-0000-7001-8000-000000000009', now() - interval '6 hours',                   NULL, NULL),

                                                                                                             ('00000000-0000-7002-8000-000000000007', NULL,          'REPORTED',    '00000000-0000-7001-8000-000000000008', now() - interval '3 days',                    NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000007', 'REPORTED',    'REJECTED',    '00000000-0000-7001-8000-000000000003', now() - interval '2 days 22 hours',           'Corte de agua programado en la zona; no es una avería', NULL),

                                                                                                             ('00000000-0000-7002-8000-000000000008', NULL,          'REPORTED',    '00000000-0000-7001-8000-000000000009', now() - interval '12 days',                   NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000008', 'REPORTED',    'VALIDATED',   '00000000-0000-7001-8000-000000000002', now() - interval '11 days 23 hours',          NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000008', 'VALIDATED',   'ASSIGNED',    '00000000-0000-7001-8000-000000000002', now() - interval '11 days 22 hours',          NULL, '{"department": "PARKS"}'),
                                                                                                             ('00000000-0000-7002-8000-000000000008', 'ASSIGNED',    'IN_PROGRESS', '00000000-0000-7001-8000-000000000006', now() - interval '9 days',                    NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000008', 'IN_PROGRESS', 'RESOLVED',    '00000000-0000-7001-8000-000000000006', now() - interval '8 days',                    'Tablones sustituidos', NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000008', 'RESOLVED',    'CLOSED',      '00000000-0000-7001-8000-000000000002', now() - interval '1 day',                     'Cierre tras verificación', NULL),

                                                                                                             ('00000000-0000-7002-8000-000000000009', NULL,          'REPORTED',    '00000000-0000-7001-8000-000000000008', now() - interval '7 days',                    NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000009', 'REPORTED',    'VALIDATED',   '00000000-0000-7001-8000-000000000002', now() - interval '6 days 23 hours',           NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000009', 'VALIDATED',   'ASSIGNED',    '00000000-0000-7001-8000-000000000002', now() - interval '6 days 22 hours',           NULL, '{"department": "MOBILITY", "technicianId": "00000000-0000-7001-8000-000000000004"}'),
                                                                                                             ('00000000-0000-7002-8000-000000000009', 'ASSIGNED',    'IN_PROGRESS', '00000000-0000-7001-8000-000000000004', now() - interval '5 days',                    NULL, NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000009', 'IN_PROGRESS', 'RESOLVED',    '00000000-0000-7001-8000-000000000004', now() - interval '4 days',                    'Ramas podadas', NULL),
                                                                                                             ('00000000-0000-7002-8000-000000000009', 'RESOLVED',    'REOPENED',    '00000000-0000-7001-8000-000000000002', now() - interval '2 hours',                   'La vecina indica que las ramas vuelven a tapar la señal', NULL);


-- ---------------------------------------------------------------------
-- Asignaciones (una abierta como mucho por incidencia)
-- ---------------------------------------------------------------------

INSERT INTO assignment (incident_id, department, technician_id, assigned_by_id, status, notes, assigned_at, ended_at) VALUES
                                                                                                                          ('00000000-0000-7002-8000-000000000001', 'MOBILITY',       '00000000-0000-7001-8000-000000000004',    '00000000-0000-7001-8000-000000000002', 'ACCEPTED',  'Revisar el regulador del cruce',            now() - interval '2 days 3 hours',             NULL),
                                                                                                                          ('00000000-0000-7002-8000-000000000002', 'CLEANING',       NULL, '00000000-0000-7001-8000-000000000003', 'PENDING',   NULL,                                        now() - interval '1 day 6 hours',              NULL),
                                                                                                                          ('00000000-0000-7002-8000-000000000003', 'PARKS',          '00000000-0000-7001-8000-000000000005',    '00000000-0000-7001-8000-000000000002', 'COMPLETED', 'Urgente: bloquea un carril',                now() - interval '4 days 23 hours 30 minutes', now() - interval '4 days 18 hours'),
                                                                                                                          ('00000000-0000-7002-8000-000000000008', 'PARKS',          '00000000-0000-7001-8000-000000000005',    '00000000-0000-7001-8000-000000000002', 'DECLINED',  'Es mobiliario urbano, no arbolado',         now() - interval '11 days 22 hours',           now() - interval '11 days 21 hours'),
                                                                                                                          ('00000000-0000-7002-8000-000000000008', 'INFRASTRUCTURE', '00000000-0000-7001-8000-000000000006',    '00000000-0000-7001-8000-000000000002', 'COMPLETED', NULL,                                        now() - interval '11 days 21 hours',           now() - interval '8 days'),
                                                                                                                          ('00000000-0000-7002-8000-000000000009', 'MOBILITY',       '00000000-0000-7001-8000-000000000004',    '00000000-0000-7001-8000-000000000002', 'COMPLETED', NULL,                                        now() - interval '6 days 22 hours',            now() - interval '4 days');


-- ---------------------------------------------------------------------
-- Adjuntos (los ficheros no existen de verdad; solo los metadatos)
-- ---------------------------------------------------------------------

INSERT INTO attachment (id, incident_id, uploaded_by_id, file_name, content_type, size_bytes, storage_path, uploaded_at) VALUES
                                                                                                                             ('00000000-0000-7003-8000-000000000001', '00000000-0000-7002-8000-000000000001', '00000000-0000-7001-8000-000000000008', 'semaforo_apagado.jpg', 'image/jpeg',       245760, 'incidents/00000000-0000-7002-8000-000000000001/00000000-0000-7003-8000-000000000001.jpg', now() - interval '2 days 5 hours'),
                                                                                                                             ('00000000-0000-7003-8000-000000000002', '00000000-0000-7002-8000-000000000003', '00000000-0000-7001-8000-000000000008', 'arbol_caido.jpg',      'image/jpeg',       512000, 'incidents/00000000-0000-7002-8000-000000000003/00000000-0000-7003-8000-000000000002.jpg',      now() - interval '5 days'),
                                                                                                                             ('00000000-0000-7003-8000-000000000003', '00000000-0000-7002-8000-000000000003', '00000000-0000-7001-8000-000000000005', 'arbol_retirado.jpg',   'image/jpeg',       480000, 'incidents/00000000-0000-7002-8000-000000000003/00000000-0000-7003-8000-000000000003.jpg',   now() - interval '4 days 18 hours'),
                                                                                                                             ('00000000-0000-7003-8000-000000000004', '00000000-0000-7002-8000-000000000006', '00000000-0000-7001-8000-000000000009', 'pintadas_parada.png',  'image/png',       1048576, 'incidents/00000000-0000-7002-8000-000000000006/00000000-0000-7003-8000-000000000004.png',  now() - interval '6 hours'),
                                                                                                                             ('00000000-0000-7003-8000-000000000005', '00000000-0000-7002-8000-000000000008', '00000000-0000-7001-8000-000000000009', 'banco_roto.mp4',       'video/mp4',       5242880, 'incidents/00000000-0000-7002-8000-000000000008/00000000-0000-7003-8000-000000000005.mp4',       now() - interval '12 days'),
                                                                                                                             ('00000000-0000-7003-8000-000000000006', '00000000-0000-7002-8000-000000000009', '00000000-0000-7001-8000-000000000004', 'informe_poda.pdf',     'application/pdf',   81920, 'incidents/00000000-0000-7002-8000-000000000009/00000000-0000-7003-8000-000000000006.pdf',     now() - interval '4 days');


-- ---------------------------------------------------------------------
-- Activos urbanos (10; UUID ...-7004-...) y su relación con las incidencias
-- ---------------------------------------------------------------------

INSERT INTO urban_asset (id, asset_type, source, external_id, name, latitude, longitude, geometry, metadata) VALUES
                                                                                                                 ('00000000-0000-7004-8000-000000000001', 'TRAFFIC_LIGHT', 'MALAGA_OPEN_DATA', 'SEM-0112',  'Semáforo Alameda Principal / calle Larios', 36.7181, -4.4216, NULL, '{"cruce": "Alameda Principal - Larios", "fases": 3}'),  -- 1
                                                                                                                 ('00000000-0000-7004-8000-000000000002', 'BUS_STOP',      'MALAGA_OPEN_DATA', '3948',      'Parada Alameda Principal',                  36.7176, -4.4229, NULL, '{"marquesina": true}'),                               -- 2
                                                                                                                 ('00000000-0000-7004-8000-000000000003', 'BUS_STOP',      'MALAGA_OPEN_DATA', '3950',      'Parada Alameda de Colón',                   36.7170, -4.4245, NULL, '{"marquesina": false}'),                              -- 3
                                                                                                                 ('00000000-0000-7004-8000-000000000004', 'CONTAINER',     'MALAGA_OPEN_DATA', 'CONT-2231', 'Contenedor de orgánico',                    36.7006, -4.4391, NULL, '{"residuo": "organico", "capacidad_l": 2400}'),       -- 4
                                                                                                                 ('00000000-0000-7004-8000-000000000005', 'TREE',          'MALAGA_OPEN_DATA', 'ARB-5540',  'Palmera del Paseo Marítimo',                36.7201, -4.4021, NULL, '{"especie": "Washingtonia robusta"}'),               -- 5
                                                                                                                 ('00000000-0000-7004-8000-000000000006', 'STREET_LIGHT',  'MALAGA_OPEN_DATA', 'FAR-7781',  'Farola Bulevar Louis Pasteur',              36.7156, -4.4729, NULL, '{"tecnologia": "LED"}'),                              -- 6
                                                                                                                 ('00000000-0000-7004-8000-000000000007', 'FOUNTAIN',      'MALAGA_OPEN_DATA', 'FUE-0031',  'Fuente ornamental de Ciudad Jardín',        36.7399, -4.4267, NULL, NULL),                                                 -- 7
                                                                                                                 ('00000000-0000-7004-8000-000000000008', 'GREEN_AREA',    'MANUAL',           NULL,        'Zona verde La Palmilla',                    36.7337, -4.4383,
                                                                                                                  '{"type": "Polygon", "coordinates": [[[-4.4390, 36.7332], [-4.4376, 36.7332], [-4.4376, 36.7342], [-4.4390, 36.7342], [-4.4390, 36.7332]]]}', NULL), -- 8
                                                                                                                 ('00000000-0000-7004-8000-000000000009', 'PARKING',       'MALAGA_OPEN_DATA', 'APA-0005',  'Aparcamiento público Centro',               36.7208, -4.4178, NULL, '{"plazas": 400}'),                                    -- 9
                                                                                                                 ('00000000-0000-7004-8000-000000000010', 'OTHER',         'MANUAL',           NULL,        'Señal de stop',                             36.6661, -4.4991, NULL, '{"tipo": "señal vertical R-2"}');                    -- 10

INSERT INTO incident_asset (incident_id, asset_id, link_type, distance_m, confidence) VALUES
                                                                                          ('00000000-0000-7002-8000-000000000001', '00000000-0000-7004-8000-000000000001',  'CONFIRMED', 21.0,  0.95),
                                                                                          ('00000000-0000-7002-8000-000000000002', '00000000-0000-7004-8000-000000000004',  'INFERRED',  11.5,  0.82),
                                                                                          ('00000000-0000-7002-8000-000000000003', '00000000-0000-7004-8000-000000000005',  'CONFIRMED',  4.2,  0.90),
                                                                                          ('00000000-0000-7002-8000-000000000004', '00000000-0000-7004-8000-000000000006',  'EXPLICIT',   3.0,  1.00),
                                                                                          ('00000000-0000-7002-8000-000000000006', '00000000-0000-7004-8000-000000000002',  'INFERRED',  14.8,  0.71),   -- dos candidatos: el operador elegirá
                                                                                          ('00000000-0000-7002-8000-000000000006', '00000000-0000-7004-8000-000000000003',  'INFERRED', 157.0,  0.18),
                                                                                          ('00000000-0000-7002-8000-000000000007', '00000000-0000-7004-8000-000000000007',  'CONFIRMED', 12.0,  0.88),
                                                                                          ('00000000-0000-7002-8000-000000000008', '00000000-0000-7004-8000-000000000008',  'CONFIRMED', 30.0,  0.60),
                                                                                          ('00000000-0000-7002-8000-000000000009', '00000000-0000-7004-8000-000000000010', 'EXPLICIT',   5.0,  1.00);


-- ---------------------------------------------------------------------
-- Observaciones externas (ids 1-9, IDENTITY) y contextos urbanos (4; UUID ...-7005-...)
-- ---------------------------------------------------------------------

INSERT INTO external_observation (source, context_type, variable, value_numeric, value_text, unit, quality,
                                  observed_at, ingested_at, valid_until, latitude, longitude, district) VALUES
                                                                                                            ('AEMET',            'WEATHER',     'precipitation',          12.4, NULL, 'mm',    'VALID',     now() - interval '2 days 5 hours', now() - interval '2 days 5 hours', now() - interval '2 days 4 hours', 36.6667, -4.4822, NULL),                 -- 1
                                                                                                            ('AEMET',            'WEATHER',     'temperature',            17.8, NULL, '°C',    'VALID',     now() - interval '2 days 5 hours', now() - interval '2 days 5 hours', now() - interval '2 days 4 hours', 36.6667, -4.4822, NULL),                 -- 2
                                                                                                            ('MALAGA_OPEN_DATA', 'TRAFFIC',     'traffic_intensity',      1450, NULL, 'veh/h', 'VALID',     now() - interval '2 days 5 hours', now() - interval '2 days 5 hours', now() - interval '2 days 4 hours', 36.7179, -4.4225, 'CENTRO'),             -- 3
                                                                                                            ('MALAGA_OPEN_DATA', 'EVENT',       'event',                  NULL, 'Evento cultural en calle Larios con cortes de tráfico', NULL, 'VALID',
                                                                                                             now() - interval '2 days 6 hours', now() - interval '2 days 6 hours', now() - interval '2 days 1 hour',  36.7197, -4.4213, 'CENTRO'),             -- 4
                                                                                                            ('AEMET',            'WEATHER',     'wind_speed',               54, NULL, 'km/h',  'VALID',     now() - interval '5 days',         now() - interval '5 days',         now() - interval '4 days 23 hours', 36.6667, -4.4822, NULL),                -- 5
                                                                                                            ('AEMET',            'WEATHER',     'temperature',            15.2, NULL, '°C',    'VALID',     now() - interval '5 days',         now() - interval '5 days',         now() - interval '4 days 23 hours', 36.6667, -4.4822, NULL),                -- 6
                                                                                                            ('MALAGA_OPEN_DATA', 'ENVIRONMENT', 'no2',                      38, NULL, 'µg/m3', 'VALID',     now() - interval '1 day',          now() - interval '1 day',          now() - interval '23 hours',        36.7210, -4.4200, 'CENTRO'),            -- 7
                                                                                                            ('AEMET',            'WEATHER',     'precipitation_forecast',  5.0, NULL, 'mm',    'ESTIMATED', now() - interval '1 hour',         now() - interval '1 hour',         now() + interval '1 day',           36.6667, -4.4822, NULL),                -- 8
                                                                                                            ('MALAGA_OPEN_DATA', 'TRAFFIC',     'traffic_intensity',      9999, NULL, 'veh/h', 'SUSPECT',   now() - interval '1 day 7 hours',  now() - interval '1 day 7 hours',  now() - interval '1 day 6 hours',   36.7010, -4.4400, 'CARRETERA_DE_CADIZ'); -- 9 (sensor con lectura anómala)

INSERT INTO urban_context (id, incident_id, district, reference_time, status, summary, created_at) VALUES
                                                                                                       ('00000000-0000-7005-8000-000000000001', '00000000-0000-7002-8000-000000000001',    NULL,     now() - interval '2 days 5 hours', 'COMPLETE',
                                                                                                        'Lluvia moderada (12,4 mm) y 17,8 °C. Tráfico alto en la Alameda (1450 veh/h) y evento con cortes de tráfico en calle Larios.',
                                                                                                        now() - interval '2 days 5 hours'),                                                                      -- 1
                                                                                                       ('00000000-0000-7005-8000-000000000002', '00000000-0000-7002-8000-000000000003',    NULL,     now() - interval '5 days',         'PARTIAL',
                                                                                                        'Viento fuerte (54 km/h) y 15,2 °C. Los datos de tráfico no estaban disponibles.',
                                                                                                        now() - interval '5 days'),                                                                              -- 2 (una fuente caída)
                                                                                                       ('00000000-0000-7005-8000-000000000003', NULL, 'CENTRO', now() - interval '1 day',          'COMPLETE',
                                                                                                        'Calidad del aire aceptable en el Centro (NO2: 38 µg/m3).',
                                                                                                        now() - interval '1 day'),                                                                               -- 3 (contexto de zona)
                                                                                                       ('00000000-0000-7005-8000-000000000004', '00000000-0000-7002-8000-000000000004',    NULL,     now() - interval '3 hours',        'PENDING', NULL, now() - interval '3 hours');         -- 4 (enriquecimiento en curso)

INSERT INTO urban_context_observation (context_id, observation_id) VALUES
                                                                       ('00000000-0000-7005-8000-000000000001', 1),
                                                                       ('00000000-0000-7005-8000-000000000001', 2),
                                                                       ('00000000-0000-7005-8000-000000000001', 3),
                                                                       ('00000000-0000-7005-8000-000000000001', 4),
                                                                       ('00000000-0000-7005-8000-000000000002', 5),
                                                                       ('00000000-0000-7005-8000-000000000002', 6),
                                                                       ('00000000-0000-7005-8000-000000000003', 7);


-- ---------------------------------------------------------------------
-- Notificaciones (una en cada estado de entrega)
-- ---------------------------------------------------------------------

INSERT INTO notification (recipient_id, incident_id, event, channel, message, status, created_at, sent_at, read_at) VALUES
                                                                                                                        ('00000000-0000-7001-8000-000000000008', '00000000-0000-7002-8000-000000000001', 'STATUS_CHANGED',    'EMAIL',  'Tu incidencia "Semáforo apagado en la Alameda" ha sido validada.',
                                                                                                                         'SENT',      now() - interval '2 days 4 hours',  now() - interval '2 days 4 hours',  NULL),
                                                                                                                        ('00000000-0000-7001-8000-000000000004', '00000000-0000-7002-8000-000000000001', 'INCIDENT_ASSIGNED', 'IN_APP', 'Se te ha asignado la incidencia "Semáforo apagado en la Alameda".',
                                                                                                                         'READ',      now() - interval '2 days 3 hours',  now() - interval '2 days 3 hours',  now() - interval '2 days 2 hours'),
                                                                                                                        ('00000000-0000-7001-8000-000000000003', '00000000-0000-7002-8000-000000000002', 'INCIDENT_CREATED',  'IN_APP', 'Nueva incidencia: "Contenedor desbordado en Huelin".',
                                                                                                                         'READ',      now() - interval '1 day 9 hours',   now() - interval '1 day 9 hours',   now() - interval '1 day 8 hours'),
                                                                                                                        ('00000000-0000-7001-8000-000000000009', '00000000-0000-7002-8000-000000000002', 'STATUS_CHANGED',    'PUSH',   'Tu incidencia "Contenedor desbordado en Huelin" está asignada al servicio de limpieza.',
                                                                                                                         'DELIVERED', now() - interval '1 day 6 hours',   now() - interval '1 day 6 hours',   NULL),
                                                                                                                        ('00000000-0000-7001-8000-000000000008', '00000000-0000-7002-8000-000000000007', 'STATUS_CHANGED',    'EMAIL',  'Tu incidencia "Fuente sin agua en Ciudad Jardín" ha sido rechazada: corte de agua programado en la zona.',
                                                                                                                         'DELIVERED', now() - interval '2 days 22 hours', now() - interval '2 days 22 hours', NULL),
                                                                                                                        ('00000000-0000-7001-8000-000000000009', '00000000-0000-7002-8000-000000000004', 'INCIDENT_CREATED',  'EMAIL',  'Hemos recibido tu incidencia "Farola fundida en Teatinos".',
                                                                                                                         'PENDING',   now() - interval '3 hours',         NULL,                               NULL),
                                                                                                                        ('00000000-0000-7001-8000-000000000008', '00000000-0000-7002-8000-000000000005', 'INFO_REQUESTED',    'EMAIL',  '¿Puedes indicar en qué carril está el bache y su tamaño aproximado?',
                                                                                                                         'FAILED',    now() - interval '1 day',           NULL,                               NULL),
                                                                                                                        ('00000000-0000-7001-8000-000000000008', '00000000-0000-7002-8000-000000000009', 'STATUS_CHANGED',    'SMS',    'Tu incidencia "Señal de stop tapada por ramas" se ha reabierto.',
                                                                                                                         'SENT',      now() - interval '2 hours',         now() - interval '2 hours',         NULL);


-- ---------------------------------------------------------------------
-- Documentos para RAG (dos versiones del mismo procedimiento)
-- ---------------------------------------------------------------------

INSERT INTO knowledge_document (id, code, version_number, title, doc_type, storage_path, source_url, effective_from, indexed_at) VALUES
                                                                                                                                     ('00000000-0000-7006-8000-000000000001', 'PROC-SEMAFOROS', 1, 'Procedimiento de actuación ante averías de semáforos', 'PROCEDURE', 'docs/PROC-SEMAFOROS_v1.pdf', NULL,
                                                                                                                                      current_date - 400, now() - interval '390 days'),
                                                                                                                                     ('00000000-0000-7006-8000-000000000002', 'PROC-SEMAFOROS', 2, 'Procedimiento de actuación ante averías de semáforos', 'PROCEDURE', 'docs/PROC-SEMAFOROS_v2.pdf', NULL,
                                                                                                                                      current_date - 30,  NULL),                                                  -- pendiente de indexar
                                                                                                                                     ('00000000-0000-7006-8000-000000000003', 'ORD-LIMPIEZA',   1, 'Ordenanza de limpieza de espacios públicos (ejemplo)', 'ORDINANCE', NULL, 'https://example.org/ordenanza-limpieza.pdf',
                                                                                                                                      current_date - 1000, now() - interval '100 days'),
                                                                                                                                     ('00000000-0000-7006-8000-000000000004', 'GUIA-ARBOLADO',  1, 'Guía de actuación ante caída de arbolado',             'GUIDE',     'docs/GUIA-ARBOLADO_v1.pdf', NULL,
                                                                                                                                      current_date - 200, now() - interval '10 days');


-- ---------------------------------------------------------------------
-- Comprobación: filas por tabla
-- ---------------------------------------------------------------------

SELECT 'app_user' AS tabla, count(*) AS filas FROM app_user
UNION ALL SELECT 'incident',                  count(*) FROM incident
UNION ALL SELECT 'status_change',             count(*) FROM status_change
UNION ALL SELECT 'assignment',                count(*) FROM assignment
UNION ALL SELECT 'attachment',                count(*) FROM attachment
UNION ALL SELECT 'urban_asset',               count(*) FROM urban_asset
UNION ALL SELECT 'incident_asset',            count(*) FROM incident_asset
UNION ALL SELECT 'external_observation',      count(*) FROM external_observation
UNION ALL SELECT 'urban_context',             count(*) FROM urban_context
UNION ALL SELECT 'urban_context_observation', count(*) FROM urban_context_observation
UNION ALL SELECT 'notification',              count(*) FROM notification
UNION ALL SELECT 'knowledge_document',        count(*) FROM knowledge_document;