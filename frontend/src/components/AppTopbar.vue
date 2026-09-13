<template>
  <header class="app-topbar">
    <button type="button" class="topbar-btn" aria-label="Abrir menu" @click="toggleMenu">
      <span class="material-symbols-outlined">menu</span>
    </button>

    <div class="topbar-brand">
      <div class="brand-icon-wrap">
        <Sprout :size="16" color="#fff" :stroke-width="1.5" />
      </div>
      <span class="brand-name">QuantaPlanta</span>
    </div>

    <AppUserWidget class="topbar-user" />
  </header>
</template>

<script setup lang="ts">
import { Sprout } from 'lucide-vue-next'
import AppUserWidget from '@/components/AppUserWidget.vue'
import { useLayout } from '@/composables/useLayout'

const { toggleMenu } = useLayout()
</script>

<style scoped>
.material-symbols-outlined {
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
  font-family: 'Material Symbols Outlined';
}

.app-topbar {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 40;
  height: calc(var(--app-topbar-height) + env(safe-area-inset-top));
  padding-top: env(safe-area-inset-top);
  padding-left: max(0.5rem, env(safe-area-inset-left));
  padding-right: max(0.75rem, env(safe-area-inset-right));
  display: flex;
  align-items: center;
  gap: 0.25rem;
  background-color: #fafafa;
  border-bottom: 1px solid #bfcaba;
  font-family: 'Inter', sans-serif;
}

.topbar-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 2.75rem;
  height: 2.75rem;
  border: none;
  border-radius: 0.75rem;
  background: transparent;
  color: #1a1c1c;
  cursor: pointer;
}

.topbar-btn:active {
  background: color-mix(in srgb, #0d631b 10%, transparent);
}

.topbar-btn .material-symbols-outlined {
  font-size: 1.5rem;
}

.topbar-brand {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  min-width: 0;
}

.brand-icon-wrap {
  width: 1.875rem;
  height: 1.875rem;
  border-radius: 0.5rem;
  background: linear-gradient(135deg, #0d631b, #2e7d32);
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.brand-name {
  font-family: 'Manrope', sans-serif;
  font-size: 1rem;
  font-weight: 800;
  color: #1a1c1c;
}

.topbar-user :deep(.avatar-btn) {
  width: 2.5rem;
  height: 2.5rem;
}
</style>
