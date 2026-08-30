package com.dev.farmmanager.usecase.user;

import com.dev.farmmanager.domain.dto.user.UserDto;
import lombok.NonNull;
import org.springframework.http.ResponseEntity;

public interface UserFetch {

    ResponseEntity<UserDto> getCurrentUser();

    ResponseEntity<UserDto> getById(@NonNull final Integer userId);

}
