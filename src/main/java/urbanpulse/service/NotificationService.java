package urbanpulse.service;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import urbanpulse.dao.NotificationRepository;

@Service
@AllArgsConstructor
public class NotificationService {
    private final NotificationRepository notificationRepository;
}
