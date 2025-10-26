# Mobile ASR Implementation Guide

This document outlines the implementation of on-device ASR for the Quran Memorizer mobile app.

## Overview

The mobile app implements a hybrid approach:
- **On-Device**: Basic ASR and simple Tajweed rules for immediate feedback
- **Server Fallback**: Full ASR pipeline with comprehensive Tajweed verification

## Dependencies

Added to `pubspec.yaml`:
```yaml
dependencies:
  record: ^5.0.4  # Audio recording
  tflite_flutter: ^0.10.0  # TensorFlow Lite inference
  audio_waveforms: ^1.0.5  # Audio visualization
```

## Model Conversion

### Step 1: Convert Whisper to TFLite

```bash
# Install conversion tools
pip install tensorflow==2.15.0
pip install tf2onnx

# Convert Whisper model
python -m tf2onnx.convert \
    --saved-model path/to/whisper/model \
    --output whisper_base.tflite \
    --opset 13
```

### Step 2: Optimize Model

```bash
# Quantize model for smaller size
python optimize_model.py \
    --input whisper_base.tflite \
    --output whisper_base_quantized.tflite \
    --quantize dynamic
```

### Step 3: Place Model

Place optimized model in:
```
mobile/assets/models/whisper_base_quantized.tflite
```

Update `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/models/whisper_base_quantized.tflite
```

## Implementation Structure

### 1. ASR Service

Create `mobile/lib/services/asr_service.dart`:

```dart
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:record/record.dart';

class ASRService {
  late Interpreter _interpreter;
  bool _initialized = false;
  
  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/models/whisper_base_quantized.tflite');
      _initialized = true;
    } catch (e) {
      print('Error loading ASR model: $e');
    }
  }
  
  Future<String> transcribe(String audioPath) async {
    if (!_initialized) await initialize();
    
    // Load and preprocess audio
    final audioData = await _loadAudio(audioPath);
    
    // Run inference
    final output = List.generate(1, (index) => List.generate(vocabSize, (index) => 0.0));
    _interpreter.run(audioData, output);
    
    // Decode transcription
    return _decodeOutput(output);
  }
}
```

### 2. Tajweed Rule Checker

Create `mobile/lib/services/tajweed_service.dart`:

```dart
class TajweedService {
  static bool checkMadd(String text, int position) {
    // Check Madd elongation rule
    // Return true if rule is followed correctly
    return true;
  }
  
  static List<String> checkAllRules(String text) {
    List<String> violations = [];
    
    // Check basic rules on-device
    // Critical rules: Madd, Ghunnah, Qalqalah
    
    return violations;
  }
}
```

### 3. Audio Analysis Service

Create `mobile/lib/services/audio_analysis_service.dart`:

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class AudioAnalysisService {
  final ASRService _asrService = ASRService();
  final Connectivity _connectivity = Connectivity();
  
  Future<AnalysisResult> analyzeRecitation(String audioPath) async {
    var connectivityResult = await _connectivity.checkConnectivity();
    bool isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
                    connectivityResult.contains(ConnectivityResult.wifi);
    
    if (isOnline) {
      // Use server for comprehensive analysis
      return _analyzeOnServer(audioPath);
    } else {
      // Use on-device model
      return _analyzeOnDevice(audioPath);
    }
  }
  
  Future<AnalysisResult> _analyzeOnDevice(String audioPath) async {
    // Basic analysis with on-device model
    final transcription = await _asrService.transcribe(audioPath);
    
    // Apply basic Tajweed rules
    final violations = TajweedService.checkAllRules(transcription);
    
    return AnalysisResult(
      transcription: transcription,
      violations: violations,
      score: _calculateScore(transcription, violations),
      mode: 'offline'
    );
  }
  
  Future<AnalysisResult> _analyzeOnServer(String audioPath) async {
    // Send to backend for comprehensive analysis
    // Implementation would use Dio to call API
    return AnalysisResult(mode: 'online');
  }
}
```

## Configuration

Add to `mobile/lib/config.dart`:

```dart
class Config {
  // ASR Configuration
  static const String asrModelPath = 'assets/models/whisper_base_quantized.tflite';
  static const bool useOnDeviceModel = true;
  static const int bufferSize = 4096;
  
  // Server Configuration
  static const String baseUrl = 'http://your-backend-url.com/api';
  static const String analyzeEndpoint = '/audio/analyze-recitation';
  
  // Connectivity
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
}
```

## Testing

### 1. On-Device Testing

Test ASR with sample recordings:
```dart
test('ASR transcription accuracy', () async {
  final asrService = ASRService();
  await asrService.initialize();
  
  final result = await asrService.transcribe('test_audio.wav');
  expect(result, isNotEmpty);
});
```

### 2. Integration Testing

Test full analysis pipeline:
```dart
test('Full analysis workflow', () async {
  final service = AudioAnalysisService();
  
  final result = await service.analyzeRecitation('recitation.mp3');
  expect(result.score, greaterThan(0.0));
  expect(result.violations, isNotEmpty);
});
```

## Performance Optimization

### Model Size Reduction
- Use dynamic quantization
- Optimize for ARM processors
- Remove unnecessary operations

### Inference Speed
- Use GPU acceleration if available
- Optimize preprocessing pipeline
- Cache frequent operations

### Memory Management
- Clear interpreters after use
- Stream audio processing
- Limit concurrent analyses

## Troubleshooting

### Model Not Loading
- Check assets path in pubspec.yaml
- Verify model file size
- Ensure TFLite version compatibility

### Slow Inference
- Reduce model size
- Use faster model variant
- Enable GPU acceleration

### Low Accuracy
- Fine-tune model on Quran dataset
- Preprocess audio properly
- Check audio quality

## Next Steps

1. Implement actual model conversion
2. Add UI for showing analysis results
3. Integrate with offline queue
4. Add audio recording UI
5. Test on various devices

