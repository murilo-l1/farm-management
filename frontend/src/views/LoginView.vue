<template>
  <div class="login-page">
    <div class="blob blob-top" />
    <div class="blob blob-bottom" />

    <main class="login-main">
      <div class="login-card">
        <!-- Brand -->
        <div class="brand">
          <div class="brand-icon">
            <Sprout :size="36" color="#fff" :stroke-width="1.5" />
          </div>
          <h1 class="brand-name">QuantaPlanta</h1>
          <p class="brand-tagline">Gestão da terra, SIMPLES</p>
        </div>

        <!-- Heading -->
        <div class="heading">
          <h2>{{ mode === 'register' ? 'Criar conta' : 'Bem-vindo de volta' }}</h2>
          <p>{{ mode === 'register'
            ? 'Preencha os dados abaixo para começar a gerenciar sua produção.'
            : 'Acesse seu painel administrativo para gerenciar ciclos de cultivo e produtividade em tempo real.' }}</p>
        </div>

        <!-- Estado 1: seleção de método -->
        <div v-if="mode === 'select'" class="actions">
          <button class="btn-google" disabled title="Em breve">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none">
              <path d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z" fill="#4285F4"/>
              <path d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z" fill="#34A853"/>
              <path d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z" fill="#FBBC05"/>
              <path d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z" fill="#EA4335"/>
            </svg>
            <span>Continuar com o Google</span>
          </button>

          <button class="btn-email" @click="mode = 'login'">
            <span class="material-symbols-outlined">mail</span>
            <span>Entrar com E-mail e Senha</span>
          </button>

          <p class="register-link">
            Não tem uma conta?
            <a href="#" @click.prevent="mode = 'register'">Cadastre-se</a>
          </p>
        </div>

        <!-- Login -->
        <form v-else-if="mode === 'login'" class="email-form" @submit.prevent="handleLogin">
          <div class="field">
            <label for="email">E-mail</label>
            <AppInput
              id="email"
              v-model="loginEmail"
              type="email"
              placeholder="seu@email.com"
              autocomplete="email"
              :disabled="loading"
              fluid
            />
          </div>

          <div class="field">
            <div class="field-label-row">
              <label for="password">Senha</label>
              <a href="#" class="forgot-link" tabindex="-1" @click.prevent>Esqueci minha senha</a>
            </div>
            <AppPassword
              id="password"
              v-model="loginPassword"
              placeholder="Mínimo 8 caracteres"
              toggle-mask
              :feedback="false"
              autocomplete="current-password"
              :disabled="loading"
              fluid
            />
          </div>

          <AppButton
            type="submit"
            label="Entrar"
            :loading="loading"
            fluid
          />

          <button type="button" class="btn-back" @click="resetForm">
            <span class="material-symbols-outlined">arrow_back</span>
            <span>Voltar</span>
          </button>
        </form>

        <!-- Register -->
        <form v-else class="email-form" @submit.prevent="handleRegister">
          <div class="field">
            <label for="reg-name">Nome completo</label>
            <AppInput
              id="reg-name"
              v-model="regName"
              placeholder="Seu nome"
              autocomplete="name"
              :disabled="loading"
              fluid
            />
          </div>

          <div class="field">
            <label for="reg-email">E-mail</label>
            <AppInput
              id="reg-email"
              v-model="regEmail"
              type="email"
              placeholder="seu@email.com"
              autocomplete="email"
              :disabled="loading"
              fluid
            />
          </div>

          <div class="field">
            <label for="reg-phone">Telefone</label>
            <AppInput
              id="reg-phone"
              :value="regPhoneDisplay"
              @input="onPhoneInput"
              placeholder="(00) 00000-0000"
              autocomplete="tel"
              :disabled="loading"
              fluid
            />
          </div>

          <div class="field">
            <label for="reg-password">Senha</label>
            <AppPassword
              id="reg-password"
              v-model="regPassword"
              placeholder="Mínimo 8 caracteres"
              toggle-mask
              :feedback="false"
              autocomplete="new-password"
              :disabled="loading"
              fluid
            />
          </div>

          <AppButton
            type="submit"
            label="Criar conta"
            :loading="loading"
            fluid
          />

          <button type="button" class="btn-back" @click="resetForm">
            <span class="material-symbols-outlined">arrow_back</span>
            <span>Já tenho uma conta</span>
          </button>
        </form>

        <!-- Legal -->
        <div class="legal">
          <p>Ao continuar, você concorda com nossos procedimentos de segurança e auditoria agrária.</p>
          <div class="legal-links">
            <a href="#">Privacy Policy</a>
            <a href="#">Terms</a>
          </div>
        </div>
      </div>
    </main>

    <div class="gradient-bar" />

    <footer class="login-footer">
      <p>© 2026 QuantaPlanta. Gestão Agrária Digital.</p>
    </footer>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Sprout } from 'lucide-vue-next'
import AppButton from '@/components/AppButton.vue'
import AppInput from '@/components/AppInput.vue'
import AppPassword from '@/components/AppPassword.vue'
import { useAuthStore } from '@/stores/auth'
import { formatPhone, stripMask } from '@/utils/format'

const router = useRouter()
const auth = useAuthStore()

type Mode = 'select' | 'login' | 'register'
const mode = ref<Mode>('select')
const loading = ref(false)

const loginEmail = ref('')
const loginPassword = ref('')

const regName = ref('')
const regEmail = ref('')
const regPhone = ref('')
const regPhoneDisplay = ref('')
const regPassword = ref('')

function onPhoneInput(event: Event) {
  const digits = stripMask((event.target as HTMLInputElement).value).slice(0, 11)
  regPhone.value = digits
  regPhoneDisplay.value = formatPhone(digits)
}

async function handleLogin() {
  loading.value = true
  await auth.login(loginEmail.value, loginPassword.value)
    .then(() => router.push('/dashboard'))
    .catch(() => {})
    .finally(() => (loading.value = false))
}

async function handleRegister() {
  loading.value = true
  await auth.register({ name: regName.value, email: regEmail.value, password: regPassword.value, phone: regPhone.value })
    .then(() => router.push('/dashboard'))
    .catch(() => {})
    .finally(() => (loading.value = false))
}

function resetForm() {
  mode.value = 'select'
  loginEmail.value = ''
  loginPassword.value = ''
  regName.value = ''
  regEmail.value = ''
  regPhone.value = ''
  regPhoneDisplay.value = ''
  regPassword.value = ''
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap');

.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined',serif;
}

/* Tokens locais — espelham o design system do protótipo */
.login-page {
  --primary:                   #0d631b;
  --primary-container:         #2e7d32;
  --primary-fixed:             #a3f69c;
  --surface:                   #f9f9f9;
  --surface-container-lowest:  #ffffff;
  --surface-container-low:     #f3f3f3;
  --surface-container-high:    #e8e8e8;
  --surface-variant:           #e2e2e2;
  --secondary-container:       #fdcdbc;
  --on-surface:                #1a1c1c;
  --on-surface-variant:        #40493d;
  --outline:                   #707a6c;
  --outline-variant:           #bfcaba;

}

.login-page {
  height: 100vh;
  overflow-y: auto;
  background-color: #0a0f0a;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 1.5rem;
  position: relative;
  font-family: 'Inter', sans-serif;
}

.blob {
  position: fixed;
  pointer-events: none;
  border-radius: 9999px;
  filter: blur(80px);
  z-index: 0;
}
.blob-top {
  top: -6rem; left: -6rem;
  width: 24rem; height: 24rem;
  background-color: color-mix(in srgb, var(--primary) 35%, transparent);
}
.blob-bottom {
  bottom: 0; right: 0;
  width: 32rem; height: 32rem;
  background-color: color-mix(in srgb, var(--primary-container) 15%, transparent);
}

.login-main {
  position: relative;
  z-index: 10;
  width: 100%;
  max-width: 28rem;
}

/* ── Card ───────────────────────────── */
.login-card {
  background-color: var(--surface-container-lowest);
  border-radius: 1.5rem;
  box-shadow: 0 25px 50px -12px color-mix(in srgb, var(--primary) 5%, transparent);
  padding: 2rem;
  display: flex;
  flex-direction: column;
  align-items: center;
  text-align: center;
  gap: 1.5rem;
  max-height: calc(100vh - 3rem);
  overflow-y: auto;
}
@media (min-width: 768px) {
  .login-card { padding: 2.5rem; }
}

/* ── Brand ──────────────────────────── */
.brand { display: flex; flex-direction: column; align-items: center; gap: 0.5rem; }

.brand-icon {
  width: 4rem; height: 4rem;
  border-radius: 1rem;
  background: linear-gradient(135deg, var(--primary), var(--primary-container));
  display: flex; align-items: center; justify-content: center;
  box-shadow: 0 8px 24px color-mix(in srgb, var(--primary) 20%, transparent);
}
.brand-icon .material-symbols-outlined {
  font-size: 2.25rem;
  color: #fff;
}
.brand-name {
  font-family: 'Manrope', sans-serif;
  font-size: 1.875rem;
  font-weight: 800;
  color: var(--on-surface);
  letter-spacing: -0.025em;
  margin: 0;
}
.brand-tagline {
  font-size: 0.75rem;
  font-weight: 500;
  color: var(--on-surface-variant);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin: 0;
}

/* ── Heading ────────────────────────── */
.heading { display: flex; flex-direction: column; gap: 0.5rem; }
.heading h2 {
  font-family: 'Manrope', sans-serif;
  font-size: 1.25rem; font-weight: 700;
  color: var(--on-surface); margin: 0;
}
.heading p {
  font-size: 0.875rem;
  color: var(--on-surface-variant);
  line-height: 1.5; margin: 0;
}

/* ── Botões de seleção ──────────────── */
.actions {
  display: flex; flex-direction: column;
  align-items: center; gap: 0.75rem; width: 100%;
}

.btn-google, .btn-email {
  width: 100%;
  display: flex; align-items: center; justify-content: center; gap: 1rem;
  padding: 1rem 1.5rem;
  border-radius: 1rem;
  font-family: 'Inter', sans-serif;
  font-size: 0.9375rem; font-weight: 600;
  cursor: pointer;
  transition: background-color 0.2s, transform 0.1s;
  color: var(--on-surface);
}
.btn-google:active:not(:disabled), .btn-email:active { transform: scale(0.98); }

.btn-google {
  background-color: var(--surface-container-high);
  border: 1px solid color-mix(in srgb, var(--outline-variant) 10%, transparent);
  opacity: 0.55;
  cursor: not-allowed;
}

.btn-email {
  background-color: transparent;
  border: 1px solid color-mix(in srgb, var(--outline) 30%, transparent);
}
.btn-email:hover { background-color: var(--surface-container-low); color: var(--primary); }
.btn-email .material-symbols-outlined {
  font-size: 1.25rem; color: var(--on-surface-variant); transition: color 0.2s;
}
.btn-email:hover .material-symbols-outlined { color: var(--primary); }

.register-link { font-size: 0.875rem; color: var(--on-surface-variant); margin: 0.25rem 0 0; }
.register-link a { color: var(--primary); font-weight: 700; text-decoration: none; }
.register-link a:hover { text-decoration: underline; }

/* ── Formulário e-mail ──────────────── */
.email-form {
  display: flex; flex-direction: column; gap: 1rem;
  width: 100%; text-align: left;
}
.field { display: flex; flex-direction: column; gap: 0.375rem; }
.field label { font-size: 0.875rem; font-weight: 500; color: var(--on-surface-variant); }

.field-label-row {
  display: flex;
  align-items: baseline;
  justify-content: space-between;
}
.forgot-link {
  font-size: 0.8125rem;
  font-weight: 500;
  color: var(--primary);
  text-decoration: none;
}
.forgot-link:hover { text-decoration: underline; }

.btn-back {
  display: flex; align-items: center; justify-content: center; gap: 0.5rem;
  background: none; border: none; cursor: pointer;
  font-family: 'Inter', sans-serif;
  font-size: 0.875rem; font-weight: 500;
  color: var(--on-surface-variant); padding: 0.5rem;
  transition: color 0.2s;
}
.btn-back:hover { color: var(--primary); }
.btn-back .material-symbols-outlined { font-size: 1rem; }


/* ── Legal ──────────────────────────── */
.legal {
  border-top: 1px solid var(--surface-variant);
  padding-top: 1.5rem; width: 100%;
  display: flex; flex-direction: column; gap: 0.5rem; align-items: center;
}
.legal p {
  font-size: 0.625rem;
  color: color-mix(in srgb, var(--on-surface-variant) 70%, transparent);
  text-transform: uppercase; letter-spacing: 0.1em; margin: 0;
}
.legal-links { display: flex; gap: 1rem; }
.legal-links a {
  font-size: 0.625rem; font-weight: 700; color: var(--primary);
  text-transform: uppercase; letter-spacing: 0.1em; text-decoration: none;
}
.legal-links a:hover { color: var(--primary-container); }

/* ── Gradient bar ───────────────────── */
.gradient-bar {
  position: fixed; bottom: 0; left: 0;
  width: 100%; height: 6px;
  background: linear-gradient(to right, var(--primary), var(--primary-container), var(--secondary-container));
  z-index: 10;
}

/* ── Footer ─────────────────────────── */
.login-footer { margin-top: auto; padding: 2rem 0; z-index: 10; }
.login-footer p {
  font-size: 0.625rem; text-transform: uppercase;
  letter-spacing: 0.1em;
  color: color-mix(in srgb, #fff 40%, transparent);
}
</style>
