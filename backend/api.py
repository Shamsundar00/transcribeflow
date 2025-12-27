from fastapi import FastAPI, WebSocket, WebSocketDisconnect, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel
from typing import List, Optional
import json
import logging
import asyncio
import os
from core import TranscribeCore

# Setup Logger
logger = logging.getLogger(__name__)

# Ensure outputs directory exists
os.makedirs("outputs", exist_ok=True)

app = FastAPI(title="TranscribeFlow Enterprise API")

# Mount static files for serving outputs
app.mount("/files", StaticFiles(directory="outputs"), name="files")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all for development/demo
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# WebSocket Manager
class ConnectionManager:
    def __init__(self):
        self.active_connections: List[WebSocket] = []

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.append(websocket)

    def disconnect(self, websocket: WebSocket):
        self.active_connections.remove(websocket)

    async def broadcast(self, message: dict):
        for connection in self.active_connections:
            try:
                await connection.send_json(message)
            except Exception as e:
                logger.error(f"Error sending to WS: {e}")

manager = ConnectionManager()

# Data Models
class ProcessingRequest(BaseModel):
    links: List[str]
    api_key: Optional[str] = None

# Core Logic Implementation with WS Feedback
async def process_links_background(links: List[str], api_key: str = None):
    # Initialize Core (Pass API key if needed dynamic, but core uses env for now or mock)
    core = TranscribeCore(api_key=api_key)
    
    # Progress Callback
    async def log_callback(message: str, level: str = "info"):
        payload = {"type": "log", "message": message, "level": level}
        await manager.broadcast(payload)

    await log_callback("Initiating TranscribeFlow Sequence...", "info")

    for link in links:
        try:
            result = await core.process_link(link, progress_callback=log_callback)
            # Send success result
            await manager.broadcast({
                "type": "result",
                "data": result
            })
        except Exception as e:
            await log_callback(f"Failed to process {link}", "error")

    await log_callback("All tasks completed.", "success")

# Endpoints
@app.post("/start_processing")
async def start_processing(request: ProcessingRequest, background_tasks: BackgroundTasks):
    if not request.links:
        raise HTTPException(status_code=400, detail="No links provided")
    
    background_tasks.add_task(process_links_background, request.links, request.api_key)
    return {"status": "started", "message": "Processing started in background"}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await manager.connect(websocket)
    try:
        while True:
            # Keep connection alive
            await websocket.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(websocket)
