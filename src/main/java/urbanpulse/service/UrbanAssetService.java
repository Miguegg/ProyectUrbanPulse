package urbanpulse.service;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import urbanpulse.dao.UrbanAssetRepository;

@Service
@AllArgsConstructor
public class UrbanAssetService {
    private final UrbanAssetRepository urbanAssetRepository;
}
