import 'package:quran_memorizer/features/recite/data/datasources/recite_remote_datasource.dart';
import 'package:quran_memorizer/features/recite/data/models/recitation_response_model.dart';
import 'package:quran_memorizer/features/recite/domain/repositories/recite_repository.dart';

class ReciteRepositoryImpl implements ReciteRepository {
  final ReciteRemoteDataSource remoteDataSource;

  ReciteRepositoryImpl(this.remoteDataSource);

  @override
  Future<RecitationResponseModel> analyzeRecitation({
    required String audioFilePath,
    required int surahId,
    required int ayahId,
    required String reciter,
  }) async {
    return await remoteDataSource.analyzeRecitation(
      audioFilePath: audioFilePath,
      surahId: surahId,
      ayahId: ayahId,
      reciter: reciter,
    );
  }
}
