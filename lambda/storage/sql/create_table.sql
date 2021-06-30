\c lametro

DROP TABLE IF EXISTS bus_arrival;

CREATE TABLE IF NOT EXISTS bus_arrival (
   timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL,
   req_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
   inserted_time TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
   route_id INT NOT NULL,
   bus_id INT NOT NULL,
   latitude DOUBLE PRECISION NOT NULL,
   longitude DOUBLE PRECISION NOT NULL,
   direction INT NOT NULL,
   stop_id INT NOT NULL,
   seconds_till_meet BIGINT NOT NULL
);

SELECT create_hypertable('bus_arrival','timestamp');
SELECT add_retention_policy('bus_arrival', INTERVAL '24 hours');

DROP TABLE IF EXISTS bus_velocity;

CREATE TABLE IF NOT EXISTS bus_velocity (
   timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL,
   req_time TIMESTAMP WITHOUT TIME ZONE NOT NULL,
   inserted_time TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT current_timestamp,
   route_id INT NOT NULL,
   bus_id INT NOT NULL,
   latitude DOUBLE PRECISION NOT NULL,
   longitude DOUBLE PRECISION NOT NULL,
   direction INT NOT NULL,
   velocity DOUBLE PRECISION NOT NULL
);

SELECT create_hypertable('bus_velocity','timestamp');
SELECT add_retention_policy('bus_velocity', INTERVAL '24 hours');