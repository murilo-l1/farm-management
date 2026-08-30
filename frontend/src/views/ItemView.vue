<template>
  <div class="item-view">
    <!-- Header -->
    <AppHeaderBar title="Inventário" subtitle="Gerencie os itens de insumos da sua propriedade" />

    <!-- Edit Drawer -->
    <Drawer
      v-model:visible="drawerOpen"
      position="right"
      :header="drawerHeader"
      style="width: 36rem"
    >
      <div v-if="drawerLoading && !editInitialData" class="drawer-loading">
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="60%" class="mb-3" />
        <Skeleton height="1.5rem" width="40%" />
      </div>
      <ItemForm
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
      :value="items"
      :loading="loading"
      :global-filter-fields="['name', 'brand', 'category_name']"
      search-placeholder="Buscar por nome, marca ou categoria"
      @edit="handleEdit"
      @delete="handleDelete"
    >
      <template #actions>
        <AppButton icon="pi pi-external-link" label="Exportar CSV" severity="secondary" outlined @click="tableRef.exportCSV()" />
        <AppButton icon="pi pi-plus" label="Novo Item" @click="handleAdd" />
      </template>
      <template #columns="{ loading }">
        <Column field="name" header="Nome" style="min-width: 14rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="10rem" />
            <span v-else class="cell-name">{{ data.name }}</span>
          </template>
        </Column>

        <Column field="unity" header="Unidade" style="min-width: 7rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="4rem" />
            <span v-else>{{ data.unity ?? '—' }}</span>
          </template>
        </Column>

        <Column field="brand" header="Marca" style="min-width: 10rem">
          <template #body="{ data }">
            <Skeleton v-if="loading" height="1rem" width="7rem" />
            <span v-else>{{ data.brand ?? '—' }}</span>
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
      </template>

      <template #empty>
        <div class="empty-state">
          <span class="material-symbols-outlined empty-icon">inventory_2</span>
          <p>Nenhum item encontrado.</p>
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
import ItemForm from '@/form/ItemForm.vue'
import { itemService } from '@/services/item.service'
import { categoryService } from '@/services/category.service'
import { toast } from '@/services/toast'
import type { ItemDto, ItemPayload } from '@/types/item'

const DEFAULT_CATEGORY_COLOR = '#757575'

const tableRef = ref()
const loading = ref(false)
const items = ref<ItemDto[]>([])
const categoryColorMap = ref<Map<number, string>>(new Map())

const drawerOpen = ref(false)
const drawerLoading = ref(false)
const drawerMode = ref<'create' | 'edit'>('edit')
const editingId = ref<number | null>(null)
const editInitialData = ref<ItemDto | null>(null)

const drawerHeader = computed(() =>
  drawerMode.value === 'create'
    ? 'Novo Item'
    : (editInitialData.value?.name ?? 'Editando Item')
)

function categoryBadgeStyle(categoryId: number | null) {
  const color = (categoryId != null ? categoryColorMap.value.get(categoryId) : null) ?? DEFAULT_CATEGORY_COLOR
  return { backgroundColor: `${color}26`, color }
}

async function loadData() {
  loading.value = true
  items.value = await itemService.findAll().finally(() => (loading.value = false))
}

onMounted(async () => {
  const [, cats] = await Promise.all([loadData(), categoryService.findAll()])
  categoryColorMap.value = new Map(cats.map((c) => [c.id, c.color ?? DEFAULT_CATEGORY_COLOR]))
})

function handleAdd() {
  drawerMode.value = 'create'
  editingId.value = null
  editInitialData.value = null
  drawerOpen.value = true
}

async function handleEdit(row: ItemDto) {
  drawerMode.value = 'edit'
  editingId.value = row.id
  editInitialData.value = null
  drawerOpen.value = true
  drawerLoading.value = true
  editInitialData.value = await itemService.getById(row.id).finally(() => (drawerLoading.value = false))
}

async function handleSave(payload: ItemPayload) {
  drawerLoading.value = true
  if (drawerMode.value === 'create') {
    await itemService.create(payload).finally(() => (drawerLoading.value = false))
    toast.success('Item criado.')
  } else {
    await itemService.update(editingId.value!, payload).finally(() => (drawerLoading.value = false))
    toast.success('Item atualizado.')
  }
  drawerOpen.value = false
  await loadData()
}

async function handleDelete(id: number) {
  await itemService.delete(id)
  items.value = items.value.filter((i) => i.id !== id)
  toast.success('Item excluído.')
}
</script>

<style scoped>
.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined';
}

.item-view {
  --primary:            #0d631b;
  --surface:            #f9f9f9;
  --on-surface:         #1a1c1c;
  --on-surface-variant: #40493d;
  --outline-variant:    #bfcaba;
}

.item-view {
  display: flex;
  flex-direction: column;
  height: 100%;
  padding: 2rem;
  gap: 1.5rem;
  background: var(--surface);
  font-family: 'Inter', sans-serif;
  overflow: hidden;
}

.cell-name    { font-weight: 600; color: var(--on-surface); }
.cell-empty   { color: var(--on-surface-variant); }

.category-badge {
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
