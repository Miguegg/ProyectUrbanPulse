package urbanpulse.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import urbanpulse.entity.UrbanContextEntity;

import java.util.UUID;

public interface UrbanContextRepository extends JpaRepository<UrbanContextEntity, UUID> {
}
