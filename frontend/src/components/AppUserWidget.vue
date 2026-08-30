<template>
  <div class="user-widget">
    <button class="avatar-btn" :title="auth.user?.name" @click="dialogVisible = true">
      <span class="avatar-initial">{{ userInitial }}</span>
    </button>

    <UserProfileDialog v-model:visible="dialogVisible" />
  </div>
</template>

<script setup lang="ts">
import { computed, ref } from 'vue'
import { useAuthStore } from '@/stores/auth'
import UserProfileDialog from '@/components/UserProfileDialog.vue'

const auth = useAuthStore()
const dialogVisible = ref(false)

const userInitial = computed(() => {
  const name = auth.user?.name ?? ''
  return name.charAt(0).toUpperCase()
})
</script>

<style scoped>
.user-widget {
  pointer-events: auto;
}

.avatar-btn {
  width: 3rem;
  height: 3rem;
  border-radius: 50%;
  border: 2px solid #bfcaba;
  background: linear-gradient(135deg, #0d631b, #2e7d32);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: border-color 0.15s, box-shadow 0.15s;
}

.avatar-btn:hover {
  border-color: #0d631b;
  box-shadow: 0 0 0 3px color-mix(in srgb, #0d631b 20%, transparent);
}

.avatar-initial {
  font-family: 'Manrope', sans-serif;
  font-size: 1rem;
  font-weight: 700;
  color: #ffffff;
  line-height: 1;
  user-select: none;
}
</style>
