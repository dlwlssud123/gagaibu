package com.example.budget.domain.accountbook.service;

import com.example.budget.domain.accountbook.dto.AccountBookCreateRequest;
import com.example.budget.domain.accountbook.dto.AccountBookResponse;
import com.example.budget.domain.accountbook.entity.AccountBook;
import com.example.budget.domain.accountbook.repository.AccountBookRepository;
import com.example.budget.domain.user.entity.User;
import com.example.budget.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AccountBookService {

    private final AccountBookRepository accountBookRepository;
    private final UserRepository userRepository;

    @Transactional
    public AccountBookResponse create(AccountBookCreateRequest request) {
        User user = userRepository.findById(request.getUserId())
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 유저입니다."));

        AccountBook accountBook = AccountBook.builder()
                .user(user)
                .amount(request.getAmount())
                .category(request.getCategory())
                .content(request.getContent())
                .transactionDate(request.getTransactionDate())
                .transactionType(request.getTransactionType())
                .build();

        AccountBook saved = accountBookRepository.save(accountBook);
        return new AccountBookResponse(saved);
    }

    public List<AccountBookResponse> getHistory(Long userId, LocalDate startDate, LocalDate endDate) {
        return accountBookRepository.findByUserIdAndTransactionDateBetween(userId, startDate, endDate)
                .stream()
                .map(AccountBookResponse::new)
                .collect(Collectors.toList());
    }

    @Transactional
    public AccountBookResponse update(Long id, AccountBookCreateRequest request) {
        AccountBook accountBook = accountBookRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 가계부 내역입니다."));

        accountBook.update(
                request.getAmount(),
                request.getCategory(),
                request.getContent(),
                request.getTransactionDate(),
                request.getTransactionType()
        );

        return new AccountBookResponse(accountBook);
    }

    @Transactional
    public void delete(Long id) {
        AccountBook accountBook = accountBookRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 가계부 내역입니다."));
        accountBookRepository.delete(accountBook);
    }
}
