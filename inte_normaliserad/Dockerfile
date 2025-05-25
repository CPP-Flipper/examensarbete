FROM mindsdb/mindsdb:v25.4.5.0

RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

COPY sql/ /sql/

RUN chmod +x /sql/init.sh

ENTRYPOINT ["/sql/init.sh"]