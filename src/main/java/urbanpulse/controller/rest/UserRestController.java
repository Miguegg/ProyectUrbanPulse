package urbanpulse.controller.rest;

import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import urbanpulse.dto.User;
import urbanpulse.service.UserService;

import java.util.List;

@RestController
@Slf4j
@AllArgsConstructor
@Tag(name = "Users", description = "User registration, lookup and role management")
@RequestMapping("/api/v1/users")
public class UserRestController {
    private final UserService userService;

    /*
     * Gets all users managed by the system.
    */
    @GetMapping("/")
    public ResponseEntity<List<User>> getUsers() {
        //TODO
        return null;
    }

    /*
     * Gets a user by its ID.
     * If it does not exist, it returns a 404 error.
    */
    @GetMapping("/{id}")
    public ResponseEntity<User> getUserById() {
        //TODO
        return null;
    }

    /*
     * Registers a new user in the system.
    */
    @PostMapping("/")
    public ResponseEntity<User> addUser() {
        //TODO
        return null;
    }

    /*
     * Updates the roles and permissions assigned to a user.
    */
    @PatchMapping("/{id}/roles")
    public ResponseEntity<User> editUserRoles() {
        //TODO
        return null;
    }
}
