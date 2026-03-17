# Help Claude

수강생이 막힌 문제를 해결해주는 트러블슈팅 skill입니다.

## When to Use

- 사용자가 `/help-claude` 를 입력했을 때
- 사용자가 "도와줘", "안 돼요", "에러", "모르겠어요" 등 도움을 요청할 때

## Instructions

### Step 1: 공감 + 상황 파악 시작

먼저 사용자에게 공감하고, 문제를 좁혀나갈 것임을 안내하세요:

```
문제를 해결해드릴게요!
몇 가지 질문으로 정확한 원인을 찾아볼게요.
(최대 5개 질문이면 충분합니다)
```

### Step 2: 문제 영역 좁히기 (Funnel)

AskUserQuestion으로 광범위 → 구체적으로 질문합니다.

**2-1. 어떤 종류의 문제인지** (1차 분류)

- question: "어떤 종류의 문제인가요?"
- header: "문제 유형"
- options:
  - label: "에러가 떠요" / description: "빨간 글씨, 에러 메시지가 보임"
  - label: "동작이 안 돼요" / description: "에러는 없는데 원하는 대로 안 됨"
  - label: "어떻게 하는지 모르겠어요" / description: "방법 자체를 모름"
  - label: "설정/환경 문제" / description: "설치, 연결, 설정 관련"

**2-2. 선택에 따라 세부 질문** (2차 분류)

**"에러가 떠요"** 선택 시:
- question: "에러가 어디서 나나요?"
- options:
  - label: "터미널 (CLI)" / description: "명령어 실행할 때"
  - label: "브라우저" / description: "웹페이지에서"
  - label: "빌드/배포" / description: "bun run build 또는 배포할 때"
  - label: "모르겠어요" / description: "정확히 어딘지 모름"

**"동작이 안 돼요"** 선택 시:
- question: "어떤 동작이 안 되나요?"
- options:
  - label: "화면이 안 보여요" / description: "빈 페이지, 로딩만 됨"
  - label: "버튼/기능이 안 돼요" / description: "클릭해도 반응 없음"
  - label: "데이터가 안 나와요" / description: "목록이 비어있거나 저장이 안 됨"
  - label: "스타일이 이상해요" / description: "레이아웃, 색상 등이 의도와 다름"

**"어떻게 하는지 모르겠어요"** 선택 시:
- question: "어떤 작업을 하고 싶으신 건가요?"
- options:
  - label: "새 기능 추가" / description: "기존에 없는 기능을 만들고 싶음"
  - label: "기존 기능 수정" / description: "있는 기능을 바꾸고 싶음"
  - label: "특정 도구 사용법" / description: "Git, Vercel, Slack 등 사용법"
  - label: "다음 단계가 뭔지" / description: "지금 뭘 해야 할지 모르겠음"

**"설정/환경 문제"** 선택 시:
- question: "어떤 설정인가요?"
- options:
  - label: "설치가 안 됨" / description: "도구/패키지 설치 실패"
  - label: "연결이 안 됨" / description: "DB, API, MCP 등 연결 실패"
  - label: "환경 변수" / description: ".env 설정 관련"
  - label: "권한 문제" / description: "permission denied 등"

### Step 3: 구체적 상황 수집

2차 분류 결과를 바탕으로 AskUserQuestion 1~2개를 더 물어봅니다.

에러인 경우:
- "에러 메시지를 복사해서 붙여넣어 주시겠어요?" (자유 입력 유도)

동작 문제인 경우:
- "어떤 화면/페이지에서 문제가 생기나요?"

**총 질문 5개를 넘기지 않습니다.**

### Step 4: 진단

수집된 정보를 바탕으로 원인을 진단합니다.

**진단 시 반드시 지켜야 할 원칙:**

1. **가설을 하나 세운다** — "아마 {X} 때문일 것이다"
2. **해당 가설만 검증한다** — 관련 파일을 읽고, 필요시 console.log/print로 확인
3. **한 번에 하나만** — 여러 가설을 동시에 테스트하지 않음
4. **가설이 틀리면** — 다음 가설로 넘어감

사용자에게 진단 과정을 보여주세요:

```
🔍 진단 중...

가설: {원인 추정}
확인: {어떤 파일/설정을 확인하는지}
결과: {확인 결과}
```

### Step 5: 해결

원인이 파악되면 해결 방안을 제시하고 **직접 실행**합니다.

1. 사용자에게 무엇을 할 건지 설명
2. 필요한 코드 수정/명령어 실행
3. 수정 후 동작 확인

**임시 스크립트가 필요한 경우:**
```bash
mkdir -p .claude/temp/scripts
# 스크립트 생성 및 실행
# 완료 후 삭제
rm -rf .claude/temp/scripts/*
```

### Step 6: 해결 확인

AskUserQuestion으로 확인:
- question: "문제가 해결되었나요?"
- header: "해결 확인"
- options:
  - label: "해결됐어요!" / description: "감사합니다"
  - label: "아직 안 돼요" / description: "같은 문제가 계속되거나 다른 문제가 생김"
  - label: "다른 문제가 생겼어요" / description: "새로운 에러/문제가 발생"

"아직 안 돼요"이면 Step 4로 돌아가서 다음 가설로 진행.
"다른 문제가 생겼어요"이면 Step 2부터 새로 시작.

### Step 7: 마무리

해결되면:

```
✅ 문제가 해결되었습니다!

📋 요약:
  - 문제: {문제 설명}
  - 원인: {원인}
  - 해결: {무엇을 했는지}

💡 같은 문제를 예방하려면:
  - {예방 팁}

궁금한 게 더 있으면 언제든 /help-claude 를 입력해주세요!
```

이 해결 과정에서 강의 도구(claude-starter)의 버그를 발견했다면,
수강생에게 PR을 올리도록 안내:
```
이 문제는 강의 도구의 개선점이 될 수 있어요.
PR을 올려서 다른 수강생들도 도움받을 수 있게 해주시겠어요?
  git checkout -b fix/{간단한-설명}
  (수정 후)
  git add . && git commit -m "[fix] {설명}"
  git push -u origin fix/{간단한-설명}
  gh pr create
```
