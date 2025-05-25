SELECT 
    date_trunc('day', to_timestamp(t_stamp / 1000)) AS day,
    info_id,
    COUNT(*) AS readings,
    AVG(data) AS avg_data
FROM data_int
WHERE t_stamp >= 1735689600000
  AND t_stamp <= 1736208000000
GROUP BY day, info_id
ORDER BY day, info_id;