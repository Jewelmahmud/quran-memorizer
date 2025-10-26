"""
Application configuration
"""

import os
from typing import Optional

class Settings:
    # Database
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./quran_memorizer.db")
    
    # JWT
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-here-change-in-production")
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "30"))
    
    # API
    API_HOST: str = os.getenv("API_HOST", "0.0.0.0")
    API_PORT: int = int(os.getenv("API_PORT", "8000"))
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"
    
    # AI Models
    MODEL_PATH: str = os.getenv("MODEL_PATH", "./ai/models/")
    AUDIO_PROCESSING_ENABLED: bool = os.getenv("AUDIO_PROCESSING_ENABLED", "True").lower() == "true"
    ON_DEVICE_MODEL_ENABLED: bool = os.getenv("ON_DEVICE_MODEL_ENABLED", "True").lower() == "true"
    
    # ASR Configuration
    ASR_MODEL_SIZE: str = os.getenv("ASR_MODEL_SIZE", "base")  # tiny, base, small, medium, large
    ASR_DEVICE: str = os.getenv("ASR_DEVICE", "auto")  # auto, cpu, cuda, cuda:0
    ASR_BEAM_SIZE: int = int(os.getenv("ASR_BEAM_SIZE", "5"))
    ASR_TEMPERATURE: float = float(os.getenv("ASR_TEMPERATURE", "0.0"))
    USE_ASR_ENGINE: bool = os.getenv("USE_ASR_ENGINE", "True").lower() == "true"
    
    # Tajweed Configuration
    TAJWEED_ENABLED: bool = os.getenv("TAJWEED_ENABLED", "True").lower() == "true"
    TAJWEED_RIGOROUS_MODE: bool = os.getenv("TAJWEED_RIGOROUS_MODE", "True").lower() == "true"
    
    # Audio
    AUDIO_STORAGE_PATH: str = os.getenv("AUDIO_STORAGE_PATH", "./data/audio/")
    MAX_AUDIO_FILE_SIZE: int = int(os.getenv("MAX_AUDIO_FILE_SIZE", "10485760"))  # 10MB
    SUPPORTED_AUDIO_FORMATS: list = os.getenv("SUPPORTED_AUDIO_FORMATS", "mp3,wav,m4a").split(",")
    
    # Rate Limiting
    RATE_LIMIT_PER_MINUTE: int = int(os.getenv("RATE_LIMIT_PER_MINUTE", "60"))
    RATE_LIMIT_BURST: int = int(os.getenv("RATE_LIMIT_BURST", "10"))

settings = Settings()
