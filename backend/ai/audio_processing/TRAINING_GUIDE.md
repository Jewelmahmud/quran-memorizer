# ASR Training Guide for Quran Recitation

This guide explains how to train/fine-tune the ASR model specifically for Quran recitation.

## Current Setup

We're using **pre-trained Whisper models** that are already trained on Quran data:
- **Primary**: `tarteel-ai/whisper-base-ar-quran` (WER: 5.75%)
- **Fallback**: `KalamTech/whisper-large-arabic-cv-11` (WER: 12.61%)

## Why Fine-Tuning May Be Needed

Fine-tuning can improve accuracy for:
1. **Specific reciters** (Abdul Basit, Mishary, etc.)
2. **Specific Quranic dialects** (Hafs, Warsh, etc.)
3. **Noisy environments** (mobile recordings)
4. **Different audio quality** (various microphones)

## Training Options

### Option 1: Fine-Tune Existing Quran Model (Recommended)

Use Tarteel's model as base and fine-tune on your specific dataset.

**Advantages:**
- Already trained on Quran recitation
- Faster to train
- Lower computational requirements
- Better starting accuracy

**Step-by-Step:**

1. **Prepare Your Dataset:**

```python
# Create training script: backend/ai/audio_processing/train_asr.py

import whisper
from datasets import load_dataset
import torch

# Load base model
model = whisper.load_model("tarteel-ai/whisper-base-ar-quran")

# Load your training data
# Expected format: (audio_path, text_transcription)
train_data = [
    ("audio/quran/001001.mp3", "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ"),
    ("audio/quran/001002.mp3", "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ"),
    # ... more examples
]

# Convert to dataset format
from whisper.data_utils import AudioDataset, WhisperDataset

train_dataset = WhisperDataset(train_data, model.tokenizer)
```

2. **Training Loop:**

```python
# Training configuration
training_args = {
    "learning_rate": 1e-5,
    "batch_size": 8,
    "num_epochs": 5,
    "warmup_steps": 500,
    "gradient_accumulation_steps": 2,
    "save_steps": 500,
    "logging_steps": 100,
}

# Train
from transformers import TrainingArguments, Trainer

training_args = TrainingArguments(
    output_dir="./whisper-finetuned",
    per_device_train_batch_size=training_args["batch_size"],
    num_train_epochs=training_args["num_epochs"],
    learning_rate=training_args["learning_rate"],
    warmup_steps=training_args["warmup_steps"],
    gradient_accumulation_steps=training_args["gradient_accumulation_steps"],
    save_strategy="steps",
    save_steps=training_args["save_steps"],
    logging_steps=training_args["logging_steps"],
    fp16=True,  # Use mixed precision for speed
)

trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    data_collator=data_collator,
)

trainer.train()

# Save fine-tuned model
model.save_pretrained("./models/whisper-quran-finetuned")
```

### Option 2: Train from Scratch (Advanced)

Train a completely new model from scratch.

**Advantages:**
- Full control over architecture
- Optimized for your specific use case
- No licensing constraints

**Disadvantages:**
- Requires large dataset (1000+ hours)
- Much more computational power needed
- Longer training time
- Requires ML expertise

**Would only recommend if:**
- You have proprietary Quran training data
- You need very specific requirements
- You have significant compute resources

## Data Requirements

### Minimum Dataset Size

For **fine-tuning** (recommended):
- **Minimum**: 100 hours of Quran recitation
- **Recommended**: 200-500 hours
- **Optimal**: 1000+ hours with various reciters

### Data Sources

1. **Tarteel Dataset**
   - Public: https://github.com/Tarteel-io/tarteel-dataset
   - ~1000 hours of Quran recordings
   - Various reciters and styles

2. **Your Own Recordings**
   - Collect user recordings from your app
   - Annotate with correct text
   - Create diverse dataset (various speakers, noise levels)

3. **Professional Reciters**
   - Download recordings from EveryAyah.com
   - Multiple reciters: Mishary, Abdul Basit, Sudais, etc.
   - Ensure proper alignment with text

### Data Preparation

```python
# backend/ai/audio_processing/data_preparation.py

import os
import librosa
import json

def prepare_training_data(
    audio_dir: str,
    text_dir: str,
    output_dir: str
):
    """
    Prepare data for training
    
    Args:
        audio_dir: Directory with audio files
        text_dir: Directory with corresponding text files
        output_dir: Output directory for prepared data
    """
    training_pairs = []
    
    # Load Quran text
    with open(text_dir, 'r', encoding='utf-8') as f:
        quran_data = json.load(f)
    
    for surah_id, surah in quran_data.items():
        for ayah_id, ayah in surah['ayahs'].items():
            audio_path = os.path.join(audio_dir, f"{surah_id:03d}{ayah_id:03d}.mp3")
            text = ayah['text']
            
            if os.path.exists(audio_path):
                # Preprocess audio
                y, sr = librosa.load(audio_path, sr=16000)
                
                # Save preprocessed audio
                output_path = os.path.join(output_dir, f"{surah_id:03d}{ayah_id:03d}.wav")
                librosa.output.write_wav(output_path, y, sr)
                
                training_pairs.append({
                    "audio_path": output_path,
                    "text": text,
                    "surah_id": int(surah_id),
                    "ayah_id": int(ayah_id)
                })
    
    # Save manifest
    manifest_path = os.path.join(output_dir, "manifest.json")
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(training_pairs, f, ensure_ascii=False, indent=2)
    
    print(f"Prepared {len(training_pairs)} training examples")
    return manifest_path

# Usage
manifest = prepare_training_data(
    audio_dir="data/audio/abdul_basit",
    text_dir="data/quran_text/quran_ar.json",
    output_dir="data/training/preprocessed"
)
```

## Training Workflow

### 1. Set Up Training Environment

```bash
# Install additional training dependencies
pip install transformers[torch] datasets evaluate jiwer wandb

# Optional: Set up Weights & Biases for tracking
wandb login
```

### 2. Configure Training

```python
# backend/config.py - Add training config

# Training Configuration
TRAINING_ENABLED: bool = os.getenv("TRAINING_ENABLED", "False").lower() == "true"
TRAINING_DATA_PATH: str = os.getenv("TRAINING_DATA_PATH", "./data/training")
MODEL_OUTPUT_PATH: str = os.getenv("MODEL_OUTPUT_PATH", "./models")
LEARNING_RATE: float = float(os.getenv("LEARNING_RATE", "1e-5"))
BATCH_SIZE: int = int(os.getenv("BATCH_SIZE", "8"))
NUM_EPOCHS: int = int(os.getenv("NUM_EPOCHS", "5"))
```

### 3. Run Training

```python
# backend/ai/audio_processing/train_asr.py

import torch
from transformers import (
    WhisperTokenizer,
    WhisperFeatureExtractor,
    WhisperProcessor,
    WhisperForConditionalGeneration,
    Seq2SeqTrainingArguments,
    Seq2SeqTrainer
)
from datasets import Dataset
import json

def train_quran_asr(
    manifest_path: str,
    base_model: str = "tarteel-ai/whisper-base-ar-quran",
    output_dir: str = "./models/whisper-quran-custom"
):
    """
    Train ASR model on Quran dataset
    
    Args:
        manifest_path: Path to training manifest
        base_model: Base model to fine-tune
        output_dir: Where to save trained model
    """
    
    # Load training data
    with open(manifest_path, 'r') as f:
        train_data = json.load(f)
    
    # Load processor
    processor = WhisperProcessor.from_pretrained(base_model)
    
    # Prepare dataset
    def prepare_dataset(data):
        audio_paths = [item["audio_path"] for item in data]
        texts = [item["text"] for item in data]
        return {"audio": audio_paths, "text": texts}
    
    dataset = Dataset.from_dict(prepare_dataset(train_data))
    
    # Split into train/eval
    dataset = dataset.train_test_split(test_size=0.1)
    train_dataset = dataset["train"]
    eval_dataset = dataset["test"]
    
    # Model
    model = WhisperForConditionalGeneration.from_pretrained(base_model)
    model.config.forced_decoder_ids = None
    
    # Training arguments
    training_args = Seq2SeqTrainingArguments(
        output_dir=output_dir,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=4,
        learning_rate=1e-5,
        warmup_steps=500,
        num_train_epochs=5,
        gradient_checkpointing=True,
        fp16=True,
        evaluation_strategy="steps",
        eval_steps=500,
        save_steps=500,
        logging_steps=100,
        save_total_limit=3,
        push_to_hub=False,
    )
    
    # Data collator
    from transformers import DataCollatorForSeq2Seq
    
    data_collator = DataCollatorForSeq2Seq(
        processor, model=model
    )
    
    # Trainer
    trainer = Seq2SeqTrainer(
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=eval_dataset,
        tokenizer=processor.feature_extractor,
        data_collator=data_collator,
    )
    
    # Train
    trainer.train()
    
    # Save
    trainer.save_model()
    
    print(f"Model saved to {output_dir}")

if __name__ == "__main__":
    train_quran_asr("data/training/manifest.json")
```

### 4. Evaluate Trained Model

```python
def evaluate_model(model_path, test_manifest_path):
    """Evaluate model on test set"""
    
    model = WhisperModel(model_path, device="cuda")
    
    # Load test data
    with open(test_manifest_path, 'r') as f:
        test_data = json.load(f)
    
    wer_scores = []
    for item in test_data:
        result = model.transcribe(item["audio_path"], language="ar")
        predicted = result["text"]
        reference = item["text"]
        
        # Calculate WER
        from jiwer import wer
        wer_score = wer(reference, predicted)
        wer_scores.append(wer_score)
    
    avg_wer = sum(wer_scores) / len(wer_scores)
    print(f"Average WER: {avg_wer:.2%}")
```

## Continuous Learning

### Active Learning Pipeline

```python
# backend/ai/audio_processing/continuous_learning.py

def update_model_with_user_recordings():
    """
    Continuously fine-tune model with user recordings
    
    Workflow:
    1. Collect user recordings with high confidence scores
    2. Manually review/verify transcriptions
    3. Add to training dataset
    4. Fine-tune model periodically
    """
    
    # Fetch high-confidence recordings
    recording_ids = fetch_recordings(
        min_confidence=0.9,
        min_count=100  # Collect 100+ before retraining
    )
    
    # Verify transcriptions (manual review required)
    verified_data = verify_transcriptions(recording_ids)
    
    # Retrain model
    retrain_model(verified_data)
```

## Hardware Requirements

### For Fine-Tuning (Recommended):
- **GPU**: NVIDIA RTX 3090 / A6000 (24GB VRAM minimum)
- **RAM**: 32GB+
- **Storage**: 500GB+ SSD
- **Training Time**: 8-24 hours

### For Training from Scratch:
- **GPU**: 4x NVIDIA A100 (80GB) or equivalent
- **RAM**: 256GB+
- **Storage**: 5TB+ SSD
- **Training Time**: Days to weeks

## Deployment

### 1. Convert to Optimized Format

```python
# Convert trained model for deployment
import whisper

model = whisper.load_model("./models/whisper-quran-custom")
model.to(device="cpu")  # CPU for deployment

# Save
model.save_pretrained("./models/whisper-quran-production")
```

### 2. Update ASR Engine

```python
# backend/ai/audio_processing/asr_engine.py

def __init__(self, model_size: str = "base", device: str = "auto"):
    # Try custom model first
    try:
        self.primary_model = WhisperModel(
            "models/whisper-quran-production",  # Your custom model
            device=device,
            compute_type="float16"
        )
        self.model_name = "custom-quran-model"
    except:
        # Fallback to pre-trained
        self.primary_model = WhisperModel(
            "tarteel-ai/whisper-base-ar-quran",
            device=device,
            compute_type="float16"
        )
        self.model_name = "tarteel-quran"
```

## Cost Estimation

### Fine-Tuning:
- **Compute**: $50-200 (cloud GPU for 24 hours)
- **Data**: Free (use Tarteel dataset or collect your own)
- **Total**: $50-200

### Training from Scratch:
- **Compute**: $500-5000 (significant GPU resources)
- **Data**: Free to collect
- **Total**: $500-5000+

## Recommendations

1. **Start with pre-trained models** (Tarteel) - they already work well
2. **Only fine-tune if you have specific needs** (specific reciter, noise conditions)
3. **Collect user data** during app usage for potential future improvements
4. **Monitor performance** - retrain if accuracy degrades
5. **Consider cloud training** (AWS SageMaker, Google Colab Pro) for cost efficiency

## Testing

After training, evaluate thoroughly:

```python
# Test on various samples
test_cases = [
    ("Short verse", "بِسْمِ اللَّهِ"),
    ("Long verse", "..."),
    ("Various reciters", "..."),
    ("Noisy audio", "..."),
]

for description, audio_path in test_cases:
    result = model.transcribe(audio_path)
    print(f"{description}: {result['text']}")
```

## Next Steps

1. **Collect data** if you need custom training
2. **Set up training environment** with GPU access
3. **Run fine-tuning script** on your dataset
4. **Evaluate** on test set
5. **Deploy** optimized model
6. **Monitor** performance in production

