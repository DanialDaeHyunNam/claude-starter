# 6. Prototype

Pencil MCP를 사용하여 PRD 기반 프로토타입을 만드는 단계입니다.

## When to Use

- 사용자가 `/6-prototype` 을 입력했을 때

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 6: 프로토타입 만들기 (Pencil)

```
PRD (기획서)               프로토타입 (시안)
┌──────────────────┐     ┌──────────────────────┐
│ 홈 화면:          │     │ ┌─────────────────┐  │
│  - 검색바         │     │ │ 🔍 검색...       │  │
│  - 상품 카드 목록  │ ──→  │ ├─────────────────┤  │
│  - 하단 네비       │     │ │ 📦 상품1  ₩15,000│  │
│                  │     │ │ 📦 상품2  ₩22,000│  │
│  (글로 된 설명)    │     │ │ 🏠 🔍 👤 🛒     │  │
└──────────────────┘     │ └─────────────────┘  │
                         └──────────────────────┘
                           (눈으로 보이는 시안)
```

**쉽게 말하면:**
기획서가 "거실에 소파를 놓겠다"는 글이라면,
프로토타입은 **인테리어 시뮬레이션 이미지**예요.
실제로 만들기 전에 "이렇게 생겼으면 좋겠다"를 미리 보는 거죠.

Pencil이라는 도구로 각 화면의 시안을 만들면:
- "이 버튼은 여기 말고 저기가 낫겠다" 같은 피드백을 미리 할 수 있어요
- 코딩 시작 전에 방향을 잡으니까 나중에 뒤집을 일이 줄어요

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

### Step 3: PRD 읽기

현재 프로젝트 폴더의 `docs/PRD.md`를 읽어서 화면 목록과 각 화면의 구성 요소를 파악합니다.

PRD가 없으면 `/5-detail-prd`를 먼저 실행하도록 안내.

### Step 4: Pencil로 프로토타입 생성

Pencil MCP 도구를 사용하여 PRD의 각 화면을 프로토타이핑합니다.

**진행 순서:**
1. `get_editor_state`로 현재 Pencil 상태 확인
2. `open_document`로 새 .pen 파일 생성 (또는 기존 파일 열기)
3. `get_guidelines`로 디자인 가이드라인 가져오기 (topic: "web-app" 또는 "mobile-app")
4. `get_style_guide_tags` → `get_style_guide`로 스타일 가이드 참고
5. PRD의 화면 목록 순서대로 `batch_design`으로 화면 생성

**각 화면마다:**
1. `find_empty_space_on_canvas`로 배치할 위치 확인
2. `batch_design`으로 UI 요소 배치 (header, content, navigation 등)
3. `get_screenshot`로 시각적 확인
4. 사용자에게 스크린샷을 보여주고 피드백 요청

AskUserQuestion으로 각 화면마다 피드백:
- question: "이 화면 디자인이 마음에 드시나요?"
- options:
  - label: "좋아요, 다음 화면으로" / description: "이 시안으로 확정합니다"
  - label: "수정해주세요" / description: "수정할 부분을 알려주세요"

"수정해주세요"이면 사용자 피드백을 반영하여 `batch_design`으로 수정 후 다시 확인.

### Step 5: 프로토타입 내보내기

모든 화면이 확정되면 이미지로 내보냅니다.

```bash
mkdir -p docs/prototype
```

`export_nodes`를 사용하여 각 화면을 PNG로 내보내기:
- 저장 경로: `docs/prototype/`
- 파일명: `01-home.png`, `02-login.png` 등 화면 순서대로

### Step 6: PRD 업데이트

PRD에 프로토타입 이미지 링크를 추가합니다.
각 화면 설명 옆에 `![화면명](../prototype/01-home.png)` 형식으로 삽입.

### Step 7: 최종 확인

```
✅ Step 6 완료! 프로토타입이 만들어졌습니다.

🎨 생성된 프로토타입:
   1. {화면1} → docs/prototype/01-{name}.png
   2. {화면2} → docs/prototype/02-{name}.png
   ...

   PRD에 프로토타입 이미지가 연결되었습니다.

다음 단계: /7-implement-by-claude-teams 를 입력해주세요.
```
