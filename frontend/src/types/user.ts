export interface UpdateProfilePayload {
  name: string
  phone: string
}

export interface ChangePasswordPayload {
  current_password: string
  new_password: string
}
