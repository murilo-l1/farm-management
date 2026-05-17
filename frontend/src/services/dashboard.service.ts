import http from '@/api/http'
import type { CategoryExpenseDto, CashFlowPeriod, CycleBudgetDto, MonthlyCashFlowDto } from '@/types/dashboard'

export const dashboardService = {
  getExpensesByCategory: () =>
    http.get<CategoryExpenseDto[]>('/farm/dashboard/expenses').then((r) => r.data),

  getCycleBudgets: () =>
    http.get<CycleBudgetDto[]>('/farm/dashboard/cycles').then((r) => r.data),

  getCashFlow: (period: CashFlowPeriod) =>
    http.get<MonthlyCashFlowDto[]>('/farm/dashboard/cash-flow', { params: { period } }).then((r) => r.data),
}
