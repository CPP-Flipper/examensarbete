import requests

base_url = "http://127.0.0.1:47337"
project = "mindsdb"
agent = "my_sql_agent"

def get_ai_respons(question: str, history: list) -> str:
    url = f"{base_url}/api/projects/{project}/agents/{agent}/completions"
    messages = history.copy()
    messages.append({"question": question, "answer": None})
    payload = {"messages": messages}
    resp = requests.post(url, json=payload)
    resp.raise_for_status()
    content = resp.json().get("message", {}).get("content", "").strip()
    return content
