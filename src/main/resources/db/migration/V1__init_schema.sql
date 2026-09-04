CREATE TYPE crop_cycle_status AS ENUM (
    'PLANNING',
    'ACTIVE',
    'PLANTING',
    'HARVESTING',
    'FINISHED',
    'CANCELLED'
    );

CREATE TYPE transaction_type AS ENUM (
    'INCOME',
    'EXPENSE'
    );

CREATE TYPE transaction_status AS ENUM (
    'PENDING',
    'FINISHED',
    'CANCELLED'
    );

CREATE TYPE payment_method AS ENUM (
    'CARD',
    'CASH',
    'PIX',
    'CHECK',
    'BOLETO'
);

CREATE TYPE stakeholder_type AS ENUM (
    'SUPPLIER',
    'BUYER',
    'BOTH'
    );

CREATE TYPE measurement_unit AS ENUM (
    'PES',
    'HECTARE',
    'METRO_QUADRADO',
    'ALQUEIRE'
    );

CREATE TABLE farm_user
(
    id         int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name       text        NOT NULL CHECK (name <> ''),
    phone      text        NOT NULL,
    email      text UNIQUE NOT NULL CHECK (email <> ''),
    password   text        NOT NULL CHECK (length(password) >= 8),
    active     boolean     NOT NULL DEFAULT TRUE,
    created_at timestamp,
    updated_at timestamp
);

INSERT INTO farm_user (name, phone, email, password, created_at, updated_at)
VALUES ('admin', '35991179667', 'admin@email.com', '$2a$12$YBOWEel6M/lO2SiPIs5zAO6KWOT3db5s4puX1ZbeCD5q90/8kGaIS', now(), now());

CREATE TABLE category
(
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id    integer REFERENCES farm_user (id),
    name       text        NOT NULL CHECK (name <> ''),
    color      varchar(7)  NULL CHECK (color IS NULL OR color ~ '^#[0-9A-Fa-f]{6}$'),
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE stakeholder
(
    id         integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id    integer REFERENCES farm_user (id),
    name       text NOT NULL CHECK (name <> ''),
    cnpj       text,
    cpf        text,
    type       stakeholder_type,
    phone      text,
    created_at timestamp,
    updated_at timestamp
);

CREATE TABLE item
(
    id          int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id     int REFERENCES farm_user (id),
    category_id int  NULL REFERENCES category (id),
    name        text NOT NULL CHECK (name <> ''),
    unity       varchar(50),
    brand       text NULL,
    created_at  timestamp,
    updated_at  timestamp
);

CREATE TABLE crop_cycle
(
    id               serial PRIMARY KEY,
    user_id          int               NOT NULL REFERENCES farm_user (id),
    name             text              NOT NULL CHECK (name <> ''),
    crop             varchar(50)       NOT NULL,
    planted_area     numeric(10, 2),
    measurement_unit measurement_unit,
    plant_count      int,
    planned_budget   numeric(15, 2),
    target_yield     numeric(15, 2),
    status           crop_cycle_status NOT NULL DEFAULT 'PLANNING',
    start_date       date              NOT NULL,
    end_date         date              NULL,
    created_at       timestamp,
    updated_at       timestamp,

    CONSTRAINT chk_crop_cycle_dates CHECK (end_date IS NULL OR end_date >= start_date),
    CONSTRAINT chk_crop_cycle_measurement_unit_pair CHECK ((measurement_unit = 'PES' AND plant_count IS NOT NULL) OR (measurement_unit <> 'PES' AND plant_count IS NULL))
);

CREATE TABLE crop_cycle_control
(
    id                  int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop_cycle_id       int UNIQUE REFERENCES crop_cycle (id) ON DELETE CASCADE,
    current_investment  numeric(15, 2) DEFAULT 0,
    current_revenue     numeric(15, 2) DEFAULT 0,
    current_roi         numeric(15, 2) DEFAULT 0,

    health_score        int            DEFAULT 100,
    progress_percentage numeric(5, 2)  DEFAULT 0,
    alerts_count        int            DEFAULT 0,

    last_calculated_at  timestamp
);

CREATE TABLE transaction
(
    id               integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id          integer REFERENCES farm_user (id),
    crop_cycle_id    integer REFERENCES crop_cycle (id),
    stakeholder_id   integer NULL REFERENCES stakeholder (id),
    category_id      integer,
    type             transaction_type NOT NULL,
    description      text,
    total_value      numeric(15, 2),
    transaction_date date,
    status           transaction_status NOT NULL DEFAULT 'PENDING'::transaction_status,
    payment_method   payment_method NULL,
    created_at       timestamp,
    updated_at       timestamp,

    CONSTRAINT chk_transaction_positive_value CHECK (total_value >= 0)
);

CREATE TABLE transaction_item
(
    id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    transaction_id integer REFERENCES transaction (id),
    item_id        integer REFERENCES item (id),
    quantity       numeric(15, 2),
    unit_price     numeric(15, 2),
    total_price    numeric(15, 2),

    CONSTRAINT chk_item_positive_values CHECK (quantity >= 0 AND unit_price >= 0 AND total_price >= 0)
);