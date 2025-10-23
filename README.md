# Quran Memorization AI App

An AI-powered mobile application to help users memorize the Quran using spaced repetition algorithms and pronunciation analysis.

## Features

### Core Features
- **Spaced Repetition Learning**: AI-driven algorithm to optimize review scheduling
- **Pronunciation Analysis**: Audio processing to provide feedback on recitation
- **Progress Tracking**: Comprehensive statistics and learning analytics
- **Offline Mode**: Learn without internet connection using on-device AI models

### AI Components
- **Learning Optimization**: Custom LSTM model for retention prediction
- **Audio Processing**: Wav2Vec2 fine-tuned for Quranic Arabic pronunciation
- **Hybrid Architecture**: REST API for heavy processing + on-device models for offline use

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  FastAPI Backend │    │  AI Models      │
│                 │    │                 │    │                 │
│ • UI/UX         │◄──►│ • REST APIs     │◄──►│ • Spaced Rep.   │
│ • On-device AI  │    │ • Authentication│    │ • Audio Analysis│
│ • Local Storage │    │ • Database      │    │ • TFLite Models │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## Project Structure

```
quranmomorizer/
├── backend/                 # Python FastAPI backend
│   ├── api/                # API routes and endpoints
│   ├── ai/                 # AI models and algorithms
│   │   ├── spaced_repetition/
│   │   └── audio_processing/
│   ├── data/               # Data processing and downloads
│   ├── database/           # Database models and configuration
│   └── requirements.txt    # Python dependencies
├── mobile/                 # Flutter mobile app
│   ├── lib/
│   │   ├── core/          # Core utilities and configuration
│   │   └── features/      # Feature-based architecture
│   └── pubspec.yaml       # Flutter dependencies
└── docs/                  # Documentation
```

## Getting Started

### Prerequisites
- Python 3.8+
- Flutter 3.0+
- Node.js (for some development tools)

### Backend Setup

1. **Install Python dependencies**:
   ```bash
   cd backend
   pip install -r requirements.txt
   ```

2. **Download Quran data**:
   ```bash
   python data/downloader.py
   ```

3. **Run the backend**:
   ```bash
   python run.py
   ```

The API will be available at `http://localhost:8000`

### Mobile App Setup

1. **Install Flutter dependencies**:
   ```bash
   cd mobile
   flutter pub get
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - User registration

### Verses
- `GET /api/verses/{surah_id}/{ayah_id}` - Get specific verse
- `GET /api/verses/surah/{surah_id}` - Get all verses in surah
- `GET /api/verses/surahs` - Get list of all surahs

### Learning
- `POST /api/learning/start-session` - Start learning session
- `POST /api/learning/complete-verse` - Complete verse learning
- `GET /api/learning/next-review` - Get verses due for review

### Audio
- `GET /api/audio/reciters` - Get available reciters
- `GET /api/audio/{reciter}/{surah_id}/{ayah_id}` - Get audio URL
- `POST /api/audio/analyze-recitation` - Analyze pronunciation
- `GET /api/audio/feedback/{session_id}` - Get analysis feedback

### Progress
- `GET /api/progress/stats` - Get user statistics
- `GET /api/progress/history` - Get learning history
- `GET /api/progress/achievements` - Get user achievements

## AI Models

### Spaced Repetition Model
- **Architecture**: LSTM with attention mechanism
- **Input**: Learning history, verse difficulty, user performance
- **Output**: Retention probability, optimal review interval
- **Size**: <5MB for on-device deployment

### Audio Analysis Model
- **Base Model**: Wav2Vec2-large-xlsr-53
- **Fine-tuning**: Tarteel.ai dataset (~50 hours)
- **Features**: MFCC + Dynamic Time Warping
- **Output**: Pronunciation score, phoneme analysis, Tajweed feedback

## Data Sources

- **Quran Text**: Tanzil.net (Arabic text and translations)
- **Audio**: EveryAyah.com (verse-by-verse recitations)
- **Training Data**: Tarteel.ai dataset (for AI model training)

## Development

### Backend Development
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
python run.py
```

### Mobile Development
```bash
cd mobile
flutter pub get
flutter run
```

### Testing
```bash
# Backend tests
cd backend
pytest

# Mobile tests
cd mobile
flutter test
```

## Deployment

### Backend Deployment
- **Production**: Docker container on AWS/GCP
- **Database**: PostgreSQL on RDS/Cloud SQL
- **Storage**: S3/Cloud Storage for audio files
- **CDN**: CloudFront for global audio delivery

### Mobile Deployment
- **iOS**: App Store via Xcode
- **Android**: Play Store via Flutter build
- **OTA Updates**: Firebase App Distribution for beta testing

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Tanzil.net for Quran text data
- EveryAyah.com for audio recitations
- Tarteel.ai for the open-source dataset
- The Quran memorization community for feedback and testing
