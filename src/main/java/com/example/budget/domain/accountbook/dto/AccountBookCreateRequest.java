package com.example.budget.domain.accountbook.dto;

import com.example.budget.domain.accountbook.entity.TransactionType;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;
import java.time.LocalDate;

@Getter
@Setter
public class AccountBookCreateRequest {

    @NotNull(message = "사용자 ID는 필수입니다.")
    private Long userId;

    @NotNull(message = "금액은 필수입니다.")
    @Min(value = 0, message = "금액은 0원 이상이어야 합니다.")
    private Long amount;

    @NotBlank(message = "카테고리는 필수입니다.")
    private String category;

    @NotBlank(message = "내용은 필수입니다.")
    private String content;

    @NotNull(message = "거래 날짜는 필수입니다.")
    private LocalDate transactionDate;

    @NotNull(message = "거래 유형(수입/지출)은 필수입니다.")
    private TransactionType transactionType;
}
