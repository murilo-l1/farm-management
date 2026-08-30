package com.dev.farmmanager.usecase.user;

import com.dev.farmmanager.domain.payload.user.ChangePasswordPayload;
import com.dev.farmmanager.domain.payload.user.UpdateUserPayload;
import com.dev.farmmanager.exception.handler.UsernameNotAllowedException;
import com.dev.farmmanager.mapper.UserMapper;
import com.dev.farmmanager.security.SecurityUtils;
import com.dev.farmmanager.service.user.UserService;
import lombok.NonNull;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class UserCommandImpl implements UserCommand {

    private final UserService service;

    public UserCommandImpl(UserService service, UserMapper mapper) {
        this.service = service;
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResponseEntity<Void> update(@NonNull UpdateUserPayload payload) {
        final Integer userId = SecurityUtils.getCurrentUserId();

        if ("admin".equals(payload.name())) {
            throw new UsernameNotAllowedException();
        }

        service.update(userId, payload);

        return ResponseEntity.noContent().build();
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResponseEntity<Void> changePassword(@NonNull ChangePasswordPayload payload) {
        final Integer userId = SecurityUtils.getCurrentUserId();

        service.changePassword(userId, payload);

        return ResponseEntity.noContent().build();
    }

}
