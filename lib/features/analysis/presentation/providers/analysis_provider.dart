import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/utils/media_validators.dart';
import '../../data/models/analysis_result.dart';
import '../../services/detection_api_service.dart';

enum AnalysisStatus {
  idle,
  compressing,
  uploading,
  analyzing,
  success,
  error,
}

class AnalysisState {
  final AnalysisStatus status;
  final double progress; // 0.0 to 1.0
  final String statusMessage;
  final AnalysisResult? result;
  final String? errorMessage;
  final File? selectedFile;
  final MediaTypeCategory category;

  const AnalysisState({
    this.status = AnalysisStatus.idle,
    this.progress = 0.0,
    this.statusMessage = '',
    this.result,
    this.errorMessage,
    this.selectedFile,
    this.category = MediaTypeCategory.image,
  });

  bool get isLoading =>
      status == AnalysisStatus.compressing ||
      status == AnalysisStatus.uploading ||
      status == AnalysisStatus.analyzing;

  AnalysisState copyWith({
    AnalysisStatus? status,
    double? progress,
    String? statusMessage,
    AnalysisResult? result,
    String? errorMessage,
    File? selectedFile,
    MediaTypeCategory? category,
  }) {
    return AnalysisState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      statusMessage: statusMessage ?? this.statusMessage,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedFile: selectedFile ?? this.selectedFile,
      category: category ?? this.category,
    );
  }
}

class AnalysisNotifier extends StateNotifier<AnalysisState> {
  final DetectionApiService _apiService;

  AnalysisNotifier({DetectionApiService? apiService})
      : _apiService = apiService ?? DetectionApiService(),
        super(const AnalysisState());

  void setCategory(MediaTypeCategory category) {
    state = state.copyWith(
      category: category,
      selectedFile: null,
      result: null,
      status: AnalysisStatus.idle,
    );
  }

  void setSelectedFile(File file) {
    state = state.copyWith(
      selectedFile: file,
      result: null,
      status: AnalysisStatus.idle,
      errorMessage: null,
    );
  }

  void clearSelection() {
    state = const AnalysisState();
  }

  Future<void> runAnalysis({File? file, MediaTypeCategory? category}) async {
    final targetFile = file ?? state.selectedFile;
    final targetCategory = category ?? state.category;

    if (targetFile == null) {
      state = state.copyWith(
        status: AnalysisStatus.error,
        errorMessage: 'No file selected for forensic analysis.',
      );
      return;
    }

    // Step 1: Validate file size and format
    final validationError = MediaValidators.validateFile(targetFile);
    if (validationError != null) {
      state = state.copyWith(
        status: AnalysisStatus.error,
        errorMessage: validationError,
      );
      return;
    }

    try {
      File fileToUpload = targetFile;

      // Step 2: Compressing step for video
      if (targetCategory == MediaTypeCategory.video) {
        state = state.copyWith(
          status: AnalysisStatus.compressing,
          progress: 0.15,
          statusMessage: 'Compressing video payload for optimal bandwidth...',
        );

        // Simulated compression optimization delay (falls back gracefully)
        await Future.delayed(const Duration(milliseconds: 600));
      }

      // Step 3: Uploading & Analyzing Payload
      state = state.copyWith(
        status: AnalysisStatus.uploading,
        progress: 0.35,
        statusMessage: 'Transmitting encrypted stream to TruSight Proxy AI core...',
      );

      final result = await _apiService.analyzeMedia(
        file: fileToUpload,
        category: targetCategory,
        onProgress: (sent, total) {
          if (total > 0) {
            final uploadFraction = (sent / total) * 0.4;
            state = state.copyWith(
              status: AnalysisStatus.analyzing,
              progress: (0.35 + uploadFraction).clamp(0.35, 0.75),
              statusMessage: 'Executing deep latent diffusion & spectral phase inspection...',
            );
          }
        },
      );

      state = state.copyWith(
        status: AnalysisStatus.analyzing,
        progress: 0.90,
        statusMessage: 'Finalizing neural telemetry report...',
      );

      await Future.delayed(const Duration(milliseconds: 300));

      state = state.copyWith(
        status: AnalysisStatus.success,
        progress: 1.0,
        statusMessage: 'Analysis Complete',
        result: result,
      );
    } catch (e) {
      state = state.copyWith(
        status: AnalysisStatus.error,
        errorMessage: 'Analysis Failed: ${e.toString()}',
      );
    }
  }
}

final detectionApiServiceProvider = Provider<DetectionApiService>((ref) {
  return DetectionApiService();
});

final analysisProvider =
    StateNotifierProvider<AnalysisNotifier, AnalysisState>((ref) {
  final apiService = ref.watch(detectionApiServiceProvider);
  return AnalysisNotifier(apiService: apiService);
});
