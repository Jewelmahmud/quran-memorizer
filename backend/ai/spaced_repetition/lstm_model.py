"""
LSTM-based retention prediction model for spaced repetition
"""

import torch
import torch.nn as nn
import numpy as np
from typing import List, Tuple, Dict
from dataclasses import dataclass
import pickle
from datetime import datetime

@dataclass
class LearningFeatures:
    """Features for learning prediction model"""
    days_since_review: int
    repetition_count: int
    last_score: float
    ease_factor: float
    verse_difficulty: float
    user_experience: float  # Total verses learned
    time_of_day: float  # 0-24 hours normalized to 0-1
    day_of_week: int  # 0-6
    session_duration: float  # Minutes

class RetentionPredictor(nn.Module):
    """
    LSTM model for predicting retention probability
    """
    
    def __init__(self, input_size: int = 9, hidden_size: int = 64, num_layers: int = 2):
        super(RetentionPredictor, self).__init__()
        
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        
        # LSTM layers
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, 
                           batch_first=True, dropout=0.2)
        
        # Attention mechanism
        self.attention = nn.Linear(hidden_size, 1)
        
        # Output layers
        self.retention_head = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(32, 1),
            nn.Sigmoid()
        )
        
        self.interval_head = nn.Sequential(
            nn.Linear(hidden_size, 32),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(32, 1),
            nn.ReLU()
        )
    
    def forward(self, x: torch.Tensor) -> Tuple[torch.Tensor, torch.Tensor]:
        """
        Forward pass
        
        Args:
            x: Input tensor of shape (batch_size, seq_len, input_size)
            
        Returns:
            Tuple of (retention_probability, optimal_interval_days)
        """
        # LSTM forward pass
        lstm_out, _ = self.lstm(x)
        
        # Attention mechanism
        attention_weights = torch.softmax(self.attention(lstm_out), dim=1)
        context_vector = torch.sum(attention_weights * lstm_out, dim=1)
        
        # Predict retention probability and optimal interval
        retention_prob = self.retention_head(context_vector)
        optimal_interval = self.interval_head(context_vector)
        
        return retention_prob, optimal_interval

class RetentionModel:
    """
    Wrapper class for the retention prediction model
    """
    
    def __init__(self, model_path: str = None):
        self.model = RetentionPredictor()
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model.to(self.device)
        
        if model_path:
            self.load_model(model_path)
    
    def prepare_features(self, features: List[LearningFeatures]) -> torch.Tensor:
        """
        Convert features to model input tensor
        
        Args:
            features: List of learning features
            
        Returns:
            Tensor ready for model input
        """
        feature_list = []
        for feat in features:
            feature_vector = [
                feat.days_since_review,
                feat.repetition_count,
                feat.last_score,
                feat.ease_factor,
                feat.verse_difficulty,
                feat.user_experience,
                feat.time_of_day,
                feat.day_of_week,
                feat.session_duration
            ]
            feature_list.append(feature_vector)
        
        # Pad sequences to same length
        max_len = max(len(feature_list), 10)  # Minimum sequence length
        padded_features = []
        
        for feat_seq in feature_list:
            if len(feat_seq) < max_len:
                # Pad with zeros
                padded = feat_seq + [0.0] * (max_len - len(feat_seq))
            else:
                padded = feat_seq[-max_len:]  # Take last max_len features
            padded_features.append(padded)
        
        return torch.tensor(padded_features, dtype=torch.float32).to(self.device)
    
    def predict_retention(self, features: List[LearningFeatures]) -> Tuple[float, float]:
        """
        Predict retention probability and optimal interval
        
        Args:
            features: List of learning features
            
        Returns:
            Tuple of (retention_probability, optimal_interval_days)
        """
        self.model.eval()
        
        with torch.no_grad():
            input_tensor = self.prepare_features(features)
            retention_prob, optimal_interval = self.model(input_tensor)
            
            return retention_prob.item(), optimal_interval.item()
    
    def generate_training_data(self, num_samples: int = 10000) -> Tuple[List[List[LearningFeatures]], List[float], List[float]]:
        """
        Generate synthetic training data for the model
        
        Args:
            num_samples: Number of training samples to generate
            
        Returns:
            Tuple of (features_sequences, retention_labels, interval_labels)
        """
        features_sequences = []
        retention_labels = []
        interval_labels = []
        
        for _ in range(num_samples):
            # Generate random sequence of learning sessions
            seq_length = np.random.randint(5, 20)
            sequence = []
            
            for i in range(seq_length):
                features = LearningFeatures(
                    days_since_review=np.random.randint(1, 30),
                    repetition_count=np.random.randint(1, 10),
                    last_score=np.random.uniform(0.3, 1.0),
                    ease_factor=np.random.uniform(1.3, 3.0),
                    verse_difficulty=np.random.uniform(0.0, 1.0),
                    user_experience=np.random.uniform(0.0, 1.0),
                    time_of_day=np.random.uniform(0.0, 1.0),
                    day_of_week=np.random.randint(0, 7),
                    session_duration=np.random.uniform(5.0, 60.0)
                )
                sequence.append(features)
            
            features_sequences.append(sequence)
            
            # Generate synthetic labels based on SM-2 algorithm logic
            last_features = sequence[-1]
            retention_prob = self._calculate_synthetic_retention(last_features)
            optimal_interval = self._calculate_synthetic_interval(last_features)
            
            retention_labels.append(retention_prob)
            interval_labels.append(optimal_interval)
        
        return features_sequences, retention_labels, interval_labels
    
    def _calculate_synthetic_retention(self, features: LearningFeatures) -> float:
        """
        Calculate synthetic retention probability based on features
        """
        # Higher ease factor and repetition count = higher retention
        retention = 0.5
        retention += (features.ease_factor - 2.5) * 0.1
        retention += features.repetition_count * 0.05
        retention += features.last_score * 0.3
        
        # Longer intervals = lower retention
        retention -= features.days_since_review * 0.01
        
        return max(0.1, min(0.95, retention))
    
    def _calculate_synthetic_interval(self, features: LearningFeatures) -> float:
        """
        Calculate synthetic optimal interval based on features
        """
        # Base interval on ease factor and repetition count
        interval = features.ease_factor * (1 + features.repetition_count * 0.5)
        
        # Adjust for difficulty
        interval *= (2 - features.verse_difficulty)
        
        return max(1.0, min(365.0, interval))
    
    def train_model(self, epochs: int = 100, learning_rate: float = 0.001):
        """
        Train the model on synthetic data
        """
        # Generate training data
        features_sequences, retention_labels, interval_labels = self.generate_training_data()
        
        # Convert to tensors
        X = torch.stack([self.prepare_features(seq).squeeze(0) for seq in features_sequences])
        y_retention = torch.tensor(retention_labels, dtype=torch.float32).to(self.device)
        y_interval = torch.tensor(interval_labels, dtype=torch.float32).to(self.device)
        
        # Training setup
        optimizer = torch.optim.Adam(self.model.parameters(), lr=learning_rate)
        retention_criterion = nn.BCELoss()
        interval_criterion = nn.MSELoss()
        
        # Training loop
        self.model.train()
        for epoch in range(epochs):
            optimizer.zero_grad()
            
            retention_pred, interval_pred = self.model(X)
            retention_loss = retention_criterion(retention_pred.squeeze(), y_retention)
            interval_loss = interval_criterion(interval_pred.squeeze(), y_interval)
            
            total_loss = retention_loss + interval_loss * 0.1  # Weight interval loss lower
            
            total_loss.backward()
            optimizer.step()
            
            if epoch % 20 == 0:
                print(f"Epoch {epoch}, Loss: {total_loss.item():.4f}")
    
    def save_model(self, path: str):
        """Save trained model"""
        torch.save({
            'model_state_dict': self.model.state_dict(),
            'model_config': {
                'input_size': 9,
                'hidden_size': 64,
                'num_layers': 2
            }
        }, path)
    
    def load_model(self, path: str):
        """Load trained model"""
        checkpoint = torch.load(path, map_location=self.device)
        self.model.load_state_dict(checkpoint['model_state_dict'])
