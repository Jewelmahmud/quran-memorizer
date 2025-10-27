import 'package:dio/dio.dart';
import 'dart:io';
import 'package:quran_memorizer/features/recite/data/models/recitation_response_model.dart';

abstract class ReciteRemoteDataSource {
  Future<RecitationResponseModel> analyzeRecitation({
    required String audioFilePath,
    required int surahId,
    required int ayahId,
    required String reciter,
  });
}

class ReciteRemoteDataSourceImpl implements ReciteRemoteDataSource {
  final Dio dio;

  ReciteRemoteDataSourceImpl(this.dio);

  @override
  Future<RecitationResponseModel> analyzeRecitation({
    required String audioFilePath,
    required int surahId,
    required int ayahId,
    required String reciter,
  }) async {
    try {
      final file = File(audioFilePath);
      final fileName = file.path.split('/').last;
      
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        'surah_id': surahId,
        'ayah_id': ayahId,
        'reciter': reciter,
      });

      final response = await dio.post(
        '/audio/analyze-recitation',
        data: formData,
      );

      return RecitationResponseModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to analyze recitation: $e');
    }
  }
}
