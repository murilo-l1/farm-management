<template>
  <div class="crop-cycle-view">
    <!-- Header -->
    <AppHeaderBar title="Safras" subtitle="Gerencie os ciclos de cultivo da sua propriedade" />

    <!-- Summary cards -->
    <div class="summary-grid">
      <div class="summary-card">
        <div class="summary-card__icon summary-card__icon--active">
          <span class="material-symbols-outlined">potted_plant</span>
        </div>
        <div class="summary-card__body">
          <span class="summary-card__label">Safras Ativas</span>
          <Skeleton v-if="loading" height="2rem" width="4rem" class="summary-card__skeleton" />
          <span v-else class="summary-card__value">{{ summary?.active_cycles_count ?? 0 }}</span>
        </div>
      </div>

      <div class="summary-card">
        <div class="summary-card__icon summary-card__icon--progress">
          <span class="material-symbols-outlined">trending_up</span>
        </div>
        <div class="summary-card__body">
          <span class="summary-card__label">Progresso Médio</span>
          <Skeleton v-if="loading" height="2rem" width="5rem" class="summary-card__skeleton" />
          <span v-else class="summary-card__value">{{ formatPercent(summary?.average_progress) }}</span>
        </div>
      </div>

      <div class="summary-card">
        <div class="summary-card__icon summary-card__icon--roi">
          <span class="material-symbols-outlined">payments</span>
        </div>
        <div class="summary-card__body">
          <span class="summary-card__label">ROI Médio</span>
          <Skeleton v-if="loading" height="2rem" width="5rem" class="summary-card__skeleton" />
          <span
            v-else
            class="summary-card__value"
            :class="roiClass(summary?.average_roi)"
          >{{ formatPercent(summary?.average_roi) }}</span>
        </div>
      </div>
    </div>

    <!-- Edit Drawer -->
    <Drawer
      v-model:visible="drawerOpen"
      position="right"
      :header="drawerHeader"
      style="width: 38rem"
    >
      <div v-if="drawerLoading && !editInitialData" class="drawer-loading">
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="40%" />
      </div>
      <CropCycleForm
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
      :value="cropCycles"
      :loading="loading"
      :global-filter-fields="['name', 'crop']"
      search-placeholder="Buscar por safra ou cultura"
      @edit="handleEdit"
      @delete="handleDelete"
    >
      <template #actions>
        <AppButton icon="pi pi-external-link" label="Exportar CSV" severity="secondary" outlined @click="tableRef.exportCSV()" />
        <AppButton icon="pi pi-plus" label="Nova Safra" @click="handleAdd" />
      </template>
      <template #filters>
        <Select
          v-model="filterStatus"
          :options="statusOptions"
          option-label="label"
          option-value="value"
          placeholder="Status"
          show-clear
          class="filter-select"
        />
        <DatePicker
          v-model="filterDate"
          placeholder="Início a partir de"
          show-button-bar
          date-format="dd/mm/yy"
          show-icon
          icon-display="input"
          class="filter-datepicker"
        />
      </template>

      <template #columns="{ loading }">
        <Column field="name" header="Safra" style="min-width: 12rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="9rem" />
            <span v-else class="cell-name">{{ data.name }}</span>
          </template>
        </Column>

        <Column field="crop" header="Cultura" style="min-width: 8rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="6rem" />
            <span v-else>{{ data.crop }}</span>
          </template>
        </Column>

        <Column header="Área" style="min-width: 8rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="5rem" />
            <span v-else>{{ formatArea(data.planted_area || data.plant_count, data.measurement_unit) }}</span>
          </template>
        </Column>

        <Column field="status" header="Status" style="min-width: 9rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1.5rem" width="7rem" border-radius="2rem" />
            <span v-else class="status-badge" :style="statusStyle(data.status)">
              {{ statusLabel(data.status) }}
            </span>
          </template>
        </Column>

        <Column field="planned_budget" header="Orçamento (R$)" style="min-width: 10rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="7rem" />
            <span v-else>{{ formatCurrency(data.planned_budget) }}</span>
          </template>
        </Column>

        <Column field="target_yield" header="Ganho Esperado (R$)" style="min-width: 11rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="7rem" />
            <span v-else>{{ formatCurrency(data.target_yield) }}</span>
          </template>
        </Column>

        <Column field="progress_percentage" header="Progresso" style="min-width: 10rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="2.25rem" width="100%" />
            <div v-else class="progress-cell">
              <span class="progress-label">{{ data.progress_percentage ?? 0 }}%</span>
              <div class="progress-track">
                <div
                  class="progress-fill"
                  :style="{ width: `${Math.min(data.progress_percentage ?? 0, 100)}%` }"
                />
              </div>
            </div>
          </template>
        </Column>
      </template>

      <template #empty>
        <div class="empty-state">
          <span class="material-symbols-outlined empty-icon">potted_plant</span>
          <p>Nenhuma safra encontrada.</p>
        </div>
      </template>
    </AppDataTable>
  </div>
</template>

<script setup lang="ts">
import { ref, watch, computed, onMounted } from 'vue'
import Column from 'primevue/column'
import Skeleton from 'primevue/skeleton'
import Select from 'primevue/select'
import DatePicker from 'primevue/datepicker'
import Drawer from 'primevue/drawer'
import AppButton from '@/components/AppButton.vue'
import AppHeaderBar from '@/components/AppHeaderBar.vue'
import AppDataTable from '@/components/AppDataTable.vue'
import { cropCycleService } from '@/services/crop-cycle.service'
import { toast } from '@/services/toast'
import CropCycleForm from '@/form/CropCycleForm.vue'
import type { CropCycleDto, CropCycleRow, CropCyclePayload, CropCycleSummary, CropCycleStatus, MeasurementUnit } from '@/types/crop-cycle'

const tableRef = ref()
const loading = ref(false)
const cropCycles = ref<CropCycleRow[]>([])
const summary = ref<CropCycleSummary | null>(null)

const filterStatus = ref<CropCycleStatus | null>(null)
const filterDate = ref<Date | null>(null)

const drawerOpen = ref(false)
const drawerLoading = ref(false)
const drawerMode = ref<'create' | 'edit'>('edit')
const editingId = ref<number | null>(null)
const editInitialData = ref<CropCycleDto | null>(null)

const drawerHeader = computed(() =>
  drawerMode.value === 'create'
    ? 'Nova Safra'
    : (editInitialData.value?.name ?? 'Editando Safra')
)

const statusOptions: { value: CropCycleStatus; label: string }[] = [
  { value: 'PLANNING',   label: 'Planejamento' },
  { value: 'ACTIVE',     label: 'Ativo'        },
  { value: 'PLANTING',   label: 'Plantio'      },
  { value: 'HARVESTING', label: 'Colheita'     },
  { value: 'FINISHED',   label: 'Finalizado'   },
  { value: 'CANCELLED',  label: 'Cancelado'    },
]

const statusConfig: Record<CropCycleStatus, { label: string; color: string; bg: string }> = {
  PLANNING:   { label: 'Planejamento', color: '#1565c0', bg: '#e3f2fd' },
  ACTIVE:     { label: 'Ativo',        color: '#2e7d32', bg: '#e8f5e9' },
  PLANTING:   { label: 'Plantio',      color: '#e65100', bg: '#fff3e0' },
  HARVESTING: { label: 'Colheita',     color: '#f57f17', bg: '#fffde7' },
  FINISHED:   { label: 'Finalizado',   color: '#546e7a', bg: '#eceff1' },
  CANCELLED:  { label: 'Cancelado',    color: '#c62828', bg: '#ffebee' },
}

function statusLabel(s: CropCycleStatus) { return statusConfig[s]?.label ?? s }
function statusStyle(s: CropCycleStatus) {
  const c = statusConfig[s]
  return c ? { color: c.color, backgroundColor: c.bg } : {}
}

function formatCurrency(value: number | null): string {
  if (value == null) return '—'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value)
}

const measurementUnitLabel: Record<MeasurementUnit, string> = {
  PES: 'pés', HECTARE: 'ha', METRO_QUADRADO: 'm²', ALQUEIRE: 'alqueires',
}

function formatArea(area: number | null, unit: MeasurementUnit | null): string {
  if (area == null) return '—'
  const label = unit ? measurementUnitLabel[unit] : ''
  return label ? `${area} ${label}` : String(area)
}

function formatPercent(value: number | null | undefined): string {
  if (value == null) return '—'
  return `${Number(value).toFixed(2)}%`
}

function roiClass(value: number | null | undefined): string {
  if (value == null) return ''
  return value >= 0 ? 'summary-card__value--positive' : 'summary-card__value--negative'
}

function toIsoDate(d: Date): string {
  return d.toISOString().split('T')[0]
}

async function loadData() {
  loading.value = true
  const page = await cropCycleService
    .findAll({ status: filterStatus.value, date: filterDate.value ? toIsoDate(filterDate.value) : null })
    .finally(() => (loading.value = false))
  summary.value = page.summary
  cropCycles.value = page.cycles
}

watch([filterStatus, filterDate], loadData)
onMounted(loadData)

function handleAdd() {
  drawerMode.value = 'create'
  editingId.value = null
  editInitialData.value = null
  drawerOpen.value = true
}

async function handleEdit(row: CropCycleRow) {
  drawerMode.value = 'edit'
  editingId.value = row.id
  editInitialData.value = null
  drawerOpen.value = true
  drawerLoading.value = true
  editInitialData.value = await cropCycleService.getById(row.id).finally(() => (drawerLoading.value = false))
}

async function handleSave(payload: CropCyclePayload) {
  drawerLoading.value = true
  if (drawerMode.value === 'create') {
    await cropCycleService.create(payload).finally(() => (drawerLoading.value = false))
    toast.success('Safra criada.')
  } else {
    await cropCycleService.update(editingId.value!, payload).finally(() => (drawerLoading.value = false))
    toast.success('Safra atualizada.')
  }
  drawerOpen.value = false
  await loadData()
}

async function handleDelete(id: number) {
  await cropCycleService.delete(id)
  cropCycles.value = cropCycles.value.filter((c) => c.id !== id)
  toast.success('Safra excluída.')
}
</script>

<style scoped>
.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined';
}

.crop-cycle-view {
  --primary:            #0d631b;
  --primary-container:  #2e7d32;
  --surface:            #f9f9f9;
  --on-surface:         #1a1c1c;
  --on-surface-variant: #40493d;
  --outline-variant:    #bfcaba;
}

.crop-cycle-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 2rem;
  gap: 1.5rem;
  background: var(--surface);
  font-family: 'Inter', sans-serif;
  overflow: hidden;
}

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
.summary-card__icon--active  { background: #e8f5e9; color: #2e7d32; }
.summary-card__icon--progress { background: #e3f2fd; color: #1565c0; }
.summary-card__icon--roi     { background: #fff3e0; color: #e65100; }

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
  font-size: 1.5rem;
  font-weight: 800;
  color: var(--on-surface);
  line-height: 1.1;
}

.summary-card__value--positive { color: #2e7d32; }
.summary-card__value--negative { color: #c62828; }
.summary-card__skeleton { margin-top: 0.125rem; }

.filter-select     { width: 10rem; font-size: 0.875rem; }
.filter-datepicker { width: 13rem; font-size: 0.875rem; }

.status-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 2rem;
  font-size: 0.75rem;
  font-weight: 600;
  white-space: nowrap;
}

.progress-cell { display: flex; flex-direction: column; gap: 0.25rem; }

.progress-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--on-surface);
}

.progress-track {
  height: 6px;
  background: #e0e7db;
  border-radius: 99px;
  overflow: hidden;
  width: 100%;
}

.progress-fill {
  height: 100%;
  background: var(--primary);
  border-radius: 99px;
  transition: width 0.3s ease;
}

.cell-name { font-weight: 600; color: var(--on-surface); }

.drawer-loading { padding: 1.5rem; display: flex; flex-direction: column; }
.mb-3 { margin-bottom: 1rem; }

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
