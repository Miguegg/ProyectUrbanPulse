package urbanpulse.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import urbanpulse.entity.IncidentEntity;

import java.util.UUID;

public interface IncidentRepository extends JpaRepository<IncidentEntity, UUID> {
}
