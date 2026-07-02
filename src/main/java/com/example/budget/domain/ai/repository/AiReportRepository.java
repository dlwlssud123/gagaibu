package com.example.budget.domain.ai.repository;

import com.example.budget.domain.ai.entity.AiReport;
import com.example.budget.domain.ai.entity.AiReportType;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AiReportRepository extends JpaRepository<AiReport, Long> {
    List<AiReport> findByUserIdAndReportTypeOrderByReportDateDesc(Long userId, AiReportType reportType);
    Optional<AiReport> findByUserIdAndReportDateAndReportType(Long userId, LocalDate reportDate, AiReportType reportType);
}
