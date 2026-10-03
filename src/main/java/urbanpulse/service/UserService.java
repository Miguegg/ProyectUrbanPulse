package urbanpulse.service;

import lombok.AllArgsConstructor;
import org.springframework.stereotype.Service;
import urbanpulse.dao.UserRepository;

@Service
@AllArgsConstructor
public class UserService {
    private final UserRepository userRepository;



}
