<template>
  <Dialog
    v-model:visible="visible"
    modal
    :draggable="false"
    header="Meu Perfil"
    :style="{ width: '28rem' }"
    class="profile-dialog"
  >
    <div class="dialog-body">
      <section class="profile-section">
        <h3 class="section-title">Dados pessoais</h3>

        <div class="field">
          <label class="field-label">Nome</label>
          <AppInput
            v-model="profileForm.name"
            placeholder="Seu nome"
            class="w-full"
            :disabled="profileLoading"
          />
        </div>

        <div class="field">
          <label class="field-label">E-mail</label>
          <AppInput
            :model-value="auth.user?.email"
            class="w-full field-readonly"
            disabled
          />
        </div>

        <div class="field">
          <label class="field-label">Telefone</label>
          <AppInput
            v-model="profileForm.phone"
            placeholder="(00) 00000-0000"
            class="w-full"
            :disabled="profileLoading"
          />
        </div>

        <div class="field-action">
          <AppButton
            label="Salvar dados"
            :loading="profileLoading"
            @click="handleProfileSave"
          />
        </div>
      </section>

      <Divider />

      <section class="profile-section">
        <h3 class="section-title">Alterar senha</h3>

        <div class="field">
          <label class="field-label">Senha atual</label>
          <AppPassword
            v-model="passwordForm.currentPassword"
            placeholder="Digite sua senha atual"
            :feedback="false"
            :toggle-mask="true"
            class="w-full"
            input-class="w-full"
            :disabled="passwordLoading"
          />
        </div>

        <div class="field">
          <label class="field-label">Nova senha</label>
          <AppPassword
            v-model="passwordForm.newPassword"
            placeholder="Digite a nova senha"
            :feedback="false"
            :toggle-mask="true"
            class="w-full"
            input-class="w-full"
            :disabled="passwordLoading"
          />
        </div>

        <div class="field-action">
          <AppButton
            label="Alterar senha"
            :loading="passwordLoading"
            @click="handlePasswordChange"
          />
        </div>
      </section>
    </div>
  </Dialog>
</template>

<script setup lang="ts">
import { reactive, watch } from 'vue'
import Dialog from 'primevue/dialog'
import Divider from 'primevue/divider'
import AppInput from '@/components/AppInput.vue'
import AppPassword from '@/components/AppPassword.vue'
import AppButton from '@/components/AppButton.vue'
import { useAuthStore } from '@/stores/auth'
import { userService } from '@/services/user.service'
import { toast } from '@/services/toast'
import { ref } from 'vue'

const visible = defineModel<boolean>('visible', { required: true })

const auth = useAuthStore()

const profileLoading = ref(false)
const passwordLoading = ref(false)

const profileForm = reactive({
  name: auth.user?.name ?? '',
  phone: auth.user?.phone ?? '',
})

const passwordForm = reactive({
  currentPassword: '',
  newPassword: '',
})

watch(visible, (isOpen) => {
  if (isOpen) {
    profileForm.name = auth.user?.name ?? ''
    profileForm.phone = auth.user?.phone ?? ''
    passwordForm.currentPassword = ''
    passwordForm.newPassword = ''
  }
})

async function handleProfileSave() {
  profileLoading.value = true
  await userService.updateProfile({ name: profileForm.name, phone: profileForm.phone })
    .then(() => {
      auth.updateProfile(profileForm.name, profileForm.phone)
      toast.success('Dados atualizados com sucesso.')
    })
    .finally(() => { profileLoading.value = false })
}

async function handlePasswordChange() {
  passwordLoading.value = true
  await userService.changePassword({
    current_password: passwordForm.currentPassword,
    new_password: passwordForm.newPassword,
  })
    .then(() => {
      passwordForm.currentPassword = ''
      passwordForm.newPassword = ''
      toast.success('Senha alterada com sucesso.')
    })
    .finally(() => { passwordLoading.value = false })
}
</script>

<style scoped>
.dialog-body {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.profile-section {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.section-title {
  font-family: 'Manrope', sans-serif;
  font-size: 0.875rem;
  font-weight: 700;
  color: #1a1c1c;
  margin: 0;
}

.field {
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
}

.field-label {
  font-size: 0.8125rem;
  font-weight: 500;
  color: #40493d;
}

.field-readonly :deep(input) {
  background-color: #f3f3f3;
  color: #707a6c;
  cursor: not-allowed;
}

.field-action {
  display: flex;
  justify-content: flex-end;
}
</style>
