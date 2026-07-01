package com.example.budget.domain.ai.dto;

import com.example.budget.domain.ai.entity.AiReport;
import lombok.Getter;
import java.time.LocalDate;

@Getter
public class AiReportResponse {
    private final Long id;
    private final Long userId;
    private final String content;
    private final LocalDate reportDate;

    public AiReportResponse(AiReport aiReport) {
        this.id = aiReport.getId();
        this.userId = aiReport.getUser().getId();
        this.content = aiReport.getContent();
        this.reportDate = aiReport.getReportDate();
    }
}
