package urbanpulse.controller.rest;

import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import urbanpulse.dto.Attachment;
import urbanpulse.service.AttachmentService;

import java.util.List;

@RestController
@Slf4j
@AllArgsConstructor
@Tag(name = "Attachments", description = "Evidence files attached to urban incidents")
@RequestMapping("/api/v1")
public class AttachmentRestController {
    private final AttachmentService attachmentService;

    /*
     * Gets the evidence files attached to an incident.
    */
    @GetMapping("/incidents/{incidentId}/attachments")
    public ResponseEntity<List<Attachment>> getIncidentAttachments() {
        //TODO
        return null;
    }

    /*
     * Adds a photo, video or document as evidence for an incident.
     * The file type and size must be validated.
    */
    @PostMapping("/incidents/{incidentId}/attachments")
    public ResponseEntity<Attachment> addIncidentAttachment() {
        //TODO
        return null;
    }
}
