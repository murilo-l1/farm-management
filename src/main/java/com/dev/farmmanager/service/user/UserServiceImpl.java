package com.dev.farmmanager.service.user;

import com.dev.farmmanager.domain.entity.User;
import com.dev.farmmanager.domain.payload.user.ChangePasswordPayload;
import com.dev.farmmanager.domain.payload.user.UpdateUserPayload;
import com.dev.farmmanager.exception.handler.UserNotFoundException;
import com.dev.farmmanager.exception.handler.WrongPasswordException;
import com.dev.farmmanager.repository.UserRepository;
import lombok.NonNull;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserServiceImpl implements UserService {

    private final UserRepository repository;
    private final PasswordEncoder passwordEncoder;

    public UserServiceImpl(UserRepository repository, PasswordEncoder passwordEncoder) {
        this.repository = repository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public Optional<User> getById(@NonNull final Integer id) {
        return repository.findById(id);
    }

    @Override
    public Optional<User> getByEmail(@NonNull final String email) {
        return repository.findUserByEmail(email);
    }

    @Override
    public User create(@NonNull User user) {
        if (this.getByEmail(user.getEmail()).isPresent()) {
            throw new com.dev.farmmanager.exception.handler.UserAlreadyExistsException();
        }
        user.setPassword(passwordEncoder.encode(user.getPassword()));

        return repository.save(user);
    }

    @Override
    public User update(@NonNull Integer userId, @NonNull UpdateUserPayload payload) {
        User user = repository.findById(userId).orElseThrow(UserNotFoundException::new);

        user.setName(payload.name());
        user.setPhone(payload.phone());

        return repository.save(user);
    }

    @Override
    public void changePassword(@NonNull Integer userId, @NonNull ChangePasswordPayload payload) {
        User user = repository.findById(userId).orElseThrow(UserNotFoundException::new);

        if (!passwordEncoder.matches(payload.currentPassword(), user.getPassword())) {
            throw new WrongPasswordException();
        }

        user.setPassword(passwordEncoder.encode(payload.newPassword()));
        repository.save(user);
    }

}
