package com.dev.farmmanager.usecase.dashboard;

import com.dev.farmmanager.domain.dto.dashboard.CategoryExpenseDto;
import com.dev.farmmanager.domain.dto.dashboard.CycleBudgetDto;
import com.dev.farmmanager.domain.dto.dashboard.MonthlyCashFlowDto;
import com.dev.farmmanager.domain.enumeration.CashFlowPeriod;
import org.springframework.http.ResponseEntity;

import java.util.List;

public interface DashboardFetch {
    ResponseEntity<List<CategoryExpenseDto>> getExpensesByCategory();
    ResponseEntity<List<CycleBudgetDto>> getCycleBudgets();
    ResponseEntity<List<MonthlyCashFlowDto>> getCashFlow(CashFlowPeriod period);
}
