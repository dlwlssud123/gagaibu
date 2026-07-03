package com.example.budget.domain.user.service;

import com.example.budget.domain.accountbook.entity.AccountBook;
import com.example.budget.domain.accountbook.entity.TransactionType;
import com.example.budget.domain.accountbook.repository.AccountBookRepository;
import com.example.budget.domain.budget.entity.Budget;
import com.example.budget.domain.budget.repository.BudgetRepository;
import com.example.budget.domain.user.entity.PersonaType;
import com.example.budget.domain.user.entity.User;
import com.example.budget.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;
import java.time.LocalDate;

@Component
@RequiredArgsConstructor
public class TestDataInitializer implements CommandLineRunner {

    private final UserRepository userRepository;
    private final BudgetRepository budgetRepository;
    private final AccountBookRepository accountBookRepository;

    @Override
    public void run(String... args) throws Exception {
        // 1. 테스트 유저 생성
        User user = userRepository.findById(1L).orElseGet(() -> {
            User newUser = User.builder()
                    .username("gagaibu_user")
                    .password("password")
                    .email("test@test.com")
                    .personaType(PersonaType.MOM)
                    .build();
            return userRepository.save(newUser);
        });
    }
}
