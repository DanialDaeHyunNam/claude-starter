---
name: prd-collab
description: PRD 협업 워크플로우. 추상→구체 12단계로 하나의 유저 경험 단위 기획을 완성.
argument-hint: "[feature-name] or empty to start fresh"
---

# PRD Collaboration Skill

사용자와 AI가 함께 기획을 구체화하는 워크플로우.
추상도가 높은 것부터 확정하며, 위 단계일수록 변경 비용이 높으므로 먼저 합의해야 함.

## Usage
- `/prd-collab` — 새 기획 시작
- `/prd-collab {feature-name}` — 기존 기획 이어서 작업

## 12-Step Framework

의사결정이 어려울 때는 항상 위 단계부터 만족하는지 확인하여 논의한다.

### Step 0. Feature Hierarchy (어디에 속하는 기능인가?)
- 이 기능이 프로덕트 내 어디에 속하는지 확정
- 예: home, onboarding, dashboard, settings, auth ...
- `docs/prd/{feature-hierarchy}/` 폴더 결정

### Step 1. User Goal (사용자의 최종 목표)
- **절대 변경 불가** 수준의 최상위 목표
- 예: "나에게 맞는 커리어 전환 경로를 가장 빠르게 찾는 것"

### Step 2. How This Helps (이 기획이 User Goal을 어떻게 돕는가)
- 이 기능이 1번 목표에 기여하는 메커니즘
- 거의 변경되지 않아야 함

### Step 3. Emotional Journey (유저가 느껴야 하는 감정과 순서)
- 기능을 봤을 때 유저의 순간적 감정 흐름
- 예: 호기심 → 몰입 → 발견의 기쁨 → "이거 진짜 되네" → 다음 행동 욕구
- 거의 변경되지 않아야 함

### Step 4. Internal Feature Name (내부 기능명)
- 프로젝트 내 공식 명칭 확정 (screening, report, booking 등)
- 4번부터는 아래 단계 작업 중 수정될 수 있음

### Step 5. Functional Requirements (기능 요구사항, 디자인 없이)
- 번호 매기기: 1. OO이 가능해야 한다. 2. ...
- 디자인/레이아웃과 무관하게 기능만 정의

### Step 6. Existing vs New Screen (기존 화면 추가 vs 신규 화면)
- 기존 화면에 추가되는가? 완전히 새로운 화면인가?

### Step 7-1. (기존 화면 추가인 경우) Context & Hierarchy
- 해당 화면 내 다른 기능과의 관계
- 어떤 게 우선되는가
- 어떤 점에서 Step 1을 더 강화하는가
- 다른 화면의 기능 디자인이 변경되어야 할 요소는 없는가
- 다른 기능들 속에서 이 기능의 위계는?

### Step 7-2. (신규 화면인 경우) Access Flow
- 접근 flow는 어떻게 되는가
- 퍼널 역할은 기존 화면에 들어가는가
- 진입점, 이탈점 정의

### Step 8. Screen Inventory (화면 종류 및 개수 확정)
- 각 화면별 정보 위계
- 요구사항 이터레이션 통해 확정

### Step 9. Wireframe Iteration (와이어프레임)
- Pencil로 저해상도 와이어프레임 (박스 + 텍스트만, 색상/이미지 없음)
- 데스크톱(1440px) + 모바일(414px) 동시
- 구조 확정까지 이터레이션

### Step 10. UX Writing Iteration (UXW)
- 실제 텍스트 작성 및 톤 확정
- CTA, 에러 메시지, 빈 상태 등 모든 텍스트 포함
- 대상 사용자 눈높이에 맞는 언어 사용

### Step 11. High-Fidelity Design (하이파이 디자인)
- 스타일 가이드 적용, 정확한 색상, 실제 이미지/아이콘
- 기존 구현된 코드가 있으면 해당 CSS 값 기반으로 작업
- 최종 이터레이션 및 확정

## Iteration Rules

- **인접 단계 간 수정 이터레이션 허용**: 특히 9번 하다보면 5번부터 수정되는 과정이 발생할 수 있음
- **Step 1은 절대 변경 불가**
- **Step 2, 3은 거의 변경 없음** (흔들림이 없어야 함)
- **Step 4부터는 디테일** — 아래 단계에서 서로 영향을 많이 받음

## Execution Procedure

### When starting fresh (`/prd-collab`):

1. **AskUserQuestion**: "어떤 기능을 기획할까요? 간단히 설명해주세요."
2. Step 0부터 순서대로 진행
3. 각 단계마다 초안 작성 → 사용자에게 확인/수정 요청
4. 합의된 내용을 즉시 PRD 파일에 저장
5. 다음 단계로 진행

### When resuming (`/prd-collab {feature-name}`):

1. `docs/prd/{feature-hierarchy}/{feature-name}-v*.md` 에서 최신 버전 읽기
2. 현재까지 확정된 단계 파악
3. 다음 미완료 단계부터 이어서 진행

### PRD File Management

**파일 경로**: `docs/prd/{feature-hierarchy}/{feature-name}-v{version}.md`
- 예: `docs/prd/onboarding/screening-v0.md` → `docs/prd/onboarding/screening-v1.md`
- 메이저 변경 시 버전 올림 (기존 파일 유지)

**파일 포맷**:
```markdown
# {Feature Name}

## Step 0. Feature Hierarchy
{feature-hierarchy}

## Step 1. User Goal
{확정된 내용}

## Step 2. How This Helps
{확정된 내용}

## Step 3. Emotional Journey
{확정된 내용}

## Step 4. Internal Feature Name
{확정된 내용}

## Step 5. Functional Requirements
1. ...
2. ...

## Step 6. Existing vs New Screen
{확정된 내용}

## Step 7. Context & Hierarchy / Access Flow
{확정된 내용}

## Step 8. Screen Inventory
{확정된 내용}

## Step 9. Wireframe
- Desktop: {Pencil frame ID or name}
- Mobile: {Pencil frame ID or name}

## Step 10. UX Writing
{확정된 내용}

## Step 11. High-Fidelity Design
- Desktop: {Pencil frame ID or name}
- Mobile: {Pencil frame ID or name}

---
**Status**: Step {N} 진행 중
**Last Updated**: YYYY-MM-DD
**Pencil File**: {파일명.pen}
```

### Each Step Interaction Pattern

각 단계에서:
1. 해당 단계의 초안을 작성하여 제시
2. 사용자에게 **구체적 질문**과 함께 확인 요청
3. 피드백 반영 후 재제시 (필요 시)
4. 합의되면 PRD 파일에 저장하고 다음 단계로

**금지**: 한 번에 여러 단계를 건너뛰어 진행하지 않는다. 반드시 한 단계씩.

## Rules

- 각 단계 합의 전에 다음 단계로 넘어가지 않는다
- Step 9부터는 반드시 Pencil 디자인 포함 (데스크톱 + 모바일)
- PRD 파일은 매 단계 합의 후 즉시 업데이트
- 이전 단계 수정이 필요하면 사용자에게 먼저 알리고 합의 후 수정
