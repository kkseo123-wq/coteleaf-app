import '../services/skin_assessment_recipe_service.dart';

/// 개별 clinical opinion
class ClinicalOpinion {
  final String measurementKey;
  final String category;
  final String measurement;
  final double score;
  final String level;
  final String finding;
  final String action;
  final int priority;

  ClinicalOpinion({
    required this.measurementKey,
    required this.category,
    required this.measurement,
    required this.score,
    required this.level,
    required this.finding,
    required this.action,
    required this.priority,
  });

  factory ClinicalOpinion.fromJson(Map<String, dynamic> json) {
    return ClinicalOpinion(
      measurementKey: json['measurement_key'] ?? '',
      category: json['category'] ?? '',
      measurement: json['measurement'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0,
      level: json['level'] ?? '',
      finding: json['finding'] ?? '',
      action: json['action'] ?? '',
      priority: json['priority'] as int? ?? 99,
    );
  }
}

/// 처방 정보
class Prescription {
  final String measurementKey;
  final String category;
  final String measurementName;
  final String level;
  final List<String> causes;
  final List<String> ingredients;
  final List<String> productTypes;
  final String usage;
  final String duration;
  final List<String> lifestyle;
  final List<String> cautions;
  final bool needConsultation;

  Prescription({
    required this.measurementKey,
    required this.category,
    required this.measurementName,
    required this.level,
    required this.causes,
    required this.ingredients,
    required this.productTypes,
    required this.usage,
    required this.duration,
    required this.lifestyle,
    required this.cautions,
    required this.needConsultation,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      measurementKey: json['measurement_key'] ?? '',
      category: json['category'] ?? '',
      measurementName: json['measurement_name'] ?? '',
      level: json['level'] ?? '',
      causes: _toStringList(json['causes']),
      ingredients: _toStringList(json['ingredients']),
      productTypes: _toStringList(json['product_types']),
      usage: json['usage'] ?? '',
      duration: json['duration'] ?? '',
      lifestyle: _toStringList(json['lifestyle']),
      cautions: _toStringList(json['cautions']),
      needConsultation: json['need_consultation'] as bool? ?? false,
    );
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }
}

/// opinion + prescription 쌍
class DetailedPrescription {
  final ClinicalOpinion opinion;
  final Prescription prescription;

  DetailedPrescription({required this.opinion, required this.prescription});

  factory DetailedPrescription.fromJson(Map<String, dynamic> json) {
    return DetailedPrescription(
      opinion: ClinicalOpinion.fromJson(json['opinion'] as Map<String, dynamic>),
      prescription: Prescription.fromJson(json['prescription'] as Map<String, dynamic>),
    );
  }
}

/// 단일 이미지 분석 결과
class SkinAnalysisResult {
  final String jobId;
  final String status;
  final String mode;
  final DateTime timestamp;
  final double overallScore;
  final double perceivedAge;
  final Map<String, double> measurements; // null 제외된 점수만
  final List<ClinicalOpinion> clinicalOpinions;
  final List<DetailedPrescription> detailedPrescriptions;
  final Map<String, String> artifacts;

  SkinAnalysisResult({
    required this.jobId,
    required this.status,
    required this.mode,
    required this.timestamp,
    required this.overallScore,
    required this.perceivedAge,
    required this.measurements,
    required this.clinicalOpinions,
    required this.detailedPrescriptions,
    required this.artifacts,
  });

  factory SkinAnalysisResult.fromJson(Map<String, dynamic> json) {
    // cv_results 안에 실제 데이터가 있음
    final cvResults = json['cv_results'] as Map<String, dynamic>? ?? {};

    // measurements에서 null이 아닌 점수만 추출
    final rawMeasurements = cvResults['measurements'] as Map<String, dynamic>? ?? {};
    final measurementsMap = <String, double>{};
    rawMeasurements.forEach((key, value) {
      if (value != null) {
        measurementsMap[key] = (value as num).toDouble();
      }
    });

    // clinical_opinions 파싱
    final opinionsJson = cvResults['clinical_opinions'] as List<dynamic>? ?? [];
    final opinions = opinionsJson
        .map((e) => ClinicalOpinion.fromJson(e as Map<String, dynamic>))
        .toList();

    // detailed_prescriptions 파싱
    final prescJson = cvResults['detailed_prescriptions'] as List<dynamic>? ?? [];
    final prescriptions = prescJson
        .map((e) => DetailedPrescription.fromJson(e as Map<String, dynamic>))
        .toList();

    // artifacts
    final artifactsMap = <String, String>{};
    if (json['artifacts'] != null) {
      (json['artifacts'] as Map<String, dynamic>).forEach((key, value) {
        if (value != null) artifactsMap[key] = value.toString();
      });
    }

    return SkinAnalysisResult(
      jobId: json['job_id'] ?? '',
      status: json['status'] ?? '',
      mode: json['mode'] ?? 'cv_only',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      overallScore: (cvResults['overall_score'] as num?)?.toDouble() ?? 0,
      perceivedAge: (cvResults['perceived_age'] as num?)?.toDouble() ?? 0,
      measurements: measurementsMap,
      clinicalOpinions: opinions,
      detailedPrescriptions: prescriptions,
      artifacts: artifactsMap,
    );
  }
}

/// 3장 평균 결과
class AssessmentRecipeEntry {
  final String mixCode;
  final String label;
  final double score;
  final String grade;
  final double percentage;

  AssessmentRecipeEntry({
    required this.mixCode,
    required this.label,
    required this.score,
    required this.grade,
    required this.percentage,
  });
}

class AggregatedSkinResult {
  final double overallScore;
  final double perceivedAge;
  final Map<String, double> averageMeasurements;
  final List<ClinicalOpinion> mergedOpinions; // 우선순위순 병합
  final List<DetailedPrescription> mergedPrescriptions;
  final List<SkinAnalysisResult> individualResults;
  final List<String> angleLabels;

  AggregatedSkinResult({
    required this.overallScore,
    required this.perceivedAge,
    required this.averageMeasurements,
    required this.mergedOpinions,
    required this.mergedPrescriptions,
    required this.individualResults,
    required this.angleLabels,
  });

  String get overallGrade {
    if (overallScore >= 90) return '매우 우수';
    if (overallScore >= 70) return '양호';
    if (overallScore >= 50) return '보통';
    if (overallScore >= 30) return '개선 필요';
    return '집중 관리';
  }

  /// AI 측정 결과로부터 계산된 A-Mix 처방 레시피
  Map<String, double> get assessmentRecipe {
    return SkinAssessmentRecipeService.calculateRecipeFromMeasurements(
      averageMeasurements,
    );
  }

  /// 평가 카테고리별 점수 (14개 항목)
  Map<String, double> get assessmentScores {
    return SkinAssessmentRecipeService.convertMeasurementsToAssessmentScores(
      averageMeasurements,
    );
  }

  /// 처방 상세 정보 (UI 표시용)
  List<AssessmentRecipeEntry> get assessmentRecipeEntries {
    final scores = assessmentScores;
    final recipe = assessmentRecipe;
    final entries = <AssessmentRecipeEntry>[];

    for (final entry in recipe.entries) {
      final mixCode = entry.key;
      final percentage = entry.value;
      final label = SkinAssessmentRecipeService.mixCodeLabels[mixCode] ?? mixCode;

      // 해당 mixCode에 대응하는 assessment key 찾기
      double score = 0;
      for (final scoreEntry in scores.entries) {
        final expectedMixCode = _assessmentKeyToMixCode[scoreEntry.key];
        if (expectedMixCode == mixCode) {
          score = scoreEntry.value;
          break;
        }
      }

      entries.add(AssessmentRecipeEntry(
        mixCode: mixCode,
        label: label,
        score: score,
        grade: SkinAssessmentRecipeService.getScoreGradeKorean(score),
        percentage: percentage,
      ));
    }

    // 처방 비율 높은 순으로 정렬
    entries.sort((a, b) => b.percentage.compareTo(a.percentage));
    return entries;
  }

  static const Map<String, String> _assessmentKeyToMixCode = {
    'radiance': 'A01',
    'wrinkle': 'A02',
    'dark_circle_v2': 'A03',
    'oiliness': 'A04',
    'firmness': 'A05',
    'age_spot': 'A06',
    'redness': 'A07',
    'droopy_lower_eyelid': 'A08',
    'pore': 'A09',
    'texture': 'A10',
    'eye_bag': 'A11',
    'droopy_upper_eyelid': 'A12',
    'moisture': 'A13',
    'acne': 'A14',
  };

  factory AggregatedSkinResult.fromResults(
    List<SkinAnalysisResult> results,
    List<String> labels,
  ) {
    // overall_score 평균
    final avgOverall = results.map((r) => r.overallScore).reduce((a, b) => a + b) / results.length;

    // perceived_age 평균
    final avgAge = results.map((r) => r.perceivedAge).reduce((a, b) => a + b) / results.length;

    // measurements 평균 (null 제외된 것들만)
    final allKeys = <String>{};
    for (final result in results) {
      allKeys.addAll(result.measurements.keys);
    }

    final avgMeasurements = <String, double>{};
    for (final key in allKeys) {
      final values = results
          .where((r) => r.measurements.containsKey(key))
          .map((r) => r.measurements[key]!)
          .toList();
      if (values.isNotEmpty) {
        avgMeasurements[key] = values.reduce((a, b) => a + b) / values.length;
      }
    }

    // opinions: 첫 번째 결과의 것을 기본으로 사용 (우선순위가 같으므로)
    final opinions = results.isNotEmpty ? results.first.clinicalOpinions : <ClinicalOpinion>[];
    final prescriptions = results.isNotEmpty ? results.first.detailedPrescriptions : <DetailedPrescription>[];

    return AggregatedSkinResult(
      overallScore: avgOverall,
      perceivedAge: avgAge,
      averageMeasurements: avgMeasurements,
      mergedOpinions: opinions,
      mergedPrescriptions: prescriptions,
      individualResults: results,
      angleLabels: labels,
    );
  }
}
