package com.example.budget.domain.user.service;

import com.example.budget.domain.user.dto.UserJoinRequest;
import com.example.budget.domain.user.dto.UserResponse;
import com.example.budget.domain.user.entity.PersonaType;
import com.example.budget.domain.user.entity.User;
import com.example.budget.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserService {

    private final UserRepository userRepository;

    @Transactional
    public UserResponse join(UserJoinRequest request) {
        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            throw new IllegalArgumentException("이미 존재하는 사용자 이름입니다.");
        }

        User user = User.builder()
                .username(request.getUsername())
                .password(request.getPassword()) // 향후 패스워드 암호화 적용 가능
                .email(request.getEmail())
                .personaType(request.getPersonaType())
                .build();

        User savedUser = userRepository.save(user);
        return new UserResponse(savedUser);
    }

    public UserResponse getUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 유저입니다."));
        return new UserResponse(user);
    }

    @Transactional
    public UserResponse updatePersona(Long userId, PersonaType personaType) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 유저입니다."));
        user.updatePersona(personaType);
        return new UserResponse(user);
    }
}
