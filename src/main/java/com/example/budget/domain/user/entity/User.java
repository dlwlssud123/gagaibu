package com.example.budget.domain.user.entity;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "users")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true)
    private String username;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String email;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private PersonaType personaType;

    @Builder
    public User(String username, String password, String email, PersonaType personaType) {
        this.username = username;
        this.password = password;
        this.email = email;
        this.personaType = personaType;
    }

    public void updatePersona(PersonaType personaType) {
        this.personaType = personaType;
    }
}
