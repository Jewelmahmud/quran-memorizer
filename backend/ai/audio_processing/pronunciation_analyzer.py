"""
Enhanced Pronunciation Analyzer with ASR and Tajweed Engine Integration
"""

import librosa
import numpy as np
from typing import List, Dict, Tuple, Optional
import soundfile as sf
from dataclasses import dataclass
import json

from .asr_engine import QuranASREngine, ASRResult
from .tajweed_engine import TajweedEngine, TajweedViolation


@dataclass
class PronunciationFeedback:
    """Enhanced pronunciation analysis results"""
    overall_score: float  # 0.0 to 1.0
    phoneme_scores: Dict[str, float]
    tajweed_violations: List[Dict[str, any]]
    suggestions: List[str]
    confidence: float
    word_alignment: List[Dict[str, any]]
    prosody_scores: Dict[str, float]
    pronunciation_errors: List[Dict[str, any]]


class PronunciationAnalyzer:
    """
    Enhanced pronunciation analyzer integrating ASR and Tajweed verification
    """
    
    def __init__(self, use_asr: bool = True):
        """
        Initialize pronunciation analyzer
        
        Args:
            use_asr: Whether to use ASR engine for transcription
        """
        self.sample_rate = 16000
        self.n_mfcc = 13
        self.hop_length = 512
        self.win_length = 2048
        
        # Initialize ASR engine
        self.asr_engine = QuranASREngine() if use_asr else None
        
        # Initialize Tajweed engine
        self.tajweed_engine = TajweedEngine()
        
        # Arabic phoneme mapping
        self.arabic_phonemes = {
            'ا': 'alif', 'ب': 'ba', 'ت': 'ta', 'ث': 'tha', 'ج': 'jeem',
            'ح': 'ha', 'خ': 'kha', 'د': 'dal', 'ذ': 'dhal', 'ر': 'ra',
            'ز': 'zay', 'س': 'seen', 'ش': 'sheen', 'ص': 'sad', 'ض': 'dad',
            'ط': 'ta', 'ظ': 'za', 'ع': 'ain', 'غ': 'ghain', 'ف': 'fa',
            'ق': 'qaf', 'ك': 'kaf', 'ل': 'lam', 'م': 'meem', 'ن': 'noon',
            'ه': 'ha', 'و': 'waw', 'ي': 'ya'
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
    
    def extract_prosodic_features(self, audio_path: str) -> Dict[str, float]:
        """
        Extract prosodic features (pitch, intensity, duration)
        
        Args:
            audio_path: Path to audio file
            
        Returns:
            Dictionary of prosodic features
        """
        # Load audio
        y, sr = librosa.load(audio_path, sr=self.sample_rate)
        
        # Extract fundamental frequency (pitch)
        pitches, magnitudes = librosa.piptrack(y=y, sr=sr)
        pitch_values = pitches[pitches > 0]
        avg_pitch = float(np.mean(pitch_values)) if len(pitch_values) > 0 else 0.0
        
        # Extract RMS energy (intensity)
        rms = librosa.feature.rms(y=y)[0]
        avg_intensity = float(np.mean(rms))
        max_intensity = float(np.max(rms))
        
        # Calculate duration
        duration = len(y) / sr
        
        # Speech rate (syllables per second approximation)
        speech_rate = float(np.sum(rms > np.percentile(rms, 50)) / duration)
        
        return {
            'average_pitch': avg_pitch,
            'average_intensity': avg_intensity,
            'max_intensity': max_intensity,
            'duration': duration,
            'speech_rate': speech_rate
        }
    
    def calculate_dtw_distance(self, features1: np.ndarray, features2: np.ndarray) -> float:
        """
        Calculate Dynamic Time Warping distance between two feature sequences
        Pure NumPy implementation for cross-platform compatibility
        
        Args:
            features1: First feature sequence
            features2: Second feature sequence
            
        Returns:
            Normalized DTW distance (0.0 = identical, higher = more different)
        """
        # Get dimensions
        n, m = len(features1), len(features2)
        
        # Initialize cost matrix
        cost_matrix = np.full((n + 1, m + 1), np.inf)
        cost_matrix[0, 0] = 0
        
        # Calculate local distance matrix (euclidean distance)
        for i in range(1, n + 1):
            for j in range(1, m + 1):
                # Compute euclidean distance between feature vectors
                local_distance = np.linalg.norm(features1[i-1] - features2[j-1])
                # DTW recurrence relation
                cost_matrix[i, j] = local_distance + min(
                    cost_matrix[i-1, j],      # insertion
                    cost_matrix[i, j-1],      # deletion
                    cost_matrix[i-1, j-1]     # match
                )
        
        # Get the final DTW distance
        distance = cost_matrix[n, m]
        
        # Normalize by the maximum sequence length
        max_len = max(n, m)
        normalized_distance = distance / max_len if max_len > 0 else 0.0
        
        return normalized_distance
    
    def analyze_pronunciation(
        self,
        user_audio_path: str,
        reference_audio_path: str,
        expected_text: str,
        surah_id: Optional[int] = None,
        ayah_id: Optional[int] = None
    ) -> PronunciationFeedback:
        """
        Enhanced pronunciation analysis with ASR and Tajweed verification
        
        Args:
            user_audio_path: Path to user's recording
            reference_audio_path: Path to reference audio
            expected_text: Expected Arabic text
            surah_id: Optional surah ID for context
            ayah_id: Optional ayah ID for context
            
        Returns:
            Enhanced pronunciation feedback
        """
        # Extract acoustic features
        user_features = self.extract_mfcc_features(user_audio_path)
        reference_features = self.extract_mfcc_features(reference_audio_path)
        
        # Calculate DTW distance for acoustic similarity
        dtw_distance = self.calculate_dtw_distance(user_features, reference_features)
        
        # Transcribe user audio using ASR
        user_transcription = None
        asr_result = None
        
        if self.asr_engine:
            asr_result = self.asr_engine.transcribe(user_audio_path)
            user_transcription = asr_result.text
            
            # Get word alignment
            word_alignment = self.asr_engine.get_word_alignment(
                asr_result,
                expected_text
            )
        else:
            # Fallback to simple text comparison
            word_alignment = []
            user_transcription = expected_text  # Placeholder
        
        # Analyze phoneme-level accuracy
        phoneme_scores = self._analyze_phonemes(user_transcription, expected_text)
        
        # Check for Tajweed violations
        tajweed_violations = self._check_tajweed_violations_extended(
            user_transcription or expected_text,
            expected_text,
            user_audio_path
        )
        
        # Extract prosodic features
        user_prosody = self.extract_prosodic_features(user_audio_path)
        reference_prosody = self.extract_prosodic_features(reference_audio_path)
        
        # Compare prosody
        prosody_scores = self._compare_prosody(user_prosody, reference_prosody)
        
        # Detect pronunciation errors
        pronunciation_errors = self._detect_pronunciation_errors(
            phoneme_scores,
            tajweed_violations,
            word_alignment
        )
        
        # Generate suggestions
        suggestions = self._generate_suggestions(
            phoneme_scores,
            tajweed_violations,
            pronunciation_errors
        )
        
        # Calculate overall score
        overall_score = self._calculate_overall_score_enhanced(
            dtw_distance,
            phoneme_scores,
            tajweed_violations,
            prosody_scores,
            pronunciation_errors
        )
        
        return PronunciationFeedback(
            overall_score=overall_score,
            phoneme_scores=phoneme_scores,
            tajweed_violations=[v.__dict__ for v in tajweed_violations],
            suggestions=suggestions,
            confidence=asr_result.language_probability if asr_result else 0.8,
            word_alignment=word_alignment,
            prosody_scores=prosody_scores,
            pronunciation_errors=pronunciation_errors
        )
    
    def _analyze_phonemes(self, user_text: str, reference_text: str) -> Dict[str, float]:
        """
        Analyze phoneme-level accuracy
        """
        phoneme_scores = {}
        
        if not user_text or not reference_text:
            return phoneme_scores
        
        # Simple character-by-character comparison
        min_len = min(len(user_text), len(reference_text))
        
        for i in range(min_len):
            char = reference_text[i]
            if char in self.arabic_phonemes:
                phoneme = self.arabic_phonemes[char]
                is_correct = user_text[i] == reference_text[i]
                phoneme_scores[f"{phoneme}_{i}"] = 1.0 if is_correct else 0.0
        
        return phoneme_scores
    
    def _check_tajweed_violations_extended(
        self,
        user_text: str,
        reference_text: str,
        audio_path: Optional[str] = None
    ) -> List[TajweedViolation]:
        """
        Check for extended Tajweed rule violations using Tajweed engine
        """
        violations = []
        
        # Use Tajweed engine for comprehensive rule checking
        if user_text and audio_path:
            # Extract audio features for timing analysis
            audio_features = {}
            try:
                # Load audio to get duration
                y, sr = librosa.load(audio_path, sr=self.sample_rate)
                audio_features['duration'] = len(y) / sr
                
                # Check for Madd violations
                pitch = librosa.yin(y, fmin=50, fmax=500)
                audio_features['pitch'] = pitch
                
            except Exception as e:
                print(f"Error loading audio features: {e}")
            
            violations = self.tajweed_engine.check_violations(
                reference_text,
                audio_features=audio_features
            )
        
        return violations
    
    def _compare_prosody(
        self,
        user_prosody: Dict[str, float],
        reference_prosody: Dict[str, float]
    ) -> Dict[str, float]:
        """
        Compare prosodic features between user and reference
        """
        prosody_scores = {}
        
        # Pitch similarity
        if user_prosody.get('average_pitch') and reference_prosody.get('average_pitch'):
            pitch_diff = abs(user_prosody['average_pitch'] - reference_prosody['average_pitch'])
            max_pitch = max(user_prosody['average_pitch'], reference_prosody['average_pitch'])
            prosody_scores['pitch_similarity'] = 1.0 - (pitch_diff / max_pitch if max_pitch > 0 else 0)
        
        # Intensity similarity
        if user_prosody.get('average_intensity') and reference_prosody.get('average_intensity'):
            intensity_diff = abs(user_prosody['average_intensity'] - reference_prosody['average_intensity'])
            max_intensity = max(user_prosody['average_intensity'], reference_prosody['average_intensity'])
            prosody_scores['intensity_similarity'] = 1.0 - (intensity_diff / max_intensity if max_intensity > 0 else 0)
        
        # Duration similarity
        if user_prosody.get('duration') and reference_prosody.get('duration'):
            duration_diff = abs(user_prosody['duration'] - reference_prosody['duration'])
            max_duration = max(user_prosody['duration'], reference_prosody['duration'])
            prosody_scores['duration_similarity'] = 1.0 - (duration_diff / max_duration if max_duration > 0 else 0)
        
        # Speech rate similarity
        if user_prosody.get('speech_rate') and reference_prosody.get('speech_rate'):
            rate_diff = abs(user_prosody['speech_rate'] - reference_prosody['speech_rate'])
            max_rate = max(user_prosody['speech_rate'], reference_prosody['speech_rate'])
            prosody_scores['speech_rate_similarity'] = 1.0 - (rate_diff / max_rate if max_rate > 0 else 0)
        
        return prosody_scores
    
    def _detect_pronunciation_errors(
        self,
        phoneme_scores: Dict[str, float],
        tajweed_violations: List[TajweedViolation],
        word_alignment: List[Dict[str, any]]
    ) -> List[Dict[str, any]]:
        """
        Detect specific pronunciation errors
        """
        errors = []
        
        # Phoneme errors
        for phoneme, score in phoneme_scores.items():
            if score < 0.5:
                errors.append({
                    'type': 'phoneme',
                    'phoneme': phoneme,
                    'confidence': 1.0 - score,
                    'severity': 'major' if score < 0.3 else 'minor'
                })
        
        # Tajweed violations as errors
        for violation in tajweed_violations:
            errors.append({
                'type': 'tajweed',
                'rule': violation.rule_name,
                'severity': violation.severity,
                'description': violation.description,
                'suggestion': violation.suggestion
            })
        
        # Word-level errors from alignment
        for alignment in word_alignment:
            if not alignment.get('match', True):
                errors.append({
                    'type': 'word',
                    'reference_word': alignment.get('reference_word', ''),
                    'recognized_word': alignment.get('recognized_word', ''),
                    'position': alignment.get('position', 0),
                    'severity': 'major'
                })
        
        return errors
    
    def _generate_suggestions(
        self,
        phoneme_scores: Dict[str, float],
        tajweed_violations: List[TajweedViolation],
        pronunciation_errors: List[Dict[str, any]]
    ) -> List[str]:
        """
        Generate improvement suggestions
        """
        suggestions = []
        
        # Group errors by severity
        critical_errors = [e for e in pronunciation_errors if e.get('severity') == 'critical']
        major_errors = [e for e in pronunciation_errors if e.get('severity') == 'major']
        minor_errors = [e for e in pronunciation_errors if e.get('severity') == 'minor']
        
        # Critical issues
        if critical_errors:
            suggestions.append(f"⚠️ {len(critical_errors)} critical errors found. Focus on these first.")
        
        # Major issues
        for error in major_errors[:3]:  # Top 3
            error_type = error.get('type', '')
            if error_type == 'tajweed':
                suggestions.append(f"📿 Tajweed: {error.get('description', '')}")
            elif error_type == 'phoneme':
                suggestions.append(f"🔤 Practice the {error.get('phoneme', '')} sound more carefully")
            elif error_type == 'word':
                ref_word = error.get('reference_word', '')
                rec_word = error.get('recognized_word', '')
                suggestions.append(f"Word error: '{rec_word}' should be '{ref_word}'")
        
        # Tajweed-specific suggestions
        for violation in tajweed_violations[:3]:  # Top 3
            suggestions.append(violation.suggestion)
        
        return suggestions
    
    def _calculate_overall_score_enhanced(
        self,
        dtw_distance: float,
        phoneme_scores: Dict[str, float],
        tajweed_violations: List[TajweedViolation],
        prosody_scores: Dict[str, float],
        pronunciation_errors: List[Dict[str, any]]
    ) -> float:
        """
        Calculate enhanced overall pronunciation score
        """
        # Base score from DTW distance (lower distance = higher score)
        dtw_score = max(0, 1 - dtw_distance)
        
        # Phoneme accuracy score
        if phoneme_scores:
            phoneme_score = sum(phoneme_scores.values()) / len(phoneme_scores)
        else:
            phoneme_score = 0.5
        
        # Prosody score
        if prosody_scores:
            prosody_score = sum(prosody_scores.values()) / len(prosody_scores)
        else:
            prosody_score = 0.5
        
        # Penalty for errors
        critical_penalty = sum(0.2 for e in pronunciation_errors if e.get('severity') == 'critical')
        major_penalty = sum(0.1 for e in pronunciation_errors if e.get('severity') == 'major')
        minor_penalty = sum(0.05 for e in pronunciation_errors if e.get('severity') == 'minor')
        
        # Tajweed violation penalty
        tajweed_penalty = len(tajweed_violations) * 0.08
        
        # Combine scores (weighted)
        overall_score = (
            dtw_score * 0.3 +
            phoneme_score * 0.4 +
            prosody_score * 0.15 +
            (1 - tajweed_penalty) * 0.15
        )
        
        # Apply penalties
        overall_score = overall_score - critical_penalty - major_penalty - minor_penalty
        
        return max(0.0, min(1.0, overall_score))
    
    def compare_with_multiple_references(
        self,
        user_audio_path: str,
        reference_paths: List[str],
        expected_text: str
    ) -> PronunciationFeedback:
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
