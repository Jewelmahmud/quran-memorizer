part of 'recite_bloc.dart';

abstract class ReciteState extends Equatable {
  const ReciteState();

  @override
  List<Object?> get props => [];
}

class ReciteInitial extends ReciteState {
  const ReciteInitial();
}

class RecordingInProgress extends ReciteState {
  final int elapsedSeconds;
  final bool isWarningVisible;
  final List<double> amplitudeData;

  const RecordingInProgress({
    required this.elapsedSeconds,
    required this.isWarningVisible,
    this.amplitudeData = const [],
  });

  @override
  List<Object?> get props => [elapsedSeconds, isWarningVisible, amplitudeData];
}

class RecordingComplete extends ReciteState {
  final String audioPath;
  final int duration;
  final bool isPlaying;
  final bool isPaused;
  final double playbackPosition;

  const RecordingComplete({
    required this.audioPath,
    required this.duration,
    this.isPlaying = false,
    this.isPaused = false,
    this.playbackPosition = 0.0,
  });

  @override
  List<Object?> get props =>
      [audioPath, duration, isPlaying, isPaused, playbackPosition];
}

class AnalyzingRecitation extends ReciteState {
  const AnalyzingRecitation();
}

class AnalysisComplete extends ReciteState {
  final dynamic result;

  const AnalysisComplete(this.result);

  @override
  List<Object?> get props => [result];
}

class ReciteError extends ReciteState {
  final String message;

  const ReciteError(this.message);

  @override
  List<Object?> get props => [message];
}
