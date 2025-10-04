import os
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import JSONResponse, FileResponse
from pydantic import BaseModel
from openai import OpenAI
from prompt import SYSTEM_PROMPT


OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
client = OpenAI(api_key=OPENAI_API_KEY)

app = FastAPI()

# Serve the built frontend from app/static
static_dir = os.path.join(os.path.dirname(__file__), "static")
app.mount("/assets", StaticFiles(directory=static_dir), name="assets")

class AdviceIn(BaseModel):
    question: str
    answer: str

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/api/advice")
def advice(inp: AdviceIn):
    if not OPENAI_API_KEY:
        return JSONResponse({"error": "Server missing OPENAI_API_KEY"}, status_code=500)

    user_msg = f"""Interview Question:\n{inp.question.strip()}\n
Candidate Draft Answer:\n{inp.answer.strip()}"""

    resp = client.chat.completions.create(
        model="gpt-4o-mini",
        temperature=0.4,
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_msg}
        ]
    )
    text = resp.choices[0].message.content
    return {"advice": text}

@app.get("/")
def index():
    index_path = os.path.join(static_dir, "index.html")
    return FileResponse(index_path)
