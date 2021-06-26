\c lametro

DROP TABLE IF EXISTS bus_arrival;

CREATE TABLE IF NOT EXISTS bus_arrival (
   timestamp TIMESTAMP WITHOUT TIME ZONE NOT NULL,
   bus_id INT NOT NULL,
   route_id INT NOT NULL,
   latitude DOUBLE PRECISION NOT NULL,
   longitude DOUBLE PRECISION NOT NULL,
   stop_id INT NOT NULL,
   seconds_till_meet BIGINT NOT NULL
);

-- Step 2: Turn into hypertable
SELECT create_hypertable('bus_arrival','timestamp');