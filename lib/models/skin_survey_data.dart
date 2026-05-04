class SkinSurveyData {
  // 섹션 1: 기본정보
  bool? consentAgreed;
  String? gender;
  String? ageGroup;
  String? ethnicity;
  String? ethnicityOther;

  // 섹션 1: 피부유형 (복수선택 가능)
  Map<String, bool> skinTypes = {
    '건성': false,
    '중성': false,
    '지성': false,
    '복합성': false,
    '민감성': false,
    '잘 모름': false,
  };

  // 섹션 2: 피부관심 (복수선택 가능)
  Map<String, bool> skinInterests = {
    '피부미백': false,
    '각질제거': false,
    '주름개선': false,
    '모공관리': false,
    '피부노화': false,
    '피부탄력': false,
    '피부보습 및 영양': false,
  };

  // 섹션 2: 현재 피부고민 (복수선택, 제한 없음)
  Map<String, bool> skinConcerns = {
    '아토피': false,
    '여드름 및 뾰루지': false,
    '붉은 자국': false,
    '가려움증': false,
    '피부건조 및 갈라짐': false,
    '따가움/화끈거림': false,
    '눈/입가/팔자 주름': false,
    '거친 피부 및 칙칙함': false,
    '과다한 피지분비': false,
    '기미, 주근깨, 잡티 등': false,
    '블랙/화이트 헤드': false,
    '각질': false,
    '알러지': false,
  };
  String? skinConcernsOther;

  // 섹션 3: 알러지 유무 (발진/두드러기 포함)
  bool? allergyHerb; // 한약/허브/풀/콩에 대한 알러지
  String? allergyHerbDetail; // 종류
  bool? allergySunlight; // 햇빛에 대한 알러지
  String? allergySunlightDetail; // 종류
  bool? allergyCosmetics; // 화장품에 대한 알러지
  String? allergyCosmeticsBrand; // 브랜드

  // 섹션 3: AI 피부 측정 결과 (29개 항목, 각 0-100점)

  // 카테고리 1: 색소 (Pigmentation)
  int melasmaScore = 50; // 기미
  int lentigoScore = 50; // 잡티/검버섯
  int freckleScore = 50; // 주근깨
  int pihScore = 50; // 색소침착 (PIH)

  // 카테고리 2: 홍조·혈관 (Redness & Vascular)
  int rednessScore = 50; // 홍조 (전반적 붉은기)
  int telangiectasiaScore = 50; // 혈관 확장
  int inflammatoryRednessScore = 50; // 염증성 붉은기

  // 카테고리 3: 모공 (Pore)
  int poreSizeScore = 50; // 모공 크기
  int poreCountScore = 50; // 모공 개수
  int poreSaggingScore = 50; // 모공 늘어짐

  // 카테고리 4: 주름 (Wrinkle & Line)
  int eyeWrinkleScore = 50; // 눈가 주름
  int glabellaWrinkleScore = 50; // 미간 주름
  int nasolabialFoldScore = 50; // 팔자 주름
  int fineDeepWrinkleScore = 50; // 잔주름/깊은 주름

  // 카테고리 5: 피부결·텍스처 (Texture)
  int roughnessScore = 50; // 피부결 거칠기
  int keratinScore = 50; // 각질 들뜸
  int smoothnessScore = 50; // 표면 매끄러움

  // 카테고리 6: 톤 & 밝기 (Tone & Brightness)
  int skinToneScore = 50; // 전체 피부톤
  int dullnessScore = 50; // 칙칙함
  int unevenToneScore = 50; // 얼룩톤

  // 카테고리 7: 탄력 & 처짐 (Elasticity & Sagging)
  int cheekSaggingScore = 50; // 볼 처짐
  int jawlineScore = 50; // 턱선 흐림
  int eyeElasticityScore = 50; // 눈가 탄력

  // 카테고리 8: 유분·수분 (Sebum & Hydration)
  int oilinessScore = 50; // 지성 (유분)
  int drynessScore = 50; // 건성 (수분)
  int sebumDistributionScore = 50; // 피지 분포

  // 카테고리 9: 트러블 & 흔적 (Acne & Marks)
  int acneScore = 50; // 여드름
  int redMarksScore = 50; // 붉은 자국
  int pigmentMarksScore = 50; // 색소 자국

  // 종합 피부 점수 (자동 계산)
  int get overallScore {
    final scores = [
      melasmaScore, lentigoScore, freckleScore, pihScore,
      rednessScore, telangiectasiaScore, inflammatoryRednessScore,
      poreSizeScore, poreCountScore, poreSaggingScore,
      eyeWrinkleScore, glabellaWrinkleScore, nasolabialFoldScore, fineDeepWrinkleScore,
      roughnessScore, keratinScore, smoothnessScore,
      skinToneScore, dullnessScore, unevenToneScore,
      cheekSaggingScore, jawlineScore, eyeElasticityScore,
      oilinessScore, drynessScore, sebumDistributionScore,
      acneScore, redMarksScore, pigmentMarksScore,
    ];
    return (scores.reduce((a, b) => a + b) / scores.length).round();
  }

  // 섹션 4: 현재 사용하는 스킨케어 제품
  Map<String, bool> currentProducts = {
    '클렌저': false,
    '토너': false,
    '에센스·세럼': false,
    '앰플': false,
    '크림': false,
    '선크림': false,
    '미백 제품': false,
    '각질 제거 제품': false,
  };
  String? currentProductsOther;
  String? productBrand;
  String? usageFrequency;

  // 섹션 5: 피부 문제 개선 목표
  Map<String, bool> improvementGoals = {
    '기미/잡티 개선': false,
    '피부톤(미백) 개선': false,
    '탄력 향상': false,
    '주름 개선': false,
    '홍조 완화': false,
    '모공 축소': false,
    '피지 컨트롤': false,
    '보습 강화': false,
  };
  String? improvementGoalsOther;
  String? priorityFirst;
  String? prioritySecond;

  // 섹션 7: 화장품 추천 조건
  Map<String, bool> preferredFormula = {
    '가벼운 제형': false,
    '리치한 제형': false,
    '무향': false,
    '천연·유기농': false,
    '저자극': false,
    '상관없음': false,
  };
  String? priceRange;

  // 섹션 8: AI 리포트 연동
  bool? wantRecommendation;
  bool? wantFollowUpAlert;

  String? savedAt; // 저장 시각 (ISO 8601)

  // AI 분석 추가 정보
  double? perceivedAge; // AI 추정 피부 나이
  bool hasAIAnalysis = false; // AI 사진 분석 완료 여부

  /// AI 측정 결과를 설문 데이터의 29개 점수 필드에 반영
  void applyAIMeasurements(Map<String, double> measurements) {
    hasAIAnalysis = true;
    measurements.forEach((key, value) {
      final intValue = value.round().clamp(0, 100);
      switch (key) {
        case 'melasma_score': melasmaScore = intValue;
        case 'lentigo_score': lentigoScore = intValue;
        case 'freckle_score': freckleScore = intValue;
        case 'pih_score': pihScore = intValue;
        case 'redness_score': rednessScore = intValue;
        case 'telangiectasia_score': telangiectasiaScore = intValue;
        case 'inflammation_redness_score': inflammatoryRednessScore = intValue;
        case 'pore_size_score': poreSizeScore = intValue;
        case 'pore_sagging_score': poreSaggingScore = intValue;
        case 'eye_wrinkle_score': eyeWrinkleScore = intValue;
        case 'glabella_wrinkle_score': glabellaWrinkleScore = intValue;
        case 'nasolabial_wrinkle_score': nasolabialFoldScore = intValue;
        case 'fine_deep_wrinkle_score': fineDeepWrinkleScore = intValue;
        case 'roughness_score': roughnessScore = intValue;
        case 'dead_skin_score': keratinScore = intValue;
        case 'smoothness_score': smoothnessScore = intValue;
        case 'skin_tone_score': skinToneScore = intValue;
        case 'dullness_score': dullnessScore = intValue;
        case 'uneven_tone_score': unevenToneScore = intValue;
        case 'cheek_sagging_score': cheekSaggingScore = intValue;
        case 'jawline_blur_score': jawlineScore = intValue;
        case 'eye_elasticity_score': eyeElasticityScore = intValue;
        case 'oily_score': oilinessScore = intValue;
        case 'dry_score': drynessScore = intValue;
        case 'sebum_score': sebumDistributionScore = intValue;
        case 'acne_score': acneScore = intValue;
        case 'red_mark_score': redMarksScore = intValue;
        case 'pigment_mark_score': pigmentMarksScore = intValue;
      }
    });
  }

  SkinSurveyData();

  factory SkinSurveyData.fromJson(Map<String, dynamic> json) {
    final data = SkinSurveyData();
    data.consentAgreed = json['consentAgreed'] as bool?;
    data.gender = json['gender'] as String?;
    data.ageGroup = json['ageGroup'] as String?;
    data.ethnicity = json['ethnicity'] as String?;
    data.ethnicityOther = json['ethnicityOther'] as String?;
    data.savedAt = json['savedAt'] as String?;

    if (json['skinTypes'] != null) {
      data.skinTypes = Map<String, bool>.from(json['skinTypes']);
    }
    if (json['skinInterests'] != null) {
      data.skinInterests = Map<String, bool>.from(json['skinInterests']);
    }
    if (json['skinConcerns'] != null) {
      data.skinConcerns = Map<String, bool>.from(json['skinConcerns']);
    }
    data.skinConcernsOther = json['skinConcernsOther'] as String?;

    data.allergyHerb = json['allergyHerb'] as bool?;
    data.allergyHerbDetail = json['allergyHerbDetail'] as String?;
    data.allergySunlight = json['allergySunlight'] as bool?;
    data.allergySunlightDetail = json['allergySunlightDetail'] as String?;
    data.allergyCosmetics = json['allergyCosmetics'] as bool?;
    data.allergyCosmeticsBrand = json['allergyCosmeticsBrand'] as String?;

    data.melasmaScore = json['melasmaScore'] as int? ?? 50;
    data.lentigoScore = json['lentigoScore'] as int? ?? 50;
    data.freckleScore = json['freckleScore'] as int? ?? 50;
    data.pihScore = json['pihScore'] as int? ?? 50;
    data.rednessScore = json['rednessScore'] as int? ?? 50;
    data.telangiectasiaScore = json['telangiectasiaScore'] as int? ?? 50;
    data.inflammatoryRednessScore = json['inflammatoryRednessScore'] as int? ?? 50;
    data.poreSizeScore = json['poreSizeScore'] as int? ?? 50;
    data.poreCountScore = json['poreCountScore'] as int? ?? 50;
    data.poreSaggingScore = json['poreSaggingScore'] as int? ?? 50;
    data.eyeWrinkleScore = json['eyeWrinkleScore'] as int? ?? 50;
    data.glabellaWrinkleScore = json['glabellaWrinkleScore'] as int? ?? 50;
    data.nasolabialFoldScore = json['nasolabialFoldScore'] as int? ?? 50;
    data.fineDeepWrinkleScore = json['fineDeepWrinkleScore'] as int? ?? 50;
    data.roughnessScore = json['roughnessScore'] as int? ?? 50;
    data.keratinScore = json['keratinScore'] as int? ?? 50;
    data.smoothnessScore = json['smoothnessScore'] as int? ?? 50;
    data.skinToneScore = json['skinToneScore'] as int? ?? 50;
    data.dullnessScore = json['dullnessScore'] as int? ?? 50;
    data.unevenToneScore = json['unevenToneScore'] as int? ?? 50;
    data.cheekSaggingScore = json['cheekSaggingScore'] as int? ?? 50;
    data.jawlineScore = json['jawlineScore'] as int? ?? 50;
    data.eyeElasticityScore = json['eyeElasticityScore'] as int? ?? 50;
    data.oilinessScore = json['oilinessScore'] as int? ?? 50;
    data.drynessScore = json['drynessScore'] as int? ?? 50;
    data.sebumDistributionScore = json['sebumDistributionScore'] as int? ?? 50;
    data.acneScore = json['acneScore'] as int? ?? 50;
    data.redMarksScore = json['redMarksScore'] as int? ?? 50;
    data.pigmentMarksScore = json['pigmentMarksScore'] as int? ?? 50;

    if (json['currentProducts'] != null) {
      data.currentProducts = Map<String, bool>.from(json['currentProducts']);
    }
    data.currentProductsOther = json['currentProductsOther'] as String?;
    data.productBrand = json['productBrand'] as String?;
    data.usageFrequency = json['usageFrequency'] as String?;

    if (json['improvementGoals'] != null) {
      data.improvementGoals = Map<String, bool>.from(json['improvementGoals']);
    }
    data.improvementGoalsOther = json['improvementGoalsOther'] as String?;
    data.priorityFirst = json['priorityFirst'] as String?;
    data.prioritySecond = json['prioritySecond'] as String?;

    if (json['preferredFormula'] != null) {
      data.preferredFormula = Map<String, bool>.from(json['preferredFormula']);
    }
    data.priceRange = json['priceRange'] as String?;

    data.wantRecommendation = json['wantRecommendation'] as bool?;
    data.wantFollowUpAlert = json['wantFollowUpAlert'] as bool?;

    data.perceivedAge = (json['perceivedAge'] as num?)?.toDouble();
    data.hasAIAnalysis = json['hasAIAnalysis'] as bool? ?? false;

    return data;
  }

  // 점수 등급 반환
  static String getGrade(int score) {
    if (score >= 90) return '매우 우수';
    if (score >= 70) return '양호';
    if (score >= 50) return '보통';
    if (score >= 30) return '개선 필요';
    return '집중 관리';
  }

  // 카테고리별 평균 점수
  int get pigmentationAvg => ((melasmaScore + lentigoScore + freckleScore + pihScore) / 4).round();
  int get rednessAvg => ((rednessScore + telangiectasiaScore + inflammatoryRednessScore) / 3).round();
  int get poreAvg => ((poreSizeScore + poreCountScore + poreSaggingScore) / 3).round();
  int get wrinkleAvg => ((eyeWrinkleScore + glabellaWrinkleScore + nasolabialFoldScore + fineDeepWrinkleScore) / 4).round();
  int get textureAvg => ((roughnessScore + keratinScore + smoothnessScore) / 3).round();
  int get toneAvg => ((skinToneScore + dullnessScore + unevenToneScore) / 3).round();
  int get elasticityAvg => ((cheekSaggingScore + jawlineScore + eyeElasticityScore) / 3).round();
  int get hydrationAvg => ((oilinessScore + drynessScore + sebumDistributionScore) / 3).round();
  int get acneAvg => ((acneScore + redMarksScore + pigmentMarksScore) / 3).round();

  Map<String, dynamic> toJson() {
    return {
      'consentAgreed': consentAgreed,
      'gender': gender,
      'ageGroup': ageGroup,
      'skinTypes': skinTypes,
      'ethnicity': ethnicity,
      'ethnicityOther': ethnicityOther,
      'skinInterests': skinInterests,
      'skinConcerns': skinConcerns,
      'skinConcernsOther': skinConcernsOther,
      'allergyHerb': allergyHerb,
      'allergyHerbDetail': allergyHerbDetail,
      'allergySunlight': allergySunlight,
      'allergySunlightDetail': allergySunlightDetail,
      'allergyCosmetics': allergyCosmetics,
      'allergyCosmeticsBrand': allergyCosmeticsBrand,
      // 색소
      'melasmaScore': melasmaScore,
      'lentigoScore': lentigoScore,
      'freckleScore': freckleScore,
      'pihScore': pihScore,
      // 홍조·혈관
      'rednessScore': rednessScore,
      'telangiectasiaScore': telangiectasiaScore,
      'inflammatoryRednessScore': inflammatoryRednessScore,
      // 모공
      'poreSizeScore': poreSizeScore,
      'poreCountScore': poreCountScore,
      'poreSaggingScore': poreSaggingScore,
      // 주름
      'eyeWrinkleScore': eyeWrinkleScore,
      'glabellaWrinkleScore': glabellaWrinkleScore,
      'nasolabialFoldScore': nasolabialFoldScore,
      'fineDeepWrinkleScore': fineDeepWrinkleScore,
      // 피부결
      'roughnessScore': roughnessScore,
      'keratinScore': keratinScore,
      'smoothnessScore': smoothnessScore,
      // 톤
      'skinToneScore': skinToneScore,
      'dullnessScore': dullnessScore,
      'unevenToneScore': unevenToneScore,
      // 탄력
      'cheekSaggingScore': cheekSaggingScore,
      'jawlineScore': jawlineScore,
      'eyeElasticityScore': eyeElasticityScore,
      // 유수분
      'oilinessScore': oilinessScore,
      'drynessScore': drynessScore,
      'sebumDistributionScore': sebumDistributionScore,
      // 트러블
      'acneScore': acneScore,
      'redMarksScore': redMarksScore,
      'pigmentMarksScore': pigmentMarksScore,
      // 종합
      'overallScore': overallScore,
      // 기타
      'currentProducts': currentProducts,
      'currentProductsOther': currentProductsOther,
      'productBrand': productBrand,
      'usageFrequency': usageFrequency,
      'improvementGoals': improvementGoals,
      'improvementGoalsOther': improvementGoalsOther,
      'priorityFirst': priorityFirst,
      'prioritySecond': prioritySecond,
      'preferredFormula': preferredFormula,
      'priceRange': priceRange,
      'wantRecommendation': wantRecommendation,
      'wantFollowUpAlert': wantFollowUpAlert,
      'savedAt': savedAt,
      'perceivedAge': perceivedAge,
      'hasAIAnalysis': hasAIAnalysis,
    };
  }
}

// 측정 항목 정의
class SkinMeasurementItem {
  final int number;
  final String category;
  final String name;
  final String aiIndicator;
  final Map<String, String> scoreDescriptions;

  const SkinMeasurementItem({
    required this.number,
    required this.category,
    required this.name,
    required this.aiIndicator,
    required this.scoreDescriptions,
  });
}

// 29개 측정 항목 상세 정의
const List<SkinMeasurementItem> skinMeasurementItems = [
  // 색소 (Pigmentation)
  SkinMeasurementItem(
    number: 1,
    category: '색소 (Pigmentation)',
    name: '기미 (Melasma)',
    aiIndicator: '색소 면적(%), 색소 농도, 명도 대비',
    scoreDescriptions: {
      '90-100': '색소 침착 없음, 균일한 톤',
      '70-89': '미세한 기미, 화장으로 커버 가능',
      '50-69': '눈에 띄는 기미, 관리 필요',
      '30-49': '넓은 면적의 진한 기미',
      '0-29': '심각한 색소 침착, 전문 치료 권장',
    },
  ),
  SkinMeasurementItem(
    number: 2,
    category: '색소 (Pigmentation)',
    name: '잡티/검버섯 (Lentigo)',
    aiIndicator: '멜라닌 지수, 경계 선명도',
    scoreDescriptions: {
      '90-100': '잡티 없음, 깨끗한 피부',
      '70-89': '작은 잡티 몇 개',
      '50-69': '여러 개의 잡티 관찰',
      '30-49': '다수의 잡티, 검버섯',
      '0-29': '광범위한 색소 병변',
    },
  ),
  SkinMeasurementItem(
    number: 3,
    category: '색소 (Pigmentation)',
    name: '주근깨 (Freckle)',
    aiIndicator: '색소 개수, 분포 패턴',
    scoreDescriptions: {
      '90-100': '주근깨 없음',
      '70-89': '소수의 연한 주근깨',
      '50-69': '중간 정도의 주근깨',
      '30-49': '다수의 진한 주근깨',
      '0-29': '밀집된 주근깨, 전체적 분포',
    },
  ),
  SkinMeasurementItem(
    number: 4,
    category: '색소 (Pigmentation)',
    name: '색소침착 (PIH)',
    aiIndicator: '염증후 색소침착 점수',
    scoreDescriptions: {
      '90-100': '염증 후 색소 없음',
      '70-89': '약한 색소 자국',
      '50-69': '중간 정도의 색소 자국',
      '30-49': '진한 색소 자국 다수',
      '0-29': '심한 색소 침착, 치료 필요',
    },
  ),
  // 홍조·혈관 (Redness & Vascular)
  SkinMeasurementItem(
    number: 5,
    category: '홍조·혈관 (Redness & Vascular)',
    name: '홍조 (전반적 붉은기)',
    aiIndicator: '적색 지수, 홍조 면적 비율(%)',
    scoreDescriptions: {
      '90-100': '붉은기 없음, 균일한 톤',
      '70-89': '약간의 붉은기',
      '50-69': '뺨과 코 부위 홍조',
      '30-49': '넓은 범위 홍조',
      '0-29': '심한 홍조, 민감성 피부',
    },
  ),
  SkinMeasurementItem(
    number: 6,
    category: '홍조·혈관 (Redness & Vascular)',
    name: '혈관 확장 (Telangiectasia)',
    aiIndicator: '혈관 노출 정도, 혈관 면적 비율(%), 선명도',
    scoreDescriptions: {
      '90-100': '혈관 노출 없음, 고른 피부톤',
      '70-89': '미세한 실핏줄 일부 관찰',
      '50-69': '눈에 띄는 혈관 확장, 관리 필요',
      '30-49': '넓은 범위의 혈관 확장',
      '0-29': '심각한 혈관 확장, 전문 치료 권장',
    },
  ),
  SkinMeasurementItem(
    number: 7,
    category: '홍조·혈관 (Redness & Vascular)',
    name: '염증성 붉은기',
    aiIndicator: '염증 점수, 색상 균일도',
    scoreDescriptions: {
      '90-100': '염증 없음',
      '70-89': '일시적 붉어짐',
      '50-69': '자극 시 붉어짐',
      '30-49': '지속적 염증성 붉은기',
      '0-29': '심한 염증, 전문 치료 필요',
    },
  ),
  // 모공 (Pore)
  SkinMeasurementItem(
    number: 8,
    category: '모공 (Pore)',
    name: '모공 크기',
    aiIndicator: '평균 모공 직경 (μm)',
    scoreDescriptions: {
      '90-100': '모공 거의 보이지 않음',
      '70-89': '작고 조밀한 모공',
      '50-69': '눈에 띄는 모공',
      '30-49': '확장된 모공',
      '0-29': '매우 넓은 모공, 집중 관리 필요',
    },
  ),
  SkinMeasurementItem(
    number: 9,
    category: '모공 (Pore)',
    name: '모공 개수',
    aiIndicator: '단위 면적당 모공 수',
    scoreDescriptions: {
      '90-100': '모공 밀도 낮음',
      '70-89': '정상 모공 밀도',
      '50-69': '약간 많은 모공',
      '30-49': '높은 모공 밀도',
      '0-29': '매우 높은 모공 밀도',
    },
  ),
  SkinMeasurementItem(
    number: 10,
    category: '모공 (Pore)',
    name: '모공 늘어짐',
    aiIndicator: '모공 형태 불규칙성, 모공 밀도',
    scoreDescriptions: {
      '90-100': '원형의 모공',
      '70-89': '약간의 타원형',
      '50-69': '늘어진 모공 관찰',
      '30-49': '심하게 늘어진 모공',
      '0-29': '노화로 인한 심각한 모공 변형',
    },
  ),
  // 주름 (Wrinkle & Line)
  SkinMeasurementItem(
    number: 11,
    category: '주름 (Wrinkle & Line)',
    name: '눈가 주름',
    aiIndicator: '주름 길이, 깊이(추정)',
    scoreDescriptions: {
      '90-100': '주름 없음, 매끄러운 눈가',
      '70-89': '미세한 잔주름',
      '50-69': '눈에 띄는 주름',
      '30-49': '깊은 주름',
      '0-29': '심각한 주름, 처짐',
    },
  ),
  SkinMeasurementItem(
    number: 12,
    category: '주름 (Wrinkle & Line)',
    name: '미간 주름',
    aiIndicator: '주름 깊이, 명암 대비',
    scoreDescriptions: {
      '90-100': '미간 주름 없음',
      '70-89': '표정 시에만 주름',
      '50-69': '약한 미간 주름',
      '30-49': '깊은 미간 주름',
      '0-29': '매우 깊은 세로 주름',
    },
  ),
  SkinMeasurementItem(
    number: 13,
    category: '주름 (Wrinkle & Line)',
    name: '팔자 주름',
    aiIndicator: '주름 길이, 심각도',
    scoreDescriptions: {
      '90-100': '팔자 주름 없음',
      '70-89': '미세한 선',
      '50-69': '중간 정도 팔자 주름',
      '30-49': '깊은 팔자 주름',
      '0-29': '매우 깊고 긴 팔자 주름',
    },
  ),
  SkinMeasurementItem(
    number: 14,
    category: '주름 (Wrinkle & Line)',
    name: '잔주름/깊은 주름',
    aiIndicator: '주름 개수, 분류',
    scoreDescriptions: {
      '90-100': '전반적으로 주름 없음',
      '70-89': '소수의 잔주름',
      '50-69': '여러 부위에 잔주름',
      '30-49': '잔주름과 깊은 주름 혼재',
      '0-29': '전체적으로 심한 주름',
    },
  ),
  // 피부결·텍스처 (Texture)
  SkinMeasurementItem(
    number: 15,
    category: '피부결·텍스처 (Texture)',
    name: '피부결 거칠기',
    aiIndicator: '거칠기 지수 (고주파 노이즈)',
    scoreDescriptions: {
      '90-100': '매끈하고 부드러운 피부결',
      '70-89': '대체로 고운 피부결',
      '50-69': '약간 거친 피부결',
      '30-49': '거칠고 울퉁불퉁한 피부결',
      '0-29': '매우 거친 피부, 관리 필요',
    },
  ),
  SkinMeasurementItem(
    number: 16,
    category: '피부결·텍스처 (Texture)',
    name: '각질 들뜸',
    aiIndicator: '각질 검출, 표면 불규칙성',
    scoreDescriptions: {
      '90-100': '각질 없음',
      '70-89': '미세한 각질',
      '50-69': '눈에 띄는 각질',
      '30-49': '심한 각질 들뜸',
      '0-29': '광범위한 각질, 즉시 관리 필요',
    },
  ),
  SkinMeasurementItem(
    number: 17,
    category: '피부결·텍스처 (Texture)',
    name: '표면 매끄러움',
    aiIndicator: '매끄러움 점수, 결 균일도',
    scoreDescriptions: {
      '90-100': '매우 매끄럽고 균일',
      '70-89': '대체로 매끄러움',
      '50-69': '약간의 불균일',
      '30-49': '울퉁불퉁한 표면',
      '0-29': '매우 불규칙한 표면',
    },
  ),
  // 톤 & 밝기 (Tone & Brightness)
  SkinMeasurementItem(
    number: 18,
    category: '톤 & 밝기 (Tone & Brightness)',
    name: '전체 피부톤',
    aiIndicator: '명도값 (CIELAB L*)',
    scoreDescriptions: {
      '90-100': '맑고 밝은 피부톤',
      '70-89': '자연스러운 밝기',
      '50-69': '약간 어두운 톤',
      '30-49': '칙칙하고 어두운 톤',
      '0-29': '매우 어둡고 생기 없음',
    },
  ),
  SkinMeasurementItem(
    number: 19,
    category: '톤 & 밝기 (Tone & Brightness)',
    name: '칙칙함',
    aiIndicator: '칙칙함 점수, 광채 지수',
    scoreDescriptions: {
      '90-100': '투명하고 화사함',
      '70-89': '건강한 광채',
      '50-69': '약간 칙칙함',
      '30-49': '칙칙하고 탁함',
      '0-29': '매우 칙칙하고 생기 없음',
    },
  ),
  SkinMeasurementItem(
    number: 20,
    category: '톤 & 밝기 (Tone & Brightness)',
    name: '얼룩톤',
    aiIndicator: '톤 편차 (불균형도)',
    scoreDescriptions: {
      '90-100': '매우 균일한 톤',
      '70-89': '대체로 균일',
      '50-69': '부분적 톤 차이',
      '30-49': '눈에 띄는 얼룩톤',
      '0-29': '심한 톤 불균형',
    },
  ),
  // 탄력 & 처짐 (Elasticity & Sagging)
  SkinMeasurementItem(
    number: 21,
    category: '탄력 & 처짐 (Elasticity & Sagging)',
    name: '볼 처짐',
    aiIndicator: '중력 변형 점수',
    scoreDescriptions: {
      '90-100': '탄력 있고 처짐 없음',
      '70-89': '약간의 처짐',
      '50-69': '눈에 띄는 처짐',
      '30-49': '뚜렷한 볼 처짐',
      '0-29': '심각한 처짐, 리프팅 필요',
    },
  ),
  SkinMeasurementItem(
    number: 22,
    category: '탄력 & 처짐 (Elasticity & Sagging)',
    name: '턱선 흐림',
    aiIndicator: '윤곽 선명도',
    scoreDescriptions: {
      '90-100': '또렷한 턱선',
      '70-89': '대체로 선명한 턱선',
      '50-69': '약간 흐려진 턱선',
      '30-49': '흐릿한 턱선, 이중턱',
      '0-29': '턱선 소실, 심한 처짐',
    },
  ),
  SkinMeasurementItem(
    number: 23,
    category: '탄력 & 처짐 (Elasticity & Sagging)',
    name: '눈가 탄력',
    aiIndicator: '탄력 추정 (주름·모공 연계)',
    scoreDescriptions: {
      '90-100': '탄력 있는 눈가',
      '70-89': '양호한 탄력',
      '50-69': '약간의 탄력 저하',
      '30-49': '눈에 띄는 탄력 저하',
      '0-29': '심한 탄력 저하, 처짐',
    },
  ),
  // 유분·수분 (Sebum & Hydration)
  SkinMeasurementItem(
    number: 24,
    category: '유분·수분 (Sebum & Hydration)',
    name: '지성 (유분)',
    aiIndicator: '광택 지수 (반사광 강도), 유분 분포',
    scoreDescriptions: {
      '90-100': '적정 유분, 건강한 광택',
      '70-89': '약간 많은 유분',
      '50-69': '번들거림 있음',
      '30-49': '과도한 유분, T존 번들거림',
      '0-29': '심한 지성, 전체적 번들거림',
    },
  ),
  SkinMeasurementItem(
    number: 25,
    category: '유분·수분 (Sebum & Hydration)',
    name: '건성 (수분)',
    aiIndicator: '건조 부위 검출, 수분 점수',
    scoreDescriptions: {
      '90-100': '충분한 수분, 촉촉함',
      '70-89': '적정 수분',
      '50-69': '약간 건조',
      '30-49': '건조하고 당김 현상',
      '0-29': '매우 건조, 각질 심함',
    },
  ),
  SkinMeasurementItem(
    number: 26,
    category: '유분·수분 (Sebum & Hydration)',
    name: '피지 분포',
    aiIndicator: '피지 분포 패턴',
    scoreDescriptions: {
      '90-100': '균일한 유분 분포',
      '70-89': '대체로 균일',
      '50-69': 'T존 집중 유분',
      '30-49': '불균일한 유분 분포',
      '0-29': '심한 불균형, 복합성',
    },
  ),
  // 트러블 & 흔적 (Acne & Marks)
  SkinMeasurementItem(
    number: 27,
    category: '트러블 & 흔적 (Acne & Marks)',
    name: '여드름',
    aiIndicator: '병변 개수, 심각도',
    scoreDescriptions: {
      '90-100': '여드름 없음',
      '70-89': '1-2개의 작은 여드름',
      '50-69': '여러 개의 여드름',
      '30-49': '다수의 염증성 여드름',
      '0-29': '심한 여드름, 전문 치료 필요',
    },
  ),
  SkinMeasurementItem(
    number: 28,
    category: '트러블 & 흔적 (Acne & Marks)',
    name: '붉은 자국',
    aiIndicator: '염증 점수, 붉은 자국 면적',
    scoreDescriptions: {
      '90-100': '붉은 자국 없음',
      '70-89': '약한 자국 1-2개',
      '50-69': '여러 개의 붉은 자국',
      '30-49': '다수의 진한 붉은 자국',
      '0-29': '광범위한 붉은 자국',
    },
  ),
  SkinMeasurementItem(
    number: 29,
    category: '트러블 & 흔적 (Acne & Marks)',
    name: '색소 자국',
    aiIndicator: '여드름 후 색소, 흉터 깊이',
    scoreDescriptions: {
      '90-100': '자국 없음',
      '70-89': '연한 색소 자국',
      '50-69': '여러 개의 색소 자국',
      '30-49': '진한 색소와 얕은 흉터',
      '0-29': '심한 색소 침착과 깊은 흉터',
    },
  ),
];
