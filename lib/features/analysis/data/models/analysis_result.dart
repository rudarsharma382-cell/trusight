import '../../../../core/utils/media_validators.dart';

enum RiskLevel {
  low,      // < 0.35 (Likely Human)
  moderate, // 0.35 - 0.70 (Uncertain / Hybrid)
  severe,   // > 0.70 (Likely AI-Generated)
}

class ArtifactBreakdown {
  final String title;
  final String description;
  final String category; // e.g. "Visual", "Frequency", "Metadata", "Acoustic"
  final double severityScore; // 0.0 to 1.0
  final bool isAnomalyDetected;

  const ArtifactBreakdown({
    required this.title,
    required this.description,
    required this.category,
    required this.severityScore,
    required this.isAnomalyDetected,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'category': category,
        'severityScore': severityScore,
        'isAnomalyDetected': isAnomalyDetected,
      };

  factory ArtifactBreakdown.fromJson(Map<String, dynamic> json) {
    return ArtifactBreakdown(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      severityScore: (json['severityScore'] as num).toDouble(),
      isAnomalyDetected: json['isAnomalyDetected'] as bool,
    );
  }
}

class AnalysisResult {
  final String id;
  final String fileName;
  final int fileSizeBytes;
  final MediaTypeCategory mediaType;
  final double overallScore; // 0.0 to 1.0 (Risk percentage)
  final String classification; // "Likely Human", "Uncertain", "Likely AI-Generated"
  final List<ArtifactBreakdown> artifacts;
  final DateTime timestamp;
  
  // Telemetry metric scores
  final double spatialArtifactScore;
  final double spectralNoiseScore;
  final double metadataIntegrityScore;
  final double temporalJitterScore;

  const AnalysisResult({
    required this.id,
    required this.fileName,
    required this.fileSizeBytes,
    required this.mediaType,
    required this.overallScore,
    required this.classification,
    required this.artifacts,
    required this.timestamp,
    required this.spatialArtifactScore,
    required this.spectralNoiseScore,
    required this.metadataIntegrityScore,
    required this.temporalJitterScore,
  });

  RiskLevel get riskLevel {
    if (overallScore < 0.35) return RiskLevel.low;
    if (overallScore < 0.70) return RiskLevel.moderate;
    return RiskLevel.severe;
  }

  int get riskPercentage => (overallScore * 100).round();

  Map<String, dynamic> toJson() => {
        'id': id,
        'fileName': fileName,
        'fileSizeBytes': fileSizeBytes,
        'mediaType': mediaType.name,
        'overallScore': overallScore,
        'classification': classification,
        'artifacts': artifacts.map((a) => a.toJson()).toList(),
        'timestamp': timestamp.toIso8601String(),
        'spatialArtifactScore': spatialArtifactScore,
        'spectralNoiseScore': spectralNoiseScore,
        'metadataIntegrityScore': metadataIntegrityScore,
        'temporalJitterScore': temporalJitterScore,
      };

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileSizeBytes: json['fileSizeBytes'] as int,
      mediaType: MediaTypeCategory.values.firstWhere(
        (e) => e.name == json['mediaType'],
        orElse: () => MediaTypeCategory.image,
      ),
      overallScore: (json['overallScore'] as num).toDouble(),
      classification: json['classification'] as String,
      artifacts: (json['artifacts'] as List)
          .map((item) => ArtifactBreakdown.fromJson(item as Map<String, dynamic>))
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      spatialArtifactScore: (json['spatialArtifactScore'] as num).toDouble(),
      spectralNoiseScore: (json['spectralNoiseScore'] as num).toDouble(),
      metadataIntegrityScore: (json['metadataIntegrityScore'] as num).toDouble(),
      temporalJitterScore: (json['temporalJitterScore'] as num).toDouble(),
    );
  }
}
