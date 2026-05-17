package com.dev.farmmanager.usecase.dashboard;

import com.dev.farmmanager.domain.dto.dashboard.CategoryExpenseDto;
import com.dev.farmmanager.domain.dto.dashboard.CycleBudgetDto;
import com.dev.farmmanager.domain.dto.dashboard.MonthlyCashFlowDto;
import com.dev.farmmanager.domain.enumeration.CashFlowPeriod;
import com.dev.farmmanager.domain.projection.CategoryExpenseProjection;
import com.dev.farmmanager.domain.projection.CycleBudgetProjection;
import com.dev.farmmanager.domain.projection.MonthlyCashFlowProjection;
import com.dev.farmmanager.repository.DashboardRepository;
import com.dev.farmmanager.security.SecurityUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service("DashboardFetch")
@RequiredArgsConstructor
public class DashboardFetchImpl implements DashboardFetch {

    private final DashboardRepository repository;

    @Override
    @Transactional(readOnly = true)
    public ResponseEntity<List<CategoryExpenseDto>> getExpensesByCategory() {
        Integer userId = SecurityUtils.getCurrentUserId();
        List<CategoryExpenseDto> result = repository.findExpensesByCategory(userId)
                .stream()
                .map(p -> new CategoryExpenseDto(
                        p.getCategoryName(),
                        p.getColor(),
                        p.getTotal(),
                        p.getPercentage()))
                .toList();
        return ResponseEntity.ok(result);
    }

    @Override
    @Transactional(readOnly = true)
    public ResponseEntity<List<CycleBudgetDto>> getCycleBudgets() {
        Integer userId = SecurityUtils.getCurrentUserId();
        List<CycleBudgetDto> result = repository.findCycleBudgets(userId)
                .stream()
                .map(p -> new CycleBudgetDto(
                        p.getCropCycleId(),
                        p.getCropCycleName(),
                        p.getPlannedBudget(),
                        p.getCurrentInvestment(),
                        p.getInvestmentExpected(),
                        p.getTargetYield(),
                        p.getCurrentRevenue(),
                        p.getRevenueExpected()))
                .toList();
        return ResponseEntity.ok(result);
    }

    @Override
    @Transactional(readOnly = true)
    public ResponseEntity<List<MonthlyCashFlowDto>> getCashFlow(CashFlowPeriod period) {
        Integer userId = SecurityUtils.getCurrentUserId();

        List<MonthlyCashFlowProjection> raw;
        YearMonth start;
        YearMonth end = YearMonth.now();

        if (period == CashFlowPeriod.ALL) {
            raw = repository.findAllMonthlyCashFlow(userId);
            start = raw.isEmpty()
                    ? end
                    : YearMonth.parse(raw.getFirst().getMonth());
        } else {
            int months = switch (period) {
                case THREE_MONTHS -> 3;
                case SIX_MONTHS   -> 6;
                default           -> 12;
            };
            LocalDate cutoff = LocalDate.now()
                    .minusMonths(months - 1L)
                    .withDayOfMonth(1);
            raw = repository.findMonthlyCashFlow(userId, cutoff);
            start = YearMonth.from(cutoff);
        }

        Map<String, MonthlyCashFlowProjection> byMonth = raw.stream()
                .collect(Collectors.toMap(MonthlyCashFlowProjection::getMonth, p -> p));

        List<MonthlyCashFlowDto> result = new ArrayList<>();
        YearMonth cursor = start;
        while (!cursor.isAfter(end)) {
            String key = cursor.toString();
            MonthlyCashFlowProjection p = byMonth.get(key);
            result.add(p != null
                    ? new MonthlyCashFlowDto(key, p.getIncome(), p.getExpense())
                    : new MonthlyCashFlowDto(key, BigDecimal.ZERO, BigDecimal.ZERO));
            cursor = cursor.plusMonths(1);
        }

        return ResponseEntity.ok(result);
    }
}
