package urbanpulse.controller.rest;

import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import urbanpulse.dto.ExternalObservation;
import urbanpulse.service.ExternalObservationService;

import java.util.List;

@RestController
@Slf4j
@AllArgsConstructor
@Tag(name = "External Observations", description = "Normalized observations ingested from external city data sources")
@RequestMapping("/api/v1/external-observations")
public class ExternalObservationRestController {
    private final ExternalObservationService externalObservationService;

    /*
     * Filters external observations by source, zone, period or quality.
    */
    @GetMapping
    public ResponseEntity<List<ExternalObservation>> filterExternalObservations() {
        //TODO
        return null;
    }

    /*
     * Saves a normalized observation provided by an external system.
    */
    @PostMapping("/")
    public ResponseEntity<ExternalObservation> addExternalObservation() {
        //TODO
        return null;
    }
}
