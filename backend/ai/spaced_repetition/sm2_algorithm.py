"""
SuperMemo 2 (SM-2) Algorithm Implementation
Base algorithm for spaced repetition system
"""

from dataclasses import dataclass
from typing import Optional
from datetime import datetime, timedelta

@dataclass
class Card:
    """Represents a learning card with SM-2 parameters"""
    surah_id: int
    ayah_id: int
    repetition_count: int = 0
    interval_days: int = 1
    ease_factor: float = 2.5
    last_reviewed: Optional[datetime] = None
    next_review: Optional[datetime] = None

class SM2Algorithm:
    """
    SuperMemo 2 algorithm for spaced repetition
    """
    
    def __init__(self):
        self.min_ease_factor = 1.3
        self.default_ease_factor = 2.5
    
    def update_card(self, card: Card, quality: float) -> Card:
        """
        Update card parameters based on recall quality (0-5 scale)
        
        Args:
            card: The learning card to update
            quality: Recall quality (0=total blackout, 5=perfect response)
            
        Returns:
            Updated card with new parameters
        """
        if quality < 3:
            # Failed recall - reset repetitions
            card.repetition_count = 0
            card.interval_days = 1
        else:
            # Successful recall
            card.repetition_count += 1
            
            if card.repetition_count == 1:
                card.interval_days = 1
            elif card.repetition_count == 2:
                card.interval_days = 6
            else:
                card.interval_days = int(card.interval_days * card.ease_factor)
            
            # Update ease factor
            card.ease_factor = card.ease_factor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02))
            card.ease_factor = max(self.min_ease_factor, card.ease_factor)
        
        # Update timestamps
        card.last_reviewed = datetime.now()
        card.next_review = datetime.now() + timedelta(days=card.interval_days)
        
        return card
    
    def get_due_cards(self, cards: list[Card], current_time: datetime = None) -> list[Card]:
        """
        Get cards that are due for review
        
        Args:
            cards: List of all learning cards
            current_time: Current time (defaults to now)
            
        Returns:
            List of cards due for review
        """
        if current_time is None:
            current_time = datetime.now()
        
        return [card for card in cards if card.next_review and card.next_review <= current_time]
    
    def calculate_difficulty(self, card: Card, response_times: list[float], 
                           error_patterns: list[str]) -> float:
        """
        Calculate difficulty score based on historical performance
        
        Args:
            card: The learning card
            response_times: List of response times in seconds
            error_patterns: List of error types made
            
        Returns:
            Difficulty score (0.0 = easy, 1.0 = very hard)
        """
        if not response_times:
            return 0.5
        
        avg_response_time = sum(response_times) / len(response_times)
        error_rate = len(error_patterns) / max(card.repetition_count, 1)
        
        # Normalize factors
        time_factor = min(avg_response_time / 10.0, 1.0)  # Assume 10s is slow
        error_factor = min(error_rate, 1.0)
        
        # Weighted difficulty score
        difficulty = (time_factor * 0.3 + error_factor * 0.7)
        return min(max(difficulty, 0.0), 1.0)
    
    def get_learning_schedule(self, cards: list[Card], 
                            study_time_minutes: int = 30) -> list[Card]:
        """
        Generate optimal learning schedule for given study time
        
        Args:
            cards: List of learning cards
            study_time_minutes: Available study time in minutes
            
        Returns:
            Prioritized list of cards for study session
        """
        due_cards = self.get_due_cards(cards)
        
        # Sort by priority (overdue first, then by ease factor)
        def priority_score(card: Card) -> tuple:
            overdue_days = 0
            if card.next_review:
                overdue_days = max(0, (datetime.now() - card.next_review).days)
            return (-overdue_days, card.ease_factor)
        
        due_cards.sort(key=priority_score)
        
        # Estimate time per card (2-5 minutes based on difficulty)
        estimated_cards = study_time_minutes // 3
        return due_cards[:estimated_cards]
