package urbanpulse.service;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import urbanpulse.dao.AttachmentRepository;

@Service
@AllArgsConstructor
public class AttachmentService {
    private final AttachmentRepository attachmentRepository;
}
