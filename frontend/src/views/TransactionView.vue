<template>
  <div class="transaction-view">
    <!-- Header -->
    <AppHeaderBar title="Financeiro" subtitle="Controle de receitas e despesas da propriedade" />

    <!-- Summary cards -->
    <div class="summary-grid">
      <div class="summary-card">
        <div class="summary-card__icon summary-card__icon--cashflow">
          <span class="material-symbols-outlined">account_balance_wallet</span>
        </div>
        <div class="summary-card__body">
          <span class="summary-card__label">Saldo</span>
          <Skeleton v-if="loading" height="2rem" width="7rem" class="summary-card__skeleton" />
          <span v-else class="summary-card__value" :class="cashFlowClass">
            {{ formatCurrency(summary?.total_cash_flow) }}
          </span>
        </div>
      </div>

      <div class="summary-card">
        <div class="summary-card__icon summary-card__icon--income">
          <span class="material-symbols-outlined">south</span>
        </div>
        <div class="summary-card__body">
          <span class="summary-card__label">Entradas</span>
          <Skeleton v-if="loading" height="2rem" width="7rem" class="summary-card__skeleton" />
          <span v-else class="summary-card__value summary-card__value--positive">
            {{ formatCurrency(summary?.total_income) }}
          </span>
        </div>
      </div>

      <div class="summary-card">
        <div class="summary-card__icon summary-card__icon--expense">
          <span class="material-symbols-outlined">north</span>
        </div>
        <div class="summary-card__body">
          <span class="summary-card__label">Saídas</span>
          <Skeleton v-if="loading" height="2rem" width="7rem" class="summary-card__skeleton" />
          <span v-else class="summary-card__value summary-card__value--negative">
            {{ formatCurrency(summary?.total_expense) }}
          </span>
        </div>
      </div>
    </div>

    <!-- Drawer -->
    <Drawer
      v-model:visible="drawerOpen"
      position="right"
      :header="drawerHeader"
      style="width: 56rem"
    >
      <div v-if="drawerLoading && !editInitialData" class="drawer-loading">
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="40%" />
      </div>
      <TransactionForm
        v-else
        :initial-data="editInitialData"
        :loading="drawerLoading"
        :mode="drawerMode"
        @submit="handleSave"
        @cancel="drawerOpen = false"
      />
    </Drawer>

    <!-- Table -->
    <AppDataTable
      ref="tableRef"
      :value="transactions"
      :loading="loading"
      :global-filter-fields="['description', 'crop_cycle_name', 'stakeholder_name', 'category_name']"
      :row-class-fn="rowClassFn"
      :expanded-rows="expandedRows"
      @update:expanded-rows="expandedRows = $event"
      search-placeholder="Buscar por descrição, safra, parceiro ou categoria"
      @edit="handleEdit"
      @delete="handleDelete"
    >
      <template #actions>
        <AppButton icon="pi pi-external-link" label="Exportar CSV" severity="secondary" outlined @click="tableRef?.exportCSV()" />
        <AppButton icon="pi pi-plus" label="Nova Transação" @click="handleAdd" />
      </template>
      <template #filters>
        <Select
          v-model="filterType"
          :options="typeOptions"
          option-label="label"
          option-value="value"
          placeholder="Tipo"
          show-clear
          class="filter-select"
        />
        <DatePicker
          v-model="filterDate"
          placeholder="Data a partir de"
          show-button-bar
          date-format="dd/mm/yy"
          show-icon
          icon-display="input"
          class="filter-datepicker"
        />
        <Select
          v-model="filterCropCycleId"
          :options="cropCycleOptions"
          option-label="name"
          option-value="id"
          placeholder="Safra"
          show-clear
          class="filter-select filter-select--wide"
        />
        <Select
          v-model="filterStatus"
          :options="statusOptions"
          option-label="label"
          option-value="value"
          placeholder="Status"
          show-clear
          class="filter-select"
        />
      </template>

      <template #columns="{ loading }">
        <Column expander style="width: 3rem; padding: 0" />

        <Column field="transaction_date" header="Data" style="min-width: 9rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="6rem" />
            <span v-else>{{ formatDate(data.transaction_date) }}</span>
          </template>
        </Column>

        <Column field="description" header="Descrição" style="min-width: 14rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="10rem" />
            <span v-else :class="data.description ? 'cell-description' : 'cell-empty'">
              {{ data.description ?? '—' }}
            </span>
          </template>
        </Column>

        <Column field="crop_cycle_name" header="Safra" style="min-width: 10rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="7rem" />
            <span v-else :class="data.crop_cycle_name ? '' : 'cell-empty'">
              {{ data.crop_cycle_name ?? '—' }}
            </span>
          </template>
        </Column>

        <Column field="stakeholder_name" header="Parceiro" style="min-width: 10rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="7rem" />
            <span v-else :class="data.stakeholder_name ? '' : 'cell-empty'">
              {{ data.stakeholder_name ?? '—' }}
            </span>
          </template>
        </Column>

        <Column field="category_name" header="Categoria" style="min-width: 10rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1.5rem" width="7rem" border-radius="2rem" />
            <span
              v-else-if="data.category_name"
              class="category-badge"
              :style="categoryBadgeStyle(data.category_id)"
            >{{ data.category_name }}</span>
            <span v-else class="cell-empty">—</span>
          </template>
        </Column>

        <Column field="status" header="Status" style="min-width: 9rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1.5rem" width="6rem" border-radius="2rem" />
            <span v-else class="status-badge" :style="statusStyle(data.status)">
              {{ statusLabel(data.status) }}
            </span>
          </template>
        </Column>

        <Column field="total_value" header="Valor Total" style="min-width: 10rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="7rem" />
            <span
              v-else
              class="cell-value"
              :class="data.type === 'INCOME' ? 'cell-value--income' : 'cell-value--expense'"
            >{{ formatCurrency(data.total_value) }}</span>
          </template>
        </Column>
      </template>

      <template #expansion="{ data }">
        <div v-if="data.items?.length > 0" class="expansion-panel">
          <div class="expansion-items">
            <div class="expansion-items__header">
              <span>Item</span>
              <span>Qtd.</span>
              <span>Preço unit.</span>
              <span>Total</span>
            </div>
            <div
              v-for="item in (data.items as TransactionItem[])"
              :key="item.id"
              class="expansion-items__row"
            >
              <span class="expansion-items__name">{{ item.item_name }}</span>
              <span class="expansion-items__qty">{{ item.quantity }}</span>
              <span class="expansion-items__unit">{{ formatCurrency(item.unit_price) }}</span>
              <span class="expansion-items__price">{{ formatCurrency(item.total_price) }}</span>
            </div>
          </div>
        </div>
      </template>

      <template #empty>
        <div class="empty-state">
          <span class="material-symbols-outlined empty-icon">receipt_long</span>
          <p>Nenhuma transação encontrada.</p>
        </div>
      </template>
    </AppDataTable>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import Column from 'primevue/column'
import Skeleton from 'primevue/skeleton'
import Select from 'primevue/select'
import DatePicker from 'primevue/datepicker'
import Drawer from 'primevue/drawer'
import AppButton from '@/components/AppButton.vue'
import AppHeaderBar from '@/components/AppHeaderBar.vue'
import AppDataTable from '@/components/AppDataTable.vue'
import TransactionForm from '@/form/TransactionForm.vue'
import { transactionService } from '@/services/transaction.service'
import { categoryService } from '@/services/category.service'
import { cropCycleService } from '@/services/crop-cycle.service'
import { toast } from '@/services/toast'
import type { TransactionDto, TransactionRow, TransactionSummary, TransactionType, TransactionStatus, TransactionItem, TransactionPayload } from '@/types/transaction'
import type { CropCycleOption } from '@/types/crop-cycle'

const DEFAULT_CATEGORY_COLOR = '#757575'

const tableRef = ref()
const loading = ref(false)
const transactions = ref<TransactionRow[]>([])
const summary = ref<TransactionSummary | null>(null)
const categoryColorMap = ref<Map<number, string>>(new Map())
const cropCycleOptions = ref<CropCycleOption[]>([])

const filterType = ref<TransactionType | null>(null)
const filterDate = ref<Date | null>(null)
const filterCropCycleId = ref<number | null>(null)
const filterStatus = ref<TransactionStatus | null>(null)

const expandedRows = ref<TransactionRow[]>([])

const drawerOpen = ref(false)
const drawerLoading = ref(false)
const drawerMode = ref<'create' | 'edit'>('create')
const editingId = ref<number | null>(null)
const editInitialData = ref<TransactionDto | null>(null)

const drawerHeader = computed(() =>
  drawerMode.value === 'create' ? 'Nova Transação' : (editInitialData.value?.description ?? 'Editar Transação')
)

const cashFlowClass = computed(() => {
  const v = summary.value?.total_cash_flow
  if (v == null) return ''
  return v >= 0 ? 'summary-card__value--positive' : 'summary-card__value--negative'
})

const typeOptions: { value: TransactionType; label: string }[] = [
  { value: 'INCOME',  label: 'Receita' },
  { value: 'EXPENSE', label: 'Despesa' },
]

const statusOptions: { value: TransactionStatus; label: string }[] = [
  { value: 'PENDING',   label: 'Pendente'  },
  { value: 'FINISHED',  label: 'Finalizada'      },
  { value: 'CANCELLED', label: 'Cancelada' },
]

const statusConfig: Record<TransactionStatus, { label: string; color: string; bg: string }> = {
  PENDING:   { label: 'Pendente',   color: '#f57f17', bg: '#fffde7' },
  FINISHED:  { label: 'Finalizada',       color: '#2e7d32', bg: '#e8f5e9' },
  CANCELLED: { label: 'Cancelada',  color: '#c62828', bg: '#ffebee' },
}

const PT_MONTHS = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez']

function formatDate(iso: string | null): string {
  if (!iso) return '—'
  const [y, m, d] = iso.split('-').map(Number)
  return `${String(d).padStart(2, '0')} ${PT_MONTHS[m - 1]} ${y}`
}

function formatCurrency(value: number | null | undefined): string {
  if (value == null) return '—'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value)
}

function toIsoDate(d: Date): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

function categoryBadgeStyle(categoryId: number | null) {
  const color = (categoryId != null ? categoryColorMap.value.get(categoryId) : null) ?? DEFAULT_CATEGORY_COLOR
  return { backgroundColor: `${color}26`, color }
}

function statusLabel(s: TransactionStatus): string {
  return statusConfig[s]?.label ?? s
}

function statusStyle(s: TransactionStatus) {
  const c = statusConfig[s]
  return c ? { color: c.color, backgroundColor: c.bg } : {}
}

function rowClassFn(row: TransactionRow): string {
  if (!row.type) return ''
  const typeClass = row.type === 'INCOME' ? 'row--income' : 'row--expense'
  const expandClass = row.items?.length ? '' : 'row--no-expand'
  return [typeClass, expandClass].filter(Boolean).join(' ')
}

async function loadData() {
  loading.value = true
  const page = await transactionService
    .findAll({
      type: filterType.value,
      date: filterDate.value ? toIsoDate(filterDate.value) : null,
      crop_cycle_id: filterCropCycleId.value,
      status: filterStatus.value,
    })
    .finally(() => (loading.value = false))
  summary.value = page.summary
  transactions.value = page.transactions
}

watch([filterType, filterDate, filterCropCycleId, filterStatus], loadData)

onMounted(async () => {
  const [, cats, options] = await Promise.all([
    loadData(),
    categoryService.findAll(),
    cropCycleService.findOptions(),
  ])
  categoryColorMap.value = new Map(cats.map((c) => [c.id, c.color ?? DEFAULT_CATEGORY_COLOR]))
  cropCycleOptions.value = options
})

function handleAdd() {
  drawerMode.value = 'create'
  editingId.value = null
  editInitialData.value = null
  drawerOpen.value = true
}

async function handleEdit(row: TransactionRow) {
  drawerMode.value = 'edit'
  editingId.value = row.id
  editInitialData.value = null
  drawerOpen.value = true
  drawerLoading.value = true
  editInitialData.value = await transactionService.getById(row.id).finally(() => (drawerLoading.value = false))
}

async function handleSave(payload: TransactionPayload) {
  drawerLoading.value = true
  if (drawerMode.value === 'create') {
    await transactionService.create(payload).finally(() => (drawerLoading.value = false))
    toast.success('Transação criada.')
  } else {
    await transactionService.update(editingId.value!, payload).finally(() => (drawerLoading.value = false))
    toast.success('Transação atualizada.')
  }
  drawerOpen.value = false
  await loadData()
}

async function handleDelete(id: number) {
  await transactionService.delete(id)
  transactions.value = transactions.value.filter((t) => t.id !== id)
  toast.success('Transação excluída.')
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap');

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined';
}

.transaction-view {
  --primary:            #0d631b;
  --surface:            #f9f9f9;
  --on-surface:         #1a1c1c;
  --on-surface-variant: #40493d;
  --outline-variant:    #bfcaba;
}

.transaction-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 2rem;
  gap: 1.5rem;
  background: var(--surface);
  font-family: 'Inter', sans-serif;
  overflow: hidden;
}

/* ── Summary ── */
.summary-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
  flex-shrink: 0;
}

.summary-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  background: #fff;
  border: 1px solid var(--outline-variant);
  border-radius: 1rem;
  padding: 1.25rem 1.5rem;
}

.summary-card__icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.75rem;
  height: 2.75rem;
  border-radius: 0.75rem;
  flex-shrink: 0;
}

.summary-card__icon .material-symbols-outlined { font-size: 1.375rem; }
.summary-card__icon--cashflow { background: #e3f2fd; color: #1565c0; }
.summary-card__icon--income   { background: #e8f5e9; color: #2e7d32; }
.summary-card__icon--expense  { background: #ffebee; color: #c62828; }

.summary-card__body {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  min-width: 0;
}

.summary-card__label {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--on-surface-variant);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  white-space: nowrap;
}

.summary-card__value {
  font-family: 'Manrope', sans-serif;
  font-size: 1.375rem;
  font-weight: 800;
  color: var(--on-surface);
  line-height: 1.1;
}

.summary-card__value--positive { color: #2e7d32; }
.summary-card__value--negative { color: #c62828; }
.summary-card__skeleton { margin-top: 0.125rem; }

/* ── Filters ── */
.filter-select     { width: 9rem; font-size: 0.875rem; }
.filter-select--wide { width: 12rem; }
.filter-datepicker { width: 13rem; font-size: 0.875rem; }

/* ── Table cells ── */
.cell-description { font-weight: 500; color: var(--on-surface); }
.cell-empty       { color: var(--on-surface-variant); }

.cell-value { font-weight: 600; }
.cell-value--income { color: #2e7d32; }
.cell-value--expense { color: #c62828; }

.category-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 2rem;
  font-size: 0.75rem;
  font-weight: 600;
  white-space: nowrap;
}

.status-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 2rem;
  font-size: 0.75rem;
  font-weight: 600;
  white-space: nowrap;
}

/* ── Row type indicator ── */
:deep(.app-data-table.p-datatable .p-datatable-tbody > tr.row--income) {
  border-left: 3px solid #2e7d32;
}
:deep(.app-data-table.p-datatable .p-datatable-tbody > tr.row--expense) {
  border-left: 3px solid #c62828;
}

/* ── Oculta o toggle de expansão para linhas sem itens ── */
:deep(.app-data-table.p-datatable .p-datatable-tbody > tr.row--no-expand .p-datatable-row-toggle-icon) {
  visibility: hidden;
  pointer-events: none;
}

/* ── Painel de expansão ── */
.expansion-panel {
  padding: 0.75rem 1rem 0.75rem 3.5rem;
}

.expansion-panel__title {
  font-size: 0.6875rem;
  font-weight: 700;
  color: var(--on-surface-variant);
  text-transform: uppercase;
  letter-spacing: 0.06em;
  margin: 0 0 0.5rem;
}

.expansion-items {
  display: flex;
  flex-direction: column;
  gap: 0;
  border: 1px solid #eef1eb;
  border-radius: 0.5rem;
  overflow: hidden;
  max-width: 36rem;
}

.expansion-items__header {
  display: grid;
  grid-template-columns: 1fr 6rem 8rem 8rem;
  padding: 0.375rem 0.875rem;
  background: #f5f7f5;
  font-size: 0.6875rem;
  font-weight: 700;
  color: var(--on-surface-variant);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.expansion-items__header span:not(:first-child),
.expansion-items__row > span:not(:first-child) {
  text-align: right;
}

.expansion-items__row {
  display: grid;
  grid-template-columns: 1fr 6rem 8rem 8rem;
  align-items: center;
  padding: 0.5rem 0.875rem;
  font-size: 0.8125rem;
  border-top: 1px solid #eef1eb;
}

.expansion-items__row:first-of-type {
  border-top: none;
}

.expansion-items__name {
  color: var(--on-surface);
  font-weight: 500;
}

.expansion-items__qty,
.expansion-items__unit {
  color: var(--on-surface-variant);
  font-variant-numeric: tabular-nums;
}

.expansion-items__price {
  color: #c62828;
  font-weight: 600;
  font-variant-numeric: tabular-nums;
}

/* ── Drawer skeleton ── */
.drawer-loading { padding: 1.5rem; display: flex; flex-direction: column; }
.mb-3 { margin-bottom: 1rem; }

/* ── Empty state ── */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 1rem;
  gap: 0.75rem;
  color: var(--on-surface-variant);
}

.empty-icon {
  font-size: 2.5rem;
  font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 48;
  opacity: 0.5;
}
</style>
