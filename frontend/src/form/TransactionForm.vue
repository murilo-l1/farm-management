<template>
  <form class="transaction-form" @submit.prevent="handleSubmit">
    <div class="form-grid">

      <!-- Tipo -->
      <div class="form-field">
        <label class="form-label">Tipo <span class="form-required">*</span></label>
        <Select
          v-model="form.type"
          :options="typeOptions"
          option-label="label"
          option-value="value"
          fluid
        />
      </div>

      <!-- Status -->
      <div class="form-field">
        <label class="form-label">Status</label>
        <Select
          v-model="form.status"
          :options="statusOptions"
          option-label="label"
          option-value="value"
          show-clear
          fluid
        />
      </div>

      <!-- Data -->
      <div class="form-field">
        <label class="form-label">Data <span class="form-required">*</span></label>
        <DatePicker
          v-model="form.transaction_date"
          date-format="dd/mm/yy"
          show-icon
          icon-display="input"
          :manual-input="true"
          fluid
        />
      </div>

      <!-- Forma de Pagamento -->
      <div class="form-field">
        <label class="form-label">Forma de Pagamento</label>
        <Select
          v-model="form.payment_method"
          :options="paymentMethodOptions"
          option-label="label"
          option-value="value"
          show-clear
          fluid
        />
      </div>

      <!-- Descrição -->
      <div class="form-field form-field--full">
        <label class="form-label">Descrição</label>
        <AppInput v-model="form.description" placeholder="Ex: Compra de herbicida, venda de soja..." fluid class="w-full" />
      </div>

      <!-- Valor Total -->
      <div class="form-field">
        <label class="form-label">
          Valor Total (R$)
          <span v-if="!hasItems" class="form-required">*</span>
        </label>
        <InputNumber
          v-model="form.total_value"
          mode="currency"
          currency="BRL"
          locale="pt-BR"
          :min="0"
          :disabled="hasItems"
          fluid
        />
        <small v-if="hasItems" class="form-hint">
          O valor total da transação é respectivo ao somatório dos gastos com os itens.
        </small>
      </div>

      <!-- Spacer -->
      <div class="form-field form-spacer" />

      <!-- Safra -->
      <div class="form-field">
        <label class="form-label">Safra</label>
        <Select
          v-model="form.crop_cycle_id"
          :options="cropCycleOptions"
          option-label="name"
          option-value="id"
          placeholder="Selecione..."
          show-clear
          fluid
        />
      </div>

      <!-- Categoria -->
      <div class="form-field">
        <label class="form-label">Categoria</label>
        <Select
          v-model="form.category_id"
          :options="categoryOptions"
          option-label="name"
          option-value="id"
          placeholder="Selecione..."
          show-clear
          fluid
        />
      </div>

      <!-- Parceiro -->
      <div class="form-field">
        <label class="form-label">Parceiro</label>
        <Select
          v-model="form.stakeholder_id"
          :options="stakeholderOptions"
          option-label="name"
          option-value="id"
          placeholder="Selecione..."
          show-clear
          fluid
        />
      </div>

      <!-- Itens -->
      <div class="form-field form-field--full">
        <div class="items-header">
          <label class="form-label">Itens</label>
          <button type="button" class="add-item-btn" aria-label="Adicionar item" @click="addItem">
            <span class="material-symbols-outlined">add</span>
            <span class="add-item-label">Adicionar item</span>
          </button>
        </div>

        <template v-if="formItems.length > 0">
          <div class="items-grid items-grid--head">
            <span>Item</span>
            <span>Unid.</span>
            <span>Qtd.</span>
            <span>Preço unit.</span>
            <span>Total</span>
            <span></span>
          </div>
          <div v-for="(fi, idx) in formItems" :key="idx" class="items-grid items-grid--row">
            <Select
              v-model="fi.item_id"
              :options="itemOptions"
              option-label="name"
              option-value="id"
              placeholder="Selecione..."
              @change="onItemSelect(fi)"
              fluid
              class="item-select"
            />
            <span class="item-cell item-cell--unity">{{ fi.item_unity || '—' }}</span>
            <InputNumber
              v-model="fi.quantity"
              :min="1"
              :max-fraction-digits="0"
              :placeholder="isMobile ? 'Qtd.' : undefined"
              fluid
              class="item-qty"
            />
            <InputNumber
              v-model="fi.unit_price"
              mode="currency"
              currency="BRL"
              locale="pt-BR"
              :min="0"
              :placeholder="isMobile ? 'Preço unit.' : undefined"
              fluid
              class="item-price"
            />
            <span class="item-cell item-cell--total">{{ formatCurrency(itemTotal(fi)) }}</span>
            <button type="button" class="remove-item-btn" aria-label="Remover item" @click="removeItem(idx)">
              <span class="material-symbols-outlined">remove</span>
            </button>
          </div>
        </template>
        <p v-else class="items-empty">Nenhum item. Clique em + para adicionar.</p>
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
import { ref, reactive, computed, watch, onMounted } from 'vue'
import Select from 'primevue/select'
import InputNumber from 'primevue/inputnumber'
import DatePicker from 'primevue/datepicker'
import AppInput from '@/components/AppInput.vue'
import AppButton from '@/components/AppButton.vue'
import { useBreakpoint } from '@/composables/useBreakpoint'
import { cropCycleService } from '@/services/crop-cycle.service'
import { categoryService } from '@/services/category.service'
import { stakeholderService } from '@/services/stakeholder.service'
import { itemService } from '@/services/item.service'
import type { TransactionDto, TransactionPayload, TransactionItemPayload, TransactionType, TransactionStatus, PaymentMethod } from '@/types/transaction'
import type { CropCycleOption } from '@/types/crop-cycle'
import type { CategoryDto } from '@/types/category'
import type { StakeholderOption } from '@/types/stakeholder'
import type { ItemDto } from '@/types/item'

interface FormItem {
  item_id:    number | null
  item_name:  string
  item_unity: string
  quantity:   number | null
  unit_price: number | null
}

interface Props {
  initialData?: TransactionDto | null
  loading?: boolean
  mode?: 'create' | 'edit'
}

const props = withDefaults(defineProps<Props>(), {
  initialData: null,
  loading: false,
  mode: 'create',
})

const emit = defineEmits<{
  submit: [payload: TransactionPayload]
  cancel: []
}>()

// no celular os itens não têm cabeçalho, então o placeholder indica o campo
const { isMobile } = useBreakpoint()

const cropCycleOptions  = ref<CropCycleOption[]>([])
const categoryOptions   = ref<CategoryDto[]>([])
const stakeholderOptions = ref<StakeholderOption[]>([])
const itemOptions        = ref<ItemDto[]>([])
const formItems          = reactive<FormItem[]>([])

const typeOptions: { value: TransactionType; label: string }[] = [
  { value: 'INCOME',  label: 'Receita'  },
  { value: 'EXPENSE', label: 'Despesa'  },
]

const statusOptions: { value: TransactionStatus; label: string }[] = [
  { value: 'PENDING',   label: 'Pendente'  },
  { value: 'FINISHED',  label: 'Finalizada'      },
  { value: 'CANCELLED', label: 'Cancelada' },
]

const paymentMethodOptions: { value: PaymentMethod; label: string }[] = [
  { value: 'CARD',   label: 'Cartão'   },
  { value: 'CASH',   label: 'Dinheiro' },
  { value: 'PIX',    label: 'Pix'      },
  { value: 'CHECK',  label: 'Cheque'   },
  { value: 'BOLETO', label: 'Boleto'   },
]

const form = reactive({
  type:             null as TransactionType | null,
  status:           null as TransactionStatus | null,
  transaction_date: null as Date | null,
  payment_method:   null as PaymentMethod | null,
  description:      '',
  total_value:      null as number | null,
  crop_cycle_id:    null as number | null,
  category_id:      null as number | null,
  stakeholder_id:   null as number | null,
})

const hasItems   = computed(() => formItems.length > 0)
const submitLabel = computed(() => props.mode === 'create' ? 'Criar' : 'Salvar')

function formatCurrency(value: number | null): string {
  if (value == null) return '—'
  return new Intl.NumberFormat('pt-BR', { style: 'currency', currency: 'BRL' }).format(value)
}

function itemTotal(fi: FormItem): number | null {
  if (fi.quantity == null || fi.unit_price == null) return null
  return fi.quantity * fi.unit_price
}

function addItem() {
  if (formItems.length === 0) form.total_value = null
  formItems.push({ item_id: null, item_name: '', item_unity: '', quantity: null, unit_price: null })
}

function removeItem(idx: number) {
  formItems.splice(idx, 1)
}

function onItemSelect(fi: FormItem) {
  const found = itemOptions.value.find(i => i.id === fi.item_id)
  fi.item_name  = found?.name  ?? ''
  fi.item_unity = found?.unity ?? ''
}

function isoToDate(iso: string | null | undefined): Date | null {
  if (!iso) return null
  const [y, m, d] = iso.split('-').map(Number)
  return new Date(y, m - 1, d)
}

function dateToIso(d: Date | null): string | null {
  if (!d) return null
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
}

function populate(data: TransactionDto) {
  form.type             = data.type
  form.status           = data.status
  form.transaction_date = isoToDate(data.transaction_date)
  form.payment_method   = data.payment_method
  form.description      = data.description ?? ''
  form.total_value      = data.total_value != null ? Number(data.total_value) : null
  form.crop_cycle_id    = data.crop_cycle_id ?? null
  form.category_id      = data.category_id ?? null
  form.stakeholder_id   = data.stakeholder_id ?? null

  formItems.splice(0, formItems.length, ...data.items.map(item => ({
    item_id:    item.item_id,
    item_name:  item.item_name,
    item_unity: itemOptions.value.find(o => o.id === item.item_id)?.unity ?? '',
    quantity:   item.quantity,
    unit_price: item.unit_price,
  })))
}

function reset() {
  form.type = null; form.status = null; form.transaction_date = null
  form.payment_method = null; form.description = ''; form.total_value = null
  form.crop_cycle_id = null; form.category_id = null; form.stakeholder_id = null
  formItems.splice(0, formItems.length)
}

watch(() => props.initialData, (data) => {
  data ? populate(data) : reset()
}, { immediate: true })

onMounted(async () => {
  const [options, cats, stakeholders, items] = await Promise.all([
    cropCycleService.findOptions(),
    categoryService.findAll(),
    stakeholderService.findOptions(),
    itemService.findAll(),
  ])
  cropCycleOptions.value  = options
  categoryOptions.value   = cats
  stakeholderOptions.value = stakeholders
  itemOptions.value        = items

  // Apply unity to items already populated from initialData (edit mode)
  formItems.forEach(fi => {
    if (!fi.item_unity) {
      const found = items.find(i => i.id === fi.item_id)
      if (found) fi.item_unity = found.unity ?? ''
    }
  })
})

function handleSubmit() {
  const items: TransactionItemPayload[] | null = hasItems.value
    ? formItems
        .filter(fi => fi.item_id != null && fi.quantity != null && fi.unit_price != null)
        .map(fi => ({
          id_item:    fi.item_id!,
          quantity:   fi.quantity!,
          unit_price: fi.unit_price!,
        }))
    : null

  emit('submit', {
    type:             form.type!,
    description:      form.description.trim() || null,
    transaction_date: dateToIso(form.transaction_date)!,
    status:           form.status,
    payment_method:   form.payment_method,
    total_value:      hasItems.value ? null : form.total_value,
    crop_cycle_id:    form.crop_cycle_id,
    category_id:      form.category_id,
    stakeholder_id:   form.stakeholder_id,
    items,
  })
}
</script>

<style scoped>
.transaction-form {
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
  color: #6b7c6e;
  line-height: 1.3;
}

.w-full {
  width: 100%;
}

/* ── Items section ── */

.items-header {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-bottom: 0.5rem;
}

.add-item-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 1.625rem;
  height: 1.625rem;
  border-radius: 50%;
  border: 1.5px solid #0d631b;
  background: transparent;
  color: #0d631b;
  cursor: pointer;
  padding: 0;
  transition: background 0.15s, color 0.15s;
}

.add-item-btn .material-symbols-outlined {
  font-size: 1rem;
}

.add-item-label {
  display: none;
}

.items-grid {
  display: grid;
  grid-template-columns: 1fr 4rem 5.5rem 9rem 8rem 2.25rem;
  align-items: center;
  gap: 0.5rem;
}

.items-grid--head {
  font-size: 0.75rem;
  font-weight: 600;
  color: #6b7c6e;
  padding: 0 0 0.25rem;
  border-bottom: 1px solid #dde8d8;
}

.items-grid--head :nth-child(3),
.items-grid--head :nth-child(4),
.items-grid--head :nth-child(5) {
  padding-inline-start: 0.625rem;
}

.items-grid--row {
  padding: 0.375rem 0;
  border-bottom: 1px solid #f0f4ee;
}

.item-cell {
  font-size: 0.8125rem;
  color: #40493d;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.item-cell--unity {
  color: #6b7c6e;
}

.item-cell--total {
  font-weight: 600;
  color: #1a3a1e;
}

.remove-item-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 1.625rem;
  height: 1.625rem;
  border-radius: 50%;
  border: 1.5px solid #c62828;
  background: transparent;
  color: #c62828;
  cursor: pointer;
  padding: 0;
  transition: background 0.15s, color 0.15s;
}

.remove-item-btn .material-symbols-outlined {
  font-size: 1rem;
}

@media (hover: hover) {
  .add-item-btn:hover {
    background: #0d631b;
    color: #fff;
  }

  .remove-item-btn:hover {
    background: #c62828;
    color: #fff;
  }
}

.items-empty {
  font-size: 0.8125rem;
  color: #9eaa99;
  margin: 0;
}

/* ── Footer ── */

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

  .form-spacer {
    display: none;
  }

  .form-footer {
    padding: 0.75rem 1rem calc(0.75rem + env(safe-area-inset-bottom));
  }

  .form-footer :deep(.p-button) {
    flex: 1;
    min-height: 2.75rem;
  }

  .items-header {
    justify-content: space-between;
  }

  .add-item-btn {
    width: auto;
    height: 2.5rem;
    gap: 0.25rem;
    padding: 0 0.875rem 0 0.625rem;
    border-radius: 2rem;
    font-family: 'Inter', sans-serif;
    font-size: 0.8125rem;
    font-weight: 600;
  }

  .add-item-btn .material-symbols-outlined {
    font-size: 1.125rem;
  }

  .add-item-label {
    display: inline;
  }

  .items-grid--head {
    display: none;
  }

  .items-grid--row {
    grid-template-columns: 1fr 1fr auto;
    grid-template-areas:
      'item  item  item'
      'qty   price price'
      'unity total remove';
    gap: 0.5rem;
    padding: 0.75rem;
    margin-bottom: 0.5rem;
    border: 1px solid #dde8d8;
    border-radius: 0.75rem;
  }

  .item-select   { grid-area: item; }
  .item-qty      { grid-area: qty; }
  .item-price    { grid-area: price; }
  .item-cell--unity { grid-area: unity; }
  .item-cell--total { grid-area: total; text-align: right; }
  .remove-item-btn  { grid-area: remove; }

  .item-cell--unity::before { content: 'Unid.: '; }
  .item-cell--total::before { content: 'Total: '; font-weight: 500; color: #6b7c6e; }

  .remove-item-btn {
    width: 2.75rem;
    height: 2.75rem;
  }

  .remove-item-btn .material-symbols-outlined {
    font-size: 1.25rem;
  }
}
</style>
