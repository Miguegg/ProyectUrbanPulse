package urbanpulse.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import urbanpulse.entity.NotificationEntity;

public interface NotificationRepository extends JpaRepository<NotificationEntity, Integer> {
}
