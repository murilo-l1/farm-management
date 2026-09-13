<template>
  <form class="stakeholder-form" @submit.prevent="handleSubmit">
    <div class="form-grid">

      <!-- Nome -->
      <div class="form-field form-field--full">
        <label class="form-label">Nome <span class="form-required">*</span></label>
        <AppInput v-model="form.name" placeholder="Ex: Agropecuária Silva" fluid class="w-full" />
      </div>

      <!-- Tipo -->
      <div class="form-field form-field--full">
        <label class="form-label">Tipo</label>
        <Select
          v-model="form.type"
          :options="typeOptions"
          option-label="label"
          option-value="value"
          placeholder="Selecione um tipo..."
          show-clear
          fluid
        />
      </div>

      <!-- CPF -->
      <div class="form-field">
        <label class="form-label">CPF</label>
        <AppInput
          :value="cpfDisplay"
          placeholder="000.000.000-00"
          fluid
          class="w-full"
          @input="onCpfInput"
        />
      </div>

      <!-- CNPJ -->
      <div class="form-field">
        <label class="form-label">CNPJ</label>
        <AppInput
          :value="cnpjDisplay"
          placeholder="00.000.000/0000-00"
          fluid
          class="w-full"
          @input="onCnpjInput"
        />
      </div>

      <!-- Telefone -->
      <div class="form-field form-field--full">
        <label class="form-label">Telefone</label>
        <AppInput
          :value="phoneDisplay"
          placeholder="(00) 00000-0000"
          fluid
          class="w-full"
          @input="onPhoneInput"
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
import { reactive, ref, computed, watch } from 'vue'
import Select from 'primevue/select'
import AppInput from '@/components/AppInput.vue'
import AppButton from '@/components/AppButton.vue'
import { formatPhone, formatCpf, formatCnpj, stripMask } from '@/utils/format'
import type { StakeholderDto, StakeholderPayload, StakeholderType } from '@/types/stakeholder'

interface Props {
  initialData?: StakeholderDto | null
  loading?: boolean
  mode?: 'create' | 'edit'
}

const props = withDefaults(defineProps<Props>(), {
  initialData: null,
  loading: false,
  mode: 'edit',
})

const emit = defineEmits<{
  submit: [payload: StakeholderPayload]
  cancel: []
}>()

const typeOptions = [
  { label: 'Fornecedor', value: 'SUPPLIER' },
  { label: 'Comprador', value: 'BUYER' },
  { label: 'Ambos', value: 'BOTH' },
]

const form = reactive({
  name: '',
  type: null as StakeholderType | null,
})

// Raw digits — payload source
const cpfDigits   = ref('')
const cnpjDigits  = ref('')
const phoneDigits = ref('')

// Formatted display values
const cpfDisplay   = computed(() => formatCpf(cpfDigits.value))
const cnpjDisplay  = computed(() => formatCnpj(cnpjDigits.value))
const phoneDisplay = computed(() => formatPhone(phoneDigits.value))

const submitLabel = computed(() => props.mode === 'create' ? 'Criar' : 'Salvar')

function onCpfInput(event: Event) {
  cpfDigits.value = stripMask((event.target as HTMLInputElement).value).slice(0, 11)
}

function onCnpjInput(event: Event) {
  cnpjDigits.value = stripMask((event.target as HTMLInputElement).value).slice(0, 14)
}

function onPhoneInput(event: Event) {
  phoneDigits.value = stripMask((event.target as HTMLInputElement).value).slice(0, 11)
}

function populate(data: StakeholderDto) {
  form.name      = data.name
  form.type      = data.type
  cpfDigits.value   = stripMask(data.cpf   ?? '')
  cnpjDigits.value  = stripMask(data.cnpj  ?? '')
  phoneDigits.value = stripMask(data.phone ?? '')
}

function reset() {
  form.name = ''; form.type = null
  cpfDigits.value = ''; cnpjDigits.value = ''; phoneDigits.value = ''
}

watch(() => props.initialData, (data) => {
  data ? populate(data) : reset()
}, { immediate: true })

function handleSubmit() {
  emit('submit', {
    name:  form.name.trim(),
    cpf:   cpfDigits.value   || null,
    cnpj:  cnpjDigits.value  || null,
    type:  form.type,
    phone: phoneDigits.value || null,
  })
}
</script>

<style scoped>
.stakeholder-form {
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
