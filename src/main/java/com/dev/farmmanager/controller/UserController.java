package com.dev.farmmanager.controller;

import com.dev.farmmanager.controller.base.BaseController;
import com.dev.farmmanager.domain.dto.user.UserDto;
import com.dev.farmmanager.domain.payload.user.ChangePasswordPayload;
import com.dev.farmmanager.domain.payload.user.UpdateUserPayload;
import com.dev.farmmanager.usecase.user.UserCommand;
import com.dev.farmmanager.usecase.user.UserFetch;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping(value = "/api/farm/user", produces = MediaType.APPLICATION_JSON_VALUE)
@RequiredArgsConstructor
@Validated
public class UserController extends BaseController {

    private final UserFetch fetch;
    private final UserCommand update;

    @GetMapping(value = "/me")
    public ResponseEntity<UserDto> getCurrentUser() {
        return fetch.getCurrentUser();
    }

    @PutMapping
    public ResponseEntity<Void> updateCurrentUser(@Valid @RequestBody @NotNull final UpdateUserPayload payload) {
        return update.update(payload);
    }

    @PatchMapping("/password")
    public ResponseEntity<Void> changePassword(@Valid @RequestBody @NotNull final ChangePasswordPayload payload) {
        return update.changePassword(payload);
    }

}
