-- 1. CREATE DATABASE / SCHEMA
CREATE DATABASE IF NOT EXISTS scooter
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE scooter;

-- 2. TABLES

-- 2.1 User: Students, Sponsors, Maintainers/Admin
CREATE TABLE user (
    user_id        INT AUTO_INCREMENT PRIMARY KEY,
    full_name      VARCHAR(100)      NOT NULL,
    email          VARCHAR(100)      NOT NULL UNIQUE,
    password_hash  VARCHAR(255)      NOT NULL,
    user_type      ENUM('USER','SPONSOR','MAINTAINER','ADMIN') NOT NULL,
    created_at     DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2.2 Account: balance of credits/debits linked to a user
CREATE TABLE account (
    account_id          INT AUTO_INCREMENT PRIMARY KEY,
    user_id             INT NOT NULL,
    current_balance     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    last_statement_date DATE NULL,
    CONSTRAINT fk_account_user
        FOREIGN KEY (user_id) REFERENCES user(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2.3 ChargingStation: campus stations
CREATE TABLE charging_station (
    station_id      INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    location_desc   VARCHAR(255) NOT NULL,
    max_capacity    INT          NOT NULL
) ENGINE=InnoDB;

-- 2.4 Scooter: e-scooters owned by sponsors
CREATE TABLE scooter (
    scooter_id          INT AUTO_INCREMENT PRIMARY KEY,
    sponsor_id          INT NOT NULL,
    make                VARCHAR(100) NOT NULL,
    model               VARCHAR(100) NOT NULL,
    vehicle_number      VARCHAR(50)  NOT NULL UNIQUE,
    colour              VARCHAR(50),
    battery_capacity_kwh DECIMAL(5,2) NOT NULL,
    status              ENUM('AVAILABLE','IN_USE','CHARGING','MAINTENANCE') 
                        NOT NULL DEFAULT 'AVAILABLE',
    created_at          DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_scooter_sponsor
        FOREIGN KEY (sponsor_id) REFERENCES user(user_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2.5 Trip: rides taken by users
CREATE TABLE trip (
    trip_id             INT AUTO_INCREMENT PRIMARY KEY,
    user_id             INT NOT NULL,
    scooter_id          INT NOT NULL,
    start_station_id    INT NULL,
    end_station_id      INT NULL,
    start_time          DATETIME NOT NULL,
    end_time            DATETIME NULL,
    distance_km         DECIMAL(6,2) NULL,
    minutes_away_from_station INT NULL,
    debit_amount        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_trip_user
        FOREIGN KEY (user_id) REFERENCES user(user_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_trip_scooter
        FOREIGN KEY (scooter_id) REFERENCES scooter(scooter_id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_trip_start_station
        FOREIGN KEY (start_station_id) REFERENCES charging_station(station_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_trip_end_station
        FOREIGN KEY (end_station_id) REFERENCES charging_station(station_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2.6 ScooterLocationHistory: simulated GPS history
CREATE TABLE scooter_location_history (
    history_id      INT AUTO_INCREMENT PRIMARY KEY,
    scooter_id      INT NOT NULL,
    station_id      INT NULL,
    location_desc   VARCHAR(255) NOT NULL,
    in_transit      BOOLEAN NOT NULL DEFAULT FALSE,
    recorded_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_scooter
        FOREIGN KEY (scooter_id) REFERENCES scooter(scooter_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_history_station
        FOREIGN KEY (station_id) REFERENCES charging_station(station_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2.7 EnergyReading: battery / energy info
CREATE TABLE energy_reading (
    reading_id      INT AUTO_INCREMENT PRIMARY KEY,
    scooter_id      INT NOT NULL,
    reading_time    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    charge_percent  INT      NOT NULL,   -- 0-100
    time_to_full_min INT     NULL,
    energy_used_kwh DECIMAL(6,3) NULL,
    CONSTRAINT fk_energy_scooter
        FOREIGN KEY (scooter_id) REFERENCES scooter(scooter_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2.8 MaintenanceAlert: predictive alerts
CREATE TABLE maintenance_alert (
    alert_id        INT AUTO_INCREMENT PRIMARY KEY,
    scooter_id      INT NOT NULL,
    created_at      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    alert_type      VARCHAR(100) NOT NULL,  -- e.g. 'BRAKE_CHECK', 'BATTERY_HEALTH'
    description     VARCHAR(255) NOT NULL,
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_alert_scooter
        FOREIGN KEY (scooter_id) REFERENCES scooter(scooter_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE=InnoDB;

-- 2.9 MaintenanceTask: tasks created from alerts
CREATE TABLE maintenance_task (
    task_id         INT AUTO_INCREMENT PRIMARY KEY,
    alert_id        INT NULL,
    scooter_id      INT NOT NULL,
    maintainer_id   INT NULL,
    scheduled_date  DATE NULL,
    completed_date  DATE NULL,
    status          ENUM('PLANNED','IN_PROGRESS','COMPLETED','CANCELLED')
                        NOT NULL DEFAULT 'PLANNED',
    notes           VARCHAR(255),
    CONSTRAINT fk_task_alert
        FOREIGN KEY (alert_id) REFERENCES maintenance_alert(alert_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE,
    CONSTRAINT fk_task_scooter
        FOREIGN KEY (scooter_id) REFERENCES scooter(scooter_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_task_maintainer
        FOREIGN KEY (maintainer_id) REFERENCES user(user_id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
) ENGINE=InnoDB;
