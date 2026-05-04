# 꼬드리브 - AI 뷰티케어 앱

AI 기반 두피/피부 진단 설문 앱입니다.

## 주요 기능

### 1. 로그인/회원가입
- 이메일 기반 인증 (현재 더미 데이터)
- 테스트 계정: `test@example.com` / `1234`

### 2. 두피 진단 설문 (6섹션)
| 섹션 | 내용 |
|------|------|
| 1 | 기본정보 (개인정보 동의, 성별, 연령대) |
| 2 | 두피 상태 자가진단 (5점 척도) |
| 3 | 생활습관 |
| 4 | 알레르기/부작용 경험 |
| 5 | AI 진단 연동 (관리자용) |
| 6 | 추천 조건 |

### 3. 피부 진단 설문 (7섹션)
| 섹션 | 내용 |
|------|------|
| 1 | 기본정보 (개인정보 동의, 성별, 연령대, 피부타입) |
| 2 | 현재 피부 상태 (5점 척도) |
| 3 | AI 진단 연동 (관리자용) |
| 4 | 현재 사용 스킨케어 제품 |
| 5 | 피부 개선 목표 |
| 6 | 화장품 추천 조건 |
| 7 | AI 리포트 연동 |

### 4. 하단 탭 네비게이션
- 홈: 대시보드, 두피/피부 진단 버튼
- 진단: 카메라 진단 (준비중)
- 추천: 제품 추천 (준비중)
- 케어팁: 맞춤 케어 정보 (준비중)
- 마이: 마이페이지

---

## 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점
├── models/
│   ├── survey_data.dart         # 두피 설문 데이터 모델
│   └── skin_survey_data.dart    # 피부 설문 데이터 모델
├── screens/
│   ├── splash_screen.dart       # 스플래시 화면
│   ├── login_screen.dart        # 로그인 화면
│   ├── main_screen.dart         # 메인 화면 (하단 탭바)
│   ├── dashboard_screen.dart    # 홈 대시보드
│   ├── survey_screen.dart       # 두피 설문 화면
│   ├── skin_survey_screen.dart  # 피부 설문 화면
│   ├── result_screen.dart       # 두피 설문 결과
│   ├── skin_result_screen.dart  # 피부 설문 결과
│   └── my_page_screen.dart      # 마이페이지
├── services/
│   └── auth_service.dart        # 인증 서비스 (싱글톤)
├── theme/
│   └── app_theme.dart           # 앱 테마 설정
└── widgets/
    ├── survey_widgets.dart      # 설문 공통 위젯
    └── score_widget.dart        # 점수 표시 위젯
```

---

## 실행 방법

### 1. 사전 요구사항
- Flutter SDK 3.0 이상
- Dart SDK 3.0 이상
- iOS: Xcode 14 이상 (Mac)
- Android: Android Studio + Android SDK

### 2. Flutter 설치 확인
```bash
flutter --version
flutter doctor
```

### 3. 의존성 설치
```bash
cd /path/to/coteleaf
flutter pub get
```

### 4. 앱 실행
```bash
# iOS 시뮬레이터
flutter run -d ios

# Android 에뮬레이터
flutter run -d android

# 연결된 기기 목록 확인
flutter devices
```

### 5. 테스트 실행
```bash
flutter test
```

### 6. 빌드
```bash
# Android APK
flutter build apk

# iOS
flutter build ios
```

---

## 테스트 계정

| 이메일 | 비밀번호 |
|--------|----------|
| test@example.com | 1234 |
| user@coteleaf.com | password |
| admin@coteleaf.com | admin123 |

---

## 테스트 코드

```
test/
├── widget_test.dart                    # 앱 기본 테스트
├── models/
│   ├── survey_data_test.dart           # 두피 설문 모델 테스트
│   └── skin_survey_data_test.dart      # 피부 설문 모델 테스트
├── services/
│   └── auth_service_test.dart          # 인증 서비스 테스트
└── screens/
    ├── login_screen_test.dart          # 로그인 화면 테스트
    ├── survey_screen_test.dart         # 두피 설문 화면 테스트
    └── skin_survey_screen_test.dart    # 피부 설문 화면 테스트
```

---

## 색상 테마

| 기능 | 색상 |
|------|------|
| 두피 진단 | Teal (청록색) |
| 피부 진단 | Pink (분홍색) |
| 앱 기본 | Primary Teal |

---

## 앱 화면 흐름

```
스플래시 화면
    ↓
로그인 화면 ──→ 회원가입
    ↓
메인 화면 (하단 탭바)
    ├── 홈 (대시보드)
    │     ├── 두피 진단 버튼 → 두피 설문 (6단계) → 결과 화면 → 홈
    │     └── 피부 진단 버튼 → 피부 설문 (7단계) → 결과 화면 → 홈
    ├── 진단 (카메라)
    ├── 추천 (제품)
    ├── 케어팁
    └── 마이페이지 → 로그아웃 → 로그인 화면
```

---

## 데이터 모델

### 두피 설문 데이터 (SurveyData)
- 기본정보: 개인정보 동의, 성별, 연령대
- 두피 고민: 비듬, 가려움, 탈모, 지성, 건조함, 냄새, 뾰루지, 붉음/염증 (1-5점)
- 생활습관: 샴푸 주기, 펌/염색 주기, 수면시간, 스트레스, 음주, 흡연
- 알레르기: 특정 성분, 두피 질환
- AI 진단: 지성지수, 민감도, 비듬지수, 탈모위험도, 개선등급
- 추천 조건: 두피타입, 제품유형, 가격대, 향

### 피부 설문 데이터 (SkinSurveyData)
- 기본정보: 개인정보 동의, 성별, 연령대, 피부타입
- 피부 고민: 기미, 잡티, 주근깨, 색소침착, 홍조, 모공, 피부결, 여드름, 주름 (1-5점)
- AI 진단: 색소지수, 홍조지수, 모공지수, 주름지수, 수분지수, 유분지수
- 사용 제품: 클렌저, 토너, 에센스, 앰플, 크림, 선크림, 미백, 각질제거
- 개선 목표: 기미개선, 미백, 탄력, 주름, 홍조, 모공, 피지, 보습
- 추천 조건: 제형 선호, 가격대, 알레르기 성분

---

## 향후 개발 예정

- [ ] 서버 API 연동
- [ ] AI 카메라 촬영 분석
- [ ] 제품 추천 기능
- [ ] 진단 기록 저장/조회
- [ ] 푸시 알림
- [ ] 소셜 로그인 (카카오, 네이버, 구글)

---

## 문의

개발 관련 문의사항은 담당자에게 연락 바랍니다.
