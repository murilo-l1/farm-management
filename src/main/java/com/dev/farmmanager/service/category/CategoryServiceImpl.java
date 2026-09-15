package com.dev.farmmanager.service.category;

import com.dev.farmmanager.domain.entity.Category;
import com.dev.farmmanager.domain.entity.User;
import com.dev.farmmanager.domain.payload.category.CategoryPayload;
import com.dev.farmmanager.exception.handler.CategoryHasItemsException;
import com.dev.farmmanager.exception.handler.CategoryHasTransactionsException;
import com.dev.farmmanager.exception.handler.CategoryNotFoundException;
import com.dev.farmmanager.exception.handler.UserNotFoundException;
import com.dev.farmmanager.repository.CategoryRepository;
import com.dev.farmmanager.repository.ItemRepository;
import com.dev.farmmanager.repository.TransactionRepository;
import com.dev.farmmanager.security.SecurityUtils;
import com.dev.farmmanager.service.user.UserService;
import lombok.NonNull;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CategoryServiceImpl implements CategoryService {

    private final CategoryRepository repository;
    private final ItemRepository itemRepository;
    private final TransactionRepository transactionRepository;
    private final UserService userService;

    @Override
    public List<Category> findAll() {
        return repository.findAllByUserId(SecurityUtils.getCurrentUserId());
    }

    @Override
    public Optional<Category> getById(@NonNull final Integer id) {
        return repository.getByIdAndUserId(id, SecurityUtils.getCurrentUserId());
    }

    @Override
    public Category create(@NonNull final Integer userId, @NonNull final CategoryPayload payload) {
        User user = userService.getById(userId).orElseThrow(UserNotFoundException::new);

        Category category = new Category();
        category.setName(payload.name().trim());
        category.setColor(payload.color());
        category.setUser(user);

        return repository.save(category);
    }

    @Override
    public void createDefaults(@NonNull final Integer userId) {
        repository.copyDefaultsToUser(userId);
    }

    @Override
    public Category update(@NonNull final Integer id, @NonNull final CategoryPayload payload) {
        Category category = this.getById(id).orElseThrow(CategoryNotFoundException::new);
        category.setName(payload.name().trim());
        category.setColor(payload.color());
        return repository.save(category);
    }

    @Override
    public void delete(@NonNull final Integer id) {
        Category category = this.getById(id).orElseThrow(CategoryNotFoundException::new);

        long itemsWithCategory = itemRepository.countAllByCategoryId(id);
        if (itemsWithCategory > 0) {
            throw new CategoryHasItemsException(itemsWithCategory);
        }

        long transactionsWithCategory = transactionRepository.countByCategoryId(id);
        if (transactionsWithCategory > 0) {
            throw new CategoryHasTransactionsException(transactionsWithCategory);
        }

        repository.delete(category);
    }
}
