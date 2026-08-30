package com.dev.farmmanager.usecase.user;

import com.dev.farmmanager.domain.dto.user.UserDto;
import com.dev.farmmanager.domain.entity.User;
import com.dev.farmmanager.exception.handler.UserNotFoundException;
import com.dev.farmmanager.mapper.UserMapper;
import com.dev.farmmanager.security.SecurityUtils;
import com.dev.farmmanager.service.user.UserService;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.validation.annotation.Validated;

@Service
@Validated
@RequiredArgsConstructor
public class UserFetchImpl implements UserFetch {

    private final UserService service;
    private final UserMapper mapper;

    @Override
    public ResponseEntity<UserDto> getCurrentUser() {
        Integer userId = SecurityUtils.getCurrentUserId();
        User user = service.getById(userId).orElseThrow(UserNotFoundException::new);

        return ResponseEntity.ok(mapper.toDto(user));
    }

    @Override
    public ResponseEntity<UserDto> getById(final @NonNull Integer userId) {
        User user = service.getById(userId).orElseThrow(UserNotFoundException::new);

        UserDto dto = mapper.toDto(user);

        return ResponseEntity.ok(dto);
    }
}
