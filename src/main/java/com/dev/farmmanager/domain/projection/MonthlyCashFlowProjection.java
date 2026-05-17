package com.dev.farmmanager.domain.projection;

import java.math.BigDecimal;

public interface MonthlyCashFlowProjection {
    String getMonth();
    BigDecimal getIncome();
    BigDecimal getExpense();
}
