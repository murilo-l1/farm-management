-- =============================================================================
-- Conta de demonstração pública — demo@quantaplanta.com / quanta123
-- > docker exec -i farm-local-database psql -U farmadmin -d farmdb < docker/init/demo_data.sql
-- =============================================================================

SET client_encoding = 'UTF8';

BEGIN;

DELETE FROM transaction_item
WHERE transaction_id IN (
    SELECT t.id FROM transaction t
    WHERE t.user_id IN (SELECT id FROM farm_user WHERE email = 'demo@quantaplanta.com')
);

DELETE FROM transaction
WHERE user_id IN (SELECT id FROM farm_user WHERE email = 'demo@quantaplanta.com');

DELETE FROM crop_cycle
WHERE user_id IN (SELECT id FROM farm_user WHERE email = 'demo@quantaplanta.com');

DELETE FROM item
WHERE user_id IN (SELECT id FROM farm_user WHERE email = 'demo@quantaplanta.com');

DELETE FROM category
WHERE user_id IN (SELECT id FROM farm_user WHERE email = 'demo@quantaplanta.com');

DELETE FROM stakeholder
WHERE user_id IN (SELECT id FROM farm_user WHERE email = 'demo@quantaplanta.com');

DELETE FROM farm_user WHERE email = 'demo@quantaplanta.com';


INSERT INTO farm_user (name, phone, email, password, created_at, updated_at)
VALUES ('Demo QuantaPlanta', '35998887766', 'demo@quantaplanta.com',
        '$2a$10$N2hlORbEkx1lLX0LuolE3OwS5YC1cVdFSpggJae7Kc50yIvC2k7Ri',
        now(), now());


INSERT INTO category (user_id, name, color, created_at, updated_at)
SELECT u.id, v.name, v.color, now(), now()
FROM farm_user u
CROSS JOIN (VALUES
    ('Fertilizantes'::text,     '#1565c0'::text),
    ('Combustível',             '#f9a825'),
    ('Manutenção Equipamento',  '#6a1b9a'),
    ('Herbicidas',              '#c62828'),
    ('Embalagem',               '#2e7d32')
) AS v(name, color)
WHERE u.email = 'demo@quantaplanta.com';

INSERT INTO stakeholder (user_id, name, cnpj, cpf, type, phone, created_at, updated_at)
SELECT u.id, v.name, v.cnpj, v.cpf, v.type::stakeholder_type, v.phone, now(), now()
FROM farm_user u
CROSS JOIN (VALUES
    ('AgroInsumos Sul de Minas'::text, '11223344000186'::text, NULL::text,    'SUPPLIER'::text, '35991110001'::text),
    ('Quitanda Central Distribuidora', '45987654000199',       NULL,          'BUYER',          '35992220002'),
    ('José Carlos Ribeiro',            NULL,                   '52998224725', 'BOTH',           '35993330003')
) AS v(name, cnpj, cpf, type, phone)
WHERE u.email = 'demo@quantaplanta.com';


INSERT INTO item (user_id, category_id, name, unity, brand, created_at, updated_at)
SELECT u.id, c.id, v.name, v.unity, v.brand, now(), now()
FROM farm_user u
CROSS JOIN (VALUES
    ('Adubo NPK 04-14-08'::text, 'kg'::text, 'Yara'::text, 'Fertilizantes'::text),
    ('Calcário Dolomítico',      'kg',       'Ibar',       'Fertilizantes'),
    ('Óleo Diesel S-10',         'L',        'Petrobras',  'Combustível'),
    ('Óleo Lubrificante 15W40',  'L',        'Ipiranga',   'Manutenção Equipamento'),
    ('Kit Bicos Pulverizador',   'un',       'Jacto',      'Manutenção Equipamento'),
    ('Herbicida Glifosato',      'L',        'Nufarm',     'Herbicidas'),
    ('Herbicida Atrazina',       'L',        'Nortox',     'Herbicidas'),
    ('Caixa Plástica 20kg',      'un',       'Rioplas',    'Embalagem'),
    ('Bandeja PET 500g',         'un',       'Prafesta',   'Embalagem')
) AS v(name, unity, brand, category_name)
JOIN category c ON c.user_id = u.id AND c.name = v.category_name
WHERE u.email = 'demo@quantaplanta.com';

INSERT INTO crop_cycle (user_id, name, crop, planted_area, measurement_unit, plant_count,
                        planned_budget, target_yield, status, start_date, end_date,
                        created_at, updated_at)
SELECT u.id, v.name, v.crop, v.planted_area, v.measurement_unit::measurement_unit, v.plant_count,
       v.planned_budget, v.target_yield, v.status::crop_cycle_status,
       v.start_date::date, v.end_date::date, now(), now()
FROM farm_user u
CROSS JOIN (VALUES
    ('Abobrinha Italiana - Safra 2026/1'::text, 'Abobrinha'::text, 800.00::numeric, 'METRO_QUADRADO'::text, NULL::integer, 5000.00::numeric,  9000.00::numeric, 'FINISHED'::text, '2025-12-01'::text, '2026-06-30'::text),
    ('Tomate Italiano - Safra 2026/2',          'Tomate',          NULL,            'PES',                  1200,          6000.00,          16000.00,          'HARVESTING',     '2026-03-10',       '2026-11-20')
) AS v(name, crop, planted_area, measurement_unit, plant_count,
       planned_budget, target_yield, status, start_date, end_date)
WHERE u.email = 'demo@quantaplanta.com';

INSERT INTO transaction (user_id, crop_cycle_id, stakeholder_id, category_id,
                         type, description, total_value, transaction_date,
                         status, payment_method, created_at, updated_at)
SELECT u.id, cc.id, s.id, cat.id, v.type::transaction_type, v.description,
       v.total_value, v.transaction_date::date, v.status::transaction_status,
       v.payment_method::payment_method, now(), now()
FROM farm_user u
CROSS JOIN (VALUES
    -- Despesas da abobrinha (soma 4.108,00, dentro do orçamento de 5.000,00)
    ('Abobrinha Italiana - Safra 2026/1'::text, 'AgroInsumos Sul de Minas'::text, 'Fertilizantes'::text,   'EXPENSE'::text, 'Adubação de base - Abobrinha'::text,      1325.00::numeric, '2025-12-05'::text, 'FINISHED'::text, 'PIX'::text),
    ('Abobrinha Italiana - Safra 2026/1',       'AgroInsumos Sul de Minas',       'Herbicidas',            'EXPENSE',       'Controle de plantas daninhas - Abobrinha',  500.00,         '2026-01-14',       'FINISHED',       'BOLETO'),
    ('Abobrinha Italiana - Safra 2026/1',       'José Carlos Ribeiro',            'Combustível',           'EXPENSE',       'Diesel do trator - preparo e tratos',      1107.00,         '2026-02-20',       'FINISHED',       'CARD'),
    ('Abobrinha Italiana - Safra 2026/1',       'AgroInsumos Sul de Minas',       'Embalagem',             'EXPENSE',       'Embalagens para colheita - Abobrinha',     1176.00,         '2026-05-08',       'FINISHED',       'PIX'),

    -- Despesas do tomate (soma 6.473,00, acima do orçamento de 6.000,00)
    ('Tomate Italiano - Safra 2026/2',          'AgroInsumos Sul de Minas',       'Fertilizantes',         'EXPENSE',       'Correção e adubação de solo - Tomate',     1940.00,         '2026-03-12',       'FINISHED',       'BOLETO'),
    ('Tomate Italiano - Safra 2026/2',          'José Carlos Ribeiro',            'Manutenção Equipamento','EXPENSE',       'Manutenção do pulverizador',                746.00,         '2026-04-18',       'FINISHED',       'PIX'),
    ('Tomate Italiano - Safra 2026/2',          'AgroInsumos Sul de Minas',       'Herbicidas',            'EXPENSE',       'Herbicida pré-emergente - Tomate',          480.00,         '2026-05-22',       'FINISHED',       'PIX'),
    ('Tomate Italiano - Safra 2026/2',          'José Carlos Ribeiro',            'Combustível',           'EXPENSE',       'Diesel para irrigação e transporte',       1397.00,         '2026-07-09',       'FINISHED',       'CASH'),
    ('Tomate Italiano - Safra 2026/2',          'AgroInsumos Sul de Minas',       'Embalagem',             'EXPENSE',       'Embalagens da colheita - Tomate',          1910.00,         '2026-08-21',       'PENDING',        'BOLETO'),

    -- Vendas da abobrinha (soma 9.250,00, acima da meta de 9.000,00)
    ('Abobrinha Italiana - Safra 2026/1',       'Quitanda Central Distribuidora', NULL,                    'INCOME',        'Venda Abobrinha - 1a colheita',            2450.00,         '2026-03-18',       'FINISHED',       'PIX'),
    ('Abobrinha Italiana - Safra 2026/1',       'Quitanda Central Distribuidora', NULL,                    'INCOME',        'Venda Abobrinha - 2a colheita',            3180.00,         '2026-04-25',       'FINISHED',       'CARD'),
    ('Abobrinha Italiana - Safra 2026/1',       'José Carlos Ribeiro',            NULL,                    'INCOME',        'Venda Abobrinha - lote final',             3620.00,         '2026-06-12',       'FINISHED',       'CHECK'),

    -- Vendas do tomate (soma 14.050,00, ainda abaixo da meta de 16.000,00)
    ('Tomate Italiano - Safra 2026/2',          'Quitanda Central Distribuidora', NULL,                    'INCOME',        'Venda Tomate - 1a colheita',               4900.00,         '2026-07-14',       'FINISHED',       'PIX'),
    ('Tomate Italiano - Safra 2026/2',          'Quitanda Central Distribuidora', NULL,                    'INCOME',        'Venda Tomate - 2a colheita',               6350.00,         '2026-08-06',       'FINISHED',       'BOLETO'),
    ('Tomate Italiano - Safra 2026/2',          'Quitanda Central Distribuidora', NULL,                    'INCOME',        'Venda Tomate - lote em negociação',        2800.00,         '2026-08-28',       'PENDING',        'BOLETO')
) AS v(cycle_name, stakeholder_name, category_name, type, description,
       total_value, transaction_date, status, payment_method)
JOIN      crop_cycle  cc  ON cc.user_id  = u.id AND cc.name  = v.cycle_name
LEFT JOIN stakeholder s   ON s.user_id   = u.id AND s.name   = v.stakeholder_name
LEFT JOIN category    cat ON cat.user_id = u.id AND cat.name = v.category_name
WHERE u.email = 'demo@quantaplanta.com';


INSERT INTO transaction_item (transaction_id, item_id, quantity, unit_price, total_price)
SELECT t.id, i.id, v.quantity, v.unit_price, ROUND(v.quantity * v.unit_price, 2)
FROM farm_user u
CROSS JOIN (VALUES
    ('Adubação de base - Abobrinha'::text,       'Adubo NPK 04-14-08'::text, 200.00::numeric,   5.20::numeric),
    ('Adubação de base - Abobrinha',             'Calcário Dolomítico',      300.00,            0.95),
    ('Controle de plantas daninhas - Abobrinha', 'Herbicida Glifosato',        8.00,           62.50),
    ('Diesel do trator - preparo e tratos',      'Óleo Diesel S-10',         180.00,            6.15),
    ('Embalagens para colheita - Abobrinha',     'Caixa Plástica 20kg',      120.00,            9.80),
    ('Correção e adubação de solo - Tomate',     'Adubo NPK 04-14-08',       300.00,            5.20),
    ('Correção e adubação de solo - Tomate',     'Calcário Dolomítico',      400.00,            0.95),
    ('Manutenção do pulverizador',               'Óleo Lubrificante 15W40',   12.00,           38.00),
    ('Manutenção do pulverizador',               'Kit Bicos Pulverizador',     2.00,          145.00),
    ('Herbicida pré-emergente - Tomate',         'Herbicida Atrazina',        10.00,           48.00),
    ('Diesel para irrigação e transporte',       'Óleo Diesel S-10',         220.00,            6.35),
    ('Embalagens da colheita - Tomate',          'Caixa Plástica 20kg',      150.00,            9.80),
    ('Embalagens da colheita - Tomate',          'Bandeja PET 500g',         800.00,            0.55)
) AS v(description, item_name, quantity, unit_price)
JOIN transaction t ON t.user_id = u.id AND t.description = v.description
JOIN item        i ON i.user_id = u.id AND i.name        = v.item_name
WHERE u.email = 'demo@quantaplanta.com';


-- engenharia reversa KPIs
INSERT INTO crop_cycle_control (crop_cycle_id, current_investment, current_revenue, current_roi,
                                health_score, progress_percentage, alerts_count, last_calculated_at)
SELECT cc.id,
       agg.investment,
       agg.revenue,
       CASE WHEN agg.investment = 0 THEN 0.00
            ELSE ROUND(ROUND((agg.revenue - agg.investment) / agg.investment, 4) * 100, 2)
       END,
       v.health_score,
       CASE WHEN cc.status IN ('FINISHED', 'CANCELLED') THEN 100.00
            WHEN cc.end_date IS NULL THEN 0.00
            ELSE LEAST(100.00, GREATEST(0.00,
                 ROUND((CURRENT_DATE - cc.start_date)::numeric * 100
                       / NULLIF((cc.end_date - cc.start_date), 0), 2)))
       END,
       v.alerts_count,
       now()
FROM farm_user u
CROSS JOIN (VALUES
    ('Abobrinha Italiana - Safra 2026/1'::text, 100, 0),
    ('Tomate Italiano - Safra 2026/2',           94, 1)
) AS v(cycle_name, health_score, alerts_count)
JOIN crop_cycle cc ON cc.user_id = u.id AND cc.name = v.cycle_name
CROSS JOIN LATERAL (
    SELECT COALESCE(SUM(t.total_value) FILTER (WHERE t.type = 'EXPENSE'), 0) AS investment,
           COALESCE(SUM(t.total_value) FILTER (WHERE t.type = 'INCOME'),  0) AS revenue
    FROM transaction t
    WHERE t.crop_cycle_id = cc.id
) agg
WHERE u.email = 'demo@quantaplanta.com';

COMMIT;
