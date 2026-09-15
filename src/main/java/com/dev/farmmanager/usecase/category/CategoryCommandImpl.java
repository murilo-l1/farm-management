package com.dev.farmmanager.usecase.category;

import com.dev.farmmanager.domain.dto.category.CategoryDto;
import com.dev.farmmanager.domain.entity.Category;
import com.dev.farmmanager.domain.payload.category.CategoryPayload;
import com.dev.farmmanager.mapper.CategoryMapper;
import com.dev.farmmanager.security.SecurityUtils;
import com.dev.farmmanager.service.category.CategoryService;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional(rollbackFor = Exception.class)
public class CategoryCommandImpl implements CategoryCommand {

    private final CategoryService service;
    private final CategoryMapper mapper;

    @Override
    public ResponseEntity<CategoryDto> create(@NonNull final CategoryPayload payload) {
        Integer userId = SecurityUtils.getCurrentUserId();
        Category category = service.create(userId, payload);

        return ResponseEntity.ok().body(mapper.toDto(category));
    }

    @Override
    public ResponseEntity<CategoryDto> update(@NonNull final Integer id, @NonNull final CategoryPayload payload) {
        Category category = service.update(id, payload);
        return ResponseEntity.ok(mapper.toDto(category));
    }

    @Override
    public ResponseEntity<Void> delete(@NonNull final Integer id) {
        service.delete(id);

        return ResponseEntity.noContent().build();
    }
}
