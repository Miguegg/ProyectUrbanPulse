package urbanpulse.dto;

import lombok.Data;
import urbanpulse.entity.UserEntity;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class Incident {
    private UUID id;
    private String title;
    private String description;
    private Category category;
    private IncidentStatus status;
    private Priority priority;
    private String priorityJustification;
    private Double latitude;
    private Double longitude;
    private Double locationAccuracy;
    private String address;
    private String neighbourhood;
    private District district;
    private UserEntity reporter;
    private LocalDateTime reportedAt;
    private LocalDateTime updatedAt;
    private LocalDateTime resolvedAt;
    private LocalDateTime closedAt;
}
