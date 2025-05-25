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

CREATE TABLE sce (
    scid        INTEGER NOT NULL, 
    start_time  BIGINT NOT NULL,
    end_time    BIGINT,
    rate        INTEGER default NULL,
    PRIMARY KEY (scid, start_time),
    CONSTRAINT fk_sce_scinfo
        FOREIGN KEY (scid) REFERENCES scinfo(id)
);

CREATE TABLE info (
    id SERIAL PRIMARY KEY,
    tagPath TEXT,
    scid INTEGER NOT NULL,
    datatype INTEGER,
    querymode INTEGER,
    created BIGINT,
    retired BIGINT DEFAULT NULL,
    CONSTRAINT fk_info_scinfo
        FOREIGN KEY (scid) REFERENCES scinfo(id)
);

CREATE TABLE data (
    info_id INTEGER NOT NULL,
    t_stamp BIGINT NOT NULL,
    intvalue INTEGER,
    floatvalue DOUBLE PRECISION,
    stringvalue TEXT,
    datevalue TIMESTAMP,
    dataintegrity INTEGER,
    PRIMARY KEY (info_id, t_stamp),
    FOREIGN KEY (info_id) REFERENCES info(id)
);


INSERT INTO drv (id, name, provider) VALUES
  (1, 'dig-dev', NULL),
  (2, 'dig-dev', 'default'),
  (3, 'dig-dev', 'devtags');

INSERT INTO scinfo (id, scname, drv_id) VALUES
  (1, '_exempt_', 2),
  (2, '_exempt_', 3);

INSERT INTO sce (scid, start_time, end_time, rate) VALUES
  (1, 1714642425000, 1746178753000, NULL),
  (2, 1714642425000, 1746178753000, NULL);

INSERT INTO info (id, tagpath, scid, datatype, querymode, created)
SELECT
  gs                           AS id,
  format(
    'SCA/%s/fiberlinje/linje %s/tork/pump %s/%s',
    CASE (gs % 2)
      WHEN 0 THEN 'ortviken/pappersbruk'
      WHEN 1 THEN 'östrand/sulfatmassabruk'
    END,
    (gs % 3) + 1,
    (gs % 5) + 1,
    CASE (gs % 4)
      WHEN 0 THEN 'vibration'
      WHEN 1 THEN 'temp'
      WHEN 2 THEN 'larmbeskriv'
      ELSE 'service'
    END
  ) AS tagpath,
  1 + (gs % 2) AS scid,
  (gs % 4) AS datatype,
  0 AS querymode,
  (extract(epoch FROM clock_timestamp())*1000)::bigint AS created
FROM generate_series(1,450) AS gs;
