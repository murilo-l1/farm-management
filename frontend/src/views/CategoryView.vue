<template>
  <div class="category-view">
    <!-- Header -->
    <AppHeaderBar title="Categorias" subtitle="Organize seus itens e transações por categoria" />

    <!-- Edit Drawer -->
    <Drawer
      v-model:visible="drawerOpen"
      position="right"
      :header="drawerHeader"
      style="width: 36rem"
    >
      <div v-if="drawerLoading && !editInitialData" class="drawer-loading">
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="40%" class="mb-3" />
        <Skeleton height="1.5rem" width="50%" />
      </div>
      <CategoryForm
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
      export-filename="categorias"
      :value="categories"
      :loading="loading"
      :global-filter-fields="['name']"
      search-placeholder="Buscar por nome"
      @edit="handleEdit"
      @delete="handleDelete"
    >
      <template #actions>
        <AppButton icon="pi pi-external-link" label="Exportar CSV" severity="secondary" outlined :disabled="loading" @click="tableRef.exportCSV()" />
        <AppButton icon="pi pi-plus" label="Nova Categoria" @click="handleAdd" />
      </template>
      <template #columns="{ loading }">
        <Column field="name" header="Nome" style="min-width: 16rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="10rem" />
            <span v-else class="cell-name">{{ data.name }}</span>
          </template>
        </Column>

        <Column header="Etiqueta" style="min-width: 10rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1.5rem" width="7rem" border-radius="2rem" />
            <span
              v-else
              class="color-badge"
              :style="colorBadgeStyle(data.color)"
            >
              {{ data.name }}
            </span>
          </template>
        </Column>
      </template>

      <template #empty>
        <div class="empty-state">
          <span class="material-symbols-outlined empty-icon">label</span>
          <p>Nenhuma categoria encontrada.</p>
        </div>
      </template>
    </AppDataTable>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import Column from 'primevue/column'
import Skeleton from 'primevue/skeleton'
import Drawer from 'primevue/drawer'
import AppButton from '@/components/AppButton.vue'
import AppHeaderBar from '@/components/AppHeaderBar.vue'
import AppDataTable from '@/components/AppDataTable.vue'
import CategoryForm from '@/form/CategoryForm.vue'
import { categoryService } from '@/services/category.service'
import { toast } from '@/services/toast'
import type { CategoryDto, CategoryPayload } from '@/types/category'

const DEFAULT_COLOR = '#757575'

const tableRef = ref()
const loading = ref(false)
const categories = ref<CategoryDto[]>([])

const drawerOpen = ref(false)
const drawerLoading = ref(false)
const drawerMode = ref<'create' | 'edit'>('edit')
const editingId = ref<number | null>(null)
const editInitialData = ref<CategoryDto | null>(null)

const drawerHeader = computed(() =>
  drawerMode.value === 'create'
    ? 'Nova Categoria'
    : (editInitialData.value?.name ?? 'Editando Categoria')
)

function colorBadgeStyle(color: string | null) {
  const c = color ?? DEFAULT_COLOR
  return { backgroundColor: `${c}26`, color: c }
}

async function loadData() {
  loading.value = true
  categories.value = await categoryService.findAll().finally(() => (loading.value = false))
}

onMounted(loadData)

function handleAdd() {
  drawerMode.value = 'create'
  editingId.value = null
  editInitialData.value = null
  drawerOpen.value = true
}

async function handleEdit(row: CategoryDto) {
  drawerMode.value = 'edit'
  editingId.value = row.id
  editInitialData.value = null
  drawerOpen.value = true
  drawerLoading.value = true
  editInitialData.value = await categoryService.getById(row.id).finally(() => (drawerLoading.value = false))
}

async function handleSave(payload: CategoryPayload) {
  drawerLoading.value = true
  if (drawerMode.value === 'create') {
    await categoryService.create(payload).finally(() => (drawerLoading.value = false))
    toast.success('Categoria criada.')
  } else {
    await categoryService.update(editingId.value!, payload).finally(() => (drawerLoading.value = false))
    toast.success('Categoria atualizada.')
  }
  drawerOpen.value = false
  await loadData()
}

async function handleDelete(id: number) {
  await categoryService.delete(id)
  categories.value = categories.value.filter((c) => c.id !== id)
  toast.success('Categoria excluída.')
}
</script>

<style scoped>
.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined';
}

.category-view {
  --primary:            #0d631b;
  --surface:            #f9f9f9;
  --on-surface:         #1a1c1c;
  --on-surface-variant: #40493d;
  --outline-variant:    #bfcaba;
}

.category-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 2rem;
  gap: 1.5rem;
  background: var(--surface);
  font-family: 'Inter', sans-serif;
  overflow: hidden;
}

.cell-name { font-weight: 600; color: var(--on-surface); }

.color-badge {
  display: inline-block;
  padding: 0.25rem 0.75rem;
  border-radius: 2rem;
  font-size: 0.75rem;
  font-weight: 600;
  white-space: nowrap;
}

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
