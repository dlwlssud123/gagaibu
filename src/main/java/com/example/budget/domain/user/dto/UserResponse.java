package com.example.budget.domain.user.dto;

import com.example.budget.domain.user.entity.PersonaType;
import com.example.budget.domain.user.entity.User;
import lombok.Getter;

@Getter
public class UserResponse {
    private final Long id;
    private final String username;
    private final String email;
    private final PersonaType personaType;

    public UserResponse(User user) {
        this.id = user.getId();
        this.username = user.getUsername();
        this.email = user.getEmail();
        this.personaType = user.getPersonaType();
    }
}
