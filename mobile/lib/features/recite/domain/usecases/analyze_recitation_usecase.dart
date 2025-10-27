import 'package:quran_memorizer/features/recite/data/models/recitation_response_model.dart';
import 'package:quran_memorizer/features/recite/domain/repositories/recite_repository.dart';

class AnalyzeRecitationUseCase {
  final ReciteRepository repository;

  AnalyzeRecitationUseCase(this.repository);

  Future<RecitationResponseModel> call({
    required String audioFilePath,
    required int surahId,
    required int ayahId,
    required String reciter,
  }) async {
    return await repository.analyzeRecitation(
      audioFilePath: audioFilePath,
      surahId: surahId,
      ayahId: ayahId,
      reciter: reciter,
    );
  }
}
