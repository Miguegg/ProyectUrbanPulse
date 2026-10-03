package urbanpulse.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import urbanpulse.dto.ContextStatus;
import urbanpulse.dto.District;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

// Contexto urbano de una incidencia o de una zona en un instante (RF24, RF17).
// Tiene que venir relleno al menos uno: incident o district.
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "urban_context")
public class UrbanContextEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    // Null si es un contexto de zona
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "incident_id")
    private IncidentEntity incident;

    @Enumerated(EnumType.STRING)
    private District district;

    // Instante al que se refiere, p. ej. el del reporte
    @Column(nullable = false, name = "reference_time")
    private LocalDateTime referenceTime;

    // PARTIAL = alguna fuente no respondió (RF26)
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ContextStatus status = ContextStatus.PENDING;

    // Resumen que ve el operador
    private String summary;

    @CreationTimestamp
    @Column(nullable = false, name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @ManyToMany
    @JoinTable(name = "urban_context_observation",
            joinColumns = @JoinColumn(name = "context_id"),
            inverseJoinColumns = @JoinColumn(name = "observation_id"))
    private List<ExternalObservationEntity> externalObservations = new ArrayList<>();
}
