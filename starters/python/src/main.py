"""Application entry point."""
from fastapi import FastAPI

app = FastAPI(title="project-name", version="0.1.0")

@app.get("/health")
async def health():
    return {"status": "ok"}
