package com.dev.farmmanager.usecase.user;

import com.dev.farmmanager.domain.payload.user.ChangePasswordPayload;
import com.dev.farmmanager.domain.payload.user.UpdateUserPayload;
import lombok.NonNull;
import org.springframework.http.ResponseEntity;

public interface UserCommand {

    ResponseEntity<Void> update(@NonNull final UpdateUserPayload payload);

    ResponseEntity<Void> changePassword(@NonNull final ChangePasswordPayload payload);

}
