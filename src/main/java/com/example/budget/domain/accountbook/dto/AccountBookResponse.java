package com.example.budget.domain.accountbook.dto;

import com.example.budget.domain.accountbook.entity.AccountBook;
import com.example.budget.domain.accountbook.entity.TransactionType;
import lombok.Getter;
import java.time.LocalDate;

@Getter
public class AccountBookResponse {
    private final Long id;
    private final Long userId;
    private final Long amount;
    private final String category;
    private final String content;
    private final LocalDate transactionDate;
    private final TransactionType transactionType;

    public AccountBookResponse(AccountBook accountBook) {
        this.id = accountBook.getId();
        this.userId = accountBook.getUser().getId();
        this.amount = accountBook.getAmount();
        this.category = accountBook.getCategory();
        this.content = accountBook.getContent();
        this.transactionDate = accountBook.getTransactionDate();
        this.transactionType = accountBook.getTransactionType();
    }
}
