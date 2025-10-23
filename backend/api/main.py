"""
Quran Memorization AI App - FastAPI Backend
Main application entry point
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer
import uvicorn

from .routers import auth, verses, audio, learning, progress

# Initialize FastAPI app
app = FastAPI(
    title="Quran Memorization AI API",
    description="Backend API for AI-powered Quran memorization app",
    version="1.0.0"
)

# CORS middleware for Flutter app
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Security
security = HTTPBearer()

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["authentication"])
app.include_router(verses.router, prefix="/api/verses", tags=["verses"])
app.include_router(audio.router, prefix="/api/audio", tags=["audio"])
app.include_router(learning.router, prefix="/api/learning", tags=["learning"])
app.include_router(progress.router, prefix="/api/progress", tags=["progress"])

@app.get("/")
async def root():
    return {"message": "Quran Memorization AI API", "version": "1.0.0"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
