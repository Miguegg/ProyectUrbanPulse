package urbanpulse.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import urbanpulse.entity.AssignmentEntity;

public interface AssignmentRepository extends JpaRepository<AssignmentEntity, Integer> {
}
