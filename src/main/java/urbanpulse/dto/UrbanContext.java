package urbanpulse.dto;

import lombok.Data;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Data
public class UrbanContext {
    private UUID id;
    private Incident incident;
    // TODO: District será una tabla
    private District district;
    private LocalDateTime referenceTime;
    private ContextStatus status;
    private String summary;
    private LocalDateTime createdAt;
    private List<ExternalObservation> externalObservations;
}
