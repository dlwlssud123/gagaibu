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

        // 2. 예산 데이터 생성 (기존 예산 초기화 후 2026년 6월 120만원, 2026년 7월 100만원 재설정)
        LocalDate today = LocalDate.now();
        budgetRepository.deleteAll();
        
        budgetRepository.save(Budget.builder()
                .user(user)
                .amount(1200000L)
                .year(2026)
                .month(6)
                .build());

        budgetRepository.save(Budget.builder()
                .user(user)
                .amount(1000000L)
                .year(2026)
                .month(7)
                .build());

        // 3. 테스트 소비/수입 내역 생성 (기존 지출 내역 싹 리셋하고 리얼한 1달치 거래내역 16개 강제 세팅)
        accountBookRepository.deleteAll();
        
        // --- 6월 거래 내역 ---
        // 6월 5일: 급여 수입
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(2500000L)
                .category("급여")
                .content("6월 급여 입금")
                .transactionDate(LocalDate.of(2026, 6, 5))
                .transactionType(TransactionType.INCOME)
                .build());

        // 6월 8일: 식비 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(12000L)
                .category("식비")
                .content("라멘 하우스 점심")
                .transactionDate(LocalDate.of(2026, 6, 8))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 6월 10일: 카페 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(5200L)
                .category("카페")
                .content("스타벅스 돌체 콜드브루")
                .transactionDate(LocalDate.of(2026, 6, 10))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 6월 12일: 쇼핑 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(45000L)
                .category("쇼핑")
                .content("무신사 반팔 티셔츠")
                .transactionDate(LocalDate.of(2026, 6, 12))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 6월 15일: 교통 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(2500L)
                .category("교통")
                .content("지하철 이용 왕복")
                .transactionDate(LocalDate.of(2026, 6, 15))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 6월 18일: 식비 지출 (과소비)
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(38000L)
                .category("식비")
                .content("교촌치킨 허니콤보 & 생맥주")
                .transactionDate(LocalDate.of(2026, 6, 18))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 6월 20일: 용돈 수입
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(100000L)
                .category("용돈")
                .content("부모님 용돈 이체")
                .transactionDate(LocalDate.of(2026, 6, 20))
                .transactionType(TransactionType.INCOME)
                .build());

        // 6월 22일: 마트 지출 (과소비)
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(58000L)
                .category("마트")
                .content("홈플러스 식료품 및 생필품 장보기")
                .transactionDate(LocalDate.of(2026, 6, 22))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 6월 24일: 카페 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(4500L)
                .category("카페")
                .content("메가커피 아이스 아메리카노")
                .transactionDate(LocalDate.of(2026, 6, 24))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 6월 25일: 식비 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(9500L)
                .category("식비")
                .content("써브웨이 샌드위치 세트")
                .transactionDate(LocalDate.of(2026, 6, 25))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 6월 27일: 여가 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(15000L)
                .category("문화/여가")
                .content("CGV 영화 티켓 예매")
                .transactionDate(LocalDate.of(2026, 6, 27))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 6월 29일: 기타 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(22000L)
                .category("기타")
                .content("다이소 생활 용품 구매")
                .transactionDate(LocalDate.of(2026, 6, 29))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // --- 7월 거래 내역 ---
        // 7월 1일: 식비 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(14000L)
                .category("식비")
                .content("놀부부대찌개 점심식사")
                .transactionDate(LocalDate.of(2026, 7, 1))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 7월 2일: 카페 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(6000L)
                .category("카페")
                .content("투썸플레이스 초코 쉐이크")
                .transactionDate(LocalDate.of(2026, 7, 2))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 7월 3일 (오늘): 쇼핑 지출 (과소비)
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(38000L)
                .category("쇼핑")
                .content("인체공학 독서대 및 필기구")
                .transactionDate(LocalDate.of(2026, 7, 3))
                .transactionType(TransactionType.EXPENDITURE)
                .build());

        // 7월 3일 (오늘): 식비 지출
        accountBookRepository.save(AccountBook.builder()
                .user(user)
                .amount(8500L)
                .category("식비")
                .content("김밥천국 모둠 라볶이 세트")
                .transactionDate(LocalDate.of(2026, 7, 3))
                .transactionType(TransactionType.EXPENDITURE)
                .build());
    }
}
