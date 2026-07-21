import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:trusight/core/utils/media_validators.dart';
import 'package:trusight/features/analysis/data/models/analysis_result.dart';
import 'package:trusight/features/analysis/services/detection_api_service.dart';
import 'package:trusight/features/history/data/history_repository.dart';
import 'package:trusight/features/history/presentation/providers/history_provider.dart';

void main() {
  group('DetectionApiService Unit Tests', () {
    late DetectionApiService apiService;

    setUp(() {
      apiService = DetectionApiService();
    });

    test('analyzeMediaBytes detects AI synthetic keyword image correctly', () async {
      final dummyBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);
      final result = await apiService.analyzeMediaBytes(
        bytes: dummyBytes,
        fileName: 'deepfake_face_ai_generated.png',
        category: MediaTypeCategory.image,
      );

      expect(result.id, startsWith('TRU-'));
      expect(result.fileName, 'deepfake_face_ai_generated.png');
      expect(result.mediaType, MediaTypeCategory.image);
      expect(result.overallScore, greaterThan(0.70));
      expect(result.classification, 'Likely AI-Generated');
      expect(result.artifacts, isNotEmpty);
      expect(result.riskPercentage, greaterThan(70));
    });

    test('analyzeMediaBytes detects original human photo correctly', () async {
      final dummyBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46]);
      final result = await apiService.analyzeMediaBytes(
        bytes: dummyBytes,
        fileName: 'camera_photo_orig_real.jpg',
        category: MediaTypeCategory.image,
      );

      expect(result.overallScore, lessThan(0.35));
      expect(result.classification, 'Likely Original');
      expect(result.riskPercentage, lessThan(35));
    });

    test('analyzeMediaBytes handles raw camera capture stream without EXIF headers', () async {
      final cameraStreamBytes = Uint8List.fromList(List.generate(300, (i) => (i * 17) % 256));
      final result = await apiService.analyzeMediaBytes(
        bytes: cameraStreamBytes,
        fileName: 'camera_capture_1784641920.jpg',
        category: MediaTypeCategory.image,
      );

      expect(result.id, startsWith('TRU-'));
      expect(result.mediaType, MediaTypeCategory.image);
      expect(result.overallScore, isNotNull);
      expect(result.artifacts, isNotEmpty);
    });

    test('analyzeMediaBytes handles video payload category and artifacts', () async {
      final dummyBytes = Uint8List.fromList([0x00, 0x00, 0x00, 0x20, 0x66, 0x74, 0x79, 0x70]);
      final result = await apiService.analyzeMediaBytes(
        bytes: dummyBytes,
        fileName: 'interview_clip.mp4',
        category: MediaTypeCategory.video,
      );

      expect(result.mediaType, MediaTypeCategory.video);
      expect(result.artifacts.length, equals(3));
      expect(result.artifacts.first.title, contains('Temporal Frame Continuity'));
    });

    test('analyzeMediaBytes handles audio payload category and artifacts', () async {
      final dummyBytes = Uint8List.fromList([0x49, 0x44, 0x33, 0x04, 0x00, 0x00]);
      final result = await apiService.analyzeMediaBytes(
        bytes: dummyBytes,
        fileName: 'voice_note_synth.mp3',
        category: MediaTypeCategory.audio,
      );

      expect(result.mediaType, MediaTypeCategory.audio);
      expect(result.overallScore, greaterThan(0.70));
      expect(result.artifacts.first.title, contains('Vocoder Spectral Cutoff'));
    });
  });

  group('HistoryRepository & Provider Tests', () {
    late HistoryRepository repository;
    late HistoryNotifier historyNotifier;

    setUp(() {
      repository = HistoryRepository();
      repository.clearHistory();
      historyNotifier = HistoryNotifier(repository: repository);
    });

    test('Add scan record and query history', () {
      final scanResult = AnalysisResult(
        id: 'TRU-TEST-001',
        fileName: 'sample_audit.jpg',
        fileSizeBytes: 2048500,
        mediaType: MediaTypeCategory.image,
        overallScore: 0.85,
        classification: 'Likely AI-Generated',
        artifacts: [],
        timestamp: DateTime.now(),
        spatialArtifactScore: 0.85,
        spectralNoiseScore: 0.80,
        metadataIntegrityScore: 0.15,
        temporalJitterScore: 0.82,
      );

      historyNotifier.addScan(scanResult);

      expect(historyNotifier.state.items, isNotEmpty);
      expect(historyNotifier.state.items.first.fileName, 'sample_audit.jpg');
    });

    test('Filter scan history by category', () {
      final imgScan = AnalysisResult(
        id: 'TRU-IMG-01',
        fileName: 'photo.jpg',
        fileSizeBytes: 1024,
        mediaType: MediaTypeCategory.image,
        overallScore: 0.10,
        classification: 'Likely Original',
        artifacts: [],
        timestamp: DateTime.now(),
        spatialArtifactScore: 0.10,
        spectralNoiseScore: 0.12,
        metadataIntegrityScore: 0.90,
        temporalJitterScore: 0.08,
      );
      final videoScan = AnalysisResult(
        id: 'TRU-VID-01',
        fileName: 'video.mp4',
        fileSizeBytes: 5048,
        mediaType: MediaTypeCategory.video,
        overallScore: 0.90,
        classification: 'Likely AI-Generated',
        artifacts: [],
        timestamp: DateTime.now(),
        spatialArtifactScore: 0.88,
        spectralNoiseScore: 0.85,
        metadataIntegrityScore: 0.10,
        temporalJitterScore: 0.92,
      );

      historyNotifier.addScan(imgScan);
      historyNotifier.addScan(videoScan);

      historyNotifier.setFilterCategory(MediaTypeCategory.video);
      expect(historyNotifier.state.items.length, equals(1));
      expect(historyNotifier.state.items.first.mediaType, MediaTypeCategory.video);
    });
  });
}
