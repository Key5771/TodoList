# TodoList 📝

iOS용 카테고리 기반 할 일 관리 애플리케이션

## 📱 프로젝트 개요

TodoList는 UIKit 기반의 iOS 애플리케이션으로, 카테고리별로 할 일을 체계적으로 관리할 수 있는 기능을 제공합니다. MVVM 아키텍처 패턴을 적용하여 코드의 가독성과 유지보수성을 높였으며, Core Data를 통한 로컬 데이터 저장을 지원합니다.

## ✨ 주요 기능

- **📂 카테고리 관리**: 할 일을 카테고리별로 분류하여 체계적인 관리
- **📝 할 일 추가/편집**: 직관적인 UI를 통한 쉬운 할 일 등록 및 수정
- **✅ 완료 상태 관리**: 할 일의 완료/미완료 상태 토글 기능 (영구 저장)
- **📊 섹션별 구분**: 할 일과 완료된 일을 별도 섹션으로 구분 표시
- **🔘 체크박스 UI**: 오른쪽 체크박스를 통한 직관적인 완료 상태 관리
- **🗑️ 삭제 기능**: ActionSheet를 통한 안전한 할 일 삭제
- **💾 영구 저장**: Core Data를 활용한 완료 상태 영구 보존
- **📈 진행 상황 추적**: 전체/진행중/완료 할 일 개수 표시
- **🎨 Code-based UI**: 프로그래밍 방식의 직관적인 인터페이스

## 🛠 기술 스택

### Frontend
- **언어**: Swift
- **UI 프레임워크**: UIKit
- **레이아웃**: Code-based UI + SnapKit
- **의존성 관리**: Swift Package Manager (SPM)

### Architecture & Libraries
- **아키텍처**: MVVM (Model-View-ViewModel)
- **데이터베이스**: Core Data
- **UI 라이브러리**: SnapKit (5.6.0+)
- **네비게이션**: 프로그래매틱 UINavigationController

### 개발 도구
- **IDE**: Xcode
- **의존성 관리**: Swift Package Manager
- **버전 관리**: Git

## 🏗 프로젝트 구조

```
TodoList/
├── TodoList/
│   ├── Model/
│   │   ├── CategoryModel.swift           # 카테고리 데이터 모델
│   │   ├── Todo+CoreDataClass.swift      # Todo Core Data 클래스
│   │   └── Todo+CoreDataProperties.swift # Todo Core Data 속성
│   ├── View/
│   │   ├── ViewController.swift          # 메인 화면 (카테고리 목록)
│   │   ├── CategoryViewController.swift  # 카테고리별 할 일 목록 (섹션별 구분)
│   │   ├── AddTodoViewController.swift   # 할 일 추가/편집
│   │   └── ContentViewController.swift   # 할 일 상세 보기
│   ├── ViewModel/
│   │   ├── ViewModel.swift              # 비즈니스 로직 처리
│   │   └── ContentViewModel.swift       # 콘텐츠 관련 로직
│   ├── Cell/
│   │   ├── CollectionViewCell/          # 카테고리 컬렉션 뷰 셀
│   │   └── TableViewCell/
│   │       └── ContentTableViewCell.swift # 할 일 테이블 뷰 셀 (체크박스 포함)
│   ├── App/
│   │   ├── AppDelegate.swift
│   │   └── SceneDelegate.swift
│   └── TodoList.xcdatamodeld/           # Core Data 모델
└── Tests/                              # 단위/UI 테스트
```

## 🚀 시작하기

### 필요 조건
- **Xcode**: 14.0+
- **iOS**: 14.0+
- **Swift**: 5.7+

### 설치 및 실행

1. **레포지토리 클론**
   ```bash
   git clone https://github.com/Key5771/TodoList.git
   cd TodoList
   ```

2. **프로젝트 열기**
   ```bash
   # Xcode에서 프로젝트 파일 열기
   open TodoList/TodoList.xcodeproj
   ```

3. **SPM 의존성 설치**
   - Xcode가 자동으로 Swift Package dependencies를 다운로드합니다
   - 수동으로 설치하려면: `File > Add Package Dependencies...`
   - SnapKit URL: `https://github.com/SnapKit/SnapKit`

4. **빌드 및 실행**
   - Xcode에서 타겟 디바이스/시뮬레이터 선택
   - `⌘ + R` 키로 앱 실행

### 🔧 SPM 의존성 관리

이 프로젝트는 **Swift Package Manager**를 사용합니다:

**설치된 패키지:**
- **SnapKit**: `https://github.com/SnapKit/SnapKit` (5.6.0+)

**새 의존성 추가 방법:**
1. Xcode에서 `File > Add Package Dependencies...`
2. Git URL 입력
3. 버전 설정 및 타겟 선택

## 📋 주요 화면 구성

### 🏠 **메인 화면 (카테고리 목록)**
- CollectionView를 통한 카테고리 격자 표시
- 각 카테고리별 할 일 개수 표시
- 설정 버튼을 통한 카테고리 관리
- Empty State 처리

### 📂 **카테고리 화면 (할 일 목록) - 📊 섹션별 구분**
- **할 일 섹션**: 미완료된 할 일 목록 표시
- **완료된 일 섹션**: 완료된 할 일 목록 표시  
- 각 섹션별 개수 표시 (예: "할 일 (3)", "완료된 일 (2)")
- 진행 상황 요약 (예: "3 pending, 2 completed")

### 🔘 **체크박스 기능**
- 각 할 일 오른쪽에 체크박스 배치
- 미완료: 빈 원 아이콘 (○)
- 완료: 채워진 체크 아이콘 (✓) - 초록색
- 터치 시 애니메이션 효과와 함께 상태 변경
- 완료된 할 일은 취소선 스타일 적용

### ➕ **할 일 추가 화면**
- 텍스트 입력을 통한 새 할 일 등록
- 카테고리 선택 기능
- 저장/취소 기능
- 새 할 일은 기본적으로 미완료 상태로 생성

### 📄 **할 일 상세 화면**
- 할 일 내용 상세 보기
- 생성 날짜 및 완료 날짜 표시
- 편집/삭제 기능
- ActionSheet를 통한 안전한 삭제 확인

## 🔧 주요 기술적 특징

### 📐 **MVVM 아키텍처**
- View와 비즈니스 로직의 명확한 분리
- ViewModel을 통한 데이터 바인딩
- 테스트 가능한 코드 구조

### 🗃️ **Core Data 활용**
- 오프라인 환경에서의 데이터 영속성
- Todo 엔티티에 `isCompleted`, `completedDate` 속성 추가
- 완료 상태 영구 저장 및 복구
- 관계형 데이터 모델링
- 효율적인 데이터 쿼리 및 관리

### 🎨 **Code-based UI + SnapKit**
- 100% 프로그래매틱 UI 구현
- SnapKit DSL을 통한 Auto Layout
- 가독성 높은 레이아웃 코드
- 다양한 화면 크기 대응

### 🧩 **현대적 iOS 디자인**
- SF Symbols 아이콘 사용 (체크박스, 아이콘 등)
- Dynamic Color 지원
- 스프링 애니메이션 효과
- 터치 피드백 및 상태 변화 애니메이션

### ✅ **완료 상태 관리 시스템**
- 실시간 완료 상태 토글
- Core Data에 즉시 저장
- 에러 발생 시 UI 상태 롤백
- 앱 재시작 후에도 완료 상태 유지

## 📈 개발 히스토리

### 🐛 **완료 상태 저장 버그 수정 (2025.09)**
- 할 일 완료 상태가 앱 재시작 후 초기화되는 문제 해결
- 오른쪽 체크박스 UI 추가로 사용자 경험 개선
- 할 일/완료된 일 섹션 구분 기능 추가
- Core Data 모델에 `isCompleted`, `completedDate` 속성 추가
- 완료 상태 변경 시 즉시 저장 로직 구현
- 섹션별 통계 및 진행 상황 표시

### 🔄 **SPM 전환 (2025.09)**
- CocoaPods → Swift Package Manager 마이그레이션
- 빌드 시간 단축 및 프로젝트 단순화
- 네이티브 의존성 관리 도구 사용

### 🎨 **Code-based UI 전환 (2025.09)**
- XIB 파일 완전 제거
- SnapKit 기반 프로그래매틱 UI 구현
- 모던한 iOS 디자인 시스템 적용

### 🏗️ **아키텍처 개선 (2023.06)**
- SnapKit 라이브러리 추가
- Storyboard → 프로그래매틱 네비게이션 전환
- MVVM 패턴 적용

### 🔧 **핵심 기능 구현 (2020.11)**
- ViewModel 생성 및 비즈니스 로직 분리
- CategoryModel 데이터 구조 설계
- 제네릭을 활용한 데이터 저장 함수 통일

### 🎨 **UI/UX 개선 (2020.10)**
- ActionSheet를 통한 삭제 확인 기능
- 카테고리 멀티라인 텍스트 지원
- TableView 구분선 최적화

## 🎯 학습 포인트

이 프로젝트를 통해 다음과 같은 iOS 개발 핵심 개념을 학습할 수 있습니다:

### 🏛️ **아키텍처 패턴**
- MVVM 패턴의 실제 적용
- 관심사의 분리 (Separation of Concerns)
- 의존성 관리 및 주입

### 📱 **UIKit 활용**
- UICollectionView와 UITableView 구현
- Custom Cell 디자인 및 구현 (체크박스 포함)
- 프로그래매틱 UI 구성
- 섹션 기반 테이블 뷰 관리

### 🗄️ **데이터 관리**
- Core Data 스택 구성
- 관계형 데이터 모델링
- 완료 상태 영구 저장
- 로컬 데이터 CRUD 연산
- NSFetchedResultsController 활용

### 🔧 **현대적 개발 도구**
- Swift Package Manager 활용
- SnapKit DSL 구문
- 프로그래매틱 Auto Layout

### 🎨 **사용자 경험 (UX)**
- 직관적인 체크박스 인터랙션
- 섹션별 데이터 구분 및 표시
- 애니메이션을 통한 피드백
- 진행 상황 시각화

## 🚧 향후 개선 계획

### ✨ **기능 확장**
- [ ] 할 일 우선순위 설정
- [ ] 날짜/시간 기반 알림 기능
- [ ] 할 일 검색 및 필터링
- [ ] 데이터 백업/복원 기능
- [x] 완료 상태 영구 저장 (완료)
- [x] 섹션별 할 일 구분 (완료)

### 🔄 **기술 업그레이드**
- [x] SPM 전환 완료
- [x] Code-based UI 전환 완료
- [x] 완료 상태 관리 시스템 구현
- [ ] SwiftUI 전환 검토
- [ ] Combine 프레임워크 도입
- [ ] 단위 테스트 커버리지 확대
- [ ] CI/CD 파이프라인 구축

### 🎨 **UX 개선**
- [ ] 다크 모드 지원
- [x] 애니메이션 효과 추가 (완료)
- [x] 체크박스 UI 개선 (완료)
- [ ] 접근성 기능 강화
- [ ] iPad 지원 최적화
- [ ] 스와이프 제스처 추가

## 🐛 해결된 이슈

### Issue #18: 완료된 할 일 상태 저장 문제 수정
- **문제**: 할 일 완료 후 앱 재시작 시 완료 상태가 초기화되는 버그
- **해결**: 
  - Core Data 모델에 `isCompleted`, `completedDate` 속성 추가
  - 체크박스 UI 구현 및 즉시 저장 로직 추가
  - 할 일/완료된 일 섹션 구분 기능 구현
  - 완료 상태 변경 시 즉시 Core Data 저장
  - 앱 생명주기에 따른 컨텍스트 저장 보장

## 📄 라이센스

이 프로젝트는 개인 학습 및 포트폴리오 목적으로 제작되었습니다.

## 📞 연락처

**Kim KiHyun (Key5771)**
- GitHub: [@Key5771](https://github.com/Key5771)
- Email: ksj57715@gmail.com

---

<div align="center">
  <p>📝 <strong>체계적인 할 일 관리로 더 나은 하루를!</strong></p>
  <p>✅ <strong>완료 상태 영구 저장으로 안정적인 진행 상황 관리</strong></p>
  <p>🚀 <strong>Swift Package Manager & Code-based UI로 현대적인 iOS 개발</strong></p>
</div>
