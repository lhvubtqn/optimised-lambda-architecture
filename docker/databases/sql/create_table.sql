\c lametro

CREATE TABLE IF NOT EXISTS bus_arrival (
   timestamp TIMESTAMP WITHOUT TIME ZONE,
   req_time TIMESTAMP WITHOUT TIME ZONE,
   inserted_time TIMESTAMP WITHOUT TIME ZONE DEFAULT current_timestamp,
   route_id INT,
   bus_id INT,
   latitude DOUBLE PRECISION,
   longitude DOUBLE PRECISION,
   velocity DOUBLE PRECISION,
   direction INT,
   stop_id INT,
   seconds_till_meet BIGINT
);

SELECT create_hypertable('bus_arrival','timestamp');
SELECT add_retention_policy('bus_arrival', INTERVAL '72 hours');