# 4. Critical Ground Rule Setup

코딩 컨벤션, Claude 협업 규칙, 프로젝트 운영 규칙을 설정하는 단계입니다.

## When to Use

- 사용자가 `/4-critical-ground-rule-setup` 을 입력했을 때

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 4: 규칙 세우기 (Ground Rules)

```
규칙 없이 일하면             규칙 세우고 일하면
┌──────────────────┐       ┌──────────────────────┐
│ 들쭉날쭉한 코드    │       │ 일관된 코드 스타일      │
│ Claude가 매번 다르게│       │ Claude가 항상 같은 방식 │
│ 파일 어디있는지 혼란│       │ 파일 위치 규칙 명확     │
│ 배포할 때 에러 폭발 │       │ 자동 검사로 에러 방지   │
└──────────────────┘       └──────────────────────┘
```

**쉽게 말하면:**
축구도 규칙이 있어야 경기가 되죠?
코딩도 마찬가지예요. 규칙을 세워두면:
1. Claude가 항상 같은 스타일로 코드를 짜요 (읽기 편함)
2. 실수를 자동으로 잡아줘요 (버그 방지)
3. 팀으로 일할 때 혼란이 없어요

3가지 규칙을 설정할 거예요:
- **코딩 컨벤션** = 코드 작성 규칙 (기본 설정 → 수정 위치 안내)
- **Claude 협업 규칙** = Claude에게 주는 작업 지시서 (함께 논의)
- **프로젝트 운영 규칙** = 브랜치, 배포 정책 (기본 설정 → 수정 위치 안내)

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

### Step 3: 프로젝트 폴더 확인

현재 작업 디렉토리가 프로젝트 폴더인지 확인합니다 (`CLAUDE.md`와 `package.json`이 함께 존재하는지).
없으면 "먼저 claude-starter에서 `/1-claude-md-setup`과 `/2-directory-structure-setup`을 실행하고 생성된 프로젝트 폴더로 이동해주세요"라고 안내.

### Step 4: 코딩 컨벤션 (기본 설정 + 안내)

비개발자 대상이므로 기본값을 자동 설정하고, 수정 방법만 안내합니다.

프로젝트 폴더에 아래 파일들을 생성/수정:

**4-1. ESLint 설정** (`eslint.config.mjs` 또는 `.eslintrc.json`)
- Next.js 기본 + 약간 엄격한 규칙
- 생성 후 사용자에게: "코드 규칙을 바꾸고 싶으면 이 파일을 수정하면 돼요"

**4-2. Prettier 설정** (`.prettierrc`)
```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100
}
```
- 생성 후 사용자에게: "코드 모양(들여쓰기, 따옴표 등)을 바꾸고 싶으면 이 파일이에요"

**4-3. Prettier 설치**
```bash
bun add -D prettier eslint-config-prettier
```

사용자에게 안내:
```
코딩 컨벤션이 기본값으로 설정되었어요.
나중에 바꾸고 싶으면:
- 코드 규칙: eslint.config.mjs (또는 .eslintrc.json)
- 코드 모양: .prettierrc
이 파일들을 수정하면 됩니다.
```

### Step 5: Claude 협업 규칙 (상세 논의)

이 부분은 사용자와 함께 논의하여 결정합니다.
프로젝트의 CLAUDE.md에 "Claude 협업 규칙" 섹션을 추가합니다.

AskUserQuestion으로 핵심 사항을 하나씩 물어보세요:

**5-1. 응답 언어**
- question: "Claude가 어떤 언어로 응답하면 좋을까요?"
- options:
  - label: "한국어" / description: "코드 주석, 커밋 메시지, 설명 모두 한국어"
  - label: "영어" / description: "모든 것을 영어로"
  - label: "혼합" / description: "설명은 한국어, 코드/커밋은 영어"

**5-2. 코드 스타일 선호**
- question: "Claude가 코드를 짤 때 어떤 스타일을 선호하시나요?"
- options:
  - label: "간결하게 (추천)" / description: "필요한 것만 딱, 주석 최소화"
  - label: "친절하게" / description: "주석 많이, 설명 많이"
  - label: "Claude한테 맡길게요" / description: "상황에 맞게 알아서"

**5-3. 작업 단위**
- question: "Claude가 한 번에 얼마나 작업하면 좋을까요?"
- options:
  - label: "작은 단위 (추천)" / description: "기능 하나씩 만들고 확인하면서 진행"
  - label: "큰 단위" / description: "여러 기능을 한꺼번에 만들기"

논의 결과를 CLAUDE.md의 협업 규칙 섹션에 반영:

```markdown
## Claude 협업 규칙

### 응답 언어
- {선택 결과}

### 코드 스타일
- {선택 결과}

### 작업 방식
- {선택 결과}
- 작업 전 계획을 먼저 공유하고 확인 후 진행
- 파일 수정 전 반드시 해당 파일을 먼저 읽을 것
- 한 번에 너무 많은 파일을 수정하지 말 것
```

### Step 6: 프로젝트 운영 규칙 (기본 설정 + 안내)

비개발자 대상이므로 기본값을 자동 설정하고, 수정 방법만 안내합니다.

CLAUDE.md에 운영 규칙 섹션을 추가:

```markdown
## 프로젝트 운영 규칙

### Git 브랜치 전략
- `main`: 배포되는 브랜치 (직접 푸시 금지)
- `develop`: 개발 브랜치
- `feature/{기능명}`: 기능 개발 브랜치
- `fix/{버그명}`: 버그 수정 브랜치

### 커밋 메시지 규칙
- feat: 새 기능
- fix: 버그 수정
- docs: 문서 수정
- style: 코드 스타일 변경
- refactor: 리팩토링

### 배포 정책
- develop → main PR 후 Vercel 자동 배포
```

사용자에게 안내:
```
프로젝트 운영 규칙이 기본값으로 설정되었어요.
나중에 바꾸고 싶으면 CLAUDE.md의 "프로젝트 운영 규칙" 섹션을 수정하면 됩니다.
```

### Step 7: 최종 확인

설정된 모든 규칙을 요약해서 보여주세요.

```
✅ Step 4 완료! Ground Rules가 설정되었습니다.

📋 설정된 규칙:
  1. 코딩 컨벤션: ESLint + Prettier (기본값)
     수정: .eslintrc.json / .prettierrc
  2. Claude 협업 규칙: {요약}
     수정: CLAUDE.md → "Claude 협업 규칙"
  3. 프로젝트 운영 규칙: Git Flow + 커밋 컨벤션 (기본값)
     수정: CLAUDE.md → "프로젝트 운영 규칙"

다음 단계: /5-detail-prd 를 입력해주세요.
```
