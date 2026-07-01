package com.example.budget.domain.ai.repository;

import com.example.budget.domain.ai.entity.AiReport;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AiReportRepository extends JpaRepository<AiReport, Long> {
    List<AiReport> findByUserIdOrderByReportDateDesc(Long userId);
    Optional<AiReport> findByUserIdAndReportDate(Long userId, LocalDate reportDate);
}
