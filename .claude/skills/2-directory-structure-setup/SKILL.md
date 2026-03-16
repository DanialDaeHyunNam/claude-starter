# 2. Directory Structure Setup

1번에서 정의한 프로젝트의 폴더 구조를 생성하고 독립 git repo로 초기화하는 단계입니다.

## When to Use

- 사용자가 `/2-directory-structure-setup` 을 입력했을 때

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 2: 프로젝트 폴더 구조 만들기

```
projects/{프로젝트명}/
├── 📁 src/
│   ├── 📁 app/           ← 페이지들이 들어가는 곳
│   │   ├── layout.tsx       (모든 페이지의 기본 틀)
│   │   ├── page.tsx         (첫 화면)
│   │   └── 📁 api/         (서버 기능)
│   ├── 📁 components/    ← 버튼, 카드 같은 UI 부품
│   ├── 📁 lib/           ← 도구 모음 (유틸리티)
│   ├── 📁 hooks/         ← 재사용 로직
│   └── 📁 types/         ← 타입 정의
├── 📁 prisma/            ← DB 설계도
├── 📁 public/            ← 이미지, 아이콘
├── 📄 package.json       ← 프로젝트 정보 + 의존성
├── 📄 CLAUDE.md          ← Claude 설계도 (1번에서 만든 것)
└── 📄 .gitignore
```

**쉽게 말하면:**
서류 정리할 때 폴더를 나눠서 보관하죠?
"계약서는 이 서랍, 영수증은 저 서랍" 이런 식으로요.

코드도 마찬가지예요:
- **app/** = 웹사이트의 각 페이지 (홈, 로그인, 마이페이지...)
- **components/** = 레고 블록처럼 조립해서 쓰는 UI 부품들
- **lib/** = 여기저기서 공통으로 쓰는 도구함
- **prisma/** = 데이터베이스 설계도 (어떤 데이터를 어떻게 저장할지)
- **public/** = 로고, 사진 같은 파일들

이 구조가 잡혀있어야 Claude가 "아, 이 코드는 여기에 넣어야겠구나" 하고 판단할 수 있어요.

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

"더 설명해주세요"를 선택하면 사용자의 추가 질문에 **어린아이도 이해할 수 있는 비유**로 답변한 뒤, 다시 같은 AskUserQuestion을 반복하세요.

### Step 3: 프로젝트 폴더 확인

1번 step에서 만든 프로젝트 폴더와 CLAUDE.md가 있는지 확인합니다.

Bash 도구로 실행:
```bash
ls projects/*/CLAUDE.md 2>/dev/null
```

- 프로젝트 폴더가 없으면: "먼저 `/1-claude-md-setup`을 실행해주세요" 안내 후 중단
- 여러 프로젝트가 있으면: AskUserQuestion으로 어떤 프로젝트를 설정할지 선택

프로젝트의 CLAUDE.md를 읽어서 핵심 기능 목록과 기술 스택을 파악하세요.

### Step 4: Next.js 프로젝트 생성

해당 프로젝트 폴더 안에서 Next.js 프로젝트를 생성합니다.

```bash
cd projects/{프로젝트명}
bunx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir --import-alias "@/*" --use-bun
```

주의: `.` (현재 디렉토리)에 생성하여 CLAUDE.md가 있는 폴더에 바로 설치합니다.
CLAUDE.md가 덮어쓰여지지 않도록 주의하세요. 혹시 덮어쓰여졌다면 1번에서 만든 내용으로 복원합니다.

### Step 5: 추가 폴더 구조 생성

create-next-app이 만들지 않는 폴더들을 추가로 생성합니다.
CLAUDE.md에서 파악한 핵심 기능에 맞춰 구조를 확장하세요.

```bash
cd projects/{프로젝트명}

# 기본 추가 폴더
mkdir -p src/components/ui
mkdir -p src/components/layout
mkdir -p src/components/common
mkdir -p src/lib
mkdir -p src/hooks
mkdir -p src/types
mkdir -p src/styles
mkdir -p prisma

# 핵심 기능별 폴더 (CLAUDE.md 기반으로 판단)
# 예: 인증 기능이 있으면
mkdir -p src/app/(auth)/login
mkdir -p src/app/(auth)/register

# 예: 대시보드가 있으면
mkdir -p src/app/(dashboard)/dashboard

# 예: API가 있으면
mkdir -p src/app/api
```

각 주요 폴더에 `.gitkeep` 파일을 생성하여 빈 폴더도 git에 추적되도록 합니다:
```bash
find src -type d -empty -exec touch {}/.gitkeep \;
```

### Step 6: 핵심 의존성 설치

CLAUDE.md의 기술 스택을 기반으로 필요한 패키지를 설치합니다.

```bash
cd projects/{프로젝트명}

# shadcn/ui 초기화
bunx shadcn@latest init -y

# Prisma (DB ORM)
bun add prisma @prisma/client
bunx prisma init

# 기타 공통 유틸리티
bun add clsx tailwind-merge lucide-react
bun add -D @types/node
```

CLAUDE.md에서 Auth가 명시되어 있으면:
```bash
bun add next-auth
# 또는
bun add @clerk/nextjs
```

### Step 7: Claude 스킬 + 플러그인 설정 복사

이 레포(claude-starter)의 `.claude/` 설정을 수강생의 프로젝트에 복사합니다.
수강생이 프로젝트 폴더에서 Claude Code를 실행해도 동일한 skill과 플러그인을 쓸 수 있도록 합니다.

```bash
cd projects/{프로젝트명}

# .claude 디렉토리 생성
mkdir -p .claude/skills

# skill 복사 (이 레포의 skill들을 그대로)
cp -r ../../.claude/skills/* .claude/skills/

# 플러그인 설정 복사
cp ../../.claude/settings.json .claude/settings.json
```

복사 후 프로젝트에 불필요한 skill이 있으면 제거합니다:
- `0-local-setup`은 이미 완료되었으므로 제거해도 됨 (선택사항)
- 나머지 skill은 프로젝트에서도 유용하므로 유지

사용자에게 안내:
```
강의에서 쓰던 슬래시 커맨드(/help-claude, /wrap-up, /plugin-guide 등)를
이 프로젝트 폴더에서도 그대로 사용할 수 있어요!
```

### Step 8: 독립 git repo 초기화

프로젝트 폴더를 독립적인 git 저장소로 초기화합니다.

```bash
cd projects/{프로젝트명}
git init
git add .
git commit -m "Initial project setup with Next.js + TypeScript + Tailwind + shadcn/ui"
```

사용자에게 설명:
```
이 프로젝트 폴더는 이제 독립적인 git 저장소예요.
강의 도구(claude-starter)와는 완전히 분리되어 있습니다.
나중에 GitHub에 올릴 때 이 폴더만 올라갑니다.
```

### Step 9: CLAUDE.md 업데이트

프로젝트 구조가 확정되었으므로, CLAUDE.md의 "프로젝트 구조" 섹션을 실제 생성된 구조로 업데이트합니다.

Bash 도구로 현재 구조를 확인:
```bash
cd projects/{프로젝트명}
find . -type f -not -path './node_modules/*' -not -path './.git/*' -not -path './.next/*' | sort | head -50
```

이 결과를 기반으로 CLAUDE.md의 프로젝트 구조 섹션을 수정하세요.

### Step 10: 최종 확인

생성된 구조를 트리 형태로 보여주고, dev 서버가 정상 동작하는지 확인합니다.

```bash
cd projects/{프로젝트명}
bun run dev &
sleep 3
curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
kill %1 2>/dev/null
```

결과를 사용자에게 보여주세요:

```
✅ Step 2 완료! 프로젝트 폴더 구조가 생성되었습니다.

📁 projects/{프로젝트명}/
   ├── Next.js + TypeScript + Tailwind 설치 완료
   ├── shadcn/ui 초기화 완료
   ├── Prisma 설치 완료
   ├── 독립 git repo 초기화 완료
   └── dev 서버 정상 동작 확인 ✅ (http://localhost:3000)

다음 단계: /3-mcp-setup 을 입력해주세요.
```
