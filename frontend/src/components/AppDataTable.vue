<template>
  <div v-if="!showCards" class="table-card">
    <DataTable
      ref="dt"
      :value="loading ? skeletonRows : value"
      paginator
      :rows="10"
      :rows-per-page-options="[5, 10, 25, 50]"
      v-model:filters="filters"
      :global-filter-fields="globalFilterFields"
      v-model:selection="selectedRow"
      selection-mode="single"
      :meta-key-selection="false"
      :data-key="dataKey"
      :row-class="rowClass"
      :export-filename="resolvedExportFilename"
      :expanded-rows="expandedRows ?? []"
      @update:expanded-rows="emit('update:expandedRows', $event)"
      class="app-data-table"
    >
      <template #header>
        <div class="table-header">
          <div class="table-header__left">
            <slot name="actions" />
          </div>
          <div class="table-header__right">
            <slot name="filters" />
            <IconField>
              <InputIcon><i class="pi pi-search" /></InputIcon>
              <InputText v-model="filters['global'].value" :placeholder="searchPlaceholder" />
            </IconField>
          </div>
        </div>
      </template>

      <slot name="columns" :loading="loading" />

      <Column header="" :exportable="false" style="width: 6rem; text-align: right">
        <template #body="{ data }">
          <div v-if="!loading" class="action-cell">
            <button class="action-btn action-btn--edit" title="Editar" @click.stop="emit('edit', data)">
              <span class="material-symbols-outlined">edit</span>
            </button>
            <button class="action-btn action-btn--delete" title="Excluir" @click.stop="requestDelete(data)">
              <span class="material-symbols-outlined">delete</span>
            </button>
          </div>
        </template>
      </Column>

      <template v-if="$slots.expansion" #expansion="slotData">
        <slot name="expansion" v-bind="slotData" />
      </template>

      <template #empty>
        <slot name="empty">
          <div class="empty-state">
            <span class="material-symbols-outlined empty-icon">table_rows</span>
            <p>Nenhum registro encontrado.</p>
          </div>
        </slot>
      </template>
    </DataTable>
  </div>

  <div v-else class="card-listing">
    <div class="mobile-toolbar">
      <div v-if="$slots.actions" class="mobile-toolbar__actions">
        <slot name="actions" />
      </div>
      <div class="mobile-toolbar__search">
        <IconField class="mobile-toolbar__search-field">
          <InputIcon><i class="pi pi-search" /></InputIcon>
          <InputText v-model="filters['global'].value" :placeholder="searchPlaceholder" fluid />
        </IconField>
        <Button
          v-if="$slots.filters"
          icon="pi pi-filter"
          severity="secondary"
          outlined
          aria-label="Filtros"
          class="mobile-toolbar__filter-btn"
          :badge="activeFilterCount ? String(activeFilterCount) : undefined"
          badge-severity="success"
          @click="filtersOpen = true"
        />
      </div>
    </div>

    <DataView
      :value="loading ? skeletonRows : filteredValue"
      :data-key="loading ? undefined : dataKey"
      paginator
      :rows="10"
      :always-show-paginator="false"
      paginator-template="PrevPageLink CurrentPageReport NextPageLink"
      current-page-report-template="{currentPage} de {totalPages}"
      class="app-data-view"
    >
      <template #list="{ items }">
        <div class="card-list">
          <article
            v-for="(row, index) in items"
            :key="loading ? index : row[dataKey]"
            class="data-card"
            :class="loading ? '' : (rowClassFn?.(row) ?? '')"
            @click="!loading && emit('edit', row)"
          >
            <div class="data-card__body">
              <slot name="card" :data="row" :loading="loading" />
            </div>
            <div v-if="!loading" class="data-card__actions">
              <button type="button" class="card-action card-action--edit" @click.stop="emit('edit', row)">
                <span class="material-symbols-outlined">edit</span>
                <span>Editar</span>
              </button>
              <button type="button" class="card-action card-action--delete" @click.stop="requestDelete(row)">
                <span class="material-symbols-outlined">delete</span>
                <span>Excluir</span>
              </button>
            </div>
          </article>
        </div>
      </template>

      <template #empty>
        <slot name="empty">
          <div class="empty-state">
            <span class="material-symbols-outlined empty-icon">table_rows</span>
            <p>Nenhum registro encontrado.</p>
          </div>
        </slot>
      </template>
    </DataView>

    <Drawer
      v-if="$slots.filters"
      v-model:visible="filtersOpen"
      position="bottom"
      header="Filtros"
      class="filters-drawer"
    >
      <div class="filters-drawer__body">
        <slot name="filters" />
      </div>
      <template #footer>
        <Button label="Ver resultados" fluid class="app-btn" @click="filtersOpen = false" />
      </template>
    </Drawer>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, useSlots, watch } from 'vue'
import DataTable from 'primevue/datatable'
import DataView from 'primevue/dataview'
import Column from 'primevue/column'
import Drawer from 'primevue/drawer'
import Button from 'primevue/button'
import IconField from 'primevue/iconfield'
import InputIcon from 'primevue/inputicon'
import InputText from 'primevue/inputtext'
import { FilterMatchMode } from '@primevue/core/api'
import { useConfirm } from 'primevue/useconfirm'
import { toIsoDate } from '@/utils/format'
import { useBreakpoint } from '@/composables/useBreakpoint'

interface Props {
  value: any[]
  loading: boolean
  dataKey?: string
  globalFilterFields: string[]
  searchPlaceholder?: string
  rowClassFn?: (row: any) => string
  exportFilename?: string
  expandedRows?: any[]
  activeFilterCount?: number
}

const props = withDefaults(defineProps<Props>(), {
  dataKey: 'id',
  searchPlaceholder: 'Buscar...',
  exportFilename: 'export',
  activeFilterCount: 0,
})

const emit = defineEmits<{
  edit: [row: any]
  delete: [id: any]
  'update:expandedRows': [rows: any[]]
}>()

const slots = useSlots()
const confirm = useConfirm()
const { isMobile } = useBreakpoint()

const showCards = computed(() => isMobile.value && !!slots.card)

const dt = ref()
const selectedRow = ref<any>(null)
const filtersOpen = ref(false)
const skeletonRows = Array(7).fill({})

// Computed para a data ser resolvida no momento do export, não na montagem.
// O PrimeVue acrescenta a extensão .csv sozinho.
const resolvedExportFilename = computed(() => `${props.exportFilename}_${toIsoDate(new Date())}`)

const filters = ref({ global: { value: null as string | null, matchMode: FilterMatchMode.CONTAINS } })

function normalize(text: unknown): string {
  return String(text ?? '').normalize('NFD').replace(/\p{Diacritic}/gu, '').toLowerCase()
}

// o DataView não tem filtro global, então a busca dos cards é feita aqui
const filteredValue = computed(() => {
  const term = normalize(filters.value.global.value).trim()
  if (!term) return props.value
  return props.value.filter((row) =>
    props.globalFilterFields.some((field) => normalize(row[field]).includes(term))
  )
})

watch(() => props.value, (newValue) => {
  if (selectedRow.value && !newValue.find((r) => r[props.dataKey] === selectedRow.value[props.dataKey])) {
    selectedRow.value = null
  }
})

function rowClass(row: any) {
  const selected = selectedRow.value?.[props.dataKey] === row[props.dataKey] ? 'row--selected' : ''
  const extra = props.rowClassFn ? props.rowClassFn(row) : ''
  return [selected, extra].filter(Boolean).join(' ')
}

function requestDelete(row: any) {
  confirm.require({
    header: 'Excluir registro?',
    message: 'Esta ação não pode ser desfeita.',
    icon: 'pi pi-exclamation-triangle',
    rejectProps: { label: 'Cancelar', severity: 'secondary', outlined: true },
    acceptProps: { label: 'Excluir', severity: 'danger' },
    accept: () => emit('delete', row[props.dataKey]),
  })
}

function exportCSV() {
  dt.value?.exportCSV()
}

defineExpose({ exportCSV })
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap');

.app-data-table.p-datatable .p-datatable-thead > tr > th {
  background: #f5f7f5;
  color: #40493d;
  font-family: 'Inter', sans-serif;
  font-size: 0.75rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  border-bottom: 1px solid #dde5d8;
  padding: 0.75rem 1rem;
}

.app-data-table.p-datatable .p-datatable-tbody > tr > td {
  font-family: 'Inter', sans-serif;
  font-size: 0.875rem;
  color: #1a1c1c;
  border-bottom: 1px solid #eef1eb;
  padding: 0.875rem 1rem;
  vertical-align: middle;
}

.app-data-table.p-datatable .p-datatable-tbody > tr:hover > td {
  background: #f5f7f5;
}

.app-data-table.p-datatable .p-datatable-tbody > tr.row--selected > td {
  background: #e8f5e9;
}

.app-data-table.p-datatable .p-datatable-tbody > tr.p-highlight > td {
  background: #e8f5e9 !important;
  color: #1a1c1c !important;
}

/* o Drawer é renderizado no body, por isso esses estilos não são scoped */
.filters-drawer.p-drawer {
  height: auto;
  max-height: 85dvh;
  border-radius: 1rem 1rem 0 0;
}

.filters-drawer .p-drawer-footer {
  padding-bottom: calc(1.25rem + env(safe-area-inset-bottom));
}

.app-data-view.p-dataview {
  background: transparent;
}

.app-data-view .p-dataview-content {
  background: transparent;
}

.app-data-view .p-paginator {
  background: transparent;
  padding: 0.75rem 0 0;
}

.app-data-view .p-paginator .p-paginator-prev,
.app-data-view .p-paginator .p-paginator-next {
  min-width: 2.75rem;
  height: 2.75rem;
}
</style>

<style scoped>
.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined';
}

.table-card {
  flex: 1;
  background: #fff;
  border: 1px solid #bfcaba;
  border-radius: 1rem;
  overflow: auto;
  display: flex;
  flex-direction: column;
  min-height: 0;
}

:deep(.app-data-table) {
  height: 100%;
}

:deep(.app-data-table .p-datatable-wrapper) {
  flex: 1;
}

.table-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.625rem;
  padding: 0.75rem 1rem;
}

.table-header__left,
.table-header__right {
  display: flex;
  align-items: center;
  gap: 0.625rem;
}

.action-cell {
  display: flex;
  gap: 0.375rem;
  justify-content: flex-end;
}

.action-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2rem;
  height: 2rem;
  border-radius: 0.5rem;
  border: none;
  background: transparent;
  cursor: pointer;
  transition: background 0.15s, color 0.15s;
  color: #40493d;
}

.action-btn .material-symbols-outlined {
  font-size: 1.1rem;
}

@media (hover: hover) {
  .action-btn--edit:hover {
    background: #e3f2fd;
    color: #1565c0;
  }

  .action-btn--delete:hover {
    background: #ffebee;
    color: #c62828;
  }
}

@media (pointer: coarse) {
  .action-btn {
    width: 2.75rem;
    height: 2.75rem;
  }
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 3rem 1rem;
  gap: 0.75rem;
  color: #40493d;
}

.empty-icon {
  font-size: 2.5rem;
  font-variation-settings: 'FILL' 0, 'wght' 300, 'GRAD' 0, 'opsz' 48;
  opacity: 0.5;
}

.card-listing {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  font-family: 'Inter', sans-serif;
}

.mobile-toolbar {
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
}

.mobile-toolbar__actions {
  display: flex;
  gap: 0.5rem;
}

.mobile-toolbar__actions :deep(.p-button) {
  flex: 1;
  min-height: 2.75rem;
}

.mobile-toolbar__search {
  display: flex;
  gap: 0.5rem;
}

.mobile-toolbar__search-field {
  flex: 1;
  min-width: 0;
}

.mobile-toolbar__search-field :deep(.p-inputtext) {
  min-height: 2.75rem;
  background: #fff;
}

.mobile-toolbar__filter-btn {
  width: 2.75rem;
  height: 2.75rem;
  flex-shrink: 0;
  background: #fff;
  overflow: visible;
}

.card-list {
  display: flex;
  flex-direction: column;
  gap: 0.625rem;
}

.data-card {
  background: #fff;
  border: 1px solid #bfcaba;
  border-radius: 1rem;
  overflow: hidden;
  cursor: pointer;
  -webkit-tap-highlight-color: transparent;
  transition: background 0.15s;
}

.data-card:active {
  background: #f5f7f5;
}

.data-card__body {
  padding: 0.875rem 1rem;
}

.data-card__actions {
  display: flex;
  border-top: 1px solid #eef1eb;
}

.card-action {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.375rem;
  min-height: 2.75rem;
  border: none;
  background: transparent;
  font-family: 'Inter', sans-serif;
  font-size: 0.8125rem;
  font-weight: 600;
  color: #40493d;
  cursor: pointer;
}

.card-action + .card-action {
  border-left: 1px solid #eef1eb;
}

.card-action .material-symbols-outlined {
  font-size: 1.125rem;
}

.card-action--edit:active {
  background: #e3f2fd;
  color: #1565c0;
}

.card-action--delete {
  color: #c62828;
}

.card-action--delete:active {
  background: #ffebee;
}

.filters-drawer__body {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.filters-drawer__body :deep(.p-select),
.filters-drawer__body :deep(.p-datepicker) {
  width: 100%;
}
</style>
