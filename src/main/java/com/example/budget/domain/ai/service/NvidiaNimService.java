package com.example.budget.domain.ai.service;

import com.example.budget.domain.ai.client.NvidiaNimClient;
import com.example.budget.domain.user.entity.PersonaType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NvidiaNimService {

    private final NvidiaNimClient nvidiaNimClient;

    public String generateCoachingReport(PersonaType personaType, Long budgetAmount, Long expenditureSum, String detailLogs) {
        // 프롬프트 조립
        String prompt = String.format(
                "당신은 가계부의 지출 내역을 분석하고 코칭해 주는 AI 조언자입니다. " +
                "현재 설정된 페르소나는 [%s] 입니다. 이 페르소나에 맞춰 말투와 어조를 다르게 해야 합니다.\n" +
                "이번 달 목표 예산: %d원\n" +
                "현재까지의 총 지출: %d원\n" +
                "상세 지출 내역:\n%s\n" +
                "목표 예산 대비 지출 현황을 파악하여 적절한 조언을 해 주세요.",
                personaType.name(), budgetAmount, expenditureSum, detailLogs
        );

        return nvidiaNimClient.callNvidiaNim(prompt);
    }
}
