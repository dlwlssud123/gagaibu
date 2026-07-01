package com.example.budget.domain.budget.controller;

import com.example.budget.domain.budget.dto.BudgetRequest;
import com.example.budget.domain.budget.dto.BudgetResponse;
import com.example.budget.domain.budget.service.BudgetService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/budgets")
@RequiredArgsConstructor
public class BudgetController {

    private final BudgetService budgetService;

    @PostMapping
    public ResponseEntity<BudgetResponse> saveOrUpdate(@RequestBody @Valid BudgetRequest request) {
        return ResponseEntity.ok(budgetService.saveOrUpdateBudget(request));
    }

    @GetMapping
    public ResponseEntity<BudgetResponse> getBudget(
            @RequestParam Long userId,
            @RequestParam Integer year,
            @RequestParam Integer month) {
        return ResponseEntity.ok(budgetService.getBudget(userId, year, month));
    }
}
