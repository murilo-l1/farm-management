package com.dev.farmmanager.domain.payload.user;

import com.dev.farmmanager.exception.handler.message.ErrorMessage;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record ChangePasswordPayload(
        @NotBlank(message = ErrorMessage.REQUIRED_PASSWORD)
        String currentPassword,
        @NotBlank(message = ErrorMessage.REQUIRED_PASSWORD) @Size(min = 8, max = 100, message = ErrorMessage.INVALID_PASSWORD_LENGTH)
        String newPassword
) { }
