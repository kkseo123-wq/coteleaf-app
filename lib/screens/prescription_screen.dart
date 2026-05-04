import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/skin_analysis_result.dart';
import '../services/skin_assessment_recipe_service.dart';
import '../widgets/gradient_scaffold.dart';

/// 처방 테이블에 표시할 행 데이터
class PrescriptionRow {
  final String code;
  final String category; // 'base', 'pcr', 'assessment'
  final String ingredientName;
  final double percentage;

  PrescriptionRow({
    required this.code,
    required this.category,
    required this.ingredientName,
    required this.percentage,
  });
}

class PrescriptionScreen extends StatelessWidget {
  final AggregatedSkinResult result;

  const PrescriptionScreen({super.key, required this.result});

  /// 처방 행 목록 생성 (M01 베이스 + A-Mix)
  List<PrescriptionRow> _buildPrescriptionRows() {
    final recipe = result.assessmentRecipe;
    final rows = <PrescriptionRow>[];

    // A-Mix 항목들 (코드 순 정렬)
    final sortedEntries = recipe.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in sortedEntries) {
      final mixCode = entry.key;
      final percentage = entry.value;
      final label = SkinAssessmentRecipeService.mixCodeLabels[mixCode] ?? mixCode;

      rows.add(PrescriptionRow(
        code: mixCode,
        category: 'assessment',
        ingredientName: '$label 개선 믹스',
        percentage: percentage,
      ));
    }

    // M01 베이스: 100% - (A-Mix 합계)
    final totalAmix = rows.fold<double>(0, (sum, r) => sum + r.percentage);
    final basePercentage = 100.0 - totalAmix;

    // M01을 맨 앞에 삽입
    rows.insert(
      0,
      PrescriptionRow(
        code: 'M01',
        category: 'base',
        ingredientName: '베이스',
        percentage: double.parse(basePercentage.toStringAsFixed(1)),
      ),
    );

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _buildPrescriptionRows();
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('맞춤형 화장품 처방', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(),
            // 테이블
            Expanded(
              child: _buildTable(rows),
            ),
            // 하단 정보
            _buildFooter(context, dateStr),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: const Icon(Icons.science_outlined, color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '맞춤형 화장품 처방',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AI 피부 분석 기반 맞춤 처방전',
                  style: TextStyle(
                    fontSize: 14,
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
  }

  Widget _buildTable(List<PrescriptionRow> rows) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // 테이블 헤더
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                border: const Border(bottom: BorderSide(color: Colors.white, width: 1.5)),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Text(
                      '코드',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Text(
                      '처방 구분',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      '처방(세럼) 원료',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '비율',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
            // 테이블 행들
            ...rows.asMap().entries.map((entry) {
              final index = entry.key;
              final row = entry.value;
              final isEven = index % 2 == 0;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: isEven ? Colors.transparent : Colors.white.withValues(alpha: 0.3),
                  border: const Border(
                    bottom: BorderSide(color: Colors.white, width: 1.0),
                  ),
                ),
                child: Row(
                  children: [
                    // 코드
                    SizedBox(
                      width: 50,
                      child: Text(
                        row.code,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // 처방 구분 아이콘
                    SizedBox(
                      width: 70,
                      child: Center(
                        child: _buildCategoryIcon(row.category),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // 원료명
                    Expanded(
                      child: Text(
                        row.ingredientName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w300,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    // 비율
                    SizedBox(
                      width: 60,
                      child: Text(
                        '${row.percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: row.category == 'base'
                              ? AppColors.textPrimary
                              : AppColors.primary,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              );
            }),
            // 합계 행
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
              ),
              child: const Row(
                children: [
                  Spacer(),
                  Text(
                    '100.0%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryIcon(String category) {
    switch (category) {
      case 'base':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            '기본',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.info,
            ),
          ),
        );
      case 'pcr':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'PCR',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.accent,
            ),
          ),
        );
      case 'assessment':
      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'AI분석',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
        );
    }
  }

  Widget _buildFooter(BuildContext context, String dateStr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: const Border(top: BorderSide(color: Colors.white, width: 1.5)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // 메타 정보
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildFooterInfo(Icons.description_outlined, '처방전', dateStr,
                    AppColors.primary),
                const SizedBox(width: 16),
                _buildFooterInfo(
                    Icons.camera_alt_outlined, '사진', dateStr, AppColors.info),
              ],
            ),
            const SizedBox(height: 24),
            // 홈으로 버튼
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.home_outlined, size: 20),
                label: const Text('홈으로 돌아가기', style: TextStyle(fontWeight: FontWeight.w400)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterInfo(
      IconData icon, String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: color,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
