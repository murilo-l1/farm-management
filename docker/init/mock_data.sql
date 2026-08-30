--teste@email.com / teste123
INSERT INTO farm_user (name, phone, email, password, created_at, updated_at)
VALUES ('teste', '11999990000', 'teste@email.com',
        '$2a$10$PuXMk9tmiB0jp/Z3j8KkH.ioAQ/o1bmENE/Pr6oUHans3pD.g38ae',
        now(), now());


INSERT INTO crop_cycle (user_id, name, crop, planted_area, measurement_unit, plant_count,
                        planned_budget, target_yield, status, start_date, end_date,
                        created_at, updated_at)
VALUES
    (2, 'Tomate Cereja - Safra 2024/1',     'Tomate Cereja',   500.00, 'METRO_QUADRADO', NULL, 2800.00, 4200.00, 'FINISHED',   '2024-02-15', '2024-07-10', now(), now()),
    (2, 'Alface Crespa - Verão 2023/24',    'Alface Crespa',   200.00, 'METRO_QUADRADO', NULL,  650.00, 1100.00, 'FINISHED',   '2023-11-01', '2024-01-20', now(), now()),
    (2, 'Cenoura Nantes - Inverno 2024',    'Cenoura',           0.30, 'HECTARE',         NULL, 1400.00, 2500.00, 'ACTIVE',     '2024-05-10', '2024-10-15', now(), now()),
    (2, 'Pimentão Vermelho - 2º Sem 2024',  'Pimentão',        400.00, 'METRO_QUADRADO', NULL, 3200.00, 5500.00, 'PLANTING',   '2024-08-01', '2025-01-15', now(), now()),
    (2, 'Abobrinha Caipira - Primavera',    'Abobrinha',       350.00, 'METRO_QUADRADO', NULL, 1800.00, 3000.00, 'HARVESTING', '2024-06-01', '2024-09-30', now(), now()),
    (2, 'Brócolis Ninja - Outono 2024',     'Brócolis',        250.00, 'METRO_QUADRADO', NULL, 1200.00, 2000.00, 'PLANNING',   '2024-10-01', '2025-01-10', now(), now()),
    (2, 'Pepino Japonês - 2024/2',          'Pepino',          300.00, 'METRO_QUADRADO', NULL, 1600.00, 2800.00, 'ACTIVE',     '2024-07-15', '2024-11-30', now(), now()),
    (2, 'Tomate Italiano - Safra 2023/2',   'Tomate Italiano', 600.00, 'METRO_QUADRADO', NULL, 3500.00, 5800.00, 'CANCELLED',  '2023-08-01',        NULL, now(), now()),
    (2, 'Rúcula Primavera 2024',            'Rúcula',          150.00, 'METRO_QUADRADO', NULL,  380.00,  700.00, 'PLANNING',   '2024-09-15', '2024-11-30', now(), now()),
    (2, 'Couve-flor Verônica - 2024/1',     'Couve-flor',      NULL,   'PES',             700, 2200.00, 3600.00, 'FINISHED',   '2024-03-01', '2024-07-20', now(), now());

INSERT INTO crop_cycle_control (crop_cycle_id, current_investment, current_revenue, current_roi,
                                 health_score, progress_percentage, alerts_count, last_calculated_at)
VALUES
    (1,  2800.00, 4550.00,  62.50, 95, 100.00, 0, now()),
    (2,   650.00, 1080.00,  66.15, 92, 100.00, 0, now()),
    (3,   980.00, 2150.00, 119.39, 78,  86.00, 1, now()),
    (4,  1200.00, 1800.00,  50.00, 85,  40.00, 0, now()),
    (5,  1800.00, 3300.00,  83.33, 88, 100.00, 1, now()),
    (7,   750.00, 2950.00, 293.33, 82,  95.00, 0, now()),
    (10, 2200.00, 3840.00,  74.55, 97, 100.00, 0, now());

INSERT INTO category (user_id, name, color, created_at, updated_at)
VALUES
    (2, 'Defensivos Agrícolas', '#c62828', now(), now()),
    (2, 'Fertilizantes',        '#1565c0', now(), now()),
    (2, 'Sementes',             '#2e7d32', now(), now()),
    (2, 'Equipamentos',         '#e65100', now(), now()),
    (2, 'Embalagens',           '#6a1b9a', now(), now());

INSERT INTO item (user_id, category_id, name, unity, brand, created_at, updated_at)
VALUES
    (2, 1, 'Herbicida Roundup',          'L',   'Monsanto',   now(), now()),
    (2, 1, 'Fungicida Amistar',          'L',   'Syngenta',   now(), now()),
    (2, 1, 'Inseticida Decis',           'mL',  'Bayer',      now(), now()),
    (2, 2, 'Adubo NPK 10-10-10',         'kg',  'Yara',       now(), now()),
    (2, 2, 'Calcário Dolomítico',        'kg',  'Ibar',       now(), now()),
    (2, 3, 'Semente Tomate Híbrido',     'un',  'Sakata',     now(), now()),
    (2, 3, 'Semente Alface Crespa',      'un',  'Feltrin',    now(), now()),
    (2, 4, 'Mangueira de Irrigação',     'm',   'Tigre',      now(), now()),
    (2, 5, 'Caixa Plástica Colheita',    'un',  'Rioplas',    now(), now()),
    (2, NULL, 'Fita de Tutoramento',     'm',   NULL,         now(), now());

INSERT INTO stakeholder (user_id, name, cnpj, cpf, type, phone, created_at, updated_at)
VALUES
    (2, 'AgroDistribuidora Minas',         '12345678000190', NULL, 'SUPPLIER', '31991110001', now(), now()),
    (2, 'Cooperativa Agropecuária Central','98765432000110', NULL, 'BUYER',    '31992220002', now(), now()),
    (2, 'Sakata Sementes Brasil',          '45678901000123', NULL, 'SUPPLIER', '11993330003', now(), now());

INSERT INTO transaction (user_id, crop_cycle_id, stakeholder_id, category_id,
                         type, description, total_value, transaction_date,
                         status, payment_method, created_at, updated_at)
VALUES
    (2,  1, NULL, 4,    'EXPENSE', 'Aluguel bomba de irrigação',           450.00, '2024-04-15', 'FINISHED', 'PIX',    now(), now()),  
    (2,  1, NULL, NULL, 'EXPENSE', 'Mão de obra – colheita tomate',        800.00, '2024-06-20', 'FINISHED', 'CASH',   now(), now()),  
    (2,  1, 2,    NULL, 'INCOME',  'Venda Tomate Cereja – lote 1',        2200.00, '2024-06-25', 'FINISHED', 'PIX',    now(), now()),  
    (2,  1, 2,    NULL, 'INCOME',  'Venda Tomate Cereja – lote 2',        1950.00, '2024-07-05', 'FINISHED', 'PIX',    now(), now()),  
    
    (2,  2, NULL, NULL, 'EXPENSE', 'Mão de obra – colheita alface',        320.00, '2024-01-10', 'FINISHED', 'CASH',   now(), now()),  
    (2,  2, 2,    NULL, 'INCOME',  'Venda Alface Crespa – entrega total', 1080.00, '2024-01-18', 'FINISHED', 'BOLETO', now(), now()),  
    
    (2,  3, 1,    NULL, 'EXPENSE', 'Frete entrega insumos – cenoura',      180.00, '2024-05-12', 'FINISHED', 'PIX',    now(), now()),  
    
    (2,  5, 2,    NULL, 'INCOME',  'Venda Abobrinha Caipira – lote 1',   1400.00, '2024-09-10', 'FINISHED', 'PIX',    now(), now()),  
    
    (2,  7, NULL, NULL, 'EXPENSE', 'Energia elétrica – bomba irrigação',   230.00, '2024-09-15', 'PENDING',  'BOLETO', now(), now()),  
    
    (2, 10, 2,    NULL, 'INCOME',  'Venda Couve-flor Verônica',           3520.00, '2024-07-15', 'FINISHED', 'PIX',    now(), now()),  

    (2,  1, 1, 1, 'EXPENSE', 'Compra defensivos – Tomate Cereja',          290.00, '2024-03-20', 'FINISHED', 'BOLETO', now(), now()), 
    (2,  1, 3, 3, 'EXPENSE', 'Sementes Tomate Híbrido – plantio inicial',  425.00, '2024-02-16', 'FINISHED', 'PIX',    now(), now()),  

    (2,  2, 3, 3, 'EXPENSE', 'Sementes Alface Crespa – plantio',           240.00, '2023-11-03', 'FINISHED', 'CARD',   now(), now()),  
    
    (2,  3, 1, 2, 'EXPENSE', 'Fertilização inicial – Cenoura Nantes',      330.00, '2024-05-15', 'FINISHED', 'PIX',    now(), now()),  
    
    (2,  4, 1, 1, 'EXPENSE', 'Defensivos fitossanitários – Pimentão',      465.00, '2024-08-10', 'PENDING',  'BOLETO', now(), now()),  
    
    (2,  5, 1, 2, 'EXPENSE', 'Adubação de cobertura – Abobrinha',          144.00, '2024-06-05', 'FINISHED', 'PIX',    now(), now()),  
    
    (2,  7, 1, NULL,'EXPENSE','Estrutura tutoramento e irrigação – Pepino', 575.00, '2024-07-18', 'PENDING',  'PIX',    now(), now()),  
    
    (2, 10, 1, 5, 'EXPENSE', 'Embalagens para colheita – Couve-flor',      960.00, '2024-07-01', 'FINISHED', 'PIX',    now(), now()),  
    
    (2,  6, 1, 1, 'EXPENSE', 'Defensivos e fertilização base – Brócolis',  277.00, '2024-10-05', 'PENDING',  'BOLETO', now(), now()),  
    
    (2,  9, 1, 2, 'EXPENSE', 'Correção de solo – Rúcula Primavera',        141.00, '2024-09-16', 'PENDING',  'PIX',    now(), now());  

INSERT INTO transaction_item (transaction_id, item_id, quantity, unit_price, total_price)
VALUES
    
    (11, 1,   2.00,  85.00,  170.00),   
    (11, 2,   1.00, 120.00,  120.00),   
    
    (12, 6, 500.00,   0.85,  425.00),   
    
    (13, 7, 800.00,   0.30,  240.00),   
   
    (14, 4,  50.00,   4.80,  240.00),   
    (14, 5, 100.00,   0.90,   90.00),   
    
    (15, 3, 500.00,   0.45,  225.00),   
    (15, 2,   2.00, 120.00,  240.00),   
   
    (16, 4,  30.00,   4.80,  144.00),   
   
    (17, 10, 200.00,  0.75,  150.00),   
    (17,  8,  50.00,  8.50,  425.00),   
   
    (18,  9,  80.00, 12.00,  960.00),   
    
    (19,  1,   1.00, 85.00,   85.00),   
    (19,  4,  40.00,  4.80,  192.00),   
    
    (20,  5,  50.00,  0.90,   45.00),
    (20,  4,  20.00,  4.80,   96.00);

-- Transações extras (nov/2024 a jul/2026) para dar continuidade e sazonalidade
-- ao gráfico de Fluxo de Caixa Mensal do dashboard (curva de crescimento anual).
INSERT INTO transaction (user_id, crop_cycle_id, stakeholder_id, category_id,
                         type, description, total_value, transaction_date,
                         status, payment_method, created_at, updated_at)
VALUES
    (2, 1,  2, NULL, 'INCOME',  'Venda Tomate Cereja – produção mensal',        600.00, '2024-11-10', 'FINISHED', 'PIX', now(), now()),
    (2, 2,  1, 1,    'EXPENSE', 'Custos operacionais – Alface Crespa',          400.00, '2024-11-20', 'FINISHED', 'PIX', now(), now()),

    (2, 3,  2, NULL, 'INCOME',  'Venda Cenoura Nantes – produção mensal',       900.00, '2024-12-10', 'FINISHED', 'PIX', now(), now()),
    (2, 5,  1, 2,    'EXPENSE', 'Custos operacionais – Abobrinha Caipira',      500.00, '2024-12-20', 'FINISHED', 'PIX', now(), now()),

    (2, 7,  2, NULL, 'INCOME',  'Venda Pepino Japonês – produção mensal',      1200.00, '2025-01-10', 'FINISHED', 'PIX', now(), now()),
    (2, 10, 1, 3,    'EXPENSE', 'Custos operacionais – Couve-flor Verônica',    700.00, '2025-01-20', 'FINISHED', 'PIX', now(), now()),

    (2, 1,  2, NULL, 'INCOME',  'Venda Tomate Cereja – produção mensal',       1500.00, '2025-02-10', 'FINISHED', 'PIX', now(), now()),
    (2, 2,  1, 4,    'EXPENSE', 'Custos operacionais – Alface Crespa',          900.00, '2025-02-20', 'FINISHED', 'PIX', now(), now()),

    (2, 3,  2, NULL, 'INCOME',  'Venda Cenoura Nantes – produção mensal',      2000.00, '2025-03-10', 'FINISHED', 'PIX', now(), now()),
    (2, 5,  1, 5,    'EXPENSE', 'Custos operacionais – Abobrinha Caipira',     1100.00, '2025-03-20', 'FINISHED', 'PIX', now(), now()),

    (2, 7,  2, NULL, 'INCOME',  'Venda Pepino Japonês – produção mensal',      2800.00, '2025-04-10', 'FINISHED', 'PIX', now(), now()),
    (2, 10, 1, 1,    'EXPENSE', 'Custos operacionais – Couve-flor Verônica',   1400.00, '2025-04-20', 'FINISHED', 'PIX', now(), now()),

    (2, 1,  2, NULL, 'INCOME',  'Venda Tomate Cereja – produção mensal',       4200.00, '2025-05-10', 'FINISHED', 'PIX', now(), now()),
    (2, 2,  1, 2,    'EXPENSE', 'Custos operacionais – Alface Crespa',         1900.00, '2025-05-20', 'FINISHED', 'PIX', now(), now()),

    (2, 3,  2, NULL, 'INCOME',  'Venda Cenoura Nantes – produção mensal',      6500.00, '2025-06-10', 'FINISHED', 'PIX', now(), now()),
    (2, 5,  1, 3,    'EXPENSE', 'Custos operacionais – Abobrinha Caipira',     2600.00, '2025-06-20', 'FINISHED', 'PIX', now(), now()),

    (2, 7,  2, NULL, 'INCOME',  'Venda Pepino Japonês – pico de colheita',     8200.00, '2025-07-10', 'FINISHED', 'PIX', now(), now()),
    (2, 10, 1, 4,    'EXPENSE', 'Custos operacionais – Couve-flor Verônica',   3200.00, '2025-07-20', 'FINISHED', 'PIX', now(), now()),

    (2, 1,  2, NULL, 'INCOME',  'Venda Tomate Cereja – produção mensal',       5000.00, '2025-08-10', 'FINISHED', 'PIX', now(), now()),
    (2, 2,  1, 5,    'EXPENSE', 'Custos operacionais – Alface Crespa',         2200.00, '2025-08-20', 'FINISHED', 'PIX', now(), now()),

    (2, 3,  2, NULL, 'INCOME',  'Venda Cenoura Nantes – produção mensal',      3200.00, '2025-09-10', 'FINISHED', 'PIX', now(), now()),
    (2, 5,  1, 1,    'EXPENSE', 'Custos operacionais – Abobrinha Caipira',     1600.00, '2025-09-20', 'FINISHED', 'PIX', now(), now()),

    (2, 7,  2, NULL, 'INCOME',  'Venda Pepino Japonês – produção mensal',      2100.00, '2025-10-10', 'FINISHED', 'PIX', now(), now()),
    (2, 10, 1, 2,    'EXPENSE', 'Custos operacionais – Couve-flor Verônica',   1200.00, '2025-10-20', 'FINISHED', 'PIX', now(), now()),

    (2, 1,  2, NULL, 'INCOME',  'Venda Tomate Cereja – produção mensal',       1400.00, '2025-11-10', 'FINISHED', 'PIX', now(), now()),
    (2, 2,  1, 3,    'EXPENSE', 'Custos operacionais – Alface Crespa',          900.00, '2025-11-20', 'FINISHED', 'PIX', now(), now()),

    (2, 3,  2, NULL, 'INCOME',  'Venda Cenoura Nantes – produção mensal',      1000.00, '2025-12-10', 'FINISHED', 'PIX', now(), now()),
    (2, 5,  1, 4,    'EXPENSE', 'Custos operacionais – Abobrinha Caipira',      700.00, '2025-12-20', 'FINISHED', 'PIX', now(), now()),

    (2, 7,  2, NULL, 'INCOME',  'Venda Pepino Japonês – produção mensal',       900.00, '2026-01-10', 'FINISHED', 'PIX', now(), now()),
    (2, 10, 1, 5,    'EXPENSE', 'Custos operacionais – Couve-flor Verônica',    600.00, '2026-01-20', 'FINISHED', 'PIX', now(), now()),

    (2, 1,  2, NULL, 'INCOME',  'Venda Tomate Cereja – produção mensal',       1200.00, '2026-02-10', 'FINISHED', 'PIX', now(), now()),
    (2, 2,  1, 1,    'EXPENSE', 'Custos operacionais – Alface Crespa',          750.00, '2026-02-20', 'FINISHED', 'PIX', now(), now()),

    (2, 3,  2, NULL, 'INCOME',  'Venda Cenoura Nantes – produção mensal',      1800.00, '2026-03-10', 'FINISHED', 'PIX', now(), now()),
    (2, 5,  1, 2,    'EXPENSE', 'Custos operacionais – Abobrinha Caipira',      950.00, '2026-03-20', 'FINISHED', 'PIX', now(), now()),

    (2, 7,  2, NULL, 'INCOME',  'Venda Pepino Japonês – produção mensal',      2600.00, '2026-04-10', 'FINISHED', 'PIX', now(), now()),
    (2, 10, 1, 3,    'EXPENSE', 'Custos operacionais – Couve-flor Verônica',   1300.00, '2026-04-20', 'FINISHED', 'PIX', now(), now()),

    (2, 1,  2, NULL, 'INCOME',  'Venda Tomate Cereja – produção mensal',       4000.00, '2026-05-10', 'FINISHED', 'PIX', now(), now()),
    (2, 2,  1, 4,    'EXPENSE', 'Custos operacionais – Alface Crespa',         1800.00, '2026-05-20', 'FINISHED', 'PIX', now(), now()),

    (2, 3,  2, NULL, 'INCOME',  'Venda Cenoura Nantes – produção mensal',      6200.00, '2026-06-10', 'FINISHED', 'PIX', now(), now()),
    (2, 5,  1, 5,    'EXPENSE', 'Custos operacionais – Abobrinha Caipira',     2500.00, '2026-06-20', 'FINISHED', 'PIX', now(), now()),

    (2, 7,  2, NULL, 'INCOME',  'Venda Pepino Japonês – produção mensal',      2500.00, '2026-07-02', 'FINISHED', 'PIX', now(), now()),
    (2, 10, 1, 1,    'EXPENSE', 'Custos operacionais – Couve-flor Verônica',   1100.00, '2026-07-05', 'FINISHED', 'PIX', now(), now());
