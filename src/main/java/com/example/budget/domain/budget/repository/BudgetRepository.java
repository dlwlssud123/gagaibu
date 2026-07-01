package com.example.budget.domain.budget.repository;

import com.example.budget.domain.budget.entity.Budget;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface BudgetRepository extends JpaRepository<Budget, Long> {
    Optional<Budget> findByUserIdAndYearAndMonth(Long userId, Integer year, Integer month);
}
