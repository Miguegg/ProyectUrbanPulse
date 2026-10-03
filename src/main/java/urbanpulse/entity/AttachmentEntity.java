package urbanpulse.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.UUID;

// Metadatos de un fichero; el fichero en sí se guarda fuera de la BD (RF05)
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "attachment")
public class AttachmentEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "incident_id", nullable = false)
    private IncidentEntity incident;

    // Usuario que subió el fichero
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "uploaded_by_id", nullable = false)
    private UserEntity uploadedBy;

    @Column(nullable = false, name = "file_name")
    private String fileName;

    // Tipo MIME, p. ej. image/jpeg
    @Column(nullable = false, name = "content_type")
    private String contentType;

    @Column(nullable = false, name = "size_bytes")
    private Long sizeBytes;

    // Ruta del fichero en el almacenamiento (p. ej. Supabase Storage)
    @Column(unique = true, nullable = false, name = "storage_path")
    private String storagePath;

    @CreationTimestamp
    @Column(nullable = false, name = "uploaded_at", updatable = false)
    private LocalDateTime uploadedAt;
}
