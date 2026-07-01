package com.example.budget.domain.ai.client;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import java.util.List;
import java.util.Map;

@Component
public class NvidiaNimClient {

    private final RestClient restClient;

    @Value("${nvidia.nim.api-key}")
    private String apiKey;

    @Value("${nvidia.nim.model}")
    private String modelName;

    public NvidiaNimClient() {
        this.restClient = RestClient.builder()
                .baseUrl("https://integrate.api.nvidia.com/v1")
                .build();
    }

    @SuppressWarnings("unchecked")
    public String callNvidiaNim(String prompt) {
        // OpenAI 호환 NVIDIA NIM Chat Completion API 요청 바디 조립
        Map<String, Object> body = Map.of(
            "model", modelName,
            "messages", List.of(Map.of("role", "user", "content", prompt)),
            "temperature", 1.0,
            "top_p", 0.95,
            "max_tokens", 16384,
            "chat_template_kwargs", Map.of("enable_thinking", true),
            "reasoning_budget", 16384
        );

        try {
            Map<String, Object> response = restClient.post()
                    .uri("/chat/completions")
                    .header("Authorization", "Bearer " + apiKey)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(body)
                    .retrieve()
                    .body(Map.class);

            if (response != null && response.containsKey("choices")) {
                List<Map<String, Object>> choices = (List<Map<String, Object>>) response.get("choices");
                if (!choices.isEmpty()) {
                    Map<String, Object> choice = choices.get(0);
                    Map<String, Object> message = (Map<String, Object>) choice.get("message");
                    if (message != null) {
                        String content = (String) message.get("content");
                        String reasoningContent = (String) message.get("reasoning_content");
                        
                        // reasoning_content가 존재한다면 최종 보고서와 함께 병합하여 반환하거나
                        // 기호에 맞게 가공할 수 있습니다. 여기서는 두 내용을 합쳐서 반환합니다.
                        if (reasoningContent != null && !reasoningContent.isBlank()) {
                            return "[AI 생각 과정]\n" + reasoningContent + "\n\n[최종 AI 분석 리포트]\n" + content;
                        }
                        return content;
                    }
                }
            }
            throw new RuntimeException("API 응답 형식이 올바르지 않습니다.");
        } catch (Exception e) {
            throw new RuntimeException("NVIDIA NIM API 호출 중 오류가 발생했습니다: " + e.getMessage(), e);
        }
    }
}
