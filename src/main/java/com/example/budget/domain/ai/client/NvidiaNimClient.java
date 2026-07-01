package com.example.budget.domain.ai.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
public class NvidiaNimClient {

    private final RestClient restClient;

    @Value("${nvidia.nim.api-key:default_key}")
    private String apiKey;

    public NvidiaNimClient() {
        this.restClient = RestClient.builder()
                .baseUrl("https://integrate.api.nvidia.com/v1") // NVIDIA NIM 기본 URL 예시
                .build();
    }

    public String callNvidiaNim(String prompt) {
        // 실제 API 호출 로직 뼈대 작성
        // HTTP 요청 헤더에 Authorization Bearer API_KEY 등을 세팅하여 호출할 예정입니다.
        try {
            /* 예시 코드:
            Map<String, Object> body = Map.of(
                "model", "meta/llama3-70b-instruct",
                "messages", List.of(Map.of("role", "user", "content", prompt))
            );
            return restClient.post()
                    .uri("/chat/completions")
                    .header("Authorization", "Bearer " + apiKey)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(String.class);
            */
            return "NVIDIA NIM API 호출 성공 피드백 예시 (가상 리포트 내용): 가상 스레드 환경에서 작성된 맞춤형 분석 보고서입니다. 예산을 초과하지 않도록 주의하세요!";
        } catch (Exception e) {
            throw new RuntimeException("NVIDIA NIM API 호출에 실패했습니다: " + e.getMessage(), e);
        }
    }
}
