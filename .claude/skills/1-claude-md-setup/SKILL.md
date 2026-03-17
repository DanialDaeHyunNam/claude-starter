# 1. CLAUDE.md Setup

프로젝트의 방향을 정하고 CLAUDE.md를 생성하는 단계입니다.

## When to Use

- 사용자가 `/1-claude-md-setup` 을 입력했을 때

## Instructions

### Step 0 (조용히): 추적 시작

```bash
bash scripts/track.sh update 1-claude-md-setup started
```

> 이 단계는 사용자에게 보여주지 않습니다. `.fearnot/participant.json`이 없으면 자동 스킵됩니다.

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 1: 프로젝트 방향 잡기 + CLAUDE.md 만들기

```
여러분이 만들고 싶은 것          CLAUDE.md (설계도)
┌──────────────────┐         ┌────────────────────────┐
│ "배달 앱 만들고    │         │ 프로젝트명: 우리동네배달  │
│  싶어요"          │  ──→    │ 폴더명: neighborhood-   │
│                  │  질문    │         delivery        │
│  (막연한 아이디어)  │  & 정리  │ 목표: 동네 음식점 배달    │
└──────────────────┘         │ 대상: 자영업자 + 고객     │
                             │ 기술: Next.js + ...     │
                             └────────────────────────┘
```

**쉽게 말하면:**
집을 지으려면 설계도가 필요하죠? CLAUDE.md가 바로 그 설계도예요.
"이런 앱 만들고 싶어요"라는 막연한 아이디어를 구체적인 설계도로 바꾸는 단계입니다.

이 설계도가 있으면 Claude가 여러분의 프로젝트를 정확히 이해하고,
앞으로 모든 단계에서 이 설계도를 보고 일합니다.

- **CLAUDE.md** = Claude에게 주는 프로젝트 설계도
- 이 파일이 있으면 Claude가 "아, 이 프로젝트는 이런 거구나" 하고 바로 이해합니다
- 매번 처음부터 설명할 필요가 없어져요

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

"더 설명해주세요"를 선택하면 사용자의 추가 질문에 **어린아이도 이해할 수 있는 비유**로 답변한 뒤, 다시 같은 AskUserQuestion을 반복하세요.

### Step 3: 어떤 프로덕트를 만들 것인지 논의

**clarify:vague skill을 호출**하여 사용자의 프로덕트 아이디어를 구체화합니다.

Skill 도구를 사용하여 `/clarify:vague`를 실행하세요.

clarify:vague가 완료되면 아래를 조용히 실행하세요 (사용자에게 보여주지 않음):

```bash
bash scripts/track.sh event 1-claude-md-setup idea-clarified
```

아래 정보가 정리되어야 합니다:
- **프로젝트명**: 무엇을 만드는지 한 줄 이름
- **목표**: 이 프로덕트가 해결하려는 문제
- **대상 사용자**: 누가 쓰는 서비스인지
- **핵심 기능**: 반드시 있어야 하는 기능 목록 (3~7개)
- **기술 스택**: 사용할 기술 (기본: Next.js + TypeScript + Tailwind + shadcn/ui + Prisma/Drizzle + Auth + DB)
- **제외 범위**: 이번에는 안 만들 것

### Step 4: 프로젝트 디렉토리명 확정 (kebab-case 필수)

clarify:vague 결과에서 프로젝트명이 정해졌으면, 이를 **kebab-case 디렉토리명**으로 변환합니다.
이 이름은 그대로 GitHub 레포명이 되므로 반드시 올바른 형식이어야 합니다.

**규칙:**
- 영문 소문자 + 하이픈만 사용 (예: `neighborhood-delivery`, `pet-care-app`)
- 한글 프로젝트명이면 영어로 번역하여 kebab-case 변환
- 2~4 단어가 적당 (너무 길지 않게)
- 숫자, 언더스코어, 대문자, 공백, 특수문자 금지

AskUserQuestion으로 확인하세요:

- question: "프로젝트 폴더명(= GitHub 레포명)을 아래와 같이 정할까요?"
- header: "프로젝트명"
- options:
  - label: "{자동 변환된 kebab-case 이름}" / description: "이 이름으로 projects/{name}/ 폴더가 만들어지고, 나중에 GitHub 레포명도 이 이름이 됩니다"
  - label: "다른 이름으로 할래요" / description: "원하는 이름을 직접 입력해주세요 (영문 소문자-하이픈만 사용)"

**"다른 이름으로"** 선택 시:
- 사용자 입력을 받아 kebab-case 규칙에 맞는지 검증
- 맞지 않으면 자동 변환하여 다시 확인: "입력하신 'My App'을 'my-app'으로 변환했습니다. 이대로 할까요?"
- 규칙에 맞을 때까지 반복

**반드시 kebab-case가 확정된 후에만 다음 step으로 진행하세요.**

프로젝트명이 확정되면 조용히 실행하세요 (사용자에게 보여주지 않음):

```bash
bash scripts/track.sh event 1-claude-md-setup project-named "{프로젝트명}"
```

### Step 5: 프로젝트 폴더 + CLAUDE.md 생성

확정된 kebab-case 이름으로 프로젝트 폴더를 만들고 CLAUDE.md를 생성합니다.

**중요 원칙:**
- 모든 수강생 작업 파일은 반드시 `projects/{프로젝트명}/` 하위에만 생성
- 이 레포(`claude-starter`) 루트에는 어떤 파일도 생성/수정하지 않음
- `projects/`는 `.gitignore`에 포함되어 있어 이 레포의 git에 영향 없음

Bash 도구로 실행:
```bash
mkdir -p projects/{프로젝트명}
```

그 다음 `projects/{프로젝트명}/CLAUDE.md`를 Write 도구로 생성합니다.

아래 템플릿을 기반으로 작성하되, clarify:vague에서 정리된 내용으로 채우세요:

```markdown
# {프로젝트 한글명} ({kebab-case-name})

## 프로젝트 개요
{목표와 해결하려는 문제를 2~3문장으로}

## 대상 사용자
{누가 쓰는지, 어떤 상황에서 쓰는지}

## 핵심 기능
1. {기능 1}: {한 줄 설명}
2. {기능 2}: {한 줄 설명}
3. ...

## 기술 스택
- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS + shadcn/ui
- **Database**: {선택된 DB} + {ORM}
- **Auth**: {선택된 인증 방식}
- **Deployment**: Vercel

## 프로젝트 구조
```
{kebab-case-name}/
├── src/
│   ├── app/          # Next.js App Router
│   ├── components/   # UI 컴포넌트
│   ├── lib/          # 유틸리티
│   └── ...
├── prisma/           # DB 스키마
├── public/           # 정적 파일
└── ...
```

## 코딩 컨벤션
- {4번 step에서 상세 설정 예정}

## 작업 원칙 (필수)

### 재사용성 최우선
- 문서/코드 모두 재사용성을 최우선으로 한다
- 상위 문서에 정의된 내용을 하위 문서에서 반복하지 않고 레퍼런스만 건다
- 문서/코드를 늘리고 확장하는 것에 극히 보수적으로 접근한다

### 임시 스크립트 관리
- 작업 수행 중 필요한 스크립트는 `.claude/temp/scripts/`에 생성한다
- 재사용성이 없는 1회성 스크립트는 작업 완료 후 반드시 삭제한다

### 디버깅 원칙
- 오류 수정 시 반드시 가설을 하나 세우고, print/console.log로 해당 가설만 검증한다
- 가설이 맞으면 수정, 틀리면 다음 가설로 넘어간다
- 한 번에 여러 가설을 동시에 테스트하지 않는다 (1가설 1검증)

## 제외 범위 (이번에는 안 만듦)
- {제외 항목들}

## 다음 단계
- `/2-directory-structure-setup` 으로 프로젝트 폴더 구조를 생성하세요
```

### Step 6: 생성 확인

CLAUDE.md가 정상적으로 생성되었는지 확인하고, 내용을 사용자에게 보여주세요.

완료 추적 (조용히):
```bash
bash scripts/track.sh event 1-claude-md-setup idea-clarified && \
bash scripts/track.sh update 1-claude-md-setup completed
```

> 이 단계는 사용자에게 보여주지 않습니다.

```
✅ Step 1 완료!

📁 projects/{kebab-case-name}/CLAUDE.md 가 생성되었습니다.
   이제 Claude가 여러분의 프로젝트를 이해합니다.

   참고: 여러분의 모든 작업은 projects/{kebab-case-name}/ 안에서 진행됩니다.
   이 강의 레포(claude-starter)의 파일은 건드리지 않아요.

   만약 강의 도구에서 버그나 개선점을 발견하면,
   이 레포에 PR을 올려서 공유해주세요! 🙌

   다음 단계: /2-directory-structure-setup 을 입력해주세요.
```

### 트러블슈팅 PR 안내

수강생이 강의 도구(scripts/, .claude/ 등)에서 문제를 발견했을 때:
1. 이 레포에서 새 브랜치를 만들고 (`git checkout -b fix/이슈설명`)
2. 수정 후 PR을 올리도록 안내
3. PR 제목 형식: `[fix] 이슈 설명` 또는 `[improve] 개선 설명`
4. 강사가 검토 후 유의미한 것들만 merge
