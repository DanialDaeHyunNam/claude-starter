# 7. Implement by Claude Teams

Claude Teams 기능을 활용하여 프로토타입을 실제 코드로 구현하는 단계입니다.

## When to Use

- 사용자가 `/7-implement-by-claude-teams` 을 입력했을 때

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 7: 본격 구현 (Claude Teams)

```
프로토타입 (시안)             실제 동작하는 앱
┌──────────────────┐       ┌──────────────────────┐
│ 📱 그림으로 된     │       │ 📱 진짜 클릭되고      │
│    화면 시안      │  ──→   │    데이터가 저장되고   │
│                  │ Claude │    로그인도 되는      │
│  (보기만 가능)     │ Teams  │    실제 웹사이트!     │
└──────────────────┘       └──────────────────────┘

Claude Teams가 역할을 나눠서 동시에 일합니다:
┌──────────────────────────────────────────┐
│  👤 Claude A: 프론트엔드 (화면 만들기)     │
│  👤 Claude B: 백엔드 (서버/DB 만들기)      │
│  👤 Claude C: 테스트 (동작 확인하기)       │
└──────────────────────────────────────────┘
```

**쉽게 말하면:**
시안(프로토타입)은 "이렇게 생기면 좋겠다"는 그림이었다면,
이번엔 **진짜 동작하는 웹사이트**를 만드는 거예요.

Claude Teams는 여러 Claude가 동시에 일하는 기능이에요.
한 명은 화면을, 한 명은 서버를, 한 명은 테스트를 맡아서
빠르게 만들어줍니다.

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

### Step 3: 구현 계획 수립

PRD와 프로토타입을 기반으로 구현 계획을 세웁니다.

1. `projects/{프로젝트명}/docs/PRD.md` 읽기
2. `projects/{프로젝트명}/CLAUDE.md` 읽기
3. 프로토타입 이미지 확인

Phase 1 (MVP) 기능부터 구현 순서를 정합니다.
각 기능을 **프론트엔드 / 백엔드 / 통합** 작업으로 분류합니다.

### Step 4: 구현 진행

PRD의 우선순위 순서대로 기능을 구현합니다.

각 기능마다:
1. **DB 스키마** 먼저 (Prisma)
2. **API 엔드포인트** (Next.js API Routes)
3. **화면 UI** (프로토타입 참고하여 컴포넌트 생성)
4. **연결** (화면 ↔ API)
5. **동작 확인** (`bun run dev`로 확인)

각 기능 구현 완료 후 사용자에게 확인:
- `bun run dev` 실행 → 브라우저에서 확인하도록 안내
- AskUserQuestion: "이 기능이 잘 동작하나요?" → "네" / "수정 필요"

### Step 5: 기능별 커밋

각 기능이 완료되고 확인되면 커밋합니다.

```bash
cd projects/{프로젝트명}
git add .
git commit -m "feat: {기능 설명}"
```

### Step 6: 최종 확인

모든 MVP 기능이 구현되면:

```bash
cd projects/{프로젝트명}
bun run build
```

빌드 성공 확인 후:

```
✅ 구현 완료!

🚀 구현된 기능:
  1. ✅ {기능 1}
  2. ✅ {기능 2}
  ...

  빌드 성공 확인 ✅
  로컬에서 확인: bun run dev → http://localhost:3000

이제 SEO + Analytics를 세팅합니다.
```

### Step 7: Growth Setup 호출

구현이 완료되었으므로 `/growth-setup` skill을 호출하여
SEO 메타태그, Google Analytics, Vercel Analytics를 세팅합니다.

> 이 단계에서 사용자와 함께 사이트 제목, 설명, GA ID 등을 설정합니다.

### Step 8: 최종 확인

`/growth-setup` 완료 후:

```
✅ Step 7 완료! 앱 구현 + 성장 도구 세팅이 완료되었습니다.

🚀 구현된 기능: {N}개
🔍 SEO 세팅 완료
📊 Analytics 세팅 완료

다음 단계: /8-github-ci-cd-setup 을 입력해주세요.
```
