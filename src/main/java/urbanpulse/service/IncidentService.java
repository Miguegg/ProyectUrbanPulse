package urbanpulse.service;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import urbanpulse.dao.IncidentRepository;

@Service
@AllArgsConstructor
public class IncidentService {
    private final IncidentRepository incidentRepository;


}
