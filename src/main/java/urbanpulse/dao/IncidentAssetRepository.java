package urbanpulse.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import urbanpulse.entity.IncidentAssetEntity;

public interface IncidentAssetRepository extends JpaRepository<IncidentAssetEntity, Integer> {
}
