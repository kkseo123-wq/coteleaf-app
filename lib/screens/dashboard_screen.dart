import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';
import '../widgets/score_widget.dart';
import '../models/skin_survey_data.dart';
import '../services/survey_storage_service.dart';
import 'skin_survey_screen.dart';
import 'saved_surveys_screen.dart';
import 'survey_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<SkinSurveyData> _surveys = [];

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    final surveys = await SurveyStorageService.loadAll();
    setState(() => _surveys = surveys);
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '-';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '-';
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  String _getSkinTypeText(SkinSurveyData data) {
    final selected = data.skinTypes.entries.where((e) => e.value).map((e) => e.key).toList();
    if (selected.isEmpty) return '-';
    return selected.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // 로고 + 알림 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.spa_outlined, color: AppColors.primary, size: 32),
                      const SizedBox(width: 10),
                      const Text(
                        'C O T E L E A F',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                          color: AppColors.primary,
                          letterSpacing: 2.0,
                          fontFamily: AppTextStyles.fontFamily,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildHealthScoreCard(context),
              const SizedBox(height: 24),
              _buildDiagnosisButton(context),
              const SizedBox(height: 32),
              _buildQuickMenuSection(context),
              const SizedBox(height: 32),
              _buildRecentDiagnosisSection(context),
              const SizedBox(height: 32),
              _buildTipsSection(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthScoreCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              '피부 건강도',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            const DashboardScoreWidget(
              score: 68,
              maxScore: 100,
              size: 160,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_outlined, size: 16, color: AppColors.warning),
                  SizedBox(width: 6),
                  Text(
                    '주의 필요',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildScoreComparison('연령대 평균', '72점'),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.textLight.withValues(alpha: 0.3),
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                ),
                _buildScoreComparison('복합성 피부 평균', '65점'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreComparison(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisButton(BuildContext context) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SkinSurveyScreen()),
          );
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        icon: const Icon(Icons.face_retouching_natural, size: 20, color: Colors.white),
        label: const Text(
          '피부 진단',
          style: TextStyle(
            fontSize: 15, 
            fontWeight: FontWeight.w400,
            letterSpacing: 1.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickMenuSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('빠른 메뉴', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildQuickMenuItem(Icons.analytics_outlined, '진단 기록', AppColors.primary, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedSurveysScreen())).then((_) => _loadSurveys());
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickMenuItem(Icons.shopping_bag_outlined, '추천 제품', AppColors.primary, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('준비 중인 기능입니다.')));
            })),
            const SizedBox(width: 12),
            Expanded(child: _buildQuickMenuItem(Icons.menu_book_outlined, '케어 가이드', AppColors.primary, () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('준비 중인 기능입니다.')));
            })),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickMenuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Colors.white, width: 1.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentDiagnosisSection(BuildContext context) {
    final recent = _surveys.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('최근 진단 기록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SavedSurveysScreen())).then((_) => _loadSurveys());
              },
              child: const Text('전체보기', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Card(
            elevation: 0,
            color: Colors.white.withValues(alpha: 0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('저장된 진단 기록이 없습니다.', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w300)),
              ),
            ),
          )
        else
          ...recent.map((survey) => Card(
            elevation: 0,
            color: Colors.white.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Colors.white, width: 1.0),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.description_outlined, color: AppColors.primary),
                ),
              ),
              title: Text(
                _formatDate(survey.savedAt),
                style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '${survey.gender ?? '-'} / ${survey.ageGroup ?? '-'} / ${_getSkinTypeText(survey)}',
                  style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 13),
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SurveyDetailScreen(surveyData: survey)));
              },
            ),
          )),
      ],
    );
  }

  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('맞춤 케어 팁', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: AppColors.textPrimary)),
            TextButton(
              onPressed: () {},
              child: const Text('더보기', style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildTipCard('💧', '지성 피부, 하루 몇 번 세안할까?'),
              _buildTipCard('🥗', '피부 건강 식단 BEST 5'),
              _buildTipCard('💆', '페이스 마사지 올바른 방법'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(String emoji, String title) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white, width: 1.0),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 12),
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
