CREATE MODEL langchain_model
PREDICT answer
USING
  engine = 'langchain_engine',
  provider = 'ollama',
  model_name = 'mistral:latest',
  base_url = 'http://host.docker.internal:11434',
  user_column = 'question',
  assistant_column = 'answer',
  verbose = False,
  prompt_template = '
  Bakgrund:
    • Tabeller:
        info    (id, scid, omrade, produktions_linje, cell, tillgang, sensor, datatype, querymode, created, retired) Beskrivning: en tupel som innehåller information om en sensor/tagg,
        site    (scid, plats, foretag, fabrik) Beskrivning: en tupel som innehåller information om en plats Exempel "plats:"östrand" "företag:"sca" "fabrik:"pappersmassabruk",
        scinfo  (id, scname, drv_id) Beskrivning: lagrar information om varje tagggrupp "On change"="exempt" eller fast tidsintervall,
        sce     (scid, start_time, end_time, rate) Beskrivning: håller koll på senaste exekvering för en tagggrupp att hämta data (end_time),
        status  (id, descr) Beskrivning: status för en sensor/tagg,
        drv     (id, name, provider) Beskrivning: drv tabellen lagrar information om drivers, vilket motsvarar Ignition Gateways eller tagg provider,
      hypertabeller:
        data_int     (info_id, t_stamp, data, di_id),
        data_float   (info_id, t_stamp, data, di_id),
        data_string  (info_id, t_stamp, data, di_id),
        data_date    (info_id, t_stamp, data, di_id),
    • tagPath-format: “Företag/Plats/Fabrik/Område/Produktionslinje/Cell/Tillgång/Sensor”.
    • Datatyper: 0=int, 1=float, 2=string, 3=date.

  Instruktioner:
    1. Du är en SQL-expert.
    2. Om timescaleDB används, använd timescalefunktioner som time_bucket...
    3. Anta PostgreSQL; du kan använda funktioner som split_part, to_timestamp.
    4. Generera **endast** en giltig SQL-sats utan förklaringar.
    5. Om ingen rad hittas, returnera en tom resultatuppsättning.
    6. Vid komplexa frågor: dela upp i steg, beskriv dem och generera SQL.

  Fråga:
    {question}',
  temperature = 0.3,
  max_tokens = 2000;