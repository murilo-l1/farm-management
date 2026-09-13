<template>
  <aside v-if="isDesktopNav" class="sidebar">
    <AppNavMenu />
  </aside>

  <Drawer
    v-else
    v-model:visible="mobileMenuOpen"
    position="left"
    class="mobile-nav-drawer"
    :pt="{ header: { class: 'hidden' } }"
  >
    <AppNavMenu />
  </Drawer>
</template>

<script setup lang="ts">
import Drawer from 'primevue/drawer'
import AppNavMenu from '@/components/AppNavMenu.vue'
import { useBreakpoint } from '@/composables/useBreakpoint'
import { useLayout } from '@/composables/useLayout'

const { isDesktopNav } = useBreakpoint()
const { mobileMenuOpen } = useLayout()
</script>

<style>
.mobile-nav-drawer.p-drawer {
  width: min(18rem, 85vw);
  background-color: #fafafa;
}

.mobile-nav-drawer .p-drawer-content {
  padding: calc(1rem + env(safe-area-inset-top)) 1rem calc(1rem + env(safe-area-inset-bottom))
    calc(1rem + env(safe-area-inset-left));
}
</style>

<style scoped>
.sidebar {
  position: fixed;
  top: 0; left: 0;
  width: 16rem;
  height: 100dvh;
  background-color: #fafafa;
  border-right: 1px solid #bfcaba;
  padding: 1rem;
  z-index: 50;
}
</style>
