<template>
  <div class="stakeholder-view">
    <!-- Header -->
    <AppHeaderBar title="Parceiros" subtitle="Gerencie fornecedores e compradores da sua propriedade" />

    <!-- Edit Drawer -->
    <AppFormDrawer
      v-model:visible="drawerOpen"
      :header="drawerHeader"
      :show-skeleton="drawerLoading && !editInitialData"
    >
      <StakeholderForm
        :initial-data="editInitialData"
        :loading="drawerLoading"
        :mode="drawerMode"
        @submit="handleSave"
        @cancel="drawerOpen = false"
      />
    </AppFormDrawer>

    <!-- Table -->
    <AppDataTable
      ref="tableRef"
      export-filename="parceiros"
      :value="stakeholders"
      :loading="loading"
      :global-filter-fields="['name', 'cpf', 'cnpj', 'phone']"
      search-placeholder="Buscar por nome, CPF, CNPJ ou telefone"
      @edit="handleEdit"
      @delete="handleDelete"
    >
      <template #actions>
        <AppButton icon="pi pi-external-link" label="Exportar CSV" severity="secondary" outlined :disabled="loading" class="hidden md:inline-flex" @click="tableRef.exportCSV()" />
        <AppButton icon="pi pi-plus" label="Novo Parceiro" @click="handleAdd" />
      </template>
      <template #columns="{ loading }">
        <Column field="name" header="Nome" style="min-width: 14rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="10rem" />
            <span v-else class="cell-name">{{ data.name }}</span>
          </template>
        </Column>

        <Column field="type" header="Tipo" style="min-width: 8rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="6rem" />
            <span v-else>{{ data.type ? typeLabel(data.type) : '—' }}</span>
          </template>
        </Column>

        <Column field="cpf" header="CPF" style="min-width: 10rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="8rem" />
            <span v-else>{{ data.cpf ? formatCpf(data.cpf) : '—' }}</span>
          </template>
        </Column>

        <Column field="cnpj" header="CNPJ" style="min-width: 12rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="9rem" />
            <span v-else>{{ data.cnpj ? formatCnpj(data.cnpj) : '—' }}</span>
          </template>
        </Column>

        <Column field="phone" header="Telefone" style="min-width: 9rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="7rem" />
            <span v-else>{{ data.phone ? formatPhone(data.phone) : '—' }}</span>
          </template>
        </Column>
      </template>

      <template #card="{ data, loading }">
        <template v-if="loading">
          <Skeleton height="1rem" width="60%" class="card-skeleton" />
          <Skeleton height="0.875rem" width="45%" />
        </template>
        <template v-else>
          <div class="card-row">
            <span class="cell-name">{{ data.name }}</span>
            <span v-if="data.type" class="type-chip">{{ typeLabel(data.type) }}</span>
          </div>
          <p v-if="data.cpf || data.cnpj" class="card-meta">
            {{ data.cnpj ? `CNPJ ${formatCnpj(data.cnpj)}` : `CPF ${formatCpf(data.cpf)}` }}
          </p>
          <a
            v-if="data.phone"
            :href="`tel:${data.phone}`"
            class="card-phone"
            @click.stop
          >
            <span class="material-symbols-outlined">call</span>
            {{ formatPhone(data.phone) }}
          </a>
        </template>
      </template>

      <template #empty>
        <div class="empty-state">
          <span class="material-symbols-outlined empty-icon">handshake</span>
          <p>Nenhum parceiro encontrado.</p>
        </div>
      </template>
    </AppDataTable>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import Column from 'primevue/column'
import Skeleton from 'primevue/skeleton'
import AppButton from '@/components/AppButton.vue'
import AppHeaderBar from '@/components/AppHeaderBar.vue'
import AppDataTable from '@/components/AppDataTable.vue'
import AppFormDrawer from '@/components/AppFormDrawer.vue'
import StakeholderForm from '@/form/StakeholderForm.vue'
import { stakeholderService } from '@/services/stakeholder.service'
import { toast } from '@/services/toast'
import { formatPhone, formatCpf, formatCnpj } from '@/utils/format'
import type { StakeholderDto, StakeholderPayload, StakeholderType } from '@/types/stakeholder'

const TYPE_LABELS: Record<StakeholderType, string> = {
  SUPPLIER: 'Fornecedor',
  BUYER:    'Comprador',
  BOTH:     'Ambos',
}

function typeLabel(type: StakeholderType): string {
  return TYPE_LABELS[type] ?? type
}

const tableRef = ref()
const loading = ref(false)
const stakeholders = ref<StakeholderDto[]>([])

const drawerOpen = ref(false)
const drawerLoading = ref(false)
const drawerMode = ref<'create' | 'edit'>('edit')
const editingId = ref<number | null>(null)
const editInitialData = ref<StakeholderDto | null>(null)

const drawerHeader = computed(() =>
  drawerMode.value === 'create'
    ? 'Novo Parceiro'
    : (editInitialData.value?.name ?? 'Editando Parceiro')
)

async function loadData() {
  loading.value = true
  stakeholders.value = await stakeholderService.findAll().finally(() => (loading.value = false))
}

onMounted(loadData)

function handleAdd() {
  drawerMode.value = 'create'
  editingId.value = null
  editInitialData.value = null
  drawerOpen.value = true
}

async function handleEdit(row: StakeholderDto) {
  drawerMode.value = 'edit'
  editingId.value = row.id
  editInitialData.value = null
  drawerOpen.value = true
  drawerLoading.value = true
  editInitialData.value = await stakeholderService.getById(row.id).finally(() => (drawerLoading.value = false))
}

async function handleSave(payload: StakeholderPayload) {
  drawerLoading.value = true
  if (drawerMode.value === 'create') {
    await stakeholderService.create(payload).finally(() => (drawerLoading.value = false))
    toast.success('Parceiro criado.')
  } else {
    await stakeholderService.update(editingId.value!, payload).finally(() => (drawerLoading.value = false))
    toast.success('Parceiro atualizado.')
  }
  drawerOpen.value = false
  await loadData()
}

async function handleDelete(id: number) {
  await stakeholderService.delete(id)
  stakeholders.value = stakeholders.value.filter((s) => s.id !== id)
  toast.success('Parceiro excluído.')
}
</script>

<style scoped>
.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined';
}

.stakeholder-view {
  --primary:            #0d631b;
  --surface:            #f9f9f9;
  --on-surface:         #1a1c1c;
  --on-surface-variant: #40493d;
  --outline-variant:    #bfcaba;
}

.stakeholder-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 2rem;
  gap: 1.5rem;
  background: var(--surface);
  font-family: 'Inter', sans-serif;
  overflow: hidden;
}

.cell-name  { font-weight: 600; color: var(--on-surface); }
.cell-empty { color: var(--on-surface-variant); }

.card-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.5rem;
}

.type-chip {
  padding: 0.125rem 0.625rem;
  border-radius: 2rem;
  background: #eef1eb;
  color: var(--on-surface-variant);
  font-size: 0.75rem;
  font-weight: 600;
  white-space: nowrap;
}

.card-meta {
  margin: 0.25rem 0 0;
  font-size: 0.8125rem;
  color: var(--on-surface-variant);
}

.card-phone {
  display: inline-flex;
  align-items: center;
  gap: 0.25rem;
  min-height: 2rem;
  margin-top: 0.25rem;
  font-size: 0.875rem;
  font-weight: 600;
  color: var(--primary);
  text-decoration: none;
}

.card-phone .material-symbols-outlined { font-size: 1rem; }

.card-skeleton { margin-bottom: 0.5rem; }

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

@media (max-width: 767px) {
  .stakeholder-view {
    height: auto;
    min-height: 100%;
    padding: 1rem;
    gap: 1rem;
    overflow: visible;
  }
}
</style>
