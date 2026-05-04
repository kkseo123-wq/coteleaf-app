import 'dart:math';

/// 피부 평가 점수 기반 A-Mix 처방 계산 서비스
///
/// AI 피부 분석 결과(29개 측정항목)를 14개 피부 평가 카테고리로 매핑하고,
/// 각 카테고리 점수를 기반으로 맞춤형 조성원료(A-Mix) 처방 비율을 계산합니다.
class SkinAssessmentRecipeService {
  SkinAssessmentRecipeService._();

  /// 피부 평가 항목 → A-Mix 코드 매핑
  static const Map<String, String> _assessmentToMixCode = {
    'radiance': 'A01',       // 광채
    'wrinkle': 'A02',        // 주름
    'dark_circle_v2': 'A03', // 다크서클
    'oiliness': 'A04',       // 유분
    'firmness': 'A05',       // 탄력
    'age_spot': 'A06',       // 색소침착
    'redness': 'A07',        // 홍조
    'droopy_lower_eyelid': 'A08', // 하안검 처짐
    'pore': 'A09',           // 모공
    'texture': 'A10',        // 피부결
    'eye_bag': 'A11',        // 눈밑 지방
    'droopy_upper_eyelid': 'A12', // 상안검 처짐
    'moisture': 'A13',       // 수분
    'acne': 'A14',           // 여드름
  };

  /// A-Mix 코드 → 한국어 라벨
  static const Map<String, String> mixCodeLabels = {
    'A01': '광채',
    'A02': '주름',
    'A03': '다크서클',
    'A04': '유분',
    'A05': '탄력',
    'A06': '색소침착',
    'A07': '홍조',
    'A08': '하안검 처짐',
    'A09': '모공',
    'A10': '피부결',
    'A11': '눈밑 지방',
    'A12': '상안검 처짐',
    'A13': '수분',
    'A14': '여드름',
  };

  /// AI 29개 측정항목 → 14개 평가 카테고리 매핑
  /// 각 카테고리에 매핑된 측정 키들의 평균으로 점수를 산출합니다.
  static const Map<String, List<String>> _measurementMapping = {
    'radiance': [
      'skin_tone_score',
      'dullness_score',
      'uneven_tone_score',
    ],
    'wrinkle': [
      'eye_wrinkle_score',
      'glabella_wrinkle_score',
      'nasolabial_wrinkle_score',
      'fine_deep_wrinkle_score',
    ],
    'dark_circle_v2': [
      'eye_elasticity_score',
    ],
    'oiliness': [
      'oily_score',
      'sebum_score',
    ],
    'firmness': [
      'cheek_sagging_score',
      'jawline_blur_score',
    ],
    'age_spot': [
      'melasma_score',
      'lentigo_score',
      'pih_score',
    ],
    'redness': [
      'redness_score',
      'telangiectasia_score',
      'inflammation_redness_score',
    ],
    // droopy_lower_eyelid: AI 측정 데이터 없음
    // eye_bag: AI 측정 데이터 없음
    // droopy_upper_eyelid: AI 측정 데이터 없음
    'pore': [
      'pore_size_score',
      'pore_sagging_score',
    ],
    'texture': [
      'roughness_score',
      'dead_skin_score',
      'smoothness_score',
    ],
    'moisture': [
      'dry_score',
    ],
    'acne': [
      'acne_score',
      'red_mark_score',
      'pigment_mark_score',
    ],
  };

  /// AI 측정 결과(29개 항목)를 14개 평가 카테고리 점수로 변환
  static Map<String, double> convertMeasurementsToAssessmentScores(
    Map<String, double> measurements,
  ) {
    final scores = <String, double>{};

    for (final entry in _measurementMapping.entries) {
      final assessmentKey = entry.key;
      final measurementKeys = entry.value;

      final values = <double>[];
      for (final key in measurementKeys) {
        if (measurements.containsKey(key)) {
          values.add(measurements[key]!);
        }
      }

      if (values.isNotEmpty) {
        scores[assessmentKey] = values.reduce((a, b) => a + b) / values.length;
      }
    }

    return scores;
  }

  /// 점수 → 처방 비율 변환
  ///
  /// | 점수 범위 | 등급       | 처방 비율     |
  /// |---------|----------|------------|
  /// | 76-100  | Good     | 0%         |
  /// | 41-75   | Moderate | 1.0% ~ 3.0% (선형) |
  /// | 0-40    | Critical | 3.0%       |
  static double calculateSkinAssessmentPercentage(double score) {
    if (score >= 76) {
      return 0.0;
    }
    if (score <= 40) {
      return 3.0;
    }
    // 41-75: 선형 계산
    final percentage = 3.0 - ((score - 41.0) * 2.0 / 34.0);
    // 0.1% 단위 반올림
    final rounded = (percentage * 10).round() / 10.0;
    // 범위 제한: 1.0% ~ 3.0%
    return max(1.0, min(3.0, rounded));
  }

  /// 피부 평가 점수 기반 A-Mix 처방 레시피 계산
  ///
  /// [skinAssessmentScores]: 14개 평가 카테고리 점수 (0-100)
  /// 반환: { "A01": 2.5, "A02": 3.0, ... }
  static Map<String, double> calculateSkinAssessmentRecipe(
    Map<String, double>? skinAssessmentScores,
  ) {
    if (skinAssessmentScores == null || skinAssessmentScores.isEmpty) {
      return {};
    }

    final recipe = <String, double>{};

    for (final entry in _assessmentToMixCode.entries) {
      final assessmentKey = entry.key;
      final mixCode = entry.value;

      final score = skinAssessmentScores[assessmentKey];
      if (score == null || score.isNaN) continue;

      final percentage = calculateSkinAssessmentPercentage(score);
      if (percentage > 0) {
        recipe[mixCode] = percentage;
      }
    }

    return recipe;
  }

  /// AI 측정 결과에서 바로 A-Mix 레시피를 계산하는 편의 메서드
  ///
  /// [measurements]: AI API에서 받은 29개 측정 결과
  /// 반환: { "A01": 2.5, "A02": 3.0, ... }
  static Map<String, double> calculateRecipeFromMeasurements(
    Map<String, double> measurements,
  ) {
    final assessmentScores = convertMeasurementsToAssessmentScores(measurements);
    return calculateSkinAssessmentRecipe(assessmentScores);
  }

  /// 점수에 대한 등급 문자열 반환
  static String getScoreGrade(double score) {
    if (score >= 90) return 'Excellent';
    if (score >= 76) return 'Good';
    if (score >= 41) return 'Moderate';
    return 'Critical';
  }

  /// 점수에 대한 한국어 등급 반환
  static String getScoreGradeKorean(double score) {
    if (score >= 90) return '매우 우수';
    if (score >= 76) return '양호';
    if (score >= 41) return '보통';
    return '개선 필요';
  }
}
