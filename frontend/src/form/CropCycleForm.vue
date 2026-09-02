<template>
  <form class="crop-cycle-form" @submit.prevent="handleSubmit">
    <div class="form-grid">

      <!-- Nome -->
      <div class="form-field form-field--full">
        <label class="form-label">Nome da Safra <span class="form-required">*</span></label>
        <AppInput v-model="form.name" placeholder="Ex: Safra 2025/1" fluid class="w-full" />
      </div>

      <!-- Cultura -->
      <div class="form-field form-field--full">
        <label class="form-label">Cultura <span class="form-required">*</span></label>
        <AppInput v-model="form.crop" placeholder="Ex: Tomate, Abobrinha, Café..." fluid class="w-full" />
      </div>

      <!-- Status -->
      <div class="form-field">
        <label class="form-label">Status <span class="form-required">*</span></label>
        <Select
          v-model="form.status"
          :options="statusOptions"
          option-label="label"
          option-value="value"
          fluid
        />
      </div>

      <!-- Unidade de Medida -->
      <div class="form-field">
        <label class="form-label">Unidade de Medida</label>
        <Select
          v-model="form.measurement_unit"
          :options="unitOptions"
          option-label="label"
          option-value="value"
          placeholder="Selecione..."
          show-clear
          fluid
        />
      </div>

      <!-- Área plantada (não-PES) ou Contagem de pés (PES) -->
      <div class="form-field">
        <template v-if="isPes">
          <label class="form-label">Quantidade de Pés</label>
          <InputNumber
            v-model="form.plant_count"
            :min="0"
            :min-fraction-digits="0"
            :max-fraction-digits="0"
            :use-grouping="true"
            locale="pt-BR"
            fluid
          />
        </template>
        <template v-else>
          <label class="form-label">Área Plantada</label>
          <InputNumber
            v-model="form.planted_area"
            :min="0"
            :min-fraction-digits="0"
            :max-fraction-digits="2"
            locale="pt-BR"
            fluid
          />
        </template>
      </div>

      <!-- Spacer -->
      <div class="form-field" />

      <!-- Orçamento Planejado -->
      <div class="form-field">
        <label class="form-label">Orçamento Planejado (R$)</label>
        <InputNumber
          v-model="form.planned_budget"
          mode="currency"
          currency="BRL"
          locale="pt-BR"
          :min="0"
          fluid
        />
      </div>

      <!-- Ganho Esperado -->
      <div class="form-field">
        <label class="form-label">Ganho Esperado (R$)</label>
        <InputNumber
          v-model="form.target_yield"
          mode="currency"
          currency="BRL"
          locale="pt-BR"
          :min="0"
          fluid
        />
      </div>

      <!-- Data de Início -->
      <div class="form-field">
        <label class="form-label">Data de Início <span class="form-required">*</span></label>
        <DatePicker
          v-model="form.start_date"
          date-format="dd/mm/yy"
          show-icon
          icon-display="input"
          :manual-input="true"
          fluid
        />
      </div>

      <!-- Data de Fim -->
      <div class="form-field">
        <label class="form-label">Data de Fim</label>
        <DatePicker
          v-model="form.end_date"
          date-format="dd/mm/yy"
          show-icon
          icon-display="input"
          :manual-input="true"
          show-button-bar
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
import { reactive, computed, watch } from 'vue'
import Select from 'primevue/select'
import InputNumber from 'primevue/inputnumber'
import DatePicker from 'primevue/datepicker'
import AppInput from '@/components/AppInput.vue'
import AppButton from '@/components/AppButton.vue'
import type { CropCycleDto, CropCyclePayload, CropCycleStatus, MeasurementUnit } from '@/types/crop-cycle'

interface Props {
  initialData?: CropCycleDto | null
  loading?: boolean
  mode?: 'create' | 'edit'
}

const props = withDefaults(defineProps<Props>(), {
  initialData: null,
  loading: false,
  mode: 'edit',
})

const emit = defineEmits<{
  submit: [payload: CropCyclePayload]
  cancel: []
}>()

const statusOptions: { value: CropCycleStatus; label: string }[] = [
  { value: 'PLANNING',   label: 'Planejamento' },
  { value: 'ACTIVE',     label: 'Ativo'        },
  { value: 'PLANTING',   label: 'Plantio'      },
  { value: 'HARVESTING', label: 'Colheita'     },
  { value: 'FINISHED',   label: 'Finalizado'   },
  { value: 'CANCELLED',  label: 'Cancelado'    },
]

const unitOptions: { value: MeasurementUnit; label: string }[] = [
  { value: 'HECTARE',        label: 'Hectare (ha)'     },
  { value: 'METRO_QUADRADO', label: 'Metro quadrado (m²)' },
  { value: 'ALQUEIRE',       label: 'Alqueire'         },
  { value: 'PES',            label: 'Pés (contagem)'   },
]

const form = reactive({
  name:             '',
  crop:             '',
  status:           null as CropCycleStatus | null,
  measurement_unit: null as MeasurementUnit | null,
  planted_area:     null as number | null,
  plant_count:      null as number | null,
  planned_budget:   null as number | null,
  target_yield:     null as number | null,
  start_date:       null as Date | null,
  end_date:         null as Date | null,
})

const isPes = computed(() => form.measurement_unit === 'PES')
const submitLabel = computed(() => props.mode === 'create' ? 'Criar' : 'Salvar')

function isoToDate(iso: string | null | undefined): Date | null {
  if (!iso) return null
  const [y, m, d] = iso.split('-').map(Number)
  return new Date(y, m - 1, d)
}

function dateToIso(d: Date | null): string | null {
  if (!d) return null
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}

function populate(data: CropCycleDto) {
  form.name             = data.name
  form.crop             = data.crop
  form.status           = data.status
  form.measurement_unit = data.measurement_unit
  form.planted_area     = data.planted_area != null ? Number(data.planted_area) : null
  form.plant_count      = data.plant_count
  form.planned_budget   = data.planned_budget != null ? Number(data.planned_budget) : null
  form.target_yield     = data.target_yield != null ? Number(data.target_yield) : null
  form.start_date       = isoToDate(data.start_date)
  form.end_date         = isoToDate(data.end_date)
}

function reset() {
  form.name = ''; form.crop = ''; form.status = null
  form.measurement_unit = null; form.planted_area = null; form.plant_count = null
  form.planned_budget = null; form.target_yield = null
  form.start_date = null; form.end_date = null
}

watch(() => props.initialData, (data) => {
  data ? populate(data) : reset()
}, { immediate: true })

// switching away from PES clears plant_count; switching to PES clears planted_area
watch(() => form.measurement_unit, (next, prev) => {
  if (next === 'PES' && prev !== 'PES') form.planted_area = null
  if (next !== 'PES' && prev === 'PES') form.plant_count = null
})

function handleSubmit() {
  emit('submit', {
    name:             form.name.trim(),
    crop:             form.crop.trim(),
    status:           form.status!,
    measurement_unit: form.measurement_unit,
    planted_area:     isPes.value ? null : form.planted_area,
    plant_count:      isPes.value ? form.plant_count : null,
    planned_budget:   form.planned_budget,
    target_yield:     form.target_yield,
    start_date:       dateToIso(form.start_date)!,
    end_date:         dateToIso(form.end_date),
  })
}
</script>

<style scoped>
.crop-cycle-form {
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
</style>
