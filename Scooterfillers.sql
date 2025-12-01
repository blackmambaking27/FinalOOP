-- USERS
INSERT INTO user (full_name, email, password_hash, user_type)
VALUES
  ('Alice Student',    'alice@student.ac.ca',    'hashed_pw1', 'USER'),
  ('Bob Sponsor',      'bob.sponsor@company.ca','hashed_pw2', 'SPONSOR'),
  ('Maya Maintainer',  'maya.maint@ac.ca',      'hashed_pw3', 'MAINTAINER'),
  ('Admin User',       'admin@ac.ca',           'hashed_admin','ADMIN');

-- ACCOUNTS (for Alice + Bob)
INSERT INTO account (user_id, current_balance, last_statement_date)
VALUES
  (1, 25.00, '2025-11-01'),
  (2, 100.00, '2025-11-01');

-- CHARGING STATIONS
INSERT INTO charging_station (name, location_desc, max_capacity)
VALUES
  ('AC Main Entrance', 'Building A - Main Entrance', 10),
  ('Library Station',  'Dare District - Library',     8),
  ('Residence Station','Residence Parking Lot',      12);

-- SCOOTERS (owned by Bob Sponsor user_id = 2)
INSERT INTO scooter (sponsor_id, make, model, vehicle_number, colour, battery_capacity_kwh, status)
VALUES
  (2, 'Segway', 'Ninebot E45', 'SCT-1001', 'Green', 0.35, 'AVAILABLE'),
  (2, 'Xiaomi', 'Mi Pro 2',    'SCT-1002', 'Black', 0.40, 'CHARGING'),
  (2, 'Bird',   'Bird One',    'SCT-1003', 'Teal',  0.45, 'MAINTENANCE');

-- TRIPS (Alice using scooters)
INSERT INTO trip (user_id, scooter_id, start_station_id, end_station_id,
                  start_time, end_time, distance_km, minutes_away_from_station, debit_amount)
VALUES
  (1, 1, 1, 2, '2025-11-20 09:10:00', '2025-11-20 09:25:00', 3.20, 15, 2.50),
  (1, 2, 2, 3, '2025-11-21 14:00:00', '2025-11-21 14:40:00', 5.10, 40, 3.75);

-- SCOOTER LOCATION HISTORY
INSERT INTO scooter_location_history (scooter_id, station_id, location_desc, in_transit, recorded_at)
VALUES
  (1, 1, 'Docked at AC Main Entrance', FALSE, '2025-11-20 08:55:00'),
  (1, NULL, 'On path between A and D buildings', TRUE, '2025-11-20 09:15:00'),
  (2, 2, 'Docked at Library Station', FALSE, '2025-11-21 13:50:00'),
  (3, 3, 'In maintenance area near Residence Station', FALSE, '2025-11-19 10:00:00');

-- ENERGY READINGS
INSERT INTO energy_reading (scooter_id, reading_time, charge_percent, time_to_full_min, energy_used_kwh)
VALUES
  (1, '2025-11-20 09:00:00', 90,  5, 0.02),
  (1, '2025-11-20 09:25:00', 65, 20, 0.06),
  (2, '2025-11-21 13:55:00', 40, 35, 0.10),
  (3, '2025-11-19 10:05:00', 20, 60, 0.12);

-- MAINTENANCE ALERTS
INSERT INTO maintenance_alert (scooter_id, created_at, alert_type, description, is_active)
VALUES
  (3, '2025-11-19 09:30:00', 'BRAKE_CHECK', 'Brake wear threshold exceeded', TRUE),
  (3, '2025-11-19 09:45:00', 'BATTERY_HEALTH', 'Battery capacity below 70%', TRUE);

-- MAINTENANCE TASKS
INSERT INTO maintenance_task (alert_id, scooter_id, maintainer_id, scheduled_date,
                              completed_date, status, notes)
VALUES
  (1, 3, 3, '2025-11-22', NULL, 'IN_PROGRESS', 'Checking front and rear brakes'),
  (2, 3, 3, '2025-11-23', NULL, 'PLANNED', 'Battery diagnostics and possible replacement');
