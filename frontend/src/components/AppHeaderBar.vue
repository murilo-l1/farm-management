<template>
  <div class="app-header-bar">
    <div class="header-title">
      <h1>{{ title }}</h1>
      <p v-if="subtitle" class="header-sub">{{ subtitle }}</p>
    </div>
    <AppUserWidget />
  </div>
</template>

<script setup lang="ts">
import AppUserWidget from '@/components/AppUserWidget.vue'

defineProps<{
  title: string
  subtitle?: string
}>()
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Manrope:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap');

.app-header-bar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-shrink: 0;
  gap: 1rem;
}

.header-title h1 {
  font-family: 'Manrope', sans-serif;
  font-size: 1.5rem;
  font-weight: 800;
  color: #1a1c1c;
  margin: 0;
  line-height: 1.2;
}

.header-sub {
  font-size: 0.8125rem;
  color: #40493d;
  margin: 0.25rem 0 0;
}

</style>
