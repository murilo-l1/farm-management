package com.dev.farmmanager.domain.payload.user;

import com.dev.farmmanager.exception.handler.message.ErrorMessage;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record UpdateUserPayload(
        @NotBlank(message = ErrorMessage.REQUIRED_NAME) @Size(min = 5, max = 100, message = ErrorMessage.INVALID_NAME_LENGTH)
        String name,
        @NotBlank(message = ErrorMessage.REQUIRED_PHONE) @Size(min = 10, max = 11, message = ErrorMessage.INVALID_PHONE_LENGTH)
        String phone
) { }
