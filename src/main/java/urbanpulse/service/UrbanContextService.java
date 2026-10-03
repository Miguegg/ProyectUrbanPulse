package urbanpulse.service;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import urbanpulse.dao.UrbanContextRepository;

@Service
@AllArgsConstructor
public class UrbanContextService {
    private final UrbanContextRepository urbanContextRepository;
}
