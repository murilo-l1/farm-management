package com.dev.farmmanager.service.category;

import com.dev.farmmanager.domain.entity.Category;
import com.dev.farmmanager.domain.payload.category.CategoryPayload;
import lombok.NonNull;

import java.util.List;
import java.util.Optional;

public interface CategoryService {

    List<Category> findAll();

    Optional<Category> getById(@NonNull final Integer id);

    Category create(@NonNull final Integer userId, @NonNull final CategoryPayload payload);

    void createDefaults(@NonNull final Integer userId);

    Category update(@NonNull final Integer id, @NonNull final CategoryPayload payload);

    void delete(@NonNull final Integer id);
}
