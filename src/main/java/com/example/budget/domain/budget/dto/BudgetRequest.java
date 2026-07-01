package com.example.budget.domain.budget.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class BudgetRequest {

    @NotNull(message = "사용자 ID는 필수입니다.")
    private Long userId;

    @NotNull(message = "예산 금액은 필수입니다.")
    @Min(value = 0, message = "예산 금액은 0원 이상이어야 합니다.")
    private Long amount;

    @NotNull(message = "연도는 필수입니다.")
    private Integer year;

    @NotNull(message = "월은 필수입니다.")
    @Min(value = 1, message = "월은 1부터 12 사이여야 합니다.")
    @Max(value = 12, message = "월은 1부터 12 사이여야 합니다.")
    private Integer month;
}
