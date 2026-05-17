package com.dev.farmmanager.controller;

import com.dev.farmmanager.controller.base.BaseController;
import com.dev.farmmanager.domain.dto.dashboard.CategoryExpenseDto;
import com.dev.farmmanager.domain.dto.dashboard.CycleBudgetDto;
import com.dev.farmmanager.domain.dto.dashboard.MonthlyCashFlowDto;
import com.dev.farmmanager.domain.enumeration.CashFlowPeriod;
import com.dev.farmmanager.usecase.dashboard.DashboardFetch;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController("DashboardController")
@RequestMapping(value = "/api/farm/dashboard", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
public class DashboardController extends BaseController {

    private final DashboardFetch fetch;

    @GetMapping("/expenses")
    public ResponseEntity<List<CategoryExpenseDto>> getExpensesByCategory() {
        return fetch.getExpensesByCategory();
    }

    @GetMapping("/cycles")
    public ResponseEntity<List<CycleBudgetDto>> getCycleBudgets() {
        return fetch.getCycleBudgets();
    }

    @GetMapping("/cash-flow")
    public ResponseEntity<List<MonthlyCashFlowDto>> getCashFlow(
            @RequestParam(required = false, defaultValue = "TWELVE_MONTHS") CashFlowPeriod period) {
        return fetch.getCashFlow(period);
    }
}
