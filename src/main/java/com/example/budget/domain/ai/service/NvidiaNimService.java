package com.example.budget.domain.ai.service;

import com.example.budget.domain.ai.client.NvidiaNimClient;
import com.example.budget.domain.ai.entity.AiReportType;
import com.example.budget.domain.user.entity.PersonaType;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class NvidiaNimService {

    private final NvidiaNimClient nvidiaNimClient;

    public String generateCoachingReport(PersonaType personaType, Long budgetAmount, Long expenditureSum, String detailLogs, AiReportType reportType) {
        String typeLabel = reportType == AiReportType.DAILY ? "하루(일간)" :
                           reportType == AiReportType.WEEKLY ? "한 주(주간)" : "한 달(월간)";

        // 프롬프트 조립
        String prompt = String.format(
                "당신은 가계부의 %s 지출 내역을 분석하고 맞춤형 코칭을 제공하는 AI 조언자입니다.\n" +
                "현재 설정된 페르소나는 [%s] 입니다. 이 페르소나에 맞춰 말투와 어조를 강하게 적용하여 코칭해 주세요.\n\n" +
                "※ 재정 정보\n" +
                "- 이번 달 전체 목표 예산: %d원\n" +
                "- 분석 기간 내의 총 지출: %d원\n" +
                "- 분석 기간 상세 지출 내역:\n%s\n\n" +
                "※ 답변 작성 시 준수사항:\n" +
                "1. 모바일 앱 화면에서 보여줄 텍스트이므로 가독성이 극대화되어야 합니다.\n" +
                "2. ### 나 ** 같은 마크다운 기호를 너무 남발하지 마세요. (마크다운 파싱을 위한 간단한 표시로 한 문단에 2~3회 이내로만 사용)\n" +
                "3. 가독성을 위해 문단 사이 줄바꿈을 넉넉히 하고, 친절한 번호 매기기 리스트를 활용해 요점을 정리해 주세요.\n" +
                "4. 텍스트 본문에 유저가 즉시 직관적으로 인지할 수 있는 해시태그를 최소 2개 이상 포함시켜 주세요. (예: #식비폭발, #절약왕, #커피과다 등)\n" +
                "5. 목표 예산 대비 지출 현황을 냉철히(혹은 페르소나 성격에 맞게 친근하게) 파악하여 현실적인 절약 팁을 제시하세요.",
                typeLabel, personaType.name(), budgetAmount, expenditureSum, detailLogs
        );

        return nvidiaNimClient.callNvidiaNim(prompt);
    }
}
