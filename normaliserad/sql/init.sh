#!/bin/bash
set -e
sleep 60

python -m mindsdb --api http,mysql,postgres &
MINDSPID=$!

while ! (echo > /dev/tcp/localhost/55432) >/dev/null 2>&1; do
    sleep 1
done

psql -h localhost -p 55432 -d mindsdb -U mindsdb -f /sql/datasource.sql
psql -h localhost -p 55432 -d mindsdb -U mindsdb -f /sql/create_ML_ENGINE.sql
psql -h localhost -p 55432 -d mindsdb -U mindsdb -f /sql/create_MODEL.sql
psql -h localhost -p 55432 -d mindsdb -U mindsdb -f /sql/create_SKILL.sql
psql -h localhost -p 55432 -d mindsdb -U mindsdb -f /sql/create_AI_agent.sql

wait $MINDSPID
