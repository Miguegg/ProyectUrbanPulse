package urbanpulse.dto;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
public class User {
    private UUID id;
    private String email;
    private String passwordHash;
    private String name;
    private String phone;
    private Role role;
    // TODO: Department se convertirá en una tabla
    private Department department;
    private Boolean active;
    // TODO: Esta variable es la típica de placeholder de Supabase,
    // TODO: Si no aparece en el pdf se borrará aquí y en Supabase
    private LocalDateTime createdAt;
}
