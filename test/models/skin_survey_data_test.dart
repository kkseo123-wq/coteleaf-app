import 'package:flutter_test/flutter_test.dart';
import 'package:coteleaf/models/skin_survey_data.dart';

void main() {
  group('SkinSurveyData', () {
    late SkinSurveyData surveyData;

    setUp(() {
      surveyData = SkinSurveyData();
    });

    test('초기값이 올바르게 설정되어야 한다', () {
      expect(surveyData.consentAgreed, isNull);
      expect(surveyData.gender, isNull);
      expect(surveyData.ageGroup, isNull);
      expect(surveyData.skinType, isNull);
      expect(surveyData.skinConcerns, isNotEmpty);
    });

    test('피부 고민 기본값은 모두 1이어야 한다', () {
      surveyData.skinConcerns.forEach((key, value) {
        expect(value, equals(1), reason: '$key의 기본값은 1이어야 함');
      });
    });

    test('피부 고민 항목이 모두 존재해야 한다', () {
      final expectedConcerns = [
        '기미', '잡티', '주근깨', '색소침착', '홍조',
        '모공 확대', '피부결 거침', '여드름', '주름/탄력 저하'
      ];

      for (final concern in expectedConcerns) {
        expect(surveyData.skinConcerns.containsKey(concern), isTrue,
            reason: '$concern 항목이 존재해야 함');
      }
    });

    test('현재 사용 제품 기본값은 모두 false여야 한다', () {
      surveyData.currentProducts.forEach((key, value) {
        expect(value, isFalse, reason: '$key의 기본값은 false여야 함');
      });
    });

    test('개선 목표 기본값은 모두 false여야 한다', () {
      surveyData.improvementGoals.forEach((key, value) {
        expect(value, isFalse, reason: '$key의 기본값은 false여야 함');
      });
    });

    test('선호 제형 기본값은 모두 false여야 한다', () {
      surveyData.preferredFormula.forEach((key, value) {
        expect(value, isFalse, reason: '$key의 기본값은 false여야 함');
      });
    });

    test('toJson이 모든 필드를 포함해야 한다', () {
      surveyData.consentAgreed = true;
      surveyData.gender = '여성';
      surveyData.ageGroup = '30대';
      surveyData.skinType = '복합성';

      final json = surveyData.toJson();

      expect(json['consentAgreed'], isTrue);
      expect(json['gender'], equals('여성'));
      expect(json['ageGroup'], equals('30대'));
      expect(json['skinType'], equals('복합성'));
      expect(json['skinConcerns'], isNotNull);
      expect(json['currentProducts'], isNotNull);
      expect(json['improvementGoals'], isNotNull);
      expect(json['preferredFormula'], isNotNull);
    });

    test('설문 데이터를 올바르게 설정할 수 있어야 한다', () {
      surveyData.consentAgreed = true;
      surveyData.gender = '남성';
      surveyData.ageGroup = '40대';
      surveyData.skinType = '지성';
      surveyData.skinConcerns['기미'] = 4;
      surveyData.skinConcerns['모공 확대'] = 5;
      surveyData.currentProducts['클렌저'] = true;
      surveyData.currentProducts['선크림'] = true;

      expect(surveyData.consentAgreed, isTrue);
      expect(surveyData.gender, equals('남성'));
      expect(surveyData.skinType, equals('지성'));
      expect(surveyData.skinConcerns['기미'], equals(4));
      expect(surveyData.skinConcerns['모공 확대'], equals(5));
      expect(surveyData.currentProducts['클렌저'], isTrue);
      expect(surveyData.currentProducts['선크림'], isTrue);
    });

    test('AI 진단 값을 설정할 수 있어야 한다', () {
      surveyData.aiPigmentLevel = 60;
      surveyData.aiPoreLevel = 45;
      surveyData.aiMoistureLevel = 70;
      surveyData.aiOilLevel = 55;
      surveyData.aiImprovementGrade = 'B';

      expect(surveyData.aiPigmentLevel, equals(60));
      expect(surveyData.aiPoreLevel, equals(45));
      expect(surveyData.aiMoistureLevel, equals(70));
      expect(surveyData.aiOilLevel, equals(55));
      expect(surveyData.aiImprovementGrade, equals('B'));
    });

    test('우선순위를 설정할 수 있어야 한다', () {
      surveyData.priorityFirst = '기미/잡티 개선';
      surveyData.prioritySecond = '보습 강화';

      expect(surveyData.priorityFirst, equals('기미/잡티 개선'));
      expect(surveyData.prioritySecond, equals('보습 강화'));
    });

    test('가격대와 알레르기 성분을 설정할 수 있어야 한다', () {
      surveyData.priceRange = '2~5만원';
      surveyData.allergyIngredients = '알코올, 향료';

      expect(surveyData.priceRange, equals('2~5만원'));
      expect(surveyData.allergyIngredients, equals('알코올, 향료'));
    });
  });
}
