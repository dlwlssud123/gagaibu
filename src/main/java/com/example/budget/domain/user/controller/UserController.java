package com.example.budget.domain.user.controller;

import com.example.budget.domain.user.dto.UserJoinRequest;
import com.example.budget.domain.user.dto.UserResponse;
import com.example.budget.domain.user.entity.PersonaType;
import com.example.budget.domain.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;

    @PostMapping("/join")
    public ResponseEntity<UserResponse> join(@RequestBody @Valid UserJoinRequest request) {
        return ResponseEntity.ok(userService.join(request));
    }

    @GetMapping("/{userId}")
    public ResponseEntity<UserResponse> getUser(@PathVariable Long userId) {
        return ResponseEntity.ok(userService.getUser(userId));
    }

    @PutMapping("/{userId}/persona")
    public ResponseEntity<UserResponse> updatePersona(
            @PathVariable Long userId,
            @RequestParam PersonaType personaType) {
        return ResponseEntity.ok(userService.updatePersona(userId, personaType));
    }
}
