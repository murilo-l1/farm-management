<template>
  <Drawer
    v-model:visible="visible"
    :position="isMobile ? 'full' : 'right'"
    :header="header"
    :style="isMobile ? undefined : { width: desktopWidth }"
    class="app-form-drawer"
    :class="{ 'app-form-drawer--mobile': isMobile }"
  >
    <div v-if="showSkeleton" class="drawer-loading">
      <Skeleton
        v-for="i in skeletonRows"
        :key="i"
        height="1.5rem"
        :width="i === skeletonRows ? '40%' : '60%'"
        class="drawer-loading__row"
      />
    </div>
    <slot v-else />
  </Drawer>
</template>

<script setup lang="ts">
import Drawer from 'primevue/drawer'
import Skeleton from 'primevue/skeleton'
import { useBreakpoint } from '@/composables/useBreakpoint'

withDefaults(defineProps<{
  header: string
  showSkeleton?: boolean
  desktopWidth?: string
  skeletonRows?: number
}>(), {
  showSkeleton: false,
  desktopWidth: '36rem',
  skeletonRows: 4,
})

const visible = defineModel<boolean>('visible', { required: true })

const { isMobile } = useBreakpoint()
</script>

<style>
.app-form-drawer--mobile .p-drawer-header {
  padding-top: calc(1.25rem + env(safe-area-inset-top));
  padding-left: max(1.25rem, env(safe-area-inset-left));
  padding-right: max(1.25rem, env(safe-area-inset-right));
}

.app-form-drawer--mobile .p-drawer-content {
  padding-left: env(safe-area-inset-left);
  padding-right: env(safe-area-inset-right);
  padding-bottom: 0;
}
</style>

<style scoped>
.drawer-loading {
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
}

.drawer-loading__row:not(:last-child) {
  margin-bottom: 1rem;
}
</style>
