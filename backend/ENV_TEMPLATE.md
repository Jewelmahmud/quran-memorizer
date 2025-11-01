# Environment Variables Template

Create a `.env` file in the backend directory with these variables:

```bash
# Database Configuration
DATABASE_URL=sqlite:///./quran_memorizer.db
# For PostgreSQL: postgresql://user:password@localhost:5432/quran_memorizer

# Security
SECRET_KEY=your-secret-key-here-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30

# API Configuration
API_HOST=0.0.0.0
API_PORT=8000
DEBUG=True

# AI Configuration
MODEL_PATH=./ai/models/
AUDIO_PROCESSING_ENABLED=True
ON_DEVICE_MODEL_ENABLED=True

# ASR Configuration
ASR_MODEL_SIZE=base
ASR_DEVICE=auto
ASR_BEAM_SIZE=5
ASR_TEMPERATURE=0.0
USE_ASR_ENGINE=True

# Tajweed Configuration
TAJWEED_ENABLED=True
TAJWEED_RIGOROUS_MODE=True

# Audio Configuration
AUDIO_STORAGE_PATH=./data/audio/
MAX_AUDIO_FILE_SIZE=10485760
SUPPORTED_AUDIO_FORMATS=mp3,wav,m4a

# Rate Limiting
RATE_LIMIT_PER_MINUTE=60
RATE_LIMIT_BURST=10
```

## Docker Compose Usage

For Docker Compose, you can either:

1. Create a `.env` file in the backend directory
2. Or set variables directly in `docker-compose.yml` (not recommended for secrets)

## Security Notes

- **Never commit** `.env` files to version control
- Change `SECRET_KEY` to a strong random string in production
- Use environment variables or secrets management for production deployments
- For PostgreSQL, use strong passwords
