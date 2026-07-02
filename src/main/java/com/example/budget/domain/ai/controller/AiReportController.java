package com.example.budget.domain.ai.controller;

import com.example.budget.domain.ai.dto.AiReportResponse;
import com.example.budget.domain.ai.entity.AiReportType;
import com.example.budget.domain.ai.service.AiReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/v1/ai-reports")
@RequiredArgsConstructor
public class AiReportController {

    private final AiReportService aiReportService;

    @PostMapping("/generate")
    public ResponseEntity<AiReportResponse> generateReport(
            @RequestParam Long userId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate reportDate,
            @RequestParam AiReportType reportType) {
        return ResponseEntity.ok(aiReportService.generateDailyReport(userId, reportDate, reportType));
    }

    @GetMapping
    public ResponseEntity<List<AiReportResponse>> getReports(
            @RequestParam Long userId,
            @RequestParam AiReportType reportType) {
        return ResponseEntity.ok(aiReportService.getReports(userId, reportType));
    }
}
