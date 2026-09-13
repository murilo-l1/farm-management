<template>
  <div class="app-layout">
    <AppSidebar />
    <AppTopbar v-if="!isDesktopNav" />
    <main class="app-content">
      <RouterView />
    </main>
  </div>
</template>

<script setup lang="ts">
import AppSidebar from '@/components/AppSidebar.vue'
import AppTopbar from '@/components/AppTopbar.vue'
import { useBreakpoint } from '@/composables/useBreakpoint'

const { isDesktopNav } = useBreakpoint()
</script>

<style scoped>
.app-layout {
  display: flex;
  height: 100%;
  background-color: #f9f9f9;
}

.app-content {
  flex: 1;
  min-width: 0;
  height: 100dvh;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
}

@media (min-width: 1024px) {
  .app-content {
    margin-left: 16rem;
  }
}

@media (max-width: 1023px) {
  .app-content {
    padding-top: calc(var(--app-topbar-height) + env(safe-area-inset-top));
    padding-bottom: env(safe-area-inset-bottom);
  }
}
</style>
