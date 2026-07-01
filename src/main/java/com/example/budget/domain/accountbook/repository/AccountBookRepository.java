package com.example.budget.domain.accountbook.repository;

import com.example.budget.domain.accountbook.entity.AccountBook;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDate;
import java.util.List;

public interface AccountBookRepository extends JpaRepository<AccountBook, Long> {

    List<AccountBook> findByUserIdAndTransactionDateBetween(Long userId, LocalDate startDate, LocalDate endDate);

    @Query("SELECT a.category, SUM(a.amount) FROM AccountBook a " +
           "WHERE a.user.id = :userId AND a.transactionDate BETWEEN :startDate AND :endDate " +
           "GROUP BY a.category")
    List<Object[]> findCategorySumByUserIdAndDateBetween(
            @Param("userId") Long userId,
            @Param("startDate") LocalDate startDate,
            @Param("endDate") LocalDate endDate
    );
}
