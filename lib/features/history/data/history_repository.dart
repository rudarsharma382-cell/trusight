import '../../analysis/data/models/analysis_result.dart';
import '../../../core/utils/media_validators.dart';

class HistoryRepository {
  final List<AnalysisResult> _history = [];

  HistoryRepository() {
    _seedMockHistory();
  }

  void addScan(AnalysisResult result) {
    _history.insert(0, result);
  }

  List<AnalysisResult> getHistory({
    MediaTypeCategory? filterCategory,
    String? searchQuery,
  }) {
    return _history.where((item) {
      if (filterCategory != null && item.mediaType != filterCategory) {
        return false;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return item.fileName.toLowerCase().contains(query) ||
            item.classification.toLowerCase().contains(query) ||
            item.id.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  void clearHistory() {
    _history.clear();
  }

  void _seedMockHistory() {
    final now = DateTime.now();
    _history.addAll([
      AnalysisResult(
        id: 'TRU-X9A21B',
        fileName: 'portrait_ai_gen.png',
        fileSizeBytes: 4210500,
        mediaType: MediaTypeCategory.image,
        overallScore: 0.94,
        classification: 'Likely AI-Generated Synthetic',
        artifacts: [
          const ArtifactBreakdown(
            title: 'Diffusion Latent Pattern',
            description: 'Latent grid signature found matching Flux.1 / Midjourney v6.',
            category: 'Spatial',
            severityScore: 0.95,
            isAnomalyDetected: true,
          ),
          const ArtifactBreakdown(
            title: 'Pupil Geometry & Reflection',
            description: 'Non-symmetric specular reflections in cornea.',
            category: 'Frequency',
            severityScore: 0.88,
            isAnomalyDetected: true,
          ),
        ],
        timestamp: now.subtract(const Duration(hours: 3)),
        spatialArtifactScore: 0.95,
        spectralNoiseScore: 0.91,
        metadataIntegrityScore: 0.10,
        temporalJitterScore: 0.88,
      ),
      AnalysisResult(
        id: 'TRU-8K11FF',
        fileName: 'camera_capture_0042.jpg',
        fileSizeBytes: 2840100,
        mediaType: MediaTypeCategory.image,
        overallScore: 0.12,
        classification: 'Likely Human Original',
        artifacts: [
          const ArtifactBreakdown(
            title: 'Hardware EXIF Verified',
            description: 'Canon EOS R5 raw sensor pattern verified.',
            category: 'Metadata',
            severityScore: 0.10,
            isAnomalyDetected: false,
          ),
        ],
        timestamp: now.subtract(const Duration(hours: 14)),
        spatialArtifactScore: 0.15,
        spectralNoiseScore: 0.18,
        metadataIntegrityScore: 0.92,
        temporalJitterScore: 0.12,
      ),
      AnalysisResult(
        id: 'TRU-V72P09',
        fileName: 'interview_clip_speech.mp4',
        fileSizeBytes: 18400500,
        mediaType: MediaTypeCategory.video,
        overallScore: 0.84,
        classification: 'Likely AI-Generated Synthetic',
        artifacts: [
          const ArtifactBreakdown(
            title: 'Viseme Lip Sync Lag',
            description: 'Phoneme timing offset detected on phonemes /b/ and /p/.',
            category: 'Temporal',
            severityScore: 0.89,
            isAnomalyDetected: true,
          ),
        ],
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        spatialArtifactScore: 0.82,
        spectralNoiseScore: 0.85,
        metadataIntegrityScore: 0.20,
        temporalJitterScore: 0.91,
      ),
      AnalysisResult(
        id: 'TRU-A34M90',
        fileName: 'voice_memo_cloned.wav',
        fileSizeBytes: 6200100,
        mediaType: MediaTypeCategory.audio,
        overallScore: 0.79,
        classification: 'Likely AI-Generated Synthetic',
        artifacts: [
          const ArtifactBreakdown(
            title: 'TTS Vocoder Brickwall',
            description: '14kHz cutoff detected matching ElevenLabs v2 vocoder.',
            category: 'Spectral',
            severityScore: 0.92,
            isAnomalyDetected: true,
          ),
        ],
        timestamp: now.subtract(const Duration(days: 2)),
        spatialArtifactScore: 0.70,
        spectralNoiseScore: 0.88,
        metadataIntegrityScore: 0.15,
        temporalJitterScore: 0.85,
      ),
    ]);
  }
}
