"""
Database models for Quran memorization app
"""

from sqlalchemy import Column, Integer, String, DateTime, Float, Boolean, Text, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from datetime import datetime

Base = declarative_base()

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    is_active = Column(Boolean, default=True)
    
    # Relationships
    progress_records = relationship("UserProgress", back_populates="user")
    learning_sessions = relationship("LearningSession", back_populates="user")

class Surah(Base):
    __tablename__ = "surahs"
    
    id = Column(Integer, primary_key=True, index=True)
    surah_id = Column(Integer, unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    name_transliterated = Column(String(100), nullable=False)
    ayah_count = Column(Integer, nullable=False)
    juz = Column(Integer)
    
    # Relationships
    verses = relationship("Verse", back_populates="surah")

class Verse(Base):
    __tablename__ = "verses"
    
    id = Column(Integer, primary_key=True, index=True)
    surah_id = Column(Integer, ForeignKey("surahs.surah_id"), nullable=False)
    ayah_id = Column(Integer, nullable=False)
    text = Column(Text, nullable=False)
    translation = Column(Text)
    transliteration = Column(Text)
    juz = Column(Integer)
    
    # Relationships
    surah = relationship("Surah", back_populates="verses")
    progress_records = relationship("UserProgress", back_populates="verse")

class UserProgress(Base):
    __tablename__ = "user_progress"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    verse_id = Column(Integer, ForeignKey("verses.id"), nullable=False)
    
    # Spaced repetition parameters
    repetition_count = Column(Integer, default=0)
    interval_days = Column(Integer, default=1)
    ease_factor = Column(Float, default=2.5)
    last_reviewed = Column(DateTime)
    next_review = Column(DateTime)
    
    # Learning metrics
    total_reviews = Column(Integer, default=0)
    average_score = Column(Float, default=0.0)
    mastery_level = Column(Integer, default=0)  # 0=learning, 1=reviewing, 2=mastered
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="progress_records")
    verse = relationship("Verse", back_populates="progress_records")

class LearningSession(Base):
    __tablename__ = "learning_sessions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    surah_id = Column(Integer, nullable=False)
    ayah_id = Column(Integer, nullable=False)
    
    # Session details
    session_type = Column(String(20), nullable=False)  # 'learning', 'review'
    started_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime)
    time_spent = Column(Integer)  # seconds
    
    # Performance metrics
    score = Column(Float)  # 0.0 to 1.0
    mistakes = Column(Text)  # JSON string of mistakes
    audio_analysis = Column(Text)  # JSON string of audio analysis results
    
    # Relationships
    user = relationship("User", back_populates="learning_sessions")

class AudioAnalysis(Base):
    __tablename__ = "audio_analyses"
    
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("learning_sessions.id"), nullable=False)
    
    # Analysis results
    pronunciation_score = Column(Float, nullable=False)
    phoneme_scores = Column(Text)  # JSON string
    tajweed_violations = Column(Text)  # JSON string
    suggestions = Column(Text)  # JSON string
    confidence = Column(Float, default=0.0)
    
    # Enhanced fields
    word_alignment = Column(Text)  # JSON string of word-by-word alignment
    prosody_scores = Column(Text)  # JSON string of prosody metrics
    model_version = Column(String(50))  # ASR model version used
    processing_time = Column(Float)  # Time taken in seconds
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    session = relationship("LearningSession")
    tajweed_violations_details = relationship("TajweedViolation", back_populates="analysis")


class TajweedViolation(Base):
    __tablename__ = "tajweed_violations"
    
    id = Column(Integer, primary_key=True, index=True)
    violation_id = Column(String(100), unique=True, index=True)
    analysis_id = Column(Integer, ForeignKey("audio_analyses.id"), nullable=False)
    
    # Violation details
    rule_category = Column(String(50), nullable=False)
    rule_name = Column(String(100), nullable=False)
    timestamp_start = Column(Float)  # Start time in seconds
    timestamp_end = Column(Float)  # End time in seconds
    
    # Severity and content
    severity = Column(String(20), nullable=False)  # critical, major, minor
    expected_pronunciation = Column(Text)
    actual_pronunciation = Column(Text)
    audio_segment_path = Column(Text)  # Path to extracted audio segment
    
    # Violation metadata
    description = Column(Text)
    suggestion = Column(Text)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    analysis = relationship("AudioAnalysis", back_populates="tajweed_violations_details")

class Reciter(Base):
    __tablename__ = "reciters"
    
    id = Column(Integer, primary_key=True, index=True)
    reciter_id = Column(String(50), unique=True, nullable=False)
    name = Column(String(100), nullable=False)
    country = Column(String(50))
    style = Column(String(50))
    is_active = Column(Boolean, default=True)
    
    created_at = Column(DateTime, default=datetime.utcnow)

class UserSettings(Base):
    __tablename__ = "user_settings"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), unique=True, nullable=False)
    
    # App settings
    preferred_reciter = Column(String(50))
    daily_goal_verses = Column(Integer, default=5)
    daily_goal_time = Column(Integer, default=30)  # minutes
    notification_enabled = Column(Boolean, default=True)
    reminder_time = Column(String(10), default="20:00")
    
    # Learning preferences
    auto_advance = Column(Boolean, default=False)
    show_translation = Column(Boolean, default=True)
    show_transliteration = Column(Boolean, default=False)
    audio_speed = Column(Float, default=1.0)
    
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User")
