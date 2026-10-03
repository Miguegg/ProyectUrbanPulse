package urbanpulse.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import urbanpulse.entity.UrbanAssetEntity;

import java.util.UUID;

public interface UrbanAssetRepository extends JpaRepository<UrbanAssetEntity, UUID> {
}
