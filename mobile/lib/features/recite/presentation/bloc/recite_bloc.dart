import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'package:quran_memorizer/features/recite/domain/usecases/analyze_recitation_usecase.dart';

part 'recite_event.dart';
part 'recite_state.dart';

class ReciteBloc extends Bloc<ReciteEvent, ReciteState> {
  final AnalyzeRecitationUseCase analyzeRecitationUseCase;
  final AudioRecorder audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();

  Timer? _durationTimer;
  Timer? _warningTimer;
  Timer? _amplitudeTimer;
  Timer? _playbackTimer;
  int _elapsedSeconds = 0;
  static const int _maxDurationSeconds = 120; // 2 minutes
  static const int _warningThreshold = 115; // 5 seconds before end

  String? _recordingPath;
  bool _isRecording = false;
  List<double> _amplitudeData = [];

  bool _isPlaying = false;
  bool _isPaused = false;
  double _playbackPosition = 0.0;

  ReciteBloc({
    required this.analyzeRecitationUseCase,
  }) : super(ReciteInitial()) {
    on<StartRecordingEvent>(_onStartRecording);
    on<StopRecordingEvent>(_onStopRecording);
    on<UpdateDurationEvent>(_onUpdateDuration);
    on<UpdateAmplitudeEvent>(_onUpdateAmplitude);
    on<ShowWarningEvent>(_onShowWarning);
    on<HideWarningEvent>(_onHideWarning);
    on<SubmitRecordingEvent>(_onSubmitRecording);
    on<ResetReciteEvent>(_onResetRecite);
    on<PlayRecordingEvent>(_onPlayRecording);
    on<PauseRecordingEvent>(_onPauseRecording);
    on<StopPlaybackEvent>(_onStopPlayback);
    on<UpdatePlaybackPositionEvent>(_onUpdatePlaybackPosition);

    // Listen to audio player position updates
    audioPlayer.onPositionChanged.listen((duration) {
      if (state is RecordingComplete) {
        _playbackPosition = duration.inMilliseconds.toDouble();
        add(UpdatePlaybackPositionEvent(_playbackPosition));
      }
    });

    // Listen to audio player state changes
    audioPlayer.onPlayerStateChanged.listen((playerState) {
      if (state is RecordingComplete) {
        if (playerState == PlayerState.completed) {
          add(const StopPlaybackEvent());
        }
      }
    });
  }

  Future<void> _onStartRecording(
    StartRecordingEvent event,
    Emitter<ReciteState> emit,
  ) async {
    try {
      // Request permissions
      if (await audioRecorder.hasPermission()) {
        // Get directory for recording
        final directory = await getApplicationDocumentsDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _recordingPath = '${directory.path}/recording_$timestamp.m4a';

        // Start recording
        await audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: _recordingPath!,
        );

        _isRecording = true;
        _elapsedSeconds = 0;

        // Start duration timer
        _amplitudeData = [];

        // Start amplitude timer to simulate audio waveform
        _amplitudeTimer?.cancel();
        _amplitudeTimer =
            Timer.periodic(const Duration(milliseconds: 100), (timer) {
          // Generate realistic waveform with sine waves
          if (_isRecording) {
            final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
            // Combine multiple sine waves for more realistic waveform
            final wave1 = (math.sin(time * 10) * 0.5 + 0.5);
            final wave2 = (math.sin(time * 20) * 0.3 + 0.5);
            final wave3 = (math.sin(time * 5) * 0.2 + 0.5);
            final amplitude = ((wave1 + wave2 + wave3) / 3).clamp(0.1, 0.9);

            _amplitudeData.add(amplitude);

            // Keep only last 50 data points for smooth scrolling
            if (_amplitudeData.length > 50) {
              _amplitudeData.removeAt(0);
            }

            add(UpdateAmplitudeEvent(_amplitudeData));
          }
        });

        _durationTimer?.cancel();
        _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _elapsedSeconds++;
          add(UpdateDurationEvent(_elapsedSeconds));

          // Show warning when approaching max duration
          if (_elapsedSeconds == _warningThreshold) {
            add(ShowWarningEvent());
            _warningTimer = Timer(const Duration(seconds: 5), () {
              add(HideWarningEvent());
            });
          }

          // Auto-stop at max duration
          if (_elapsedSeconds >= _maxDurationSeconds) {
            add(StopRecordingEvent());
          }
        });

        emit(RecordingInProgress(
          elapsedSeconds: _elapsedSeconds,
          isWarningVisible: false,
          amplitudeData: _amplitudeData,
        ));
      } else {
        emit(ReciteError('Microphone permission denied'));
      }
    } catch (e) {
      emit(ReciteError('Failed to start recording: $e'));
    }
  }

  Future<void> _onStopRecording(
    StopRecordingEvent event,
    Emitter<ReciteState> emit,
  ) async {
    try {
      if (_isRecording) {
        _isRecording = false;
        _durationTimer?.cancel();
        _warningTimer?.cancel();
        _amplitudeTimer?.cancel();

        if (_recordingPath != null) {
          await audioRecorder.stop();

          final file = File(_recordingPath!);
          final exists = await file.exists();

          if (exists) {
            emit(RecordingComplete(
              audioPath: _recordingPath!,
              duration: _elapsedSeconds,
            ));
          } else {
            emit(ReciteError('Recording file not found'));
          }
        } else {
          emit(ReciteError('No recording path available'));
        }
      }
    } catch (e) {
      emit(ReciteError('Failed to stop recording: $e'));
    }
  }

  void _onUpdateDuration(
    UpdateDurationEvent event,
    Emitter<ReciteState> emit,
  ) {
    if (state is RecordingInProgress) {
      emit(RecordingInProgress(
        elapsedSeconds: event.elapsedSeconds,
        isWarningVisible: (state as RecordingInProgress).isWarningVisible,
        amplitudeData: (state as RecordingInProgress).amplitudeData,
      ));
    }
  }

  void _onUpdateAmplitude(
    UpdateAmplitudeEvent event,
    Emitter<ReciteState> emit,
  ) {
    if (state is RecordingInProgress) {
      emit(RecordingInProgress(
        elapsedSeconds: _elapsedSeconds,
        isWarningVisible: (state as RecordingInProgress).isWarningVisible,
        amplitudeData: event.amplitudeData,
      ));
    }
  }

  void _onUpdatePlaybackPosition(
    UpdatePlaybackPositionEvent event,
    Emitter<ReciteState> emit,
  ) {
    if (state is RecordingComplete) {
      final currentState = state as RecordingComplete;
      emit(RecordingComplete(
        audioPath: currentState.audioPath,
        duration: currentState.duration,
        isPlaying: currentState.isPlaying,
        isPaused: currentState.isPaused,
        playbackPosition: event.position,
      ));
    }
  }

  void _onShowWarning(
    ShowWarningEvent event,
    Emitter<ReciteState> emit,
  ) {
    if (state is RecordingInProgress) {
      emit(RecordingInProgress(
        elapsedSeconds: _elapsedSeconds,
        isWarningVisible: true,
        amplitudeData: (state as RecordingInProgress).amplitudeData,
      ));
    }
  }

  void _onHideWarning(
    HideWarningEvent event,
    Emitter<ReciteState> emit,
  ) {
    if (state is RecordingInProgress) {
      emit(RecordingInProgress(
        elapsedSeconds: _elapsedSeconds,
        isWarningVisible: false,
        amplitudeData: (state as RecordingInProgress).amplitudeData,
      ));
    }
  }

  Future<void> _onSubmitRecording(
    SubmitRecordingEvent event,
    Emitter<ReciteState> emit,
  ) async {
    if (_recordingPath == null) return;

    emit(AnalyzingRecitation());

    try {
      final result = await analyzeRecitationUseCase(
        audioFilePath: _recordingPath!,
        surahId: event.surahId,
        ayahId: event.ayahId,
        reciter: event.reciter,
      );

      emit(AnalysisComplete(result));
    } catch (e) {
      emit(ReciteError('Failed to analyze recitation: $e'));
    }
  }

  void _onResetRecite(
    ResetReciteEvent event,
    Emitter<ReciteState> emit,
  ) {
    _durationTimer?.cancel();
    _warningTimer?.cancel();
    _amplitudeTimer?.cancel();
    _playbackTimer?.cancel();
    _recordingPath = null;
    _elapsedSeconds = 0;
    _isRecording = false;
    _amplitudeData = [];
    _isPlaying = false;
    _isPaused = false;
    _playbackPosition = 0.0;
    audioPlayer.stop();
    emit(ReciteInitial());
  }

  Future<void> _onPlayRecording(
    PlayRecordingEvent event,
    Emitter<ReciteState> emit,
  ) async {
    if (state is RecordingComplete) {
      final currentState = state as RecordingComplete;

      if (currentState.isPaused) {
        await audioPlayer.resume();
        _isPaused = false;
        _isPlaying = true;
      } else {
        await audioPlayer.play(DeviceFileSource(currentState.audioPath));
        _isPlaying = true;
        _isPaused = false;
        _playbackPosition = 0.0;
      }

      emit(RecordingComplete(
        audioPath: currentState.audioPath,
        duration: currentState.duration,
        isPlaying: _isPlaying,
        isPaused: _isPaused,
        playbackPosition: _playbackPosition,
      ));
    }
  }

  Future<void> _onPauseRecording(
    PauseRecordingEvent event,
    Emitter<ReciteState> emit,
  ) async {
    if (state is RecordingComplete) {
      final currentState = state as RecordingComplete;

      if (currentState.isPlaying) {
        await audioPlayer.pause();
        _isPlaying = false;
        _isPaused = true;

        emit(RecordingComplete(
          audioPath: currentState.audioPath,
          duration: currentState.duration,
          isPlaying: _isPlaying,
          isPaused: _isPaused,
          playbackPosition: _playbackPosition,
        ));
      }
    }
  }

  Future<void> _onStopPlayback(
    StopPlaybackEvent event,
    Emitter<ReciteState> emit,
  ) async {
    if (state is RecordingComplete) {
      final currentState = state as RecordingComplete;

      await audioPlayer.stop();
      _isPlaying = false;
      _isPaused = false;
      _playbackPosition = 0.0;

      emit(RecordingComplete(
        audioPath: currentState.audioPath,
        duration: currentState.duration,
        isPlaying: _isPlaying,
        isPaused: _isPaused,
        playbackPosition: _playbackPosition,
      ));
    }
  }

  @override
  Future<void> close() {
    _durationTimer?.cancel();
    _warningTimer?.cancel();
    _amplitudeTimer?.cancel();
    _playbackTimer?.cancel();
    audioRecorder.dispose();
    audioPlayer.dispose();
    return super.close();
  }
}
