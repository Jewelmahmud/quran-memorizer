# Quran ASR System with Tajweed Verification

This module implements a comprehensive Automatic Speech Recognition (ASR) system specifically designed for Quran recitation with advanced Tajweed rule verification.

## Components

### 1. ASR Engine (`asr_engine.py`)

The `QuranASREngine` class provides Quran-specific speech recognition using Whisper models.

**Features:**
- Uses Tarteel's `whisper-base-ar-quran` model (WER: 5.75%) for Quran-specific transcription
- Fallback to KalamTech's general Arabic model
- Word-level and phoneme-level transcription with timestamps
- Audio preprocessing with noise reduction and normalization
- Batch processing support

**Usage:**
```python
from ai.audio_processing import QuranASREngine

engine = QuranASREngine(model_size="base", device="auto")
result = engine.transcribe("path/to/audio.mp3", language="ar")
```

### 2. Tajweed Engine (`tajweed_engine.py`)

The `TajweedEngine` class implements 70+ Tajweed rules for comprehensive pronunciation verification.

**Rule Categories:**
- **Makharij al-Huruf**: Articulation points (throat, tongue, lip letters)
- **Madd**: Elongation rules (natural, compulsory, permissible, connected, separated)
- **Ghunnah**: Nasalization with Noon and Meem Sakinah
- **Idgham**: Assimilation rules (complete, incomplete, with/without Ghunnah)
- **Iqlab**: Substitution rules
- **Idhhar**: Clear pronunciation rules
- **Ikhfa**: Hiding rules
- **Qalqalah**: Echoing rules (minor and major)
- **Tafkheem/Tarqeeq**: Heavy/light pronunciation
- **Waqf**: Stopping rules

**Usage:**
```python
from ai.audio_processing import TajweedEngine

engine = TajweedEngine()
violations = engine.check_violations(text, audio_features)
```

### 3. Pronunciation Analyzer (`pronunciation_analyzer.py`)

The `PronunciationAnalyzer` class integrates ASR and Tajweed engines to provide comprehensive pronunciation feedback.

**Features:**
- ASR-based transcription with word and phoneme-level alignment
- Tajweed rule verification with detailed violations
- Prosodic feature extraction (pitch, intensity, duration, speech rate)
- Multi-reference audio comparison using DTW alignment
- Four-level error detection:
  - Phoneme-level
  - Word-level
  - Tajweed-level
  - Prosodic-level

**Usage:**
```python
from ai.audio_processing import PronunciationAnalyzer

analyzer = PronunciationAnalyzer(use_asr=True)
feedback = analyzer.analyze_pronunciation(
    user_audio_path="user_recitation.mp3",
    reference_audio_path="reference.mp3",
    expected_text="القرآن النص",
    surah_id=1,
    ayah_id=1
)
```

## API Integration

The ASR system is integrated into the `/analyze-recitation` endpoint:

**Endpoint:** `POST /api/audio/analyze-recitation`

**Parameters:**
- `file`: Audio file (UploadFile)
- `surah_id`: Surah number (int)
- `ayah_id`: Ayah number (int)
- `reciter`: Reciter name (str)

**Response:**
```json
{
  "session_id": "string",
  "pronunciation_score": 85.0,
  "feedback": ["list of suggestions"],
  "phoneme_errors": ["error details"],
  "tajweed_violations": ["violation details"]
}
```

## Configuration

Add to your `.env` file:

```env
# ASR Configuration
ASR_MODEL_SIZE=base
ASR_DEVICE=auto
ASR_BEAM_SIZE=5
ASR_TEMPERATURE=0.0
USE_ASR_ENGINE=True

# Tajweed Configuration
TAJWEED_ENABLED=True
TAJWEED_RIGOROUS_MODE=True
```

## Database Schema

Two tables are used to store analysis results:

### `audio_analyses`
- Stores overall analysis results
- Fields: pronunciation_score, phoneme_scores, tajweed_violations, suggestions
- Enhanced fields: word_alignment, prosody_scores, model_version, processing_time

### `tajweed_violations`
- Stores detailed Tajweed violations
- Fields: rule_category, rule_name, timestamp, severity, expected/actual pronunciation
- Relationships: Links to audio_analyses via analysis_id

## Dependencies

Required Python packages (already added to `requirements.txt`):
- `openai-whisper==20231117`
- `faster-whisper==0.10.0`
- `phonemizer==3.2.1`
- `praatio==6.0.0`
- `noisereduce==3.0.0`

## Model Loading

The system automatically attempts to load models in this order:
1. `tarteel-ai/whisper-base-ar-quran` (Quran-specific)
2. `KalamTech/whisper-large-arabic-cv-11` (General Arabic)
3. Base multilingual Whisper model (fallback)

## Mobile Integration

For mobile deployment:
1. Convert Whisper model to TFLite format
2. Implement offline ASR using `tflite_flutter` package
3. Add basic Tajweed rules for on-device checking
4. Fallback to server for comprehensive analysis

## Future Enhancements

1. **Fine-tuning**: Fine-tune on Tarteel dataset for even better accuracy
2. **Custom Validation**: Add validation set with expert Tajweed annotations
3. **Continuous Learning**: Implement feedback loop to improve models
4. **Advanced Prosody**: Deeper analysis of rhythm and melody
5. **Multi-reciter Support**: Train on multiple reciter styles

## Testing

Create test cases with sample recitations to validate:
- ASR transcription accuracy
- Tajweed rule detection
- Error classification and severity
- Suggestion relevance

