package com.dev.farmmanager.domain.dto.dashboard;

import java.math.BigDecimal;

public record MonthlyCashFlowDto(
        String month,
        BigDecimal income,
        BigDecimal expense
) {}
