package com.dev.farmmanager.repository;

import com.dev.farmmanager.domain.entity.Category;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Integer> {

    List<Category> findAllByUserId(Integer userId);

    @EntityGraph(attributePaths = "user")
    Optional<Category> getByIdAndUserId(Integer id, Integer userId);

    @Modifying
    @Query(nativeQuery = true, value = """
            INSERT INTO category (user_id, name, color, created_at, updated_at)
            SELECT :userId, name, color, now(), now() FROM default_category
            """)
    int copyDefaultsToUser(@Param("userId") Integer userId);
}
