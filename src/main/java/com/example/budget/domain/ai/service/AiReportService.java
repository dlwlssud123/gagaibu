package com.example.budget.domain.ai.service;

import com.example.budget.domain.accountbook.entity.AccountBook;
import com.example.budget.domain.accountbook.repository.AccountBookRepository;
import com.example.budget.domain.ai.dto.AiReportResponse;
import com.example.budget.domain.ai.entity.AiReport;
import com.example.budget.domain.ai.entity.AiReportType;
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
    public AiReportResponse generateDailyReport(Long userId, LocalDate reportDate, AiReportType reportType) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 유저입니다."));

        // 리포트 타입별로 조회 기간 분기
        LocalDate startDate;
        LocalDate endDate = reportDate;

        if (reportType == AiReportType.DAILY) {
            startDate = reportDate;
        } else if (reportType == AiReportType.WEEKLY) {
            startDate = reportDate.minusDays(6);
        } else {
            startDate = reportDate.withDayOfMonth(1);
            endDate = reportDate.withDayOfMonth(reportDate.lengthOfMonth());
        }

        List<AccountBook> history = accountBookRepository.findByUserIdAndTransactionDateBetween(userId, startDate, endDate);
        
        // 지출 총합 및 로그 조립
        long expenditureSum = history.stream()
                .filter(item -> com.example.budget.domain.accountbook.entity.TransactionType.EXPENDITURE.equals(item.getTransactionType()))
                .mapToLong(AccountBook::getAmount)
                .sum();

        String detailLogs = history.stream()
                .map(item -> String.format("[%s] %s > %s: %d원 (%s)", 
                        item.getTransactionDate(), 
                        item.getCategory(), 
                        item.getSubCategory() != null ? item.getSubCategory() : "기타", 
                        item.getAmount(), 
                        item.getContent()))
                .collect(Collectors.joining("\n"));

        // 예산 정보 가져오기 (없으면 0원)
        long budgetAmount = budgetRepository.findByUserIdAndYearAndMonth(userId, reportDate.getYear(), reportDate.getMonthValue())
                .map(Budget::getAmount)
                .orElse(0L);

        // AI 리포트 본문 생성 (타입 정보 전달 추가)
        String aiContent = nvidiaNimService.generateCoachingReport(user.getPersonaType(), budgetAmount, expenditureSum, detailLogs, reportType);

        // 리포트 엔티티 영속화 (기존 동일 일자/타입 리포트가 있으면 덮어쓰거나 새로 작성)
        AiReport aiReport = aiReportRepository.findByUserIdAndReportDateAndReportType(userId, reportDate, reportType)
                .map(existing -> AiReport.builder()
                        .user(user)
                        .content(aiContent)
                        .reportDate(reportDate)
                        .reportType(reportType)
                        .build())
                .orElseGet(() -> AiReport.builder()
                        .user(user)
                        .content(aiContent)
                        .reportDate(reportDate)
                        .reportType(reportType)
                        .build());

        AiReport saved = aiReportRepository.save(aiReport);
        return new AiReportResponse(saved);
    }

    public List<AiReportResponse> getReports(Long userId, AiReportType reportType) {
        return aiReportRepository.findByUserIdAndReportTypeOrderByReportDateDesc(userId, reportType)
                .stream()
                .map(AiReportResponse::new)
                .collect(Collectors.toList());
    }
}
