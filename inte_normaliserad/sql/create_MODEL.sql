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
    Tabeller:
        • info(
            id SERIAL PRIMARY KEY,
            tagPath TEXT,          -- "Företag/Plats/Fabrik/Område/Produktionslinje/Cell/Tillgång/Sensor"
            scid INTEGER NOT NULL,
            datatype INTEGER,
            querymode INTEGER,
            created BIGINT,
            retired BIGINT
        )
        • data(info_id, t_stamp, intValue, floatValue, stringValue, dateValue, dataIntegrity)
    Format:
    - tagPath är hierarkisk med "/"-separerade segment.
    - Datatyp: 0=int, 1=float, 2=string, 3=date.
    Antaganden:
    - Svara **endast** med den giltiga SQL-satsen, inga kommentarer.
    Fråga:
    {question}',
    temperature = 0.3,
    max_tokens = 2000;