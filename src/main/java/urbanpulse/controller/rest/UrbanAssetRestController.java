package urbanpulse.controller.rest;

import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import urbanpulse.dto.UrbanAsset;
import urbanpulse.service.UrbanAssetService;

import java.util.List;

@RestController
@Slf4j
@AllArgsConstructor
@Tag(name = "Urban Assets", description = "City assets and candidate assets near incidents or locations")
@RequestMapping("/api/v1/urban-assets")
public class UrbanAssetRestController {
    private final UrbanAssetService urbanAssetService;

    /*
     * Gets urban assets available as relevant city layers.
    */
    @GetMapping("/")
    public ResponseEntity<List<UrbanAsset>> getUrbanAssets() {
        //TODO
        return null;
    }

    /*
     * Finds candidate urban assets near an incident or location.
    */
    @GetMapping("/nearby")
    public ResponseEntity<List<UrbanAsset>> getNearbyUrbanAssets() {
        //TODO
        return null;
    }

    /*
     * Gets an urban asset by its ID.
     * If it does not exist, it returns a 404 error.
    */
    @GetMapping("/{id}")
    public ResponseEntity<UrbanAsset> getUrbanAssetById() {
        //TODO
        return null;
    }
}
