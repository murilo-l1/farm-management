export interface CategoryExpenseDto {
  category_name: string
  color: string | null
  total: number
  percentage: number
}

export interface CycleBudgetDto {
  crop_cycle_id: number
  crop_cycle_name: string
  planned_budget: number
  current_investment: number
  investment_expected: boolean
  target_yield: number
  current_revenue: number
  revenue_expected: boolean | null
}

export type CashFlowPeriod = 'THREE_MONTHS' | 'SIX_MONTHS' | 'TWELVE_MONTHS' | 'ALL'

export interface MonthlyCashFlowDto {
  month: string
  income: number
  expense: number
}
