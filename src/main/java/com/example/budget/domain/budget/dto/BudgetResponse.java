package com.example.budget.domain.budget.dto;

import com.example.budget.domain.budget.entity.Budget;
import lombok.Getter;

@Getter
public class BudgetResponse {
    private final Long id;
    private final Long userId;
    private final Long amount;
    private final Integer year;
    private final Integer month;

    public BudgetResponse(Budget budget) {
        this.id = budget.getId();
        this.userId = budget.getUser().getId();
        this.amount = budget.getAmount();
        this.year = budget.getYear();
        this.month = budget.getMonth();
    }
}
