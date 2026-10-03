package urbanpulse.service;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import urbanpulse.dao.ExternalObservationRepository;

@Service
@AllArgsConstructor
public class ExternalObservationService {
    private final ExternalObservationRepository externalObservationRepository;
}
