package urbanpulse.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnTransformer;
import org.hibernate.annotations.CreationTimestamp;
import urbanpulse.dto.AssetType;
import urbanpulse.dto.ExternalSource;

import java.time.LocalDateTime;
import java.util.UUID;

// Elemento físico de la ciudad: semáforo, contenedor, parada... (RF22)
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "urban_asset")
public class UrbanAssetEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, name = "asset_type")
    private AssetType assetType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, name = "source")
    private ExternalSource externalSource;

    // String porque no sabemos que tipo de id nos puedes dar el servicio externo
    @Column(name = "external_id")
    private String externalId;

    private String name;

    // Punto representativo (centroide si es un área)
    @Column(nullable = false)
    private Double latitude;

    @Column(nullable = false)
    private Double longitude;

    // JSONB: GeoJSON si el activo no es un punto
    @Column(columnDefinition = "jsonb")
    @ColumnTransformer(write = "?::jsonb")
    private String geometry;

    // JSONB: datos libres de la fuente
    @Column(columnDefinition = "jsonb")
    @ColumnTransformer(write = "?::jsonb")
    private String metadata;

    @CreationTimestamp
    @Column(nullable = false, name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
