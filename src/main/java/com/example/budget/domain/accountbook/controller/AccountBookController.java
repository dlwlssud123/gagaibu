package com.example.budget.domain.accountbook.controller;

import com.example.budget.domain.accountbook.dto.AccountBookCreateRequest;
import com.example.budget.domain.accountbook.dto.AccountBookResponse;
import com.example.budget.domain.accountbook.service.AccountBookService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/account-books")
@RequiredArgsConstructor
public class AccountBookController {

    private final AccountBookService accountBookService;

    @PostMapping
    public ResponseEntity<AccountBookResponse> create(@RequestBody @Valid AccountBookCreateRequest request) {
        return ResponseEntity.ok(accountBookService.create(request));
    }

    @GetMapping
    public ResponseEntity<List<AccountBookResponse>> getHistory(
            @RequestParam Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ResponseEntity.ok(accountBookService.getHistory(userId, startDate, endDate));
    }

    @PutMapping("/{id}")
    public ResponseEntity<AccountBookResponse> update(
            @PathVariable Long id,
            @RequestBody @Valid AccountBookCreateRequest request) {
        return ResponseEntity.ok(accountBookService.update(id, request));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        accountBookService.delete(id);
        return ResponseEntity.ok().build();
    }
}
