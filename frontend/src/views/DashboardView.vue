<template>
  <div class="dashboard-view">
    <AppHeaderBar title="Dashboard" subtitle="Visão geral da sua propriedade" />

    <div class="charts-grid">

      <!-- Gastos por Categoria -->
      <div class="chart-card chart-card--pie">
        <div class="chart-card__header">
          <span class="material-symbols-outlined chart-icon">donut_large</span>
          <div>
            <h2 class="chart-card__title">Gastos por Categoria</h2>
            <p class="chart-card__sub">Distribuição das despesas registradas</p>
          </div>
        </div>

        <div v-if="expensesLoading" class="chart-skeleton">
          <Skeleton shape="circle" size="14rem" class="pie-skeleton" />
          <div class="legend-skeleton">
            <div v-for="i in 4" :key="i" class="legend-skeleton__row">
              <Skeleton shape="circle" size="0.75rem" />
              <Skeleton height="0.75rem" width="8rem" />
            </div>
          </div>
        </div>

        <div v-else-if="expenses.length === 0" class="chart-empty">
          <span class="material-symbols-outlined empty-icon">receipt_long</span>
          <p>Nenhuma despesa registrada ainda.</p>
        </div>

        <Chart
          v-else
          type="doughnut"
          :data="pieData"
          :options="pieOptions"
          class="pie-chart"
        />
      </div>

      <!-- Orçamento vs. Investimento por Safra -->
      <div class="chart-card chart-card--bar">
        <div class="chart-card__header">
          <span class="material-symbols-outlined chart-icon">bar_chart</span>
          <div class="chart-card__header-text">
            <h2 class="chart-card__title">Desempenho por Safra</h2>
            <p class="chart-card__sub">Últimas 6 safras com orçamento definido</p>
          </div>
          <div class="bar-mode-switch">
            <button
              class="mode-btn"
              :class="{ 'mode-btn--active': barMode === 'EXPENSE' }"
              @click="barMode = 'EXPENSE'"
            >Despesas</button>
            <button
              class="mode-btn"
              :class="{ 'mode-btn--active': barMode === 'INCOME' }"
              @click="barMode = 'INCOME'"
            >Receitas</button>
          </div>
        </div>

        <div v-if="cyclesLoading" class="chart-skeleton chart-skeleton--bar">
          <div class="bar-skeleton-row" v-for="i in 4" :key="i">
            <Skeleton height="1rem" width="5rem" />
            <Skeleton height="6rem" width="100%" />
          </div>
        </div>

        <div v-else-if="cycles.length === 0" class="chart-empty">
          <span class="material-symbols-outlined empty-icon">agriculture</span>
          <p>Nenhuma safra com orçamento registrada.</p>
        </div>

        <Chart
          v-else
          type="bar"
          :data="barData"
          :options="barOptions"
          class="bar-chart"
        />

        <div v-if="!cyclesLoading && cycles.length > 0" class="custom-bar-legend">
          <div class="custom-legend-item">
            <span class="legend-dot" style="background: #1565c0" />
            <span>{{ barMode === 'EXPENSE' ? 'Orçamento Planejado' : 'Receita Esperada' }}</span>
          </div>

          <div
            class="custom-legend-item custom-legend-item--hoverable"
            @mouseenter="showBarTooltip = true"
            @mouseleave="showBarTooltip = false"
          >
            <span class="legend-dot legend-dot--split" />
            <span>{{ barMode === 'EXPENSE' ? 'Investimento Realizado' : 'Receita Obtida' }}</span>
            <div v-show="showBarTooltip" class="legend-dialog">
              <div class="legend-dialog__row">
                <span class="legend-dot-sm legend-dot-sm--green" />
                <span>{{ barMode === 'EXPENSE'
                  ? 'Investimento Realizado menor que o planejado.'
                  : 'Receita Obtida maior que a desejada.' }}</span>
              </div>
              <div class="legend-dialog__row">
                <span class="legend-dot-sm legend-dot-sm--red" />
                <span>{{ barMode === 'EXPENSE'
                  ? 'Investimento Realizado ultrapassa o planejado.'
                  : 'Receita Obtida menor que a desejada.' }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- Fluxo de Caixa Mensal -->
    <div class="cashflow-section">
      <div class="chart-card chart-card--line">
        <div class="chart-card__header">
          <span class="material-symbols-outlined chart-icon">show_chart</span>
          <div class="chart-card__header-text">
            <h2 class="chart-card__title">Fluxo de Caixa Mensal</h2>
            <p class="chart-card__sub">Receitas e despesas por mês</p>
          </div>
          <div class="bar-mode-switch">
            <button
              v-for="opt in PERIOD_OPTIONS"
              :key="opt.value"
              class="mode-btn"
              :class="{ 'mode-btn--active': cashFlowPeriod === opt.value }"
              @click="cashFlowPeriod = opt.value"
            >{{ opt.label }}</button>
          </div>
        </div>

        <div v-if="cashFlowLoading" class="chart-skeleton chart-skeleton--bar">
          <div class="bar-skeleton-row" v-for="i in 4" :key="i">
            <Skeleton height="1rem" width="5rem" />
            <Skeleton height="6rem" width="100%" />
          </div>
        </div>

        <div v-else-if="cashFlow.length === 0" class="chart-empty">
          <span class="material-symbols-outlined empty-icon">show_chart</span>
          <p>Nenhuma transação encontrada para o período.</p>
        </div>

        <Chart
          v-else
          type="line"
          :data="lineData"
          :options="lineOptions"
          class="line-chart"
        />
      </div>
    </div>

  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import Chart from 'primevue/chart'
import Skeleton from 'primevue/skeleton'
import AppHeaderBar from '@/components/AppHeaderBar.vue'
import { dashboardService } from '@/services/dashboard.service'
import type { CategoryExpenseDto, CashFlowPeriod, CycleBudgetDto, MonthlyCashFlowDto } from '@/types/dashboard'

type BarMode = 'EXPENSE' | 'INCOME'

const COLOR_BLUE  = '#1565c0'
const COLOR_GREEN = '#2e7d32'
const COLOR_RED   = '#c62828'
const COLOR_GREY  = '#757575'
const DEFAULT_COLOR = '#757575'

// --- Pie chart state ---
const expensesLoading = ref(false)
const expenses = ref<CategoryExpenseDto[]>([])

// --- Bar chart state ---
const cyclesLoading = ref(false)
const cycles = ref<CycleBudgetDto[]>([])
const barMode = ref<BarMode>('EXPENSE')
const showBarTooltip = ref(false)

// --- Line chart state ---
const cashFlowPeriod = ref<CashFlowPeriod>('TWELVE_MONTHS')
const cashFlow = ref<MonthlyCashFlowDto[]>([])
const cashFlowLoading = ref(false)

const PERIOD_OPTIONS: { label: string; value: CashFlowPeriod }[] = [
  { label: '3M',  value: 'THREE_MONTHS' },
  { label: '6M',  value: 'SIX_MONTHS' },
  { label: '12M', value: 'TWELVE_MONTHS' },
  { label: 'Todo Período', value: 'ALL' },
]

function loadCashFlow() {
  cashFlowLoading.value = true
  dashboardService
    .getCashFlow(cashFlowPeriod.value)
    .then((d) => (cashFlow.value = d))
    .finally(() => (cashFlowLoading.value = false))
}

watch(cashFlowPeriod, loadCashFlow)

// -1 sentinel → 0 so the bar area still exists for hover/tooltip
function val(v: number): number {
  return v === -1 ? 0 : v
}

// --- Pie computed ---
const pieData = computed(() => ({
  labels: expenses.value.map((e) => e.category_name),
  datasets: [
    {
      data: expenses.value.map((e) => e.total),
      backgroundColor: expenses.value.map((e) => e.color ?? DEFAULT_COLOR),
      borderColor: expenses.value.map((e) => e.color ?? DEFAULT_COLOR),
      borderWidth: 2,
      hoverOffset: 8,
    },
  ],
}))

const pieOptions = computed(() => ({
  responsive: true,
  maintainAspectRatio: false,
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        font: { family: 'Inter', size: 12 },
        color: '#40493d',
        padding: 16,
        usePointStyle: true,
        pointStyleWidth: 10,
      },
    },
    tooltip: {
      callbacks: {
        label: (ctx: any) => {
          const item = expenses.value[ctx.dataIndex]
          const valor = item.total.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
          return `  ${item.category_name}: ${valor} (${item.percentage}%)`
        },
      },
    },
  },
}))

// --- Bar computed ---
const sortedCycles = computed(() => cycles.value.slice().reverse())

const barData = computed(() => {
  const labels = sortedCycles.value.map((c) => c.crop_cycle_name)

  if (barMode.value === 'EXPENSE') {
    const investmentColors = sortedCycles.value.map((c) =>
      c.investment_expected ? COLOR_GREEN : COLOR_RED
    )
    return {
      labels,
      datasets: [
        {
          label: 'Orçamento Planejado',
          data: sortedCycles.value.map((c) => val(c.planned_budget)),
          backgroundColor: COLOR_BLUE,
          borderRadius: 4,
        },
        {
          label: 'Investimento Realizado',
          data: sortedCycles.value.map((c) => val(c.current_investment)),
          backgroundColor: investmentColors,
          borderRadius: 4,
        },
      ],
    }
  }

  // INCOME mode
  const revenueColors = sortedCycles.value.map((c) => {
    if (c.revenue_expected === null) return COLOR_GREY
    return c.revenue_expected ? COLOR_GREEN : COLOR_RED
  })
  return {
    labels,
    datasets: [
      {
        label: 'Receita Esperada',
        data: sortedCycles.value.map((c) => val(c.target_yield)),
        backgroundColor: COLOR_BLUE,
        borderRadius: 4,
      },
      {
        label: 'Receita Obtida',
        data: sortedCycles.value.map((c) => val(c.current_revenue)),
        backgroundColor: revenueColors,
        borderRadius: 4,
      },
    ],
  }
})

const barOptions = computed(() => ({
  responsive: true,
  maintainAspectRatio: false,
  interaction: {
    mode: 'index',
    intersect: false,
  },
  scales: {
    x: {
      ticks: {
        font: { family: 'Inter', size: 11 },
        color: '#40493d',
        maxRotation: 30,
      },
      grid: { display: false },
    },
    y: {
      beginAtZero: true,
      ticks: {
        stepSize: 5000,
        font: { family: 'Inter', size: 11 },
        color: '#40493d',
        callback: (v: any) =>
          `R$ ${Number(v).toLocaleString('pt-BR', { maximumFractionDigits: 0 })}`,
      },
      grid: { color: '#bfcaba44' },
    },
  },
  plugins: {
    legend: { display: false },
    tooltip: {
      callbacks: {
        label: (ctx: any) => {
          const cycle = sortedCycles.value[ctx.dataIndex]
          if (!cycle) return ''

          let original: number
          let name: string

          if (barMode.value === 'EXPENSE') {
            if (ctx.datasetIndex === 0) { original = cycle.planned_budget;     name = 'Orçamento Planejado' }
            else                        { original = cycle.current_investment;  name = 'Investimento Realizado' }
          } else {
            if (ctx.datasetIndex === 0) { original = cycle.target_yield;        name = 'Receita Esperada' }
            else                        { original = cycle.current_revenue;     name = 'Receita Obtida' }
          }

          if (original <= 0) return `  ${name}: não foi calculado(a).`

          const brl = original.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
          return `  ${name}: ${brl}`
        },
      },
    },
  },
}))

function formatMonth(ym: string): string {
  const [year, month] = ym.split('-').map(Number)
  return new Date(year, month - 1).toLocaleDateString('pt-BR', { month: 'short', year: '2-digit' })
}

const lineData = computed(() => ({
  labels: cashFlow.value.map((m) => formatMonth(m.month)),
  datasets: [
    {
      label: 'Receitas',
      data: cashFlow.value.map((m) => m.income),
      borderColor: '#2e7d32',
      backgroundColor: '#2e7d3220',
      fill: true,
      tension: 0.35,
      pointRadius: 3,
      pointHoverRadius: 5,
    },
    {
      label: 'Despesas',
      data: cashFlow.value.map((m) => m.expense),
      borderColor: '#c62828',
      backgroundColor: '#c6282820',
      fill: true,
      tension: 0.35,
      pointRadius: 3,
      pointHoverRadius: 5,
    },
  ],
}))

const lineOptions = computed(() => ({
  responsive: true,
  maintainAspectRatio: false,
  interaction: { mode: 'index', intersect: false },
  scales: {
    x: {
      ticks: { font: { family: 'Inter', size: 11 }, color: '#40493d' },
      grid: { display: false },
    },
    y: {
      beginAtZero: true,
      ticks: {
        font: { family: 'Inter', size: 11 },
        color: '#40493d',
        callback: (v: any) =>
          `R$ ${Number(v).toLocaleString('pt-BR', { maximumFractionDigits: 0 })}`,
      },
      grid: { color: '#bfcaba44' },
    },
  },
  plugins: {
    legend: {
      position: 'bottom',
      labels: {
        font: { family: 'Inter', size: 12 },
        color: '#40493d',
        usePointStyle: true,
        pointStyleWidth: 8,
        padding: 16,
      },
    },
    tooltip: {
      callbacks: {
        label: (ctx: any) => {
          const brl = (ctx.raw as number).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' })
          return `  ${ctx.dataset.label}: ${brl}`
        },
      },
    },
  },
}))

onMounted(() => {
  expensesLoading.value = true
  cyclesLoading.value = true
  cashFlowLoading.value = true
  Promise.all([
    dashboardService
      .getExpensesByCategory()
      .then((d) => (expenses.value = d))
      .finally(() => (expensesLoading.value = false)),
    dashboardService
      .getCycleBudgets()
      .then((d) => (cycles.value = d))
      .finally(() => (cyclesLoading.value = false)),
    dashboardService
      .getCashFlow(cashFlowPeriod.value)
      .then((d) => (cashFlow.value = d))
      .finally(() => (cashFlowLoading.value = false)),
  ])
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap');

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined';
}

.dashboard-view {
  --primary:            #0d631b;
  --surface:            #f9f9f9;
  --on-surface:         #1a1c1c;
  --on-surface-variant: #40493d;
  --outline-variant:    #bfcaba;
}

.dashboard-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 2rem;
  gap: 1.5rem;
  background: var(--surface);
  font-family: 'Inter', sans-serif;
  overflow-y: auto;
}

/* ── Grid ─────────────────────────────── */
.charts-grid {
  display: flex;
  gap: 1.25rem;
  align-items: stretch;
  flex-wrap: wrap;
}

/* ── Cards ────────────────────────────── */
.chart-card {
  background: #ffffff;
  border: 1px solid var(--outline-variant);
  border-radius: 1rem;
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.chart-card--pie {
  width: 26rem;
  flex-shrink: 0;
}

.chart-card--bar {
  flex: 1;
  min-width: 24rem;
}

/* ── Card header ──────────────────────── */
.chart-card__header {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.chart-card__header-text { flex: 1; }

.chart-icon {
  font-size: 1.5rem;
  color: var(--primary);
  font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  flex-shrink: 0;
}

.chart-card__title {
  font-family: 'Manrope', sans-serif;
  font-size: 1rem;
  font-weight: 700;
  color: var(--on-surface);
  margin: 0;
}

.chart-card__sub {
  font-size: 0.75rem;
  color: var(--on-surface-variant);
  margin: 0.125rem 0 0;
}

/* ── Mode switch ──────────────────────── */
.bar-mode-switch {
  display: flex;
  border: 1px solid var(--outline-variant);
  border-radius: 0.5rem;
  overflow: hidden;
  flex-shrink: 0;
}

.mode-btn {
  padding: 0.3rem 0.75rem;
  white-space: nowrap;
  font-family: 'Inter', sans-serif;
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--on-surface-variant);
  background: transparent;
  border: none;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
}

.mode-btn + .mode-btn {
  border-left: 1px solid var(--outline-variant);
}

.mode-btn--active {
  background: var(--primary);
  color: #ffffff;
}

/* ── Charts ───────────────────────────── */
.pie-chart { flex: 1; min-height: 0; }
.bar-chart  { height: 20rem; }

/* ── Skeletons ────────────────────────── */
.chart-skeleton {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1.5rem;
  padding: 1rem 0;
}

.chart-skeleton--bar {
  align-items: flex-start;
  gap: 1rem;
}

.pie-skeleton { opacity: 0.6; }

.legend-skeleton {
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
  width: 100%;
}

.legend-skeleton__row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.bar-skeleton-row {
  display: flex;
  align-items: flex-end;
  gap: 0.5rem;
  width: 100%;
}

/* ── Empty state ──────────────────────── */
.chart-empty {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 1rem;
  gap: 0.75rem;
  color: var(--on-surface-variant);
  font-size: 0.875rem;
}

.empty-icon {
  font-size: 2.5rem;
  font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 48;
  opacity: 0.5;
}

/* ── Custom bar legend ────────────────── */
.custom-bar-legend {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 1.5rem;
  flex-wrap: wrap;
  padding-top: 0.25rem;
}

.custom-legend-item {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.75rem;
  color: #40493d;
  font-family: 'Inter', sans-serif;
}

.custom-legend-item--hoverable {
  position: relative;
  cursor: default;
  user-select: none;
}

.legend-dot {
  width: 10px;
  height: 10px;
  border-radius: 50%;
  flex-shrink: 0;
  display: inline-block;
}

.legend-dot--split {
  background: linear-gradient(to right, #2e7d32 50%, #c62828 50%);
}

.legend-dialog {
  position: absolute;
  bottom: calc(100% + 8px);
  left: 50%;
  transform: translateX(-50%);
  background: #1a1c1c;
  color: #ffffff;
  border-radius: 0.5rem;
  padding: 0.625rem 0.875rem;
  font-size: 0.75rem;
  line-height: 1.5;
  white-space: nowrap;
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  z-index: 10;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.25);
  pointer-events: none;
}

.legend-dialog::after {
  content: '';
  position: absolute;
  top: 100%;
  left: 50%;
  transform: translateX(-50%);
  border: 5px solid transparent;
  border-top-color: #1a1c1c;
}

.legend-dialog__row {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.legend-dot-sm {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  flex-shrink: 0;
  display: inline-block;
}

.legend-dot-sm--green { background: #2e7d32; }
.legend-dot-sm--red   { background: #c62828; }

/* ── Cash flow section ────────────────── */
.cashflow-section {
  width: 100%;
}

.chart-card--line {
  width: 100%;
}

.line-chart { height: 22rem; }
</style>
