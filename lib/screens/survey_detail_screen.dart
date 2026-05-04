import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/skin_survey_data.dart';
import '../widgets/gradient_scaffold.dart';

class SurveyDetailScreen extends StatelessWidget {
  final SkinSurveyData surveyData;
  const SurveyDetailScreen({super.key, required this.surveyData});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('설문 응답 상세', style: TextStyle(fontWeight: FontWeight.w300)),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // 1. 기본 정보
              _buildSummaryCard(
                title: '기본 정보',
                icon: Icons.person_outline,
                children: [
                  _buildInfoRow('성별', surveyData.gender ?? '-'),
                  _buildInfoRow('연령대', surveyData.ageGroup ?? '-'),
                  _buildInfoRow('피부유형', _selectedKeys(surveyData.skinTypes, fallback: '선택 없음')),
                  _buildInfoRow('민족적 배경', surveyData.ethnicity ?? '-'),
                ],
              ),

              // 2. 피부관심
              _buildSummaryCard(
                title: '피부관심',
                icon: Icons.favorite_outline,
                children: [
                  _buildInfoRow('관심 분야', _selectedKeys(surveyData.skinInterests, fallback: '선택 없음')),
                ],
              ),

              // 3. 피부고민
              _buildSummaryCard(
                title: '피부고민',
                icon: Icons.face_outlined,
                children: [
                  _buildInfoRow('선택한 고민', _selectedKeys(surveyData.skinConcerns, fallback: '선택 없음')),
                ],
              ),

              // 4. 알러지 유무
              _buildSummaryCard(
                title: '알러지 유무',
                icon: Icons.health_and_safety_outlined,
                children: [
                  _buildInfoRow('한약/허브/풀/콩', _allergyText(surveyData.allergyHerb, surveyData.allergyHerbDetail)),
                  _buildInfoRow('햇빛', _allergyText(surveyData.allergySunlight, surveyData.allergySunlightDetail)),
                  _buildInfoRow('화장품', _allergyText(surveyData.allergyCosmetics, surveyData.allergyCosmeticsBrand)),
                ],
              ),

              // 5. 현재 사용 제품
              _buildSummaryCard(
                title: '현재 사용 제품',
                icon: Icons.shopping_bag_outlined,
                children: [
                  _buildInfoRow('사용 제품', _selectedKeys(surveyData.currentProducts, fallback: '없음')),
                  _buildInfoRow('브랜드', surveyData.productBrand ?? '-'),
                  _buildInfoRow('사용 빈도', surveyData.usageFrequency ?? '-'),
                ],
              ),

              // 6. 개선 목표
              _buildSummaryCard(
                title: '개선 목표',
                icon: Icons.flag_outlined,
                children: [
                  _buildInfoRow('1순위', surveyData.priorityFirst ?? '-'),
                  _buildInfoRow('2순위', surveyData.prioritySecond ?? '-'),
                ],
              ),

              // 7. 추천 조건
              _buildSummaryCard(
                title: '추천 조건',
                icon: Icons.tune_outlined,
                children: [
                  _buildInfoRow('금액대', surveyData.priceRange ?? '-'),
                  _buildInfoRow('선호 제형', _selectedKeys(surveyData.preferredFormula, fallback: '상관없음', maxItems: 2)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper: 선택된 키 추출 ---
  String _selectedKeys(Map<String, bool> map, {String fallback = '-', int? maxItems}) {
    final selected = map.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toList();
    if (selected.isEmpty) return fallback;
    if (maxItems != null && selected.length > maxItems) {
      return selected.take(maxItems).join(', ');
    }
    return selected.join(', ');
  }

  // --- Helper: 알러지 텍스트 ---
  String _allergyText(bool? hasAllergy, String? detail) {
    if (hasAllergy == null) return '-';
    if (hasAllergy == false) return '없다';
    final detailText = (detail != null && detail.isNotEmpty) ? ' ($detail)' : '';
    return '있다$detailText';
  }

  // --- 요약 카드 ---
  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary)),
            ]),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.white),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  // --- 정보 행 ---
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w300)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400, color: AppColors.textPrimary),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
