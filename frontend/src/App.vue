<template>
  <RouterView />
  <Toast :breakpoints="{ '767px': { width: 'calc(100vw - 2rem)', left: '1rem', right: '1rem' } }" />
  <ConfirmDialog :breakpoints="{ '575px': '92vw' }" />
</template>

<script setup lang="ts">
import Toast from 'primevue/toast'
import ConfirmDialog from 'primevue/confirmdialog'
import { useToast } from 'primevue/usetoast'
import { registerToast } from '@/services/toast'

registerToast(useToast())
</script>

<style>
*, *::before, *::after { box-sizing: border-box; }

html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  overflow: hidden;
}

#app {
  height: 100%;
}

</style>
