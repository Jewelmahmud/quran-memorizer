import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_memorizer/core/di/injection.dart' as di;
import 'package:quran_memorizer/core/widgets/bottom_navigation_bar.dart';
import 'package:quran_memorizer/features/recite/presentation/bloc/recite_bloc.dart';
import 'package:quran_memorizer/l10n/app_localizations.dart';

class RecitePage extends StatelessWidget {
  const RecitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.getIt<ReciteBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.recite),
        ),
        bottomNavigationBar: const AppBottomNavigationBar(currentIndex: 1),
        body: BlocConsumer<ReciteBloc, ReciteState>(
          listener: (context, state) {
            if (state is ReciteError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ReciteInitial) {
              return const _ReadyToRecordView();
            } else if (state is RecordingInProgress) {
              return _RecordingInProgressView(
                elapsedSeconds: state.elapsedSeconds,
                isWarningVisible: state.isWarningVisible,
                amplitudeData: state.amplitudeData,
              );
            } else if (state is RecordingComplete) {
              return _RecordingCompleteView(
                audioPath: state.audioPath,
                duration: state.duration,
                isPlaying: state.isPlaying,
                isPaused: state.isPaused,
                playbackPosition: state.playbackPosition,
              );
            } else if (state is AnalyzingRecitation) {
              return const _AnalyzingView();
            } else if (state is AnalysisComplete) {
              return _AnalysisCompleteView(result: state.result);
            } else if (state is ReciteError) {
              return _ErrorView(message: state.message);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _ReadyToRecordView extends StatelessWidget {
  const _ReadyToRecordView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mic,
              size: 120,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.maxRecordingTime,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ReciteBloc>().add(const StartRecordingEvent());
              },
              icon: const Icon(Icons.mic),
              label: Text(l10n.startRecording),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecordingInProgressView extends StatelessWidget {
  final int elapsedSeconds;
  final bool isWarningVisible;
  final List<double> amplitudeData;

  const _RecordingInProgressView({
    required this.elapsedSeconds,
    required this.isWarningVisible,
    required this.amplitudeData,
  });

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final remainingSeconds = 120 - elapsedSeconds;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Warning notification
          if (isWarningVisible)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    '5 ${l10n.seconds} remaining!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // Recording indicator
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withOpacity(0.1),
            ),
            child: const Icon(
              Icons.mic,
              size: 100,
              color: Colors.red,
            ),
          ),

          const SizedBox(height: 32),

          // Audio Waveform
          if (amplitudeData.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              height: 80,
              child: _AudioWaveformView(amplitudeData: amplitudeData),
            ),

          const SizedBox(height: 32),

          // Time display
          Text(
            _formatDuration(elapsedSeconds),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
          ),

          const SizedBox(height: 8),

          Text(
            l10n.recordingInProgress,
            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 8),

          Text(
            '${remainingSeconds} ${l10n.seconds} remaining',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),

          const SizedBox(height: 48),

          // Stop button
          ElevatedButton.icon(
            onPressed: () {
              context.read<ReciteBloc>().add(const StopRecordingEvent());
            },
            icon: const Icon(Icons.stop),
            label: Text(l10n.stopRecording),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingCompleteView extends StatelessWidget {
  final String audioPath;
  final int duration;
  final bool isPlaying;
  final bool isPaused;
  final double playbackPosition;

  const _RecordingCompleteView({
    required this.audioPath,
    required this.duration,
    required this.isPlaying,
    required this.isPaused,
    required this.playbackPosition,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle,
            size: 120,
            color: Colors.green,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.recordingStopped,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Duration: ${duration}s',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),

          // Playback controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  context.read<ReciteBloc>().add(const StopPlaybackEvent());
                },
                icon: const Icon(Icons.stop),
                iconSize: 40,
                color: Colors.red,
              ),
              const SizedBox(width: 16),
              IconButton(
                onPressed: isPlaying
                    ? () {
                        context
                            .read<ReciteBloc>()
                            .add(const PauseRecordingEvent());
                      }
                    : () {
                        context
                            .read<ReciteBloc>()
                            .add(const PlayRecordingEvent());
                      },
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 60,
                color: Colors.blue,
              ),
            ],
          ),

          const SizedBox(height: 24),
          Text(
            isPlaying
                ? l10n.playing
                : isPaused
                    ? l10n.paused
                    : l10n.tapPlayToListen,
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 48),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  context.read<ReciteBloc>().add(const ResetReciteEvent());
                },
                child: Text(l10n.recordAgain),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: Get surah and ayah from context or params
                  context.read<ReciteBloc>().add(
                        const SubmitRecordingEvent(
                          surahId: 1,
                          ayahId: 1,
                          reciter: 'mishary',
                        ),
                      );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.analyzeRecitation),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            l10n.analyzingRecitation,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _AnalysisCompleteView extends StatelessWidget {
  final dynamic result;

  const _AnalysisCompleteView({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                l10n.recitationAnalysis,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      l10n.pronunciationScore,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(result.pronunciationScore).toStringAsFixed(1)}%',
                      style:
                          Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.feedback,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (result.feedback != null && result.feedback.isNotEmpty)
              ...result.feedback.map((item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: Text(item),
                    ),
                  )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.read<ReciteBloc>().add(const ResetReciteEvent());
                },
                child: Text(l10n.recordAgain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 120,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<ReciteBloc>().add(const ResetReciteEvent());
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AudioWaveformView extends StatelessWidget {
  final List<double> amplitudeData;

  const _AudioWaveformView({required this.amplitudeData});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _WaveformPainter(amplitudeData: amplitudeData),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> amplitudeData;

  _WaveformPainter({required this.amplitudeData});

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudeData.isEmpty) return;

    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final centerY = size.height / 2;
    final barWidth = size.width / amplitudeData.length;

    for (int i = 0; i < amplitudeData.length; i++) {
      final amplitude = amplitudeData[i];
      final barHeight =
          (amplitude * size.height * 0.8).clamp(4.0, size.height * 0.8);

      final startX = i * barWidth + barWidth / 2;
      final startY = centerY - barHeight / 2;
      final endY = centerY + barHeight / 2;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(startX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter oldDelegate) {
    return oldDelegate.amplitudeData != amplitudeData;
  }
}
