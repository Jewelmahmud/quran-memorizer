"""
Audio router for recitation playback and pronunciation analysis
"""

from fastapi import APIRouter, HTTPException, UploadFile, File
from pydantic import BaseModel
from typing import List, Optional
import os
import time
import json

from ai.audio_processing.pronunciation_analyzer import PronunciationAnalyzer
from ai.audio_processing.asr_engine import QuranASREngine
from database.database import get_db
from sqlalchemy.orm import Session

router = APIRouter()

# Initialize analyzers
pronunciation_analyzer = PronunciationAnalyzer()
asr_engine = QuranASREngine()

class AudioAnalysis(BaseModel):
    session_id: str
    pronunciation_score: float
    feedback: List[str]
    phoneme_errors: List[str]
    tajweed_violations: List[str]

class Reciter(BaseModel):
    reciter_id: str
    name: str
    country: str
    style: str

@router.get("/reciters", response_model=List[Reciter])
async def get_available_reciters():
    """
    Get list of available reciters
    """
    reciters = [
        Reciter(reciter_id="mishary", name="Mishary Rashid Alafasy", country="Kuwait", style="Modern"),
        Reciter(reciter_id="sudais", name="Abdul Rahman Al-Sudais", country="Saudi Arabia", style="Traditional"),
        Reciter(reciter_id="hudhaify", name="Saad Al-Ghamdi", country="Saudi Arabia", style="Traditional"),
    ]
    return reciters

@router.get("/{reciter}/{surah_id}/{ayah_id}")
async def get_verse_audio(reciter: str, surah_id: int, ayah_id: int):
    """
    Get audio file URL for a specific verse recitation
    """
    # TODO: Implement audio file serving
    # For now, return a mock URL
    audio_url = f"/audio/{reciter}/{surah_id:03d}{ayah_id:03d}.mp3"
    return {"audio_url": audio_url, "duration": 15.5}

@router.post("/analyze-recitation")
async def analyze_recitation(
    file: UploadFile = File(...),
    surah_id: int = 1,
    ayah_id: int = 1,
    reciter: str = "mishary"
):
    """
    Analyze user's recitation and provide comprehensive feedback
    """
    start_time = time.time()
    
    # Save uploaded file temporarily
    file_path = f"temp_audio/{file.filename}"
    os.makedirs("temp_audio", exist_ok=True)
    
    with open(file_path, "wb") as buffer:
        content = await file.read()
        buffer.write(content)
    
    # Get reference audio path (simplified - would use actual file paths)
    reference_audio_path = f"backend/data/audio/{reciter}/{surah_id:03d}{ayah_id:03d}.mp3"
    
    # For now, use user's audio as both user and reference (placeholder)
    # In production, fetch actual reference audio from database
    expected_text = "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"  # Example text
    
    # Perform comprehensive analysis
    try:
        feedback = pronunciation_analyzer.analyze_pronunciation(
            user_audio_path=file_path,
            reference_audio_path=file_path,  # Placeholder
            expected_text=expected_text,
            surah_id=surah_id,
            ayah_id=ayah_id
        )
        
        processing_time = time.time() - start_time
        
        # Get model info
        model_info = asr_engine.get_model_info()
        
        # Parse violations to extract feedback messages
        violation_messages = []
        if feedback.tajweed_violations:
            for violation in feedback.tajweed_violations:
                violation_messages.append(violation.get('description', ''))
        
        # Parse pronunciation errors
        error_messages = []
        if feedback.pronunciation_errors:
            for error in feedback.pronunciation_errors:
                if error.get('type') == 'tajweed':
                    error_messages.append(f"Tajweed: {error.get('description', '')}")
                elif error.get('type') == 'phoneme':
                    error_messages.append(f"Phoneme error: {error.get('phoneme', '')}")
                elif error.get('type') == 'word':
                    error_messages.append(f"Word error at position {error.get('position', 0)}")
        
        # Combine all feedback
        all_feedback = feedback.suggestions + violation_messages + error_messages
        
        analysis = AudioAnalysis(
            session_id="session_123",
            pronunciation_score=float(feedback.overall_score * 100),  # Convert to percentage
            feedback=all_feedback,
            phoneme_errors=error_messages,
            tajweed_violations=[v for v in violation_messages]
        )
        
    except Exception as e:
        print(f"Analysis error: {e}")
        # Return basic analysis on error
        analysis = AudioAnalysis(
            session_id="session_123",
            pronunciation_score=0.0,
            feedback=[f"Analysis error: {str(e)}"],
            phoneme_errors=[],
            tajweed_violations=[]
        )
    
    finally:
        # Clean up temp file
        if os.path.exists(file_path):
            os.remove(file_path)
    
    return analysis

@router.get("/feedback/{session_id}", response_model=AudioAnalysis)
async def get_analysis_feedback(session_id: str):
    """
    Get detailed feedback for a completed analysis session
    """
    # TODO: Implement database query for analysis results
    return AudioAnalysis(
        session_id=session_id,
        pronunciation_score=0.85,
        feedback=["Detailed feedback here"],
        phoneme_errors=[],
        tajweed_violations=[]
    )
