package urbanpulse.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import urbanpulse.entity.StatusChangeEntity;

public interface StatusChangeRepository extends JpaRepository<StatusChangeEntity, Integer> {
}
