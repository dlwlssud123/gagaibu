package com.example.budget.domain.accountbook.entity;

import com.example.budget.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Entity
@Table(name = "account_books")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AccountBook {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private Long amount;

    @Column(nullable = false)
    private String category;

    @Column(nullable = false)
    private String content;

    @Column(nullable = false)
    private LocalDate transactionDate;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private TransactionType transactionType;

    @Builder
    public AccountBook(User user, Long amount, String category, String content, LocalDate transactionDate, TransactionType transactionType) {
        this.user = user;
        this.amount = amount;
        this.category = category;
        this.content = content;
        this.transactionDate = transactionDate;
        this.transactionType = transactionType;
    }

    public void update(Long amount, String category, String content, LocalDate transactionDate, TransactionType transactionType) {
        this.amount = amount;
        this.category = category;
        this.content = content;
        this.transactionDate = transactionDate;
        this.transactionType = transactionType;
    }
}
