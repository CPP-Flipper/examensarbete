SELECT COUNT(*)
FROM   info i
JOIN   site s USING (scid)
WHERE  s.plats = 'östrand';