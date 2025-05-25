CREATE AGENT my_sql_agent
USING
    skills = ['text2sql_skill'],
    model  = 'langchain_model',
    temperature = 0.3,
    max_tokens = 2000;