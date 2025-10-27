import 'package:quran_memorizer/features/recite/data/models/recitation_response_model.dart';

abstract class ReciteRepository {
  Future<RecitationResponseModel> analyzeRecitation({
    required String audioFilePath,
    required int surahId,
    required int ayahId,
    required String reciter,
  });
}
