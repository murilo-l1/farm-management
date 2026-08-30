import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authService } from '@/services/auth.service'
import type { CreateUserPayload, AuthUser } from '@/types/auth'

export const useAuthStore = defineStore('auth', () => {

  const user = ref<AuthUser | null>(null)
  const isAuthenticated = computed(() => user.value !== null)

  async function fetchMe() {
    user.value = await authService.me()
  }

  async function login(email: string, password: string) {
    await authService.login({ email, password })
    await fetchMe()
  }

  async function register(payload: CreateUserPayload) {
    await authService.register(payload)
    await fetchMe()
  }

  async function logout() {
    await authService.logout()
    user.value = null
  }

  function updateProfile(name: string, phone: string) {
    if (user.value) {
      user.value = { ...user.value, name, phone }
    }
  }

  return { user, isAuthenticated, fetchMe, login, register, logout, updateProfile }
})
