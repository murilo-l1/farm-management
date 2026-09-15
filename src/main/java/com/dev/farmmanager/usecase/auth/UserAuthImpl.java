package com.dev.farmmanager.usecase.auth;

import com.dev.farmmanager.domain.dto.auth.JwtDto;
import com.dev.farmmanager.domain.entity.User;
import com.dev.farmmanager.domain.payload.auth.CreateUserPayload;
import com.dev.farmmanager.domain.payload.auth.EmailLoginPayload;
import com.dev.farmmanager.exception.handler.BlankCredentialsException;
import com.dev.farmmanager.exception.handler.UserNotFoundException;
import com.dev.farmmanager.exception.handler.UsernameNotAllowedException;
import com.dev.farmmanager.mapper.UserMapper;
import com.dev.farmmanager.security.CookieHandler;
import com.dev.farmmanager.service.auth.AuthService;
import com.dev.farmmanager.service.category.CategoryService;
import com.dev.farmmanager.service.user.UserService;

import lombok.NonNull;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class UserAuthImpl implements UserAuth {

    @Value("${farm.jwt.token.expiration}")
    private Long expiresIn;

    private final UserService userService;
    private final CategoryService categoryService;
    private final AuthService authService;
    private final UserMapper userMapper;
    private final CookieHandler cookieHandler;

    public UserAuthImpl(UserService userService, CategoryService categoryService, AuthService authService, UserMapper userMapper, CookieHandler cookieHandler) {
        this.userService = userService;
        this.categoryService = categoryService;
        this.authService = authService;
        this.userMapper = userMapper;
        this.cookieHandler = cookieHandler;
    }

    @Override
    public ResponseEntity<JwtDto> login(@NonNull final EmailLoginPayload payload) {

        if (StringUtils.isBlank(payload.email()) || StringUtils.isBlank(payload.password())) {
            throw new BlankCredentialsException();
        }

        userService.getByEmail(payload.email()).orElseThrow(UserNotFoundException::new);

        final String token = authService.login(payload);

        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, cookieHandler.jwtCookie(token).toString())
                .body(new JwtDto(expiresIn));
    }

    @Transactional(rollbackFor = Exception.class)
    @Override
    public ResponseEntity<Void> register(@NonNull final CreateUserPayload payload) {

        if ("admin".equals(payload.name())) {
            throw new UsernameNotAllowedException();
        }

        User user = userMapper.toEntity(payload);
        User created = userService.create(user);
        categoryService.createDefaults(created.getId());

        final String token = authService.register(payload);

        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, cookieHandler.jwtCookie(token).toString())
                .build();
    }

    @Override
    public ResponseEntity<Void> logout() {
        SecurityContextHolder.clearContext();
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, cookieHandler.expiredJwtCookie().toString())
                .build();
    }
}
