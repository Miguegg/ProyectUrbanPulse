package urbanpulse.dto;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class Attachment {
    private UUID id;
    private Incident incident;
    private User uploadedBy;
    private String fileName;
    private String contentType;
    private Long sizeBytes;
    private String storagePath;
    private LocalDateTime uploadedAt;
}
