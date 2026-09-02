<template>
  <div class="table-card">
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
            <button class="action-btn action-btn--delete" title="Excluir" @click.stop="emit('delete', data[dataKey])">
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
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import DataTable from 'primevue/datatable'
import Column from 'primevue/column'
import IconField from 'primevue/iconfield'
import InputIcon from 'primevue/inputicon'
import InputText from 'primevue/inputtext'
import { FilterMatchMode } from '@primevue/core/api'
import { toIsoDate } from '@/utils/format'

interface Props {
  value: any[]
  loading: boolean
  dataKey?: string
  globalFilterFields: string[]
  searchPlaceholder?: string
  rowClassFn?: (row: any) => string
  exportFilename?: string
  expandedRows?: any[]
}

const props = withDefaults(defineProps<Props>(), {
  dataKey: 'id',
  searchPlaceholder: 'Buscar...',
  exportFilename: 'export',
})

const emit = defineEmits<{
  edit: [row: any]
  delete: [id: any]
  'update:expandedRows': [rows: any[]]
}>()

const dt = ref()
const selectedRow = ref<any>(null)
const skeletonRows = Array(7).fill({})

// Computed para a data ser resolvida no momento do export, não na montagem.
// O PrimeVue acrescenta a extensão .csv sozinho.
const resolvedExportFilename = computed(() => `${props.exportFilename}_${toIsoDate(new Date())}`)

const filters = ref({ global: { value: null as string | null, matchMode: FilterMatchMode.CONTAINS } })

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

function exportCSV() {
  dt.value.exportCSV()
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

.action-btn--edit:hover {
  background: #e3f2fd;
  color: #1565c0;
}

.action-btn--delete:hover {
  background: #ffebee;
  color: #c62828;
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
</style>
