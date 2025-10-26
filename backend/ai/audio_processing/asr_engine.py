"""
ASR Engine for Quran recitation using Whisper models
"""

import torch
import numpy as np
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass
from faster_whisper import WhisperModel
import librosa
import noisereduce as nr


@dataclass
class TranscriptionSegment:
    """A segment of transcribed speech with timing and confidence"""
    start: float
    end: float
    text: str
    words: List[Dict[str, any]]
    confidence: float
    phonemes: List[str]


@dataclass
class ASRResult:
    """Complete ASR transcription result"""
    text: str
    segments: List[TranscriptionSegment]
    language: str
    duration: float
    language_probability: float


class QuranASREngine:
    """
    ASR Engine specifically tuned for Quranic Arabic recitation
    Uses Whisper models fine-tuned on Quran data
    """
    
    def __init__(self, model_size: str = "base", device: str = "auto"):
        """
        Initialize ASR engine
        
        Args:
            model_size: Model size (tiny, base, small, medium, large)
            device: Device to run on (auto, cpu, cuda, cuda:0)
        """
        self.model_size = model_size
        self.device = device
        
        # Try to load Tarteel's Quran-specific model
        try:
            self.primary_model = WhisperModel(
                "tarteel-ai/whisper-base-ar-quran",
                device=device,
                compute_type="float16" if device != "cpu" else "int8"
            )
            self.model_name = "tarteel-quran"
            print("Loaded Tarteel Quran-specific Whisper model")
        except Exception as e:
            print(f"Could not load Tarteel model: {e}. Falling back to general Arabic model.")
            try:
                self.primary_model = WhisperModel(
                    "KalamTech/whisper-large-arabic-cv-11",
                    device=device,
                    compute_type="float16" if device != "cpu" else "int8"
                )
                self.model_name = "kalamtech-arabic"
            except Exception as e2:
                print(f"Could not load KalamTech model: {e2}. Using base multilingual model.")
                self.primary_model = WhisperModel(
                    model_size,
                    device=device
                )
                self.model_name = f"whisper-{model_size}"
        
        # Audio preprocessing parameters
        self.sample_rate = 16000
        self.hop_length = 512
        self.n_fft = 2048
        
        # Arabic phonetic mapping
        self.arabic_phonemes = {
            'ا': 'ʔalif', 'أ': 'ʔalif', 'إ': 'ʔalif', 'ء': 'hamza',
            'ب': 'ba', 'ت': 'ta', 'ث': 'θa', 'ج': 'dʒiːm',
            'ح': 'ħaw', 'خ': 'xaw', 'د': 'dal', 'ذ': 'ðal',
            'ر': 'ra', 'ز': 'zaj', 'س': 'siːn', 'ش': 'ʃiːn',
            'ص': 'ṣad', 'ض': 'ḍad', 'ط': 'ṭa', 'ظ': 'ẓa',
            'ع': 'ʕajn', 'غ': 'ɣajn', 'ف': 'fa', 'ق': 'qaf',
            'ك': 'kaf', 'ل': 'lam', 'م': 'miːm', 'ن': 'nuːn',
            'ه': 'haw', 'و': 'waw', 'ي': 'jaj', 'ى': 'jaj',
            'ة': 'ta', 'َ': 'fatha', 'ُ': 'damma', 'ِ': 'kasra',
            'ٌ': 'tanween damma', 'ً': 'tanween fatha', 'ٍ': 'tanween kasra',
            'ْ': 'sukun', 'ّ': 'shadda', 'ّو': 'madd'
        }
    
    def preprocess_audio(self, audio_path: str) -> np.ndarray:
        """
        Preprocess audio for ASR
        
        Args:
            audio_path: Path to audio file
            
        Returns:
            Preprocessed audio array
        """
        # Load audio
        y, sr = librosa.load(audio_path, sr=self.sample_rate)
        
        # Noise reduction
        y = nr.reduce_noise(y=y, sr=sr, stationary=False)
        
        # Normalize
        y = librosa.util.normalize(y)
        
        return y
    
    def transcribe(
        self,
        audio_path: str,
        language: str = "ar",
        temperature: float = 0.0,
        beam_size: int = 5,
        word_timestamps: bool = True,
        initial_prompt: Optional[str] = None
    ) -> ASRResult:
        """
        Transcribe audio to text
        
        Args:
            audio_path: Path to audio file
            language: Language code (ar for Arabic)
            temperature: Sampling temperature
            beam_size: Beam size for beam search
            word_timestamps: Whether to return word-level timestamps
            initial_prompt: Optional initial text to guide transcription
            
        Returns:
            ASRResult with transcription and metadata
        """
        # Preprocess audio
        audio_array = self.preprocess_audio(audio_path)
        
        # Get audio duration
        duration = len(audio_array) / self.sample_rate
        
        # Transcribe
        segments, info = self.primary_model.transcribe(
            audio_array,
            language=language,
            task="transcribe",
            temperature=temperature,
            beam_size=beam_size,
            word_timestamps=word_timestamps,
            initial_prompt=initial_prompt,
            vad_filter=True,  # Voice activity detection
            vad_parameters=dict(
                min_silence_duration_ms=500,
                max_speech_length_s=30.0
            )
        )
        
        # Process segments
        transcription_segments = []
        full_text_parts = []
        
        for segment in segments:
            # Process words if available
            words = []
            if hasattr(segment, 'words') and segment.words:
                for word in segment.words:
                    words.append({
                        'word': word.word,
                        'start': word.start,
                        'end': word.end,
                        'confidence': word.probability
                    })
            
            # Extract phonemes from text
            phonemes = self._extract_phonemes(segment.text)
            
            transcription_segments.append(
                TranscriptionSegment(
                    start=segment.start,
                    end=segment.end,
                    text=segment.text.strip(),
                    words=words,
                    confidence=segment.probability,
                    phonemes=phonemes
                )
            )
            
            full_text_parts.append(segment.text.strip())
        
        return ASRResult(
            text=" ".join(full_text_parts),
            segments=transcription_segments,
            language=info.language,
            duration=duration,
            language_probability=info.language_probability
        )
    
    def _extract_phonemes(self, text: str) -> List[str]:
        """
        Extract phonetic representation of Arabic text
        
        Args:
            text: Arabic text
            
        Returns:
            List of phonemes
        """
        phonemes = []
        for char in text:
            if char in self.arabic_phonemes:
                phonemes.append(self.arabic_phonemes[char])
        return phonemes
    
    def get_word_alignment(
        self,
        asr_result: ASRResult,
        reference_text: str
    ) -> List[Dict[str, any]]:
        """
        Align ASR transcription with reference text
        
        Args:
            asr_result: ASR transcription result
            reference_text: Expected text
            
        Returns:
            List of alignment info for each word
        """
        # Split texts into words
        asr_words = asr_result.text.split()
        ref_words = reference_text.split()
        
        # Simple word-by-word alignment
        alignment = []
        min_len = min(len(asr_words), len(ref_words))
        
        for i in range(min_len):
            is_match = asr_words[i] == ref_words[i]
            alignment.append({
                'reference_word': ref_words[i],
                'recognized_word': asr_words[i],
                'match': is_match,
                'position': i,
                'confidence': 1.0 if is_match else 0.5
            })
        
        return alignment
    
    def batch_transcribe(
        self,
        audio_paths: List[str],
        language: str = "ar"
    ) -> List[ASRResult]:
        """
        Transcribe multiple audio files
        
        Args:
            audio_paths: List of audio file paths
            language: Language code
            
        Returns:
            List of ASR results
        """
        results = []
        for audio_path in audio_paths:
            result = self.transcribe(audio_path, language=language)
            results.append(result)
        return results
    
    def get_model_info(self) -> Dict[str, any]:
        """
        Get information about the loaded model
        
        Returns:
            Dictionary with model information
        """
        return {
            'model_name': self.model_name,
            'model_size': self.model_size,
            'device': self.device,
            'sample_rate': self.sample_rate,
            'supported_languages': ['ar', 'en'],
            'language': 'Arabic (Quran-specific)' if self.model_name == 'tarteel-quran' else 'Arabic'
        }

