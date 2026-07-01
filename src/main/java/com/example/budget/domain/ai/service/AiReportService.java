package com.example.budget.domain.ai.service;

import com.example.budget.domain.accountbook.entity.AccountBook;
import com.example.budget.domain.accountbook.repository.AccountBookRepository;
import com.example.budget.domain.ai.dto.AiReportResponse;
import com.example.budget.domain.ai.entity.AiReport;
import com.example.budget.domain.ai.repository.AiReportRepository;
import com.example.budget.domain.budget.entity.Budget;
import com.example.budget.domain.budget.repository.BudgetRepository;
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
public class AiReportService {

    private final AiReportRepository aiReportRepository;
    private final UserRepository userRepository;
    private final AccountBookRepository accountBookRepository;
    private final BudgetRepository budgetRepository;
    private final NvidiaNimService nvidiaNimService;

    @Transactional
    public AiReportResponse generateDailyReport(Long userId, LocalDate reportDate) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 유저입니다."));

        // 특정 일자 및 해당 월의 지출 내역 조회 (한 달 치 조언용)
        LocalDate startOfMonth = reportDate.withDayOfMonth(1);
        LocalDate endOfMonth = reportDate.withDayOfMonth(reportDate.lengthOfMonth());
        
        List<AccountBook> monthlyHistory = accountBookRepository.findByUserIdAndTransactionDateBetween(userId, startOfMonth, endOfMonth);
        
        // 지출 총합 및 로그 조립
        long expenditureSum = monthlyHistory.stream()
                .filter(item -> com.example.budget.domain.accountbook.entity.TransactionType.EXPENDITURE.equals(item.getTransactionType()))
                .mapToLong(AccountBook::getAmount)
                .sum();

        String detailLogs = monthlyHistory.stream()
                .map(item -> String.format("[%s] %s: %d원 (%s)", item.getTransactionDate(), item.getCategory(), item.getAmount(), item.getContent()))
                .collect(Collectors.joining("\n"));

        // 예산 정보 가져오기 (없으면 0원)
        long budgetAmount = budgetRepository.findByUserIdAndYearAndMonth(userId, reportDate.getYear(), reportDate.getMonthValue())
                .map(Budget::getAmount)
                .orElse(0L);

        // AI 리포트 본문 생성
        String aiContent = nvidiaNimService.generateCoachingReport(user.getPersonaType(), budgetAmount, expenditureSum, detailLogs);

        // 리포트 엔티티 영속화 (기존 일자 리포트가 있으면 덮어쓰거나 새로 작성)
        AiReport aiReport = aiReportRepository.findByUserIdAndReportDate(userId, reportDate)
                .map(existing -> AiReport.builder()
                        .user(user)
                        .content(aiContent)
                        .reportDate(reportDate)
                        .build()) // 새로운 인스턴스로 교체 로직은 적절히 조정 가능 (여기선 덮어쓰는 대체본 구현)
                .orElseGet(() -> AiReport.builder()
                        .user(user)
                        .content(aiContent)
                        .reportDate(reportDate)
                        .build());

        AiReport saved = aiReportRepository.save(aiReport);
        return new AiReportResponse(saved);
    }

    public List<AiReportResponse> getReports(Long userId) {
        return aiReportRepository.findByUserIdOrderByReportDateDesc(userId)
                .stream()
                .map(AiReportResponse::new)
                .collect(Collectors.toList());
    }
}
