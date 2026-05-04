import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';

class CareTipsScreen extends StatefulWidget {
  const CareTipsScreen({super.key});

  @override
  State<CareTipsScreen> createState() => _CareTipsScreenState();
}

class _CareTipsScreenState extends State<CareTipsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('스킨 케어 팁', style: TextStyle(fontWeight: FontWeight.w300)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
          labelStyle: const TextStyle(fontWeight: FontWeight.w400),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w300),
          dividerColor: Colors.white.withValues(alpha: 0.3),
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '세안법'),
            Tab(text: '마사지'),
            Tab(text: '식습관'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildAllContent(),
            _buildShampooContent(),
            _buildMassageContent(),
            _buildDietContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('영상 가이드'),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildVideoCard('🚿', '올바른 세안 방법', '2:34'),
              _buildVideoCard('💆', '페이스 마사지 루틴', '3:15'),
              _buildVideoCard('🧴', '세럼 사용법', '1:58'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('아티클'),
        const SizedBox(height: 12),
        _buildArticleCard(
          '💧',
          '지성 피부, 하루 몇 번 세안할까?',
          '지성 피부라면 하루에 두 번 세안하는 것이 좋습니다. 하지만 과도한 세정은...',
          '5분 읽기',
        ),
        _buildArticleCard(
          '🥗',
          '피부 건강 식단 BEST 5',
          '피부 건강에 좋은 음식들을 소개합니다. 단백질, 비타민, 미네랄이 풍부한...',
          '7분 읽기',
        ),
        _buildArticleCard(
          '⏰',
          '각질 관리 주기는?',
          '각질 관리는 주 1-2회가 적당합니다. 너무 자주하면 피부에 자극이...',
          '4분 읽기',
        ),
        _buildArticleCard(
          '😰',
          '스트레스와 피부의 관계',
          '스트레스는 피부 트러블의 주요 원인 중 하나입니다. 스트레스 호르몬인 코르티솔이...',
          '6분 읽기',
        ),
      ],
    );
  }

  Widget _buildShampooContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTipCard(
          '1',
          '미온수로 얼굴 적시기',
          '너무 뜨거운 물은 피부를 자극하고 건조하게 합니다. 32-34도 정도의 미온수가 적당합니다.',
          Icons.water_drop,
        ),
        _buildTipCard(
          '2',
          '클렌저 거품 내기',
          '클렌저를 손바닥에서 충분히 거품을 낸 후 얼굴에 도포하세요. 직접 피부에 짜면 자극이 될 수 있습니다.',
          Icons.bubble_chart,
        ),
        _buildTipCard(
          '3',
          '부드럽게 세안하기',
          '손끝을 이용해 얼굴을 부드럽게 마사지하듯 세안하세요. 문지르지 마세요.',
          Icons.back_hand,
        ),
        _buildTipCard(
          '4',
          '충분히 헹구기',
          '클렌저 잔여물이 남으면 피부 트러블의 원인이 됩니다. 충분히 헹궈주세요.',
          Icons.shower,
        ),
        _buildTipCard(
          '5',
          '수건으로 톡톡',
          '문지르지 말고 수건으로 가볍게 톡톡 두드려 물기를 제거하세요.',
          Icons.air,
        ),
      ],
    );
  }

  Widget _buildMassageContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Column(
            children: [
              const Text(
                '💆',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                '페이스 마사지 효과',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '혈액순환 촉진 • 피지 분비 조절 • 스트레스 해소',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildMassageStep(
          '1',
          '이완하기',
          '양 손 끝으로 관자놀이를 원을 그리며 부드럽게 누릅니다.',
          '30초',
        ),
        _buildMassageStep(
          '2',
          '앞머리 라인',
          '이마 경계선을 따라 손가락으로 지그재그로 눌러줍니다.',
          '1분',
        ),
        _buildMassageStep(
          '3',
          '정수리 마사지',
          '정수리를 중심으로 원을 그리며 부드럽게 눌러줍니다.',
          '2분',
        ),
        _buildMassageStep(
          '4',
          '전체 두드리기',
          '손끝으로 얼굴 전체를 가볍게 두드려 마무리합니다.',
          '30초',
        ),
      ],
    );
  }

  Widget _buildDietContent() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSectionTitle('피부 건강에 좋은 음식'),
        const SizedBox(height: 12),
        _buildFoodCard('🥚', '계란', '비오틴, 단백질', '피부 재생 촉진'),
        _buildFoodCard('🥬', '시금치', '철분, 비타민A', '피부 건강 유지'),
        _buildFoodCard('🐟', '연어', '오메가3, 단백질', '피부 탄력 부여'),
        _buildFoodCard('🥜', '호두', '오메가3, 비타민E', '노화 예방'),
        _buildFoodCard('🥕', '당근', '비타민A', '피부 유분 조절'),
        const SizedBox(height: 24),
        _buildSectionTitle('피해야 할 음식'),
        const SizedBox(height: 12),
        _buildBadFoodCard('🍟', '기름진 음식', '과도한 피지 분비 유발'),
        _buildBadFoodCard('🍺', '과도한 음주', '영양소 흡수 방해'),
        _buildBadFoodCard('🍰', '당분 과다', '염증 유발 가능'),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildVideoCard(String emoji, String title, String duration) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 0,
        color: Colors.white.withValues(alpha: 0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Colors.white, width: 1.5),
        ),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  border: const Border(bottom: BorderSide(color: Colors.white, width: 1.5)),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          duration,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(String emoji, String title, String preview, String readTime) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      preview,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      readTime,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String number, String title, String description, IconData icon) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
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
                      Icon(icon, size: 20, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textSecondary,
                      height: 1.4,
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

  Widget _buildMassageStep(String number, String title, String description, String duration) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  number,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w400,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
              ),
              child: Text(
                duration,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.info,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodCard(String emoji, String name, String nutrients, String benefit) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w400)),
        subtitle: Text('$nutrients • $benefit', style: const TextStyle(fontWeight: FontWeight.w300)),
      ),
    );
  }

  Widget _buildBadFoodCard(String emoji, String name, String reason) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.6),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white, width: 1.5),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w400)),
        subtitle: Text(reason, style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.w300)),
      ),
    );
  }
}
