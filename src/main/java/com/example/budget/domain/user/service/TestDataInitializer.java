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

        // 2. 당월 예산 데이터 로드 (2026년 7월 기준 예산 100만 원 설정)
        LocalDate today = LocalDate.now();
        int year = today.getYear();
        int month = today.getMonthValue();

        if (budgetRepository.findByUserIdAndYearAndMonth(user.getId(), year, month).isEmpty()) {
            Budget budget = Budget.builder()
                    .user(user)
                    .amount(1000000L)
                    .year(year)
                    .month(month)
                    .build();
            budgetRepository.save(budget);
        }

        // 3. 테스트 소비 내역 생성 (내역이 없을 때만 삽입)
        LocalDate startOfMonth = today.withDayOfMonth(1);
        if (accountBookRepository.findByUserIdAndTransactionDateBetween(user.getId(), startOfMonth, today).isEmpty()) {
            
            // 지출 내역 1
            accountBookRepository.save(AccountBook.builder()
                    .user(user)
                    .amount(15000L)
                    .category("식비")
                    .content("점심 식사 (김치찌개)")
                    .transactionDate(today.minusDays(2))
                    .transactionType(TransactionType.EXPENDITURE)
                    .build());

            // 지출 내역 2
            accountBookRepository.save(AccountBook.builder()
                    .user(user)
                    .amount(4500L)
                    .category("카페")
                    .content("아이스 아메리카노")
                    .transactionDate(today.minusDays(1))
                    .transactionType(TransactionType.EXPENDITURE)
                    .build());

            // 수입 내역 1
            accountBookRepository.save(AccountBook.builder()
                    .user(user)
                    .amount(50000L)
                    .category("기타수입")
                    .content("용돈 입금")
                    .transactionDate(today.minusDays(1))
                    .transactionType(TransactionType.INCOME)
                    .build());

            // 지출 내역 3 (오늘 지출)
            accountBookRepository.save(AccountBook.builder()
                    .user(user)
                    .amount(23000L)
                    .category("쇼핑")
                    .content("스마트폰 젤리 케이스")
                    .transactionDate(today)
                    .transactionType(TransactionType.EXPENDITURE)
                    .build());
        }
    }
}
