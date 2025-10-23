"""
Pronunciation analysis using MFCC and Dynamic Time Warping
"""

import librosa
import numpy as np
from dtaidistance import dtw
from typing import List, Dict, Tuple
import soundfile as sf
from dataclasses import dataclass
import torch
import torchaudio
from transformers import Wav2Vec2Processor, Wav2Vec2ForCTC

@dataclass
class PronunciationFeedback:
    """Pronunciation analysis results"""
    overall_score: float  # 0.0 to 1.0
    phoneme_scores: Dict[str, float]
    tajweed_violations: List[str]
    suggestions: List[str]
    confidence: float

class PronunciationAnalyzer:
    """
    Analyzes pronunciation using MFCC features and DTW alignment
    """
    
    def __init__(self):
        self.sample_rate = 16000
        self.n_mfcc = 13
        self.hop_length = 512
        self.win_length = 2048
        
        # Load Wav2Vec2 model for transcription
        self.processor = Wav2Vec2Processor.from_pretrained("facebook/wav2vec2-large-xlsr-53")
        self.model = Wav2Vec2ForCTC.from_pretrained("facebook/wav2vec2-large-xlsr-53")
        
        # Arabic phoneme mapping
        self.arabic_phonemes = {
            'ا': 'alif', 'ب': 'ba', 'ت': 'ta', 'ث': 'tha', 'ج': 'jeem',
            'ح': 'ha', 'خ': 'kha', 'د': 'dal', 'ذ': 'dhal', 'ر': 'ra',
            'ز': 'zay', 'س': 'seen', 'ش': 'sheen', 'ص': 'sad', 'ض': 'dad',
            'ط': 'ta', 'ظ': 'za', 'ع': 'ain', 'غ': 'ghain', 'ف': 'fa',
            'ق': 'qaf', 'ك': 'kaf', 'ل': 'lam', 'م': 'meem', 'ن': 'noon',
            'ه': 'ha', 'و': 'waw', 'ي': 'ya'
        }
        
        # Tajweed rules mapping
        self.tajweed_rules = {
            'madd': ['ا', 'و', 'ي'],
            'ghunnah': ['ن', 'م'],
            'qalqalah': ['ق', 'ط', 'ب', 'ج', 'د']
        }
    
    def extract_mfcc_features(self, audio_path: str) -> np.ndarray:
        """
        Extract MFCC features from audio file
        
        Args:
            audio_path: Path to audio file
            
        Returns:
            MFCC feature matrix
        """
        # Load audio
        y, sr = librosa.load(audio_path, sr=self.sample_rate)
        
        # Extract MFCC features
        mfccs = librosa.feature.mfcc(
            y=y,
            sr=sr,
            n_mfcc=self.n_mfcc,
            hop_length=self.hop_length,
            win_length=self.win_length
        )
        
        return mfccs.T  # Transpose to (time, features)
    
    def calculate_dtw_distance(self, features1: np.ndarray, features2: np.ndarray) -> float:
        """
        Calculate Dynamic Time Warping distance between two feature sequences
        
        Args:
            features1: First feature sequence
            features2: Second feature sequence
            
        Returns:
            Normalized DTW distance (0.0 = identical, higher = more different)
        """
        distance = dtw.distance(features1, features2)
        max_len = max(len(features1), len(features2))
        normalized_distance = distance / max_len
        
        return normalized_distance
    
    def transcribe_audio(self, audio_path: str) -> str:
        """
        Transcribe audio to Arabic text using Wav2Vec2
        
        Args:
            audio_path: Path to audio file
            
        Returns:
            Transcribed text
        """
        # Load and preprocess audio
        speech_array, sampling_rate = librosa.load(audio_path, sr=16000)
        
        # Process with Wav2Vec2
        inputs = self.processor(
            speech_array, 
            sampling_rate=sampling_rate, 
            return_tensors="pt", 
            padding=True
        )
        
        # Get transcription
        with torch.no_grad():
            logits = self.model(inputs.input_values, attention_mask=inputs.attention_mask).logits
        
        # Decode
        predicted_ids = torch.argmax(logits, dim=-1)
        transcription = self.processor.decode(predicted_ids[0])
        
        return transcription
    
    def analyze_pronunciation(self, user_audio_path: str, 
                            reference_audio_path: str,
                            expected_text: str) -> PronunciationFeedback:
        """
        Analyze user's pronunciation against reference
        
        Args:
            user_audio_path: Path to user's recording
            reference_audio_path: Path to reference audio
            expected_text: Expected Arabic text
            
        Returns:
            Pronunciation analysis results
        """
        # Extract MFCC features
        user_features = self.extract_mfcc_features(user_audio_path)
        reference_features = self.extract_mfcc_features(reference_audio_path)
        
        # Calculate DTW distance
        dtw_distance = self.calculate_dtw_distance(user_features, reference_features)
        
        # Transcribe user audio
        user_transcription = self.transcribe_audio(user_audio_path)
        
        # Analyze phoneme-level accuracy
        phoneme_scores = self._analyze_phonemes(user_transcription, expected_text)
        
        # Check for Tajweed violations
        tajweed_violations = self._check_tajweed_violations(user_transcription, expected_text)
        
        # Generate suggestions
        suggestions = self._generate_suggestions(phoneme_scores, tajweed_violations)
        
        # Calculate overall score
        overall_score = self._calculate_overall_score(dtw_distance, phoneme_scores, tajweed_violations)
        
        return PronunciationFeedback(
            overall_score=overall_score,
            phoneme_scores=phoneme_scores,
            tajweed_violations=tajweed_violations,
            suggestions=suggestions,
            confidence=0.8  # Mock confidence score
        )
    
    def _analyze_phonemes(self, user_text: str, reference_text: str) -> Dict[str, float]:
        """
        Analyze phoneme-level accuracy
        """
        phoneme_scores = {}
        
        # Simple character-by-character comparison for now
        min_len = min(len(user_text), len(reference_text))
        
        for i in range(min_len):
            char = reference_text[i]
            if char in self.arabic_phonemes:
                phoneme = self.arabic_phonemes[char]
                is_correct = user_text[i] == reference_text[i]
                phoneme_scores[phoneme] = 1.0 if is_correct else 0.0
        
        return phoneme_scores
    
    def _check_tajweed_violations(self, user_text: str, reference_text: str) -> List[str]:
        """
        Check for Tajweed rule violations
        """
        violations = []
        
        # Check for missing madd letters
        for char in reference_text:
            if char in self.tajweed_rules['madd']:
                if char not in user_text:
                    violations.append(f"Missing madd letter: {char}")
        
        # Check for ghunnah violations
        for char in reference_text:
            if char in self.tajweed_rules['ghunnah']:
                if char not in user_text:
                    violations.append(f"Missing ghunnah: {char}")
        
        return violations
    
    def _generate_suggestions(self, phoneme_scores: Dict[str, float], 
                            violations: List[str]) -> List[str]:
        """
        Generate improvement suggestions
        """
        suggestions = []
        
        # Suggest improvements for low-scoring phonemes
        for phoneme, score in phoneme_scores.items():
            if score < 0.5:
                suggestions.append(f"Practice the {phoneme} sound more carefully")
        
        # Add suggestions for violations
        for violation in violations:
            if "madd" in violation:
                suggestions.append("Hold the madd letters longer")
            elif "ghunnah" in violation:
                suggestions.append("Apply proper nasalization for ghunnah")
        
        return suggestions
    
    def _calculate_overall_score(self, dtw_distance: float, 
                               phoneme_scores: Dict[str, float],
                               violations: List[str]) -> float:
        """
        Calculate overall pronunciation score
        """
        # Base score from DTW distance (lower distance = higher score)
        dtw_score = max(0, 1 - dtw_distance)
        
        # Phoneme accuracy score
        if phoneme_scores:
            phoneme_score = sum(phoneme_scores.values()) / len(phoneme_scores)
        else:
            phoneme_score = 0.5
        
        # Penalty for violations
        violation_penalty = len(violations) * 0.1
        
        # Combine scores
        overall_score = (dtw_score * 0.4 + phoneme_score * 0.6) - violation_penalty
        
        return max(0.0, min(1.0, overall_score))
    
    def compare_with_multiple_references(self, user_audio_path: str, 
                                       reference_paths: List[str],
                                       expected_text: str) -> PronunciationFeedback:
        """
        Compare user pronunciation with multiple reference recordings
        """
        best_feedback = None
        best_score = 0.0
        
        for ref_path in reference_paths:
            feedback = self.analyze_pronunciation(user_audio_path, ref_path, expected_text)
            
            if feedback.overall_score > best_score:
                best_score = feedback.overall_score
                best_feedback = feedback
        
        return best_feedback
