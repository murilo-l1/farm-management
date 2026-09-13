<template>
  <div class="nav-menu">
    <!-- Brand -->
    <div class="sidebar-brand">
      <div class="brand-icon-wrap">
        <Sprout :size="18" color="#fff" :stroke-width="1.5" />
      </div>
      <div>
        <p class="brand-name">QuantaPlanta</p>
        <p class="brand-sub">Gestão Agrária Digital</p>
      </div>
    </div>

    <!-- Nav items via PrimeVue Menu -->
    <nav class="sidebar-nav">
      <Menu :model="navItems" class="sidebar-menu">
        <template #item="{ item, props }">
          <router-link :to="item.route" custom v-slot="{ href, navigate, isExactActive }">
            <a
              :href="href"
              @click="navigate"
              class="nav-link"
              :class="{ 'nav-link--active': isExactActive }"
              v-bind="props.action"
            >
              <span class="material-symbols-outlined nav-icon" :class="{ 'nav-icon--active': isExactActive }">
                {{ item.materialIcon }}
              </span>
              <span class="nav-label">{{ item.label }}</span>
            </a>
          </router-link>
        </template>
      </Menu>
    </nav>

    <!-- Footer: suporte + logout -->
    <div class="sidebar-footer">
      <button class="nav-link nav-link--footer">
        <span class="material-symbols-outlined nav-icon">help</span>
        <span class="nav-label">Suporte</span>
      </button>
      <button class="nav-link nav-link--logout" @click="handleLogout">
        <span class="material-symbols-outlined nav-icon">logout</span>
        <span class="nav-label">Sair</span>
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import Menu from 'primevue/menu'
import { Sprout } from 'lucide-vue-next'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = useRouter()
const auth = useAuthStore()

const navItems = [
  { label: 'Dashboard',  route: '/dashboard',  materialIcon: 'dashboard'   },
  { label: 'Safras',     route: '/safras',      materialIcon: 'potted_plant' },
  { label: 'Financeiro', route: '/financeiro',  materialIcon: 'payments'    },
  { label: 'Inventário', route: '/inventario',  materialIcon: 'inventory_2' },
  { label: 'Categorias', route: '/categorias',  materialIcon: 'category'    },
  { label: 'Parceiros',  route: '/parceiros',   materialIcon: 'handshake'   },
]

async function handleLogout() {
  await auth.logout()
  await router.push('/login')
}
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap');

/* Reset PrimeVue Menu para sidebar */
.sidebar-menu.p-menu {
  background: transparent;
  border: none;
  padding: 0;
  width: 100%;
  border-radius: 0;
}

.sidebar-menu .p-menu-list {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  padding: 0;
}

.sidebar-menu .p-menuitem {
  padding: 0;
}

.sidebar-menu .p-menuitem-content {
  border-radius: 0.75rem;
  overflow: hidden;
  background: transparent !important;
}

/* Neutraliza o overlay preto que o PrimeVue injeta no foco/click */
.sidebar-menu .p-menuitem.p-focus > .p-menuitem-content,
.sidebar-menu .p-menuitem > .p-menuitem-content:focus,
.sidebar-menu .p-menuitem > .p-menuitem-content:active {
  background: transparent !important;
  box-shadow: none !important;
}
</style>

<style scoped>
.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined';
}

/* ── Tokens ────────────────────────── */
.nav-menu {
  --primary:             #0d631b;
  --primary-container:   #2e7d32;
  --on-surface:          #1a1c1c;
  --on-surface-variant:  #40493d;
  --surface-low:         #f3f3f3;
  --outline-variant:     #bfcaba;
}

.nav-menu {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
  height: 100%;
  font-family: 'Inter', sans-serif;
}

/* ── Brand ─────────────────────────── */
.sidebar-brand {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  margin-bottom: 0.5rem;
}

.brand-icon-wrap {
  width: 2.25rem; height: 2.25rem;
  border-radius: 0.5rem;
  background: linear-gradient(135deg, var(--primary), var(--primary-container));
  display: flex; align-items: center; justify-content: center;
  flex-shrink: 0;
}

.brand-name {
  font-family: 'Manrope', sans-serif;
  font-size: 0.9375rem;
  font-weight: 800;
  color: var(--on-surface);
  margin: 0;
  line-height: 1.2;
}

.brand-sub {
  font-size: 0.625rem;
  font-weight: 500;
  color: var(--on-surface-variant);
  text-transform: uppercase;
  letter-spacing: 0.08em;
  margin: 0;
}

/* ── Nav ───────────────────────────── */
.sidebar-nav {
  flex: 1;
  overflow-y: auto;
}

.nav-link {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  width: 100%;
  padding: 0.75rem 1rem;
  border-radius: 0.75rem;
  border: none;
  background: none;
  cursor: pointer;
  text-decoration: none;
  font-family: 'Inter', sans-serif;
  font-size: 0.875rem;
  font-weight: 500;
  color: var(--on-surface-variant);
  transition: background-color 0.15s, color 0.15s;
}

.nav-link--active {
  background-color: transparent;
  color: var(--primary);
  font-weight: 600;
  box-shadow: inset 0 0 0 2px var(--primary);
}

.nav-icon {
  font-size: 1.25rem;
  color: var(--on-surface-variant);
  transition: color 0.15s;
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

.nav-icon--active {
  color: var(--primary);
  font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

.nav-link--active .nav-icon {
  color: var(--primary);
}

/* hover só com mouse, no toque ele fica grudado */
@media (hover: hover) {
  .nav-link:hover {
    background-color: transparent;
    color: var(--on-surface);
    box-shadow: inset 0 0 0 1.5px color-mix(in srgb, var(--primary) 45%, transparent);
  }

  .nav-link--active:hover {
    background-color: transparent;
    box-shadow: inset 0 0 0 2px var(--primary);
  }

  .nav-link:hover .nav-icon {
    color: var(--on-surface);
  }

  .nav-link--active:hover .nav-icon {
    color: var(--primary);
  }

  .nav-link--logout:hover {
    background-color: color-mix(in srgb, #ba1a1a 8%, transparent);
    color: #ba1a1a;
  }

  .nav-link--logout:hover .nav-icon {
    color: #ba1a1a;
  }
}

/* ── Footer ────────────────────────── */
.sidebar-footer {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  padding-top: 0.75rem;
  border-top: 1px solid var(--outline-variant);
}

.nav-link--footer {
  color: var(--on-surface-variant);
}
</style>
