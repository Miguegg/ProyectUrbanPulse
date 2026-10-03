package urbanpulse.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import urbanpulse.entity.ExternalObservationEntity;

public interface ExternalObservationRepository extends JpaRepository<ExternalObservationEntity, Integer> {
}
