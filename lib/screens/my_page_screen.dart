import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../services/survey_storage_service.dart';
import '../models/skin_survey_data.dart';
import '../widgets/gradient_scaffold.dart';
import 'login_screen.dart';
import 'saved_surveys_screen.dart';
import 'survey_detail_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
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

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final userEmail = authService.currentUserEmail ?? '';

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(fontWeight: FontWeight.w300)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(userEmail),
            const SizedBox(height: 20),
            _buildDiagnosisHistory(context),
            const SizedBox(height: 20),
            _buildUsedProducts(),
            const SizedBox(height: 20),
            _buildMenuSection(
              context,
              title: '설정',
              icon: Icons.settings_outlined,
              items: [
                _MenuItem(icon: Icons.notifications_outlined, title: '알림 설정'),
                _MenuItem(icon: Icons.healing_outlined, title: '피부 정보 수정'),
                _MenuItem(icon: Icons.block_outlined, title: '알레르기 성분 관리'),
                _MenuItem(icon: Icons.manage_accounts_outlined, title: '계정 설정'),
              ],
            ),
            _buildMenuSection(
              context,
              title: '고객센터',
              icon: Icons.support_agent_outlined,
              items: [
                _MenuItem(icon: Icons.help_outline, title: 'FAQ'),
                _MenuItem(icon: Icons.chat_outlined, title: '1:1 문의'),
                _MenuItem(icon: Icons.calendar_today_outlined, title: '전문가 상담 예약'),
              ],
            ),
            _buildMenuSection(
              context,
              title: '약관 및 정책',
              icon: Icons.description_outlined,
              items: [
                _MenuItem(icon: Icons.article_outlined, title: '이용약관'),
                _MenuItem(icon: Icons.privacy_tip_outlined, title: '개인정보 처리방침'),
              ],
            ),
            const SizedBox(height: 8),
            _buildLogoutButton(context, authService),
            const SizedBox(height: 32),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildProfileSection(String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        border: const Border(bottom: BorderSide(color: Colors.white, width: 1.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.person_outline, size: 32, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '회원님',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _surveys.isNotEmpty
                      ? '${_surveys.first.ageGroup ?? '-'} ${_surveys.first.gender ?? '-'} · ${_getLatestSkinType()}'
                      : '설문을 완료해주세요',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (_surveys.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '최근 설문: ',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: AppColors.primary),
                        ),
                        Text(
                          _formatDate(_surveys.first.savedAt),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text(
              '수정',
              style: TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosisHistory(BuildContext context) {
    final recent = _surveys.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.6),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.analytics_outlined, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        '진단 히스토리',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SavedSurveysScreen()),
                      ).then((_) => _loadSurveys());
                    },
                    child: const Text('전체 보기'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (recent.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '저장된 진단 기록이 없습니다.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                )
              else
                ...recent.asMap().entries.map((entry) {
                  final index = entry.key;
                  final survey = entry.value;
                  return Column(
                    children: [
                      if (index > 0) const Divider(height: 20),
                      _buildHistoryItem(context, survey),
                    ],
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, SkinSurveyData survey) {
    final skinTypes = _getSkinTypeText(survey);
    final date = _formatDate(survey.savedAt);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SurveyDetailScreen(surveyData: survey),
          ),
        );
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.description_outlined, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
                const SizedBox(height: 4),
                Text(
                  '${survey.gender ?? '-'} / ${survey.ageGroup ?? '-'} / $skinTypes',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildUsedProducts() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white, width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shopping_bag_outlined, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text(
                    '사용 중인 제품',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Center(
                      child: Text('🧴', style: TextStyle(fontSize: 26)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '닥터포헤어 탈모샴푸',
                          style: TextStyle(fontWeight: FontWeight.w400),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            '재구매 추천일: D-7',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: const Text('재구매', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<_MenuItem> items,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Card(
            elevation: 0,
            color: Colors.white.withValues(alpha: 0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Colors.white, width: 1.5),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    ListTile(
                      leading: Icon(item.icon, color: AppColors.primary, size: 24),
                      title: Text(item.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w300)),
                      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('준비 중인 기능입니다.'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    ),
                    if (index < items.length - 1)
                      Divider(height: 1, indent: 64, color: Colors.white.withValues(alpha: 0.5)),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '-';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '-';
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }

  String _getSkinTypeText(SkinSurveyData data) {
    final selected = data.skinTypes.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (selected.isEmpty) return '-';
    return selected.join(', ');
  }

  String _getLatestSkinType() {
    if (_surveys.isEmpty) return '-';
    return _getSkinTypeText(_surveys.first);
  }

  Widget _buildLogoutButton(BuildContext context, AuthService authService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.w400)),
                content: const Text('정말 로그아웃 하시겠습니까?', style: TextStyle(fontWeight: FontWeight.w300)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소', style: TextStyle(fontWeight: FontWeight.w400, color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () {
                      authService.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text('로그아웃', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w400)),
                  ),
                ],
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
            foregroundColor: AppColors.error,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          icon: const Icon(Icons.logout_outlined, size: 20),
          label: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.w400)),
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;

  _MenuItem({required this.icon, required this.title});
}
