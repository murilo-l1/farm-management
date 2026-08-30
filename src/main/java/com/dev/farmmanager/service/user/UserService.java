package com.dev.farmmanager.service.user;

import com.dev.farmmanager.domain.entity.User;
import com.dev.farmmanager.domain.payload.user.ChangePasswordPayload;
import com.dev.farmmanager.domain.payload.user.UpdateUserPayload;
import jakarta.validation.constraints.NotBlank;
import lombok.NonNull;

import java.util.Optional;

public interface UserService {

    Optional<User> getById(@NonNull final Integer id);

    Optional<User> getByEmail(@NonNull @NotBlank final String email);

    User create(@NonNull User user);

    User update(@NonNull final Integer userId, @NonNull UpdateUserPayload payload);

    void changePassword(@NonNull final Integer userId, @NonNull ChangePasswordPayload payload);

}
