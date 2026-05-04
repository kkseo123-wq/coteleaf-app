import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../theme/app_theme.dart';
import '../models/skin_analysis_result.dart';
import '../models/skin_survey_data.dart';
import '../widgets/radar_chart.dart';
import '../widgets/gradient_scaffold.dart';
import '../services/survey_storage_service.dart';
import '../services/pdf_report_service.dart';
import 'prescription_screen.dart';
import 'survey_detail_screen.dart';

class UnifiedResultScreen extends StatefulWidget {
  final SkinSurveyData surveyData;
  final AggregatedSkinResult aiResult;

  const UnifiedResultScreen({
    super.key,
    required this.surveyData,
    required this.aiResult,
  });

  @override
  State<UnifiedResultScreen> createState() => _UnifiedResultScreenState();
}

class _UnifiedResultScreenState extends State<UnifiedResultScreen> {
  bool _isSaved = false;

  static const Map<String, List<String>> _categories = {
    '색소': ['melasma_score', 'lentigo_score', 'freckle_score', 'pih_score'],
    '홍조': [
      'redness_score',
      'telangiectasia_score',
      'inflammation_redness_score'
    ],
    '모공': ['pore_size_score', 'pore_sagging_score'],
    '주름': [
      'eye_wrinkle_score',
      'glabella_wrinkle_score',
      'nasolabial_wrinkle_score',
      'fine_deep_wrinkle_score'
    ],
    '피부결': ['roughness_score', 'dead_skin_score', 'smoothness_score'],
    '톤 & 밝기': ['skin_tone_score', 'dullness_score', 'uneven_tone_score'],
    '탄력': [
      'cheek_sagging_score',
      'jawline_blur_score',
      'eye_elasticity_score'
    ],
    '유수분': ['oily_score', 'dry_score', 'sebum_score'],
    '트러블': ['acne_score', 'red_mark_score', 'pigment_mark_score'],
  };

  static const Map<String, String> _measurementLabels = {
    'melasma_score': '기미',
    'lentigo_score': '잡티/검버섯',
    'freckle_score': '주근깨',
    'pih_score': '색소침착',
    'redness_score': '홍조',
    'telangiectasia_score': '혈관 확장',
    'inflammation_redness_score': '염증성 붉은기',
    'pore_size_score': '모공 크기',
    'pore_sagging_score': '모공 늘어짐',
    'eye_wrinkle_score': '눈가 주름',
    'glabella_wrinkle_score': '미간 주름',
    'nasolabial_wrinkle_score': '팔자 주름',
    'fine_deep_wrinkle_score': '잔주름/깊은 주름',
    'roughness_score': '피부결 거칠기',
    'dead_skin_score': '각질 들뜸',
    'smoothness_score': '표면 매끄러움',
    'skin_tone_score': '전체 피부톤',
    'dullness_score': '칙칙함',
    'uneven_tone_score': '얼룩톤',
    'cheek_sagging_score': '볼 처짐',
    'jawline_blur_score': '턱선 흐림',
    'eye_elasticity_score': '눈가 탄력',
    'oily_score': '지성(유분)',
    'dry_score': '건성(수분)',
    'sebum_score': '피지',
    'acne_score': '여드름',
    'red_mark_score': '붉은 자국',
    'pigment_mark_score': '색소 자국',
  };

  Color _gradeColor(int score) {
    if (score >= 90) return AppColors.gradeExcellent;
    if (score >= 70) return AppColors.gradeGood;
    if (score >= 50) return AppColors.gradeNormal;
    if (score >= 30) return AppColors.gradeCaution;
    return AppColors.gradeBad;
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('피부 분석 결과', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 16),
              _buildOverallScoreCard(),
              const SizedBox(height: 16),
              _buildRadarChartCard(),
              const SizedBox(height: 16),
              _buildCategoryScoresCard(),
              if (widget.aiResult.mergedOpinions.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildClinicalOpinionsCard(),
              ],
              if (widget.aiResult.mergedPrescriptions.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildPrescriptionsCard(),
              ],
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 1. Header Card
  // ──────────────────────────────────────────────
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.check_circle_outline, size: 64, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text(
            '분석 완료',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.aiResult.individualResults.length}개 각도 분석 결과',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
            ),
          ),
          if (widget.aiResult.perceivedAge > 0) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                '피부 나이: ${widget.aiResult.perceivedAge.toStringAsFixed(1)}세',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 2. Overall Score Card
  // ──────────────────────────────────────────────
  Widget _buildOverallScoreCard() {
    final score = widget.surveyData.overallScore;
    final grade = SkinSurveyData.getGrade(score);
    final color = _gradeColor(score);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Column(
        children: [
          const Text(
            '종합 피부 점수',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              grade,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 3. Radar Chart Card
  // ──────────────────────────────────────────────
  Widget _buildRadarChartCard() {
    final chartData = [
      RadarChartData(
          label: '색소', value: widget.surveyData.pigmentationAvg.toDouble()),
      RadarChartData(
          label: '홍조\u00B7혈관',
          value: widget.surveyData.rednessAvg.toDouble()),
      RadarChartData(
          label: '모공', value: widget.surveyData.poreAvg.toDouble()),
      RadarChartData(
          label: '주름', value: widget.surveyData.wrinkleAvg.toDouble()),
      RadarChartData(
          label: '피부결', value: widget.surveyData.textureAvg.toDouble()),
      RadarChartData(
          label: '톤&밝기', value: widget.surveyData.toneAvg.toDouble()),
      RadarChartData(
          label: '탄력', value: widget.surveyData.elasticityAvg.toDouble()),
      RadarChartData(
          label: '유수분', value: widget.surveyData.hydrationAvg.toDouble()),
      RadarChartData(
          label: '트러블', value: widget.surveyData.acneAvg.toDouble()),
    ];

    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.radar, color: AppColors.primary, size: 22),
                SizedBox(width: 12),
                Text(
                  '피부 상태 종합 분석',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: RadarChart(data: chartData, size: 300),
            ),
            const SizedBox(height: 24),
            const Text(
              '점수가 높을수록 해당 항목의 상태가 양호합니다',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 4. Category Scores Card
  // ──────────────────────────────────────────────
  Widget _buildCategoryScoresCard() {
    final measurements = widget.aiResult.averageMeasurements;

    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.analytics_outlined, color: AppColors.primary, size: 22),
                SizedBox(width: 12),
                Text(
                  '항목별 점수',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ..._categories.entries.map((category) {
              final keys = category.value;
              final hasAny =
                  keys.any((key) => measurements.containsKey(key));
              if (!hasAny) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 12),
                    child: Text(
                      category.key,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  ...keys.where((key) => measurements.containsKey(key)).map(
                    (key) {
                      final score = measurements[key]!;
                      final label =
                          _measurementLabels[key] ?? key;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 90,
                              child: Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w300,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (score / 100).clamp(0.0, 1.0),
                                  backgroundColor:
                                      AppColors.textLight.withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      _gradeColor(score.round())),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 42,
                              child: Text(
                                score.round().toString(),
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: _gradeColor(score.round()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 5. Clinical Opinions Card
  // ──────────────────────────────────────────────
  Widget _buildClinicalOpinionsCard() {
    final opinions = widget.aiResult.mergedOpinions;

    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.medical_services_outlined, color: AppColors.primary, size: 22),
                SizedBox(width: 12),
                Text(
                  'AI 소견',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...opinions.map((opinion) {
              final isWarning = opinion.score < 70;
              final circleColor =
                  isWarning ? AppColors.warning : AppColors.primary;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: circleColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: circleColor, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          '${opinion.priority}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: circleColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                opinion.measurement,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _gradeColor(opinion.score.round())
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${opinion.score.round()}점',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color:
                                        _gradeColor(opinion.score.round()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            opinion.action,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w300,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 6. Prescriptions Card
  // ──────────────────────────────────────────────
  Widget _buildPrescriptionsCard() {
    final prescriptions = widget.aiResult.mergedPrescriptions.take(3).toList();

    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.local_pharmacy_outlined, color: AppColors.primary, size: 22),
                SizedBox(width: 12),
                Text(
                  '케어 추천',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...prescriptions.map((dp) {
              final rx = dp.prescription;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rx.measurementName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (rx.productTypes.isNotEmpty)
                      _prescriptionInfoRow(
                          '추천 제품', rx.productTypes.join(', ')),
                    if (rx.usage.isNotEmpty)
                      _prescriptionInfoRow('사용법', rx.usage),
                    if (rx.duration.isNotEmpty)
                      _prescriptionInfoRow('기간', rx.duration),
                    if (rx.lifestyle.isNotEmpty)
                      _prescriptionInfoRow(
                          '생활습관', rx.lifestyle.join(', ')),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _prescriptionInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  // 7. Action Buttons
  // ──────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // 처방전 확인하기
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PrescriptionScreen(result: widget.aiResult),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.science_outlined, size: 20),
              label: const Text('처방전 확인하기', style: TextStyle(fontWeight: FontWeight.w400)),
            ),
          ),
          const SizedBox(height: 12),

          // 설문 응답 상세보기
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SurveyDetailScreen(surveyData: widget.surveyData),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.list_alt, size: 20),
              label: const Text('설문 응답 상세보기', style: TextStyle(fontWeight: FontWeight.w400)),
            ),
          ),
          const SizedBox(height: 12),

          // 결과 저장하기
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isSaved
                  ? null
                  : () async {
                      await SurveyStorageService.save(widget.surveyData);
                      setState(() {
                        _isSaved = true;
                      });
                    },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.save_alt, size: 20),
              label: Text(_isSaved ? '저장 완료' : '결과 저장하기', style: const TextStyle(fontWeight: FontWeight.w400)),
            ),
          ),
          const SizedBox(height: 12),

          // PDF 리포트 내보내기
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final pdfBytes =
                    await PdfReportService.generate(widget.surveyData);
                await Printing.layoutPdf(
                  onLayout: (_) => pdfBytes,
                );
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
              label: const Text('PDF 리포트 내보내기', style: TextStyle(fontWeight: FontWeight.w400)),
            ),
          ),
          const SizedBox(height: 12),

          // 홈으로 돌아가기
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                foregroundColor: AppColors.textSecondary,
              ),
              icon: const Icon(Icons.home_outlined, size: 20),
              label: const Text('홈으로 돌아가기', style: TextStyle(fontWeight: FontWeight.w300)),
            ),
          ),
        ],
      ),
    );
  }
}
