CREATE TABLE drv (
    id       SERIAL PRIMARY KEY,
    name     TEXT   NOT NULL,
    provider TEXT
);

CREATE TABLE scinfo (
    id      SERIAL PRIMARY KEY,
    scname  TEXT NOT NULL,
    drv_id  INTEGER NOT NULL,
    CONSTRAINT fk_scinfo_drv
        FOREIGN KEY (drv_id) REFERENCES drv(id)
);

 
CREATE TABLE site (
    scid     INTEGER PRIMARY KEY,
    plats    TEXT,
    foretag  TEXT,
    fabrik   TEXT,
    CONSTRAINT fk_site_scinfo
        FOREIGN KEY (scid) REFERENCES scinfo(id)
        ON DELETE CASCADE
);


CREATE TABLE sce (
    scid        INTEGER NOT NULL, 
    start_time  BIGINT NOT NULL,
    end_time    BIGINT,
    rate        INTEGER default NULL,
    PRIMARY KEY (scid, start_time),
    CONSTRAINT fk_sce_scinfo
        FOREIGN KEY (scid) REFERENCES scinfo(id)
        ON DELETE CASCADE
);


CREATE TABLE info (
    id SERIAL PRIMARY KEY,
    scid INTEGER NOT NULL,
    cell TEXT,
    produktions_linje TEXT,
    omrade TEXT,
    tillgang TEXT,
    sensor TEXT,
    datatype INTEGER,
    querymode INTEGER,
    created BIGINT,
    retired BIGINT default NULL,
    CONSTRAINT fk_info_site
        FOREIGN KEY (scid) REFERENCES site(scid)
);


CREATE TABLE status (
    id    SERIAL PRIMARY KEY,
    descr TEXT
);


CREATE TABLE data_int (
    info_id INTEGER NOT NULL,
    t_stamp BIGINT NOT NULL,
    data INTEGER,
    dataintegrity INTEGER,
    PRIMARY KEY (info_id, t_stamp),
    FOREIGN KEY (info_id) REFERENCES info(id),
    FOREIGN KEY (dataintegrity)  REFERENCES status(id)
);

CREATE TABLE data_float (
    info_id INTEGER NOT NULL,
    t_stamp BIGINT NOT NULL,
    data DOUBLE PRECISION,
    dataintegrity INTEGER,
    PRIMARY KEY (info_id, t_stamp),
    FOREIGN KEY (info_id) REFERENCES info(id),
    FOREIGN KEY (dataintegrity)  REFERENCES status(id)
);

CREATE TABLE data_string (
    info_id INTEGER  NOT NULL,
    t_stamp BIGINT NOT NULL,
    data TEXT,
    dataintegrity INTEGER,
    PRIMARY KEY (info_id, t_stamp),
    FOREIGN KEY (info_id) REFERENCES info(id),
    FOREIGN KEY (dataintegrity)  REFERENCES status(id)
);

CREATE TABLE data_date (
    info_id   INT       NOT NULL,
    t_stamp   BIGINT NOT NULL,
    data      DATE,
    dataintegrity     INT,
    PRIMARY KEY (info_id, t_stamp),
    FOREIGN KEY (info_id) REFERENCES info(id),
    FOREIGN KEY (dataintegrity)  REFERENCES status(id)
);

INSERT INTO drv (id, name, provider) VALUES
  (1, 'dig-dev', NULL),
  (2, 'dig-dev', 'default'),
  (3, 'dig-dev', 'devtags');

INSERT INTO scinfo (id, scname, drv_id) VALUES
  (1, '_exempt_', 2),
  (2, '_exempt_', 3);

INSERT INTO site (scid, plats, foretag, fabrik) VALUES
  (1, 'östrand',     'SCA', 'sulfatmassabruk'),
  (2, 'ortviken',    'SCA', 'pappersbruk');


INSERT INTO sce (scid, start_time, end_time, rate) VALUES
  (1, 1714642425000, 1746178753000, NULL),
  (2, 1714642425000, 1746178753000, NULL);


INSERT INTO status (id, descr) VALUES
  (192, 'The data has met all criteria for being considered reliable.'),
  (0,   'The data is not reliable, further data is not available.'),
  (8,   'The OPC server is not connected or no value has been received yet.'),
  (300, 'There is a problem with the tags configuration.'),
  (301, 'There is a communication problem between the tag and its data source.'),
  (310, 'The tags expression generated an evaluation error.'),
  (320, 'Temporary “Good”; underlying quality may differ from what appears.'),
  (330, 'There was an error when evaluating the tag.'),
  (340, 'The value could not be converted to the requested data type.'),
  (403, 'Access denied, current user may not view this tag.'),
  (404, 'The tag (or a referenced tag) could not be found.'),
  (410, 'The tag is disabled (enabled=false).'),
  (500, 'The tag has not been evaluated within the expected time frame.'),
  (900, 'The driver is in demo mode and has timed out.'),
  (901, 'Gateway communication is turned off from the Designer toolbar.');


INSERT INTO info
        (scid, omrade, produktions_linje, cell,
         tillgang, sensor, datatype, querymode, created)
SELECT
  1 + (n % 2) AS scid,
  CASE WHEN n % 2 = 1 THEN 'fiberlinje'
       ELSE 'PM' || (3 + (n % 4)) END AS omrade,
  'linje ' || (1 + (n % 5)) AS produktions_linje,
  'cell '  || chr(65 + (n % 6)) AS cell,
  'asset ' || (10 + (n % 30)) AS tillgang,
  CASE (n % 4)
     WHEN 0 THEN 'vibration'
     WHEN 1 THEN 'temp'
     WHEN 2 THEN 'larmbeskriv'
     ELSE 'service'
  END AS sensor,
  (n % 4) AS datatype,
  NULL AS querymode,
  (extract(epoch FROM clock_timestamp())*1000)::bigint AS created
FROM generate_series(1,450) AS n;

CREATE TEMP VIEW v_info_by_type AS
SELECT id,
       CASE datatype
         WHEN 0 THEN 'int'
         WHEN 1 THEN 'float'
         WHEN 2 THEN 'string'
         WHEN 3 THEN 'date'
       END AS dtype
FROM info;

WITH base AS (
    SELECT EXTRACT(EPOCH FROM DATE '2022-01-01')*1000 AS start_ms,
           EXTRACT(EPOCH FROM DATE '2025-05-01')*1000      AS end_ms
),
span AS (
    SELECT start_ms,
           end_ms,
           (end_ms-start_ms) AS span_ms,
           100000            AS n_rows
    FROM   base
),
id_pool AS (
    SELECT array_agg(id) AS ids,
           array_length(array_agg(id),1) AS cnt
    FROM   v_info_by_type
    WHERE  dtype = 'float'
)
INSERT INTO data_float (info_id, t_stamp, data, dataintegrity)
SELECT
    ids[ 1 + floor(random()*cnt) ]                            AS info_id,
    (start_ms + (gs.i-1) * (span_ms/(n_rows-1)))::BIGINT      AS t_stamp,
    (random()*100)::DOUBLE PRECISION                    AS data,
    (SELECT id FROM status ORDER BY random() LIMIT 1)  AS dataintegrity
FROM  span, id_pool,
      LATERAL generate_series(1, n_rows) AS gs(i);




WITH base AS (
    SELECT EXTRACT(EPOCH FROM DATE '2022-01-01')*1000 AS start_ms,
           EXTRACT(EPOCH FROM DATE '2025-05-01')*1000 AS end_ms
),
span AS (
    SELECT start_ms,
           end_ms,
           (end_ms-start_ms) AS span_ms,
           100000            AS n_rows
    FROM   base
),
id_pool AS (
    SELECT array_agg(id) AS ids,
           array_length(array_agg(id),1) AS cnt
    FROM   v_info_by_type
    WHERE  dtype = 'int'
)
INSERT INTO data_int (info_id, t_stamp, data, dataintegrity)
SELECT
    ids[ 1 + floor(random()*cnt) ] AS info_id,
    (start_ms + (gs.i-1) * (span_ms/(n_rows-1)))::BIGINT AS t_stamp,
    floor(random()*100)::DOUBLE PRECISION AS data,
    (SELECT id FROM status ORDER BY random() LIMIT 1) AS dataintegrity
FROM  span, id_pool,
      LATERAL generate_series(1, n_rows) AS gs(i);



WITH base AS (
    SELECT EXTRACT(EPOCH FROM DATE '2022-01-01')*1000 AS start_ms,
           EXTRACT(EPOCH FROM DATE '2025-05-01')*1000 AS end_ms
),
span AS (
    SELECT start_ms,
           end_ms,
           (end_ms - start_ms) AS span_ms,
           100000             AS n_rows
    FROM   base
),
id_pool AS (
    SELECT array_agg(id) AS ids,
           array_length(array_agg(id), 1) AS cnt
    FROM   v_info_by_type
    WHERE  dtype = 'string'
)
INSERT INTO data_string (info_id, t_stamp, data, dataintegrity)
SELECT
    ids[1 + floor(random()*cnt)] AS info_id,
    (start_ms + (gs.i-1) * (span_ms/(n_rows-1)))::BIGINT AS t_stamp,
    substr(md5(random()::text), 1, 16) AS data,
    (SELECT id FROM status ORDER BY random() LIMIT 1) AS dataintegrity
FROM  span, id_pool,
      LATERAL generate_series(1, n_rows) AS gs(i);




WITH base AS (
    SELECT EXTRACT(EPOCH FROM DATE '2022-01-01')*1000 AS start_ms,
           EXTRACT(EPOCH FROM DATE '2025-05-01')*1000 AS end_ms
),
span AS (
    SELECT start_ms,
           end_ms,
           (end_ms - start_ms) AS span_ms,
           100000             AS n_rows
    FROM   base
),
id_pool AS (
    SELECT array_agg(id) AS ids,
           array_length(array_agg(id), 1) AS cnt
    FROM   v_info_by_type
    WHERE  dtype = 'date'
)
INSERT INTO data_date (info_id, t_stamp, data, dataintegrity)
SELECT
    ids[1 + floor(random()*cnt)] AS info_id,
    (start_ms + (gs.i-1) * (span_ms/(n_rows-1)))::BIGINT AS t_stamp,
    to_timestamp(                                                   
        (start_ms/1000) + 
        ((gs.i-1) * (span_ms/(n_rows-1)))/1000
    )::date AS data,
    (SELECT id FROM status ORDER BY random() LIMIT 1) AS dataintegrity
FROM  span, id_pool,
      LATERAL generate_series(1, n_rows) AS gs(i);


CREATE INDEX on info(scid);

CREATE EXTENSION IF NOT EXISTS timescaledb;

SELECT create_hypertable('data_int', 't_stamp',
        chunk_time_interval => 2592000000, migrate_data => TRUE);

SELECT create_hypertable('data_float', 't_stamp',
        chunk_time_interval => 2592000000, migrate_data => TRUE);

SELECT create_hypertable('data_string', 't_stamp',
        chunk_time_interval => 2592000000, migrate_data => TRUE);

SELECT create_hypertable('data_date', 't_stamp',
        chunk_time_interval => 2592000000, migrate_data => TRUE);
