-- =============================================================================
-- Categorias padrão copiadas para cada usuário + integridade de category
-- =============================================================================

-- Template copiado para cada usuário no registro (UserAuthImpl.register)
CREATE TABLE default_category
(
    id    int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name  text       NOT NULL CHECK (name <> ''),
    color varchar(7) NULL CHECK (color IS NULL OR color ~ '^#[0-9A-Fa-f]{6}$')
);

INSERT INTO default_category (name, color)
VALUES ('Sementes e Mudas', '#2e7d32'),
       ('Fertilizantes', '#1565c0'),
       ('Defensivos', '#c62828'),
       ('Combustível', '#f9a825'),
       ('Mão de Obra', '#6d4c41'),
       ('Manutenção', '#6a1b9a'),
       ('Embalagem', '#00838f'),
       ('Vendas', '#43a047');

-- Categorias sem dono não referenciadas por itens são descartadas.
-- Se alguma ainda for referenciada, o SET NOT NULL falha e a migration é abortada (intencional).
DELETE FROM category
WHERE user_id IS NULL
  AND id NOT IN (SELECT category_id FROM item WHERE category_id IS NOT NULL);

ALTER TABLE category ALTER COLUMN user_id SET NOT NULL;

-- Limpa referências órfãs antes de criar a FK
UPDATE transaction
SET category_id = NULL
WHERE category_id IS NOT NULL
  AND category_id NOT IN (SELECT id FROM category);

ALTER TABLE transaction
    ADD CONSTRAINT fk_transaction_category FOREIGN KEY (category_id) REFERENCES category (id);

-- Backfill: somente usuários que ainda não têm nenhuma categoria
INSERT INTO category (user_id, name, color, created_at, updated_at)
SELECT u.id, d.name, d.color, now(), now()
FROM farm_user u
CROSS JOIN default_category d
WHERE u.email <> 'admin@email.com'
  AND NOT EXISTS (SELECT 1 FROM category c WHERE c.user_id = u.id);
