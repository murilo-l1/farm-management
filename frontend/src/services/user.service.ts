import http from '@/api/http'
import type { UpdateProfilePayload, ChangePasswordPayload } from '@/types/user'

export const userService = {
  updateProfile: (payload: UpdateProfilePayload) =>
    http.put('/farm/user', payload),

  changePassword: (payload: ChangePasswordPayload) =>
    http.patch('/farm/user/password', payload),
}
