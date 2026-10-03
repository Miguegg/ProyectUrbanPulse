package urbanpulse.dao;

import org.springframework.data.jpa.repository.JpaRepository;
import urbanpulse.entity.AttachmentEntity;

import java.util.UUID;

public interface AttachmentRepository extends JpaRepository<AttachmentEntity, UUID> {

}
