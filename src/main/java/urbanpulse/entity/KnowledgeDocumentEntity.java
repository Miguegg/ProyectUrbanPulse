package urbanpulse.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import urbanpulse.dto.DocumentType;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.UUID;

// Procedimiento o normativa versionada que puede indexarse para RAG.
// Cada versión es una fila; code se repite entre versiones del mismo documento.
@Getter
@Setter
@NoArgsConstructor
@Entity
@Table(name = "knowledge_document")
public class KnowledgeDocumentEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String code;

    @Column(nullable = false, name = "version_number")
    private Integer versionNumber = 1;

    @Column(nullable = false)
    private String title;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, name = "doc_type")
    private DocumentType docType;

    // Al menos uno de los dos tiene que venir relleno
    @Column(name = "storage_path")
    private String storagePath;

    @Column(name = "source_url")
    private String sourceUrl;

    @Column(name = "effective_from")
    private LocalDate effectiveFrom;

    // Null = aún no indexado para RAG
    @Column(name = "indexed_at")
    private LocalDateTime indexedAt;

    @CreationTimestamp
    @Column(nullable = false, name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
