package com.example.budget.domain.budget.service;

import com.example.budget.domain.budget.dto.BudgetRequest;
import com.example.budget.domain.budget.dto.BudgetResponse;
import com.example.budget.domain.budget.entity.Budget;
import com.example.budget.domain.budget.repository.BudgetRepository;
import com.example.budget.domain.user.entity.User;
import com.example.budget.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class BudgetService {

    private final BudgetRepository budgetRepository;
    private final UserRepository userRepository;

    @Transactional
    public BudgetResponse saveOrUpdateBudget(BudgetRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 유저입니다."));

        Optional<Budget> existing = budgetRepository.findByUserIdAndYearAndMonth(
                request.getUserId(), request.getYear(), request.getMonth()
        );

        if (existing.isPresent()) {
            Budget budget = existing.get();
            budget.updateAmount(request.getAmount());
            return new BudgetResponse(budget);
        } else {
            Budget budget = Budget.builder()
                    .user(user)
                    .amount(request.getAmount())
                    .year(request.getYear())
                    .month(request.getMonth())
                    .build();
            Budget saved = budgetRepository.save(budget);
            return new BudgetResponse(saved);
        }
    }

    public BudgetResponse getBudget(Long userId, Integer year, Integer month) {
        Budget budget = budgetRepository.findByUserIdAndYearAndMonth(userId, year, month)
                .orElseThrow(() -> new IllegalArgumentException("설정된 예산이 없습니다."));
        return new BudgetResponse(budget);
    }
}
