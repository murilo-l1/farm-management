<template>
  <form class="category-form" @submit.prevent="handleSubmit">
    <div class="form-grid">

      <!-- Nome -->
      <div class="form-field form-field--full">
        <label class="form-label">Nome <span class="form-required">*</span></label>
        <AppInput v-model="form.name" placeholder="Ex: Defensivos Agrícolas" fluid class="w-full" />
      </div>

      <!-- Cor -->
      <div class="form-field form-field--full">
        <label class="form-label">Cor</label>
        <div class="color-picker-row">
          <ColorPicker v-model="form.colorHex" format="hex" />
          <span class="color-preview" :style="previewStyle">
            {{ previewLabel }}
          </span>
          <button
            v-if="form.colorHex"
            type="button"
            class="color-clear"
            title="Remover cor"
            @click="form.colorHex = null"
          >
            <i class="pi pi-times" />
          </button>
        </div>
        <span class="form-hint">Deixe em branco para usar a cor padrão</span>
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
import { reactive, computed, watch } from 'vue'
import ColorPicker from 'primevue/colorpicker'
import AppInput from '@/components/AppInput.vue'
import AppButton from '@/components/AppButton.vue'
import type { CategoryDto, CategoryPayload } from '@/types/category'

interface Props {
  initialData?: CategoryDto | null
  loading?: boolean
  mode?: 'create' | 'edit'
}

const props = withDefaults(defineProps<Props>(), {
  initialData: null,
  loading: false,
  mode: 'edit',
})

const emit = defineEmits<{
  submit: [payload: CategoryPayload]
  cancel: []
}>()

const form = reactive({
  name:     '',
  colorHex: null as string | null,
})

const submitLabel = computed(() => props.mode === 'create' ? 'Criar' : 'Salvar')

const fullColor = computed(() =>
  form.colorHex ? `#${form.colorHex}` : null
)

const previewStyle = computed(() => {
  const color = fullColor.value ?? '#757575'
  return {
    backgroundColor: `${color}26`,
    color,
  }
})

const previewLabel = computed(() =>
  form.name.trim() || 'Prévia'
)

function populate(data: CategoryDto) {
  form.name     = data.name
  form.colorHex = data.color ? data.color.replace('#', '') : null
}

function reset() {
  form.name = ''
  form.colorHex = null
}

watch(() => props.initialData, (data) => {
  data ? populate(data) : reset()
}, { immediate: true })

function handleSubmit() {
  emit('submit', {
    name:  form.name.trim(),
    color: fullColor.value,
  })
}
</script>

<style scoped>
.category-form {
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

.form-hint {
  font-size: 0.75rem;
  color: #6b7280;
}

.w-full {
  width: 100%;
}

.color-picker-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.color-preview {
  display: inline-flex;
  align-items: center;
  padding: 0.25rem 0.875rem;
  border-radius: 2rem;
  font-size: 0.8125rem;
  font-weight: 600;
  white-space: nowrap;
  transition: background-color 0.2s, color 0.2s;
}

.color-clear {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 1.75rem;
  height: 1.75rem;
  border-radius: 50%;
  border: 1px solid #bfcaba;
  background: transparent;
  cursor: pointer;
  color: #40493d;
  font-size: 0.65rem;
  transition: background 0.15s;
}

.color-clear:hover {
  background: #ffebee;
  color: #c62828;
  border-color: #ef9a9a;
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

  .color-clear {
    width: 2.75rem;
    height: 2.75rem;
    font-size: 0.875rem;
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
