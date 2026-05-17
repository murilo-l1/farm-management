package com.dev.farmmanager.repository;

import com.dev.farmmanager.domain.entity.Transaction;
import com.dev.farmmanager.domain.projection.CategoryExpenseProjection;
import com.dev.farmmanager.domain.projection.CycleBudgetProjection;
import com.dev.farmmanager.domain.projection.MonthlyCashFlowProjection;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;

import java.util.List;

@Repository
public interface DashboardRepository extends JpaRepository<Transaction, Integer> {

    @Query(value = """
            WITH base AS (
                SELECT c.name  AS category_name,
                       c.color AS color,
                       t.total_value
                FROM transaction t
                JOIN category c ON c.id = t.category_id
                WHERE t.user_id = :userId AND t.type = 'EXPENSE'

                UNION ALL

                SELECT COALESCE(c.name, 'Sem Categoria') AS category_name,
                       c.color                            AS color,
                       ti.total_price                     AS total_value
                FROM transaction t
                JOIN transaction_item ti ON ti.transaction_id = t.id
                JOIN item i              ON i.id = ti.item_id
                LEFT JOIN category c     ON c.id = i.category_id
                WHERE t.user_id = :userId AND t.type = 'EXPENSE' AND t.category_id IS NULL

                UNION ALL

                SELECT 'Sem Categoria' AS category_name,
                       NULL            AS color,
                       t.total_value
                FROM transaction t
                WHERE t.user_id = :userId AND t.type = 'EXPENSE' AND t.category_id IS NULL
                  AND NOT EXISTS (
                      SELECT 1 FROM transaction_item ti
                      JOIN item i ON i.id = ti.item_id
                      WHERE ti.transaction_id = t.id AND i.category_id IS NOT NULL
                  )
            )
            SELECT
                COALESCE(category_name, 'Sem Categoria') AS category_name,
                color,
                SUM(total_value) AS total,
                ROUND(SUM(total_value) * 100.0 / SUM(SUM(total_value)) OVER (), 2) AS percentage
            FROM base
            GROUP BY COALESCE(category_name, 'Sem Categoria'), color
            ORDER BY total DESC
            """, nativeQuery = true)
    List<CategoryExpenseProjection> findExpensesByCategory(@Param("userId") Integer userId);

    @Query(value = """
            SELECT
                cc.id                                                              AS crop_cycle_id,
                cc.name                                                            AS crop_cycle_name,
                COALESCE(cc.planned_budget,      -1)                               AS planned_budget,
                COALESCE(ccc.current_investment, -1)                               AS current_investment,
                (COALESCE(ccc.current_investment, 0) <= cc.planned_budget)         AS investment_expected,
                COALESCE(cc.target_yield,        -1)                               AS target_yield,
                COALESCE(ccc.current_revenue,    -1)                               AS current_revenue,
                CASE WHEN cc.target_yield IS NOT NULL
                     THEN (COALESCE(ccc.current_revenue, 0) >= cc.target_yield)
                     ELSE NULL END                                                 AS revenue_expected
            FROM crop_cycle cc
            JOIN crop_cycle_control ccc ON ccc.crop_cycle_id = cc.id
            WHERE cc.user_id = :userId AND cc.planned_budget IS NOT NULL
            ORDER BY cc.start_date DESC
            LIMIT 6
            """, nativeQuery = true)
    List<CycleBudgetProjection> findCycleBudgets(@Param("userId") Integer userId);

    @Query(value = """
            SELECT
                TO_CHAR(DATE_TRUNC('month', transaction_date), 'YYYY-MM') AS month,
                SUM(CASE WHEN type = 'INCOME'  THEN total_value ELSE 0 END) AS income,
                SUM(CASE WHEN type = 'EXPENSE' THEN total_value ELSE 0 END) AS expense
            FROM transaction
            WHERE user_id = :userId
              AND transaction_date >= :cutoff
            GROUP BY DATE_TRUNC('month', transaction_date)
            ORDER BY DATE_TRUNC('month', transaction_date)
            """, nativeQuery = true)
    List<MonthlyCashFlowProjection> findMonthlyCashFlow(
            @Param("userId") Integer userId,
            @Param("cutoff") LocalDate cutoff);

    @Query(value = """
            SELECT
                TO_CHAR(DATE_TRUNC('month', transaction_date), 'YYYY-MM') AS month,
                SUM(CASE WHEN type = 'INCOME'  THEN total_value ELSE 0 END) AS income,
                SUM(CASE WHEN type = 'EXPENSE' THEN total_value ELSE 0 END) AS expense
            FROM transaction
            WHERE user_id = :userId
            GROUP BY DATE_TRUNC('month', transaction_date)
            ORDER BY DATE_TRUNC('month', transaction_date)
            """, nativeQuery = true)
    List<MonthlyCashFlowProjection> findAllMonthlyCashFlow(@Param("userId") Integer userId);

}
