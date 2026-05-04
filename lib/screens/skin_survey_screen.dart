import 'package:flutter/material.dart';
import '../models/skin_survey_data.dart';
import '../theme/app_theme.dart';
import '../widgets/gradient_scaffold.dart';
import 'photo_capture_screen.dart';

class SkinSurveyScreen extends StatefulWidget {
  const SkinSurveyScreen({super.key});

  @override
  State<SkinSurveyScreen> createState() => _SkinSurveyScreenState();
}

class _SkinSurveyScreenState extends State<SkinSurveyScreen> {
  final PageController _pageController = PageController();
  final SkinSurveyData _surveyData = SkinSurveyData();
  int _currentPage = 0;
  final int _totalPages = 7;

  final _skinConcernsOtherController = TextEditingController();
  final _currentProductsOtherController = TextEditingController();
  final _productBrandController = TextEditingController();
  final _improvementGoalsOtherController = TextEditingController();
  final _ethnicityOtherController = TextEditingController();
  final _allergyHerbDetailController = TextEditingController();
  final _allergySunlightDetailController = TextEditingController();
  final _allergyCosmeticsBrandController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _skinConcernsOtherController.dispose();
    _currentProductsOtherController.dispose();
    _productBrandController.dispose();
    _improvementGoalsOtherController.dispose();
    _ethnicityOtherController.dispose();
    _allergyHerbDetailController.dispose();
    _allergySunlightDetailController.dispose();
    _allergyCosmeticsBrandController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitSurvey() {
    _surveyData.skinConcernsOther = _skinConcernsOtherController.text;
    _surveyData.currentProductsOther = _currentProductsOtherController.text;
    _surveyData.productBrand = _productBrandController.text;
    _surveyData.improvementGoalsOther = _improvementGoalsOtherController.text;
    _surveyData.ethnicityOther = _ethnicityOtherController.text;
    _surveyData.allergyHerbDetail = _allergyHerbDetailController.text;
    _surveyData.allergySunlightDetail = _allergySunlightDetailController.text;
    _surveyData.allergyCosmeticsBrand = _allergyCosmeticsBrandController.text;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotoCaptureScreen(surveyData: _surveyData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        title: const Text('피부 진단 설문'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: _buildProgressBar(),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildSection1(),
                  _buildSection2(),
                  _buildSection3(),
                  _buildSection4(),
                  _buildSection5(),
                  _buildSection6(),
                  _buildSection7(),
                ],
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentPage + 1) / _totalPages,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Text(
          '${_currentPage + 1} / $_totalPages',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        border: Border(top: BorderSide(color: Colors.white, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (_currentPage > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousPage,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('이전', style: TextStyle(fontWeight: FontWeight.w400)),
                ),
              ),
            if (_currentPage > 0) const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed:
                    _currentPage == _totalPages - 1 ? _submitSurvey : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _currentPage == _totalPages - 1 ? '제출하기' : '다음',
                  style: const TextStyle(fontWeight: FontWeight.w400, letterSpacing: 1.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 섹션 1: 기본정보
  Widget _buildSection1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('1', '기본정보', Icons.person_outline),
          const SizedBox(height: 24),
          // 개인정보 수집 동의
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('개인정보 수집 동의', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    Text(' (필수)', style: TextStyle(color: AppColors.error, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('동의합니다', style: TextStyle(fontSize: 14)),
                        value: true,
                        groupValue: _surveyData.consentAgreed,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) => setState(() => _surveyData.consentAgreed = value),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('동의하지 않습니다', style: TextStyle(fontSize: 14)),
                        value: false,
                        groupValue: _surveyData.consentAgreed,
                        activeColor: AppColors.primary,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (value) => setState(() => _surveyData.consentAgreed = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildRadioGroup(
            label: '성별',
            options: const ['남성', '여성'],
            selectedValue: _surveyData.gender,
            onChanged: (value) => setState(() => _surveyData.gender = value),
          ),
          _buildRadioGroup(
            label: '연령대',
            options: const ['10대', '20대', '30대', '40대', '50대', '60대 이상'],
            selectedValue: _surveyData.ageGroup,
            onChanged: (value) => setState(() => _surveyData.ageGroup = value),
          ),
          const Text(
            '피부유형 (중복선택가능)',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _surveyData.skinTypes.entries.map((entry) {
              return FilterChip(
                label: Text(entry.key, style: TextStyle(fontSize: 13, color: entry.value ? Colors.white : AppColors.textPrimary)),
                selected: entry.value,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    _surveyData.skinTypes[entry.key] = selected;
                  });
                },
              );
            }).toList(),
          ),
          if (_surveyData.skinTypes['잘 모름'] == true)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'AI가 피부 타입을 분석해드려요!',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          _buildEthnicityQuestion(),
        ],
      ),
    );
  }

  Widget _buildEthnicityQuestion() {
    final ethnicityOptions = [
      '한국인',
      '동북아시아',
      '동남아시아',
      '남아시아',
      '중동/북아프리카',
      '사하라 이남 아프리카',
      '유럽계',
      '라틴/히스패닉계',
      '다문화, 복수 민족적 배경',
      '기타',
      '응답하지 않음',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '민족적/인종적 배경',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '피부 특성 분석 및 맞춤형 화장품 제조를 위해, 본인의 민족적/인종적 배경을 가장 잘 설명하는 항목을 선택해 주세요.\n\n(본 정보는 피부 생리학적 특성 차이를 분석하여 개인 맞춤형 화장품을 제조하기 위한 연구,통계 목적에만 사용되며, 개인을 식별하거나 차별하는 용도로는 사용되지 않습니다)',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 16),
          ...ethnicityOptions.map((option) {
            final isSelected = _surveyData.ethnicity == option;
            return InkWell(
              onTap: () => setState(() => _surveyData.ethnicity = option),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        option == '기타' ? '기타 (직접 입력)' : option,
                        style: TextStyle(
                          fontSize: 14,
                          color: isSelected ? AppColors.primaryDark : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_surveyData.ethnicity == '기타')
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextField(
                controller: _ethnicityOtherController,
                decoration: InputDecoration(
                  hintText: '직접 입력해주세요',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 섹션 2: 피부관심 & 피부고민
  Widget _buildSection2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('2', '피부관심 & 피부고민', Icons.face_outlined),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFE8F4FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '해당되는 항목을 모두 선택해주세요 (중복선택가능)',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 피부관심
          const Text(
            '피부관심 (중복선택가능)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _surveyData.skinInterests.entries.map((entry) {
              return FilterChip(
                label: Text(entry.key, style: const TextStyle(fontSize: 14)),
                selected: entry.value,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    _surveyData.skinInterests[entry.key] = selected;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          // 피부고민
          const Text(
            '피부고민 (중복선택가능)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _surveyData.skinConcerns.entries.map((entry) {
              return FilterChip(
                label: Text(entry.key, style: const TextStyle(fontSize: 14)),
                selected: entry.value,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    _surveyData.skinConcerns[entry.key] = selected;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _skinConcernsOtherController,
            decoration: InputDecoration(
              labelText: '기타 피부 고민',
              hintText: '기타 고민이 있다면 입력해주세요',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  // 섹션 3: 알러지 유무
  Widget _buildSection3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('3', '알러지 유무', Icons.health_and_safety_outlined),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFFFF3E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_outlined, color: AppColors.warning),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '발진/두드러기를 포함하여 알러지 여부를 체크해주세요.',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 한약/허브/풀/콩 알러지
          _buildAllergyItem(
            label: '한약/허브/풀/콩에 대한 알러지',
            value: _surveyData.allergyHerb,
            onChanged: (val) => setState(() => _surveyData.allergyHerb = val),
            detailController: _allergyHerbDetailController,
            detailHint: '종류를 입력해주세요',
          ),
          const SizedBox(height: 20),
          // 햇빛 알러지
          _buildAllergyItem(
            label: '햇빛에 대한 알러지',
            value: _surveyData.allergySunlight,
            onChanged: (val) => setState(() => _surveyData.allergySunlight = val),
            detailController: _allergySunlightDetailController,
            detailHint: '종류를 입력해주세요',
          ),
          const SizedBox(height: 20),
          // 화장품 알러지
          _buildAllergyItem(
            label: '화장품에 대한 알러지',
            value: _surveyData.allergyCosmetics,
            onChanged: (val) => setState(() => _surveyData.allergyCosmetics = val),
            detailController: _allergyCosmeticsBrandController,
            detailHint: '브랜드를 입력해주세요',
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyItem({
    required String label,
    required bool? value,
    required ValueChanged<bool?> onChanged,
    required TextEditingController detailController,
    required String detailHint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('있다', style: TextStyle(fontSize: 14)),
                  value: true,
                  groupValue: value,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: onChanged,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('없다', style: TextStyle(fontSize: 14)),
                  value: false,
                  groupValue: value,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          if (value == true) ...[
            const SizedBox(height: 8),
            TextField(
              controller: detailController,
              decoration: InputDecoration(
                hintText: detailHint,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 섹션 4: 현재 사용하는 스킨케어 제품
  Widget _buildSection4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('4', '현재 사용 제품', Icons.shopping_bag_outlined),
          const SizedBox(height: 24),
          const Text(
            '사용 중인 제품 유형 (복수 선택)',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _surveyData.currentProducts.entries.map((entry) {
              return FilterChip(
                label: Text(entry.key, style: TextStyle(fontSize: 13, color: entry.value ? Colors.white : AppColors.textPrimary)),
                selected: entry.value,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    _surveyData.currentProducts[entry.key] = selected;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _currentProductsOtherController,
            decoration: InputDecoration(
              labelText: '기타 제품',
              hintText: '기타 사용 제품이 있다면 입력해주세요',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _productBrandController,
            decoration: InputDecoration(
              labelText: '브랜드 또는 제품명',
              hintText: '사용 중인 제품의 브랜드나 이름',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),
          _buildRadioGroup(
            label: '사용 빈도',
            options: const ['하루 2회 이상 (아침/저녁 모두)', '하루 1회', '주 4–6회', '주 1–3회', '거의 사용하지 않음'],
            selectedValue: _surveyData.usageFrequency,
            onChanged: (value) =>
                setState(() => _surveyData.usageFrequency = value),
          ),
        ],
      ),
    );
  }

  // 섹션 5: 피부 문제 개선 목표
  Widget _buildSection5() {
    final goalOptions = [
      '기미/잡티 개선',
      '피부톤(미백) 개선',
      '탄력 향상',
      '주름 개선',
      '홍조 완화',
      '모공 축소',
      '피지 컨트롤',
      '보습 강화'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('5', '개선 목표', Icons.flag_outlined),
          const SizedBox(height: 24),
          const Text(
            '원하는 개선 항목 (복수 선택)',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _surveyData.improvementGoals.entries.map((entry) {
              return FilterChip(
                label: Text(entry.key, style: TextStyle(fontSize: 13, color: entry.value ? Colors.white : AppColors.textPrimary)),
                selected: entry.value,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    _surveyData.improvementGoals[entry.key] = selected;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _improvementGoalsOtherController,
            decoration: InputDecoration(
              labelText: '기타 개선 목표',
              hintText: '기타 목표가 있다면 입력해주세요',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '개선 우선순위',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _surveyData.priorityFirst,
            decoration: InputDecoration(
              labelText: '1순위',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: goalOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) =>
                setState(() => _surveyData.priorityFirst = value),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _surveyData.prioritySecond,
            decoration: InputDecoration(
              labelText: '2순위',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            items: goalOptions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (value) =>
                setState(() => _surveyData.prioritySecond = value),
          ),
        ],
      ),
    );
  }

  // 섹션 6: 화장품 추천 조건
  Widget _buildSection6() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('6', '추천 조건', Icons.tune_outlined),
          const SizedBox(height: 24),
          const Text(
            '선호하는 제품 형태 (복수 선택)',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _surveyData.preferredFormula.entries.map((entry) {
              return FilterChip(
                label: Text(entry.key, style: TextStyle(fontSize: 13, color: entry.value ? Colors.white : AppColors.textPrimary)),
                selected: entry.value,
                selectedColor: AppColors.primary,
                checkmarkColor: Colors.white,
                onSelected: (selected) {
                  setState(() {
                    _surveyData.preferredFormula[entry.key] = selected;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          _buildRadioGroup(
            label: '금액대',
            options: const ['2만 원 이하', '2~5만 원', '5~10만 원', '10만 원 이상'],
            selectedValue: _surveyData.priceRange,
            onChanged: (value) =>
                setState(() => _surveyData.priceRange = value),
          ),
        ],
      ),
    );
  }

  // 섹션 7: AI 피부분석 리포트 연동
  Widget _buildSection7() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('7', 'AI 피부분석 리포트 연동', Icons.smart_toy_outlined),
          const SizedBox(height: 24),
          _buildYesNoQuestion(
            '나만의 맞춤형 화장품을 주문하시겠습니까?',
            _surveyData.wantRecommendation,
            (value) => setState(() => _surveyData.wantRecommendation = value),
          ),
          const SizedBox(height: 24),
          _buildYesNoQuestion(
            '사용한 제품의 2개월 후 효과 추적\n재진단 알림을 수신하시겠습니까?',
            _surveyData.wantFollowUpAlert,
            (value) => setState(() => _surveyData.wantFollowUpAlert = value),
          ),
          const SizedBox(height: 32),
          // 홈케어/관리 방향 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.spa_outlined, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    Text(
                      '홈케어/관리 방향',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '설문 완료 후 AI가 다음 항목을 분석하여 제공합니다:',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                _buildRecommendationItem('추천 제품군'),
                _buildRecommendationItem('피해야 할 성분'),
                _buildRecommendationItem('생활습관 개선'),
                _buildRecommendationItem('전문 관리 필요 여부'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.check_circle_outline,
                    size: 48, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text(
                  '설문이 거의 완료되었습니다!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  '제출하기 버튼을 눌러 설문을 완료해주세요.',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  // 공통 위젯들
  Widget _buildSectionHeader(String number, String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.primary, 
                fontWeight: FontWeight.w400,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w300,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRadioGroup({
    required String label,
    required List<String> options,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedValue == option;
              return ChoiceChip(
                label: Text(option, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : AppColors.textPrimary)),
                selected: isSelected,
                selectedColor: AppColors.primary,
                onSelected: (selected) => onChanged(selected ? option : null),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildYesNoQuestion(
      String question, bool? value, ValueChanged<bool?> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('예', style: TextStyle(fontSize: 14)),
                  value: true,
                  groupValue: value,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: onChanged,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('아니오', style: TextStyle(fontSize: 14)),
                  value: false,
                  groupValue: value,
                  activeColor: AppColors.primary,
                  contentPadding: EdgeInsets.zero,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
