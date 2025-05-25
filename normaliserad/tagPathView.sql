CREATE OR REPLACE VIEW v_tag_path AS
SELECT
    i.id,
    concat_ws(
        '/',
        s.foretag,
        s.plats,
        s.fabrik,
        i.omrade,
        i.produktions_linje,
        i.cell,
        i.tillgang,
        i.sensor
    ) AS tagPath,
    i.scid,
    i.datatype,
    i.querymode,
    i.created,
    i.retired
FROM info  i
JOIN site  s  ON s.scid = i.scid; 