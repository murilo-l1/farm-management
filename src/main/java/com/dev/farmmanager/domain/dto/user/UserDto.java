package com.dev.farmmanager.domain.dto.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record UserDto(
        @NotNull Integer id,
        @NotBlank String name,
        @Email @NotBlank String email,
        @NotBlank String phone,
        @NotNull Boolean active
) {}
