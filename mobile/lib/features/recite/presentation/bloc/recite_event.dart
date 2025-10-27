part of 'recite_bloc.dart';

abstract class ReciteEvent extends Equatable {
  const ReciteEvent();

  @override
  List<Object?> get props => [];
}

class StartRecordingEvent extends ReciteEvent {
  const StartRecordingEvent();
}

class StopRecordingEvent extends ReciteEvent {
  const StopRecordingEvent();
}

class UpdateDurationEvent extends ReciteEvent {
  final int elapsedSeconds;

  const UpdateDurationEvent(this.elapsedSeconds);

  @override
  List<Object?> get props => [elapsedSeconds];
}

class UpdateAmplitudeEvent extends ReciteEvent {
  final List<double> amplitudeData;

  const UpdateAmplitudeEvent(this.amplitudeData);

  @override
  List<Object?> get props => [amplitudeData];
}

class ShowWarningEvent extends ReciteEvent {
  const ShowWarningEvent();
}

class HideWarningEvent extends ReciteEvent {
  const HideWarningEvent();
}

class SubmitRecordingEvent extends ReciteEvent {
  final int surahId;
  final int ayahId;
  final String reciter;

  const SubmitRecordingEvent({
    required this.surahId,
    required this.ayahId,
    required this.reciter,
  });

  @override
  List<Object?> get props => [surahId, ayahId, reciter];
}

class ResetReciteEvent extends ReciteEvent {
  const ResetReciteEvent();
}

class PlayRecordingEvent extends ReciteEvent {
  const PlayRecordingEvent();
}

class PauseRecordingEvent extends ReciteEvent {
  const PauseRecordingEvent();
}

class StopPlaybackEvent extends ReciteEvent {
  const StopPlaybackEvent();
}

class UpdatePlaybackPositionEvent extends ReciteEvent {
  final double position;

  const UpdatePlaybackPositionEvent(this.position);

  @override
  List<Object?> get props => [position];
}
