<template>
  <form class="item-form" @submit.prevent="handleSubmit">
    <div class="form-grid">

      <!-- Nome -->
      <div class="form-field form-field--full">
        <label class="form-label">Nome <span class="form-required">*</span></label>
        <AppInput v-model="form.name" placeholder="Ex: Herbicida Roundup" fluid class="w-full" />
      </div>

      <!-- Unidade -->
      <div class="form-field">
        <label class="form-label">Unidade</label>
        <AppInput v-model="form.unity" placeholder="Ex: L, kg, un..." fluid class="w-full" />
      </div>

      <!-- Marca -->
      <div class="form-field">
        <label class="form-label">Marca</label>
        <AppInput v-model="form.brand" placeholder="Ex: Bayer, Basf..." fluid class="w-full" />
      </div>

      <!-- Categoria -->
      <div class="form-field form-field--full">
        <label class="form-label">Categoria</label>
        <Select
          v-model="form.category_id"
          :options="categories"
          option-label="name"
          option-value="id"
          placeholder="Selecione uma categoria..."
          show-clear
          :loading="categoriesLoading"
          fluid
        />
      </div>

    </div>

    <div class="form-footer">
      <AppButton
        type="button"
        label="Cancelar"
        severity="secondary"
        outlined
        @click="emit('cancel')"
      />
      <AppButton
        type="submit"
        :label="submitLabel"
        :loading="loading"
      />
    </div>
  </form>
</template>

<script setup lang="ts">
import { reactive, computed, watch, onMounted, ref } from 'vue'
import Select from 'primevue/select'
import AppInput from '@/components/AppInput.vue'
import AppButton from '@/components/AppButton.vue'
import { categoryService } from '@/services/category.service'
import type { CategoryDto } from '@/types/category'
import type { ItemDto, ItemPayload } from '@/types/item'

interface Props {
  initialData?: ItemDto | null
  loading?: boolean
  mode?: 'create' | 'edit'
}

const props = withDefaults(defineProps<Props>(), {
  initialData: null,
  loading: false,
  mode: 'edit',
})

const emit = defineEmits<{
  submit: [payload: ItemPayload]
  cancel: []
}>()

const categories = ref<CategoryDto[]>([])
const categoriesLoading = ref(false)

const form = reactive({
  name:        '',
  unity:       null as string | null,
  brand:       null as string | null,
  category_id: null as number | null,
})

const submitLabel = computed(() => props.mode === 'create' ? 'Criar' : 'Salvar')

function populate(data: ItemDto) {
  form.name        = data.name
  form.unity       = data.unity
  form.brand       = data.brand
  form.category_id = data.category_id
}

function reset() {
  form.name = ''; form.unity = null; form.brand = null; form.category_id = null
}

watch(() => props.initialData, (data) => {
  data ? populate(data) : reset()
}, { immediate: true })

onMounted(async () => {
  categoriesLoading.value = true
  categories.value = await categoryService.findAll().finally(() => (categoriesLoading.value = false))
})

function handleSubmit() {
  emit('submit', {
    name:        form.name.trim(),
    unity:       form.unity?.trim() || null,
    brand:       form.brand?.trim() || null,
    category_id: form.category_id,
  })
}
</script>

<style scoped>
.item-form {
  display: flex;
  flex-direction: column;
  height: 100%;
  font-family: 'Inter', sans-serif;
}

.form-grid {
  flex: 1;
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 1.25rem 1rem;
  overflow-y: auto;
  padding: 1.5rem;
}

.form-field {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  min-width: 0;
}

.form-field--full {
  grid-column: 1 / -1;
}

.form-label {
  font-size: 0.8125rem;
  font-weight: 600;
  color: #40493d;
}

.form-required {
  color: #c62828;
}

.w-full {
  width: 100%;
}

.form-footer {
  display: flex;
  justify-content: flex-end;
  gap: 0.625rem;
  padding: 1rem 1.5rem;
  border-top: 1px solid #bfcaba;
  flex-shrink: 0;
}

@media (max-width: 767px) {
  .form-grid {
    grid-template-columns: 1fr;
    align-content: start;
    gap: 1rem;
    padding: 1rem;
  }

  .form-footer {
    padding: 0.75rem 1rem calc(0.75rem + env(safe-area-inset-bottom));
  }

  .form-footer :deep(.p-button) {
    flex: 1;
    min-height: 2.75rem;
  }
}
</style>
