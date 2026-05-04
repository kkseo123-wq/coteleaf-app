import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/skin_analysis_result.dart';

class SkinAnalysisService {
  static const String _baseUrl = 'https://skin.ai.coteleaf.com';
  static const Duration _pollInterval = Duration(seconds: 3);
  static const Duration _timeout = Duration(minutes: 5);

  // ★ 테스트용 Mock 모드 - 스크린샷 촬영 후 false로 되돌리기
  static const bool useMock = false;

  void _log(String message) {
    debugPrint('[SkinAnalysis] $message');
  }

  /// 서버 헬스 체크
  Future<bool> healthCheck() async {
    final url = Uri.parse('$_baseUrl/health');
    _log('>>> GET $url');

    try {
      final response = await http.get(url);
      _log('<<< ${response.statusCode} body: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      _log('<<< ERROR: $e');
      return false;
    }
  }

  /// Job 생성 - 이미지 파일을 업로드하여 분석 시작
  /// POST /v1/analysis/jobs (multipart/form-data)
  Future<String> createJobWithFile(
    File imageFile, {
    String mode = 'cv_only',
    String? customerId,
  }) async {
    final uri = Uri.parse('$_baseUrl/v1/analysis/jobs');
    final request = http.MultipartRequest('POST', uri);

    request.fields['mode'] = mode;
    if (customerId != null) {
      request.fields['customer_id'] = customerId;
    }

    request.files.add(
      await http.MultipartFile.fromPath('image', imageFile.path),
    );

    _log('>>> POST $uri');
    _log('>>> fields: ${request.fields}');
    _log('>>> image: ${imageFile.path} (${await imageFile.length()} bytes)');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    _log('<<< ${response.statusCode} ${response.reasonPhrase}');
    _log('<<< body: ${response.body}');

    if (response.statusCode == 202) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      // response 구조가 {"additionalProp1": {}} 형태이므로 첫 번째 키에서 job_id 추출 시도
      final jobId = _extractJobId(data);
      _log('=== Job 생성 완료: $jobId');
      return jobId;
    } else {
      throw SkinAnalysisException(
        'Job 생성 실패: ${response.statusCode}',
        response.body,
      );
    }
  }

  /// 202 응답에서 job_id 추출
  String _extractJobId(Map<String, dynamic> data) {
    // 직접 job_id 키가 있는 경우
    if (data.containsKey('job_id')) {
      return data['job_id'].toString();
    }
    // 중첩 구조에서 job_id 찾기
    for (final value in data.values) {
      if (value is Map<String, dynamic> && value.containsKey('job_id')) {
        return value['job_id'].toString();
      }
    }
    // 첫 번째 키를 job_id로 사용 (서버 응답에 따라)
    _log('!!! job_id를 찾을 수 없음. 전체 응답: $data');
    throw SkinAnalysisException(
      'job_id를 찾을 수 없습니다',
      data.toString(),
    );
  }

  /// Job 상태/정보 조회
  /// GET /v1/analysis/jobs/{job_id}
  Future<Map<String, dynamic>> getJobStatus(String jobId) async {
    final url = Uri.parse('$_baseUrl/v1/analysis/jobs/$jobId');
    _log('>>> GET $url');

    final response = await http.get(url);

    _log('<<< ${response.statusCode} body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw SkinAnalysisException(
        '상태 조회 실패: ${response.statusCode}',
        response.body,
      );
    }
  }

  /// Job 결과 조회
  /// GET /v1/analysis/jobs/{job_id}/result
  Future<SkinAnalysisResult> getJobResult(String jobId) async {
    final url = Uri.parse('$_baseUrl/v1/analysis/jobs/$jobId/result');
    _log('>>> GET $url');

    final response = await http.get(url);

    _log('<<< ${response.statusCode} body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _log('=== 결과 수신 완료: keys=${data.keys.toList()}');
      return SkinAnalysisResult.fromJson(data);
    } else {
      throw SkinAnalysisException(
        '결과 조회 실패: ${response.statusCode}',
        response.body,
      );
    }
  }

  /// Artifact 다운로드
  /// GET /v1/analysis/jobs/{job_id}/artifacts/{name}
  Future<String> getArtifact(String jobId, String name) async {
    final url = Uri.parse('$_baseUrl/v1/analysis/jobs/$jobId/artifacts/$name');
    _log('>>> GET $url');

    final response = await http.get(url);

    _log('<<< ${response.statusCode} body length: ${response.body.length}');

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw SkinAnalysisException(
        'Artifact 다운로드 실패: ${response.statusCode}',
        response.body,
      );
    }
  }

  /// Mock 데이터 생성
  SkinAnalysisResult _generateMockResult() {
    // jsonDecode(jsonEncode(...))로 감싸서 Map<String, dynamic> 타입 보장
    final mockJson = jsonDecode(jsonEncode({
      'job_id': 'mock-${DateTime.now().millisecondsSinceEpoch}',
      'status': 'succeeded',
      'mode': 'cv_only',
      'timestamp': DateTime.now().toIso8601String(),
      'artifacts': {},
      'cv_results': {
        'overall_score': 72.5,
        'perceived_age': 28.0,
        'measurements': {
          // 색소
          'melasma_score': 68.0,
          'lentigo_score': 75.0,
          'freckle_score': 82.0,
          'pih_score': 70.0,
          // 홍조
          'redness_score': 65.0,
          'telangiectasia_score': 78.0,
          'inflammation_redness_score': 80.0,
          // 모공
          'pore_size_score': 60.0,
          'pore_sagging_score': 72.0,
          // 주름
          'eye_wrinkle_score': 74.0,
          'glabella_wrinkle_score': 85.0,
          'nasolabial_wrinkle_score': 70.0,
          'fine_deep_wrinkle_score': 76.0,
          // 피부결
          'roughness_score': 66.0,
          'dead_skin_score': 78.0,
          'smoothness_score': 71.0,
          // 톤
          'skin_tone_score': 73.0,
          'dullness_score': 64.0,
          'uneven_tone_score': 69.0,
          // 탄력
          'cheek_sagging_score': 77.0,
          'jawline_blur_score': 80.0,
          'eye_elasticity_score': 68.0,
          // 유수분
          'oily_score': 55.0,
          'dry_score': 62.0,
          'sebum_score': 58.0,
          // 트러블
          'acne_score': 83.0,
          'red_mark_score': 71.0,
          'pigment_mark_score': 74.0,
        },
        'clinical_opinions': [
          {
            'measurement_key': 'pore_size_score',
            'category': '모공',
            'measurement': '모공 크기',
            'score': 60.0,
            'level': 'moderate',
            'finding': '모공이 다소 넓어진 상태입니다. T존 부위에 모공이 두드러집니다.',
            'action': '모공 수축 효과가 있는 토너와 세럼 사용을 권장합니다.',
            'priority': 1,
          },
          {
            'measurement_key': 'dullness_score',
            'category': '톤 & 밝기',
            'measurement': '칙칙함',
            'score': 64.0,
            'level': 'moderate',
            'finding': '피부 전체적으로 칙칙한 톤이 관찰됩니다.',
            'action': '비타민C 세럼과 각질 관리로 피부 톤을 개선할 수 있습니다.',
            'priority': 2,
          },
          {
            'measurement_key': 'redness_score',
            'category': '홍조',
            'measurement': '홍조',
            'score': 65.0,
            'level': 'mild',
            'finding': '볼 주위로 가벼운 홍조가 있습니다.',
            'action': '자극이 적은 진정 케어 제품을 사용해 주세요.',
            'priority': 3,
          },
        ],
        'detailed_prescriptions': [
          {
            'opinion': {
              'measurement_key': 'pore_size_score',
              'category': '모공',
              'measurement': '모공 크기',
              'score': 60.0,
              'level': 'moderate',
              'finding': '모공이 다소 넓어진 상태입니다.',
              'action': '모공 수축 효과가 있는 토너와 세럼 사용을 권장합니다.',
              'priority': 1,
            },
            'prescription': {
              'measurement_key': 'pore_size_score',
              'category': '모공',
              'measurement_name': '모공 크기',
              'level': 'moderate',
              'causes': ['과도한 피지 분비', '노화로 인한 탄력 저하', '자외선 노출'],
              'ingredients': ['나이아신아마이드', 'BHA(살리실산)', '레티놀'],
              'product_types': ['모공 토너', '세럼', '클레이 마스크'],
              'usage': '아침저녁 토너 후 세럼 도포, 주 1-2회 클레이 마스크',
              'duration': '4-6주',
              'lifestyle': ['세안 후 찬물로 마무리', '유분기 많은 음식 줄이기'],
              'cautions': ['과도한 각질 제거 주의', '레티놀은 밤에만 사용'],
              'need_consultation': false,
            },
          },
          {
            'opinion': {
              'measurement_key': 'dullness_score',
              'category': '톤 & 밝기',
              'measurement': '칙칙함',
              'score': 64.0,
              'level': 'moderate',
              'finding': '피부 전체적으로 칙칙한 톤이 관찰됩니다.',
              'action': '비타민C 세럼과 각질 관리로 피부 톤을 개선할 수 있습니다.',
              'priority': 2,
            },
            'prescription': {
              'measurement_key': 'dullness_score',
              'category': '톤 & 밝기',
              'measurement_name': '칙칙함',
              'level': 'moderate',
              'causes': ['각질 축적', '수분 부족', '혈액 순환 저하'],
              'ingredients': ['비타민C', 'AHA(글리콜산)', '알부틴'],
              'product_types': ['브라이트닝 세럼', '필링 패드', '수분 크림'],
              'usage': '아침 비타민C 세럼, 저녁 AHA 필링, 매일 수분 크림',
              'duration': '3-4주',
              'lifestyle': ['충분한 수분 섭취', '자외선 차단제 필수'],
              'cautions': ['AHA와 비타민C 동시 사용 주의'],
              'need_consultation': false,
            },
          },
        ],
      },
    })) as Map<String, dynamic>;
    return SkinAnalysisResult.fromJson(mockJson);
  }

  /// 단일 이미지 분석 전체 플로우 (생성 → 폴링 → 결과)
  Future<SkinAnalysisResult> analyzeImage(
    File imageFile, {
    String mode = 'cv_only',
    String? customerId,
    void Function(String status)? onStatusChanged,
  }) async {
    // ★ Mock 모드
    if (useMock) {
      _log('★ Mock 모드 활성화 - API 호출 건너뜀');
      onStatusChanged?.call('uploading');
      await Future.delayed(const Duration(milliseconds: 800));
      onStatusChanged?.call('processing');
      await Future.delayed(const Duration(seconds: 2));
      onStatusChanged?.call('fetching_result');
      await Future.delayed(const Duration(milliseconds: 500));
      onStatusChanged?.call('succeeded');
      return _generateMockResult();
    }

    // 1. Job 생성
    onStatusChanged?.call('uploading');
    final jobId = await createJobWithFile(
      imageFile,
      mode: mode,
      customerId: customerId,
    );

    // 2. 폴링으로 완료 대기
    onStatusChanged?.call('processing');
    final startTime = DateTime.now();
    Map<String, dynamic> lastStatusData = {};

    while (true) {
      final elapsed = DateTime.now().difference(startTime);
      if (elapsed > _timeout) {
        throw SkinAnalysisException('분석 시간 초과', 'Job $jobId timed out');
      }

      lastStatusData = await getJobStatus(jobId);
      final status = lastStatusData['status'] as String? ?? '';

      _log('=== Job $jobId 상태: $status');
      onStatusChanged?.call(status);

      if (status == 'completed' || status == 'done' || status == 'succeeded') {
        break;
      } else if (status == 'failed' || status == 'error') {
        final errorMsg = lastStatusData['error'] ?? '알 수 없는 오류';
        throw SkinAnalysisException('분석 실패', errorMsg.toString());
      }

      await Future.delayed(_pollInterval);
    }

    // 3. 결과 조회 - artifacts에서 results.json 다운로드
    onStatusChanged?.call('fetching_result');

    // artifacts에 results.json 경로가 있으면 그것으로 조회
    final artifacts = lastStatusData['artifacts'] as Map<String, dynamic>?;
    if (artifacts != null && artifacts.containsKey('results.json')) {
      _log('=== artifacts/results.json 에서 결과 조회');
      final resultsJsonStr = await getArtifact(jobId, 'results.json');
      final resultsData = jsonDecode(resultsJsonStr) as Map<String, dynamic>;
      _log('=== results.json keys: ${resultsData.keys.toList()}');
      return SkinAnalysisResult.fromJson({
        ...resultsData,
        'job_id': jobId,
        'status': 'succeeded',
        'mode': lastStatusData['mode'] ?? 'cv_only',
        'artifacts': artifacts,
      });
    }

    // fallback: /result 엔드포인트 시도
    return await getJobResult(jobId);
  }

  /// 3장 병렬 분석 후 점수 평균 계산
  Future<AggregatedSkinResult> analyzeMultipleImages(
    List<File> imageFiles,
    List<String> angleLabels, {
    String mode = 'cv_only',
    String? customerId,
    void Function(int index, String status)? onImageStatusChanged,
    void Function(int completedCount, int totalCount)? onProgressChanged,
  }) async {
    _log('=== ${imageFiles.length}장 병렬 분석 시작 (mode: $mode)');
    int completedCount = 0;

    final futures = imageFiles.asMap().entries.map((entry) {
      final index = entry.key;
      final file = entry.value;
      final label = index < angleLabels.length ? angleLabels[index] : 'image_$index';
      _log('=== [$label] 분석 시작: ${file.path}');

      return analyzeImage(
        file,
        mode: mode,
        customerId: customerId,
        onStatusChanged: (status) {
          onImageStatusChanged?.call(index, status);
        },
      ).then((result) {
        completedCount++;
        _log('=== [$label] 분석 완료 ($completedCount/${imageFiles.length})');
        onProgressChanged?.call(completedCount, imageFiles.length);
        return result;
      });
    });

    final results = await Future.wait(futures);

    final aggregated = AggregatedSkinResult.fromResults(results, angleLabels);
    _log('=== 전체 분석 완료. 종합 점수: ${aggregated.overallScore.toStringAsFixed(1)}');
    return aggregated;
  }
}

class SkinAnalysisException implements Exception {
  final String message;
  final String details;

  SkinAnalysisException(this.message, this.details);

  @override
  String toString() => 'SkinAnalysisException: $message ($details)';
}
