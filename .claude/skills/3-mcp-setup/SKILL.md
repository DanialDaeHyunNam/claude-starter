# 3. MCP Setup

Claude가 외부 도구들과 연결되도록 MCP(Model Context Protocol) 서버를 설정하는 단계입니다.

## When to Use

- 사용자가 `/3-mcp-setup` 을 입력했을 때

## Instructions

### Step 0-pre (조용히): 추적 시작

```bash
bash scripts/track.sh update 3-mcp-setup started
```

> 이 단계는 사용자에게 보여주지 않습니다. `.fearnot/participant.json`이 없으면 자동 스킵됩니다.

### Step 0: MCP 유효성 사전 검증 (사용자에게 보이지 않게 진행)

사용자에게 설명하기 **전에**, 이 스킬에 적힌 MCP 설정이 여전히 유효한지 검증합니다.
이 단계는 사용자에게 출력하지 않고 조용히 진행하세요.

**검증 대상:**

| MCP | 유형 | 현재 설정 |
|-----|------|----------|
| Playwright | npm 패키지 | `@playwright/mcp` |
| Slack | HTTP (OAuth) | `https://mcp.slack.com/mcp` + client-id `1601185624273.8899143856786` |
| Pencil | 앱 바이너리 | macOS: `/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64` |

**검증 방법:**
```bash
# npm 패키지 검증
npm view @playwright/mcp version 2>&1
# Slack HTTP MCP URL 접근성 확인
curl -s -o /dev/null -w "%{http_code}" https://mcp.slack.com/mcp 2>&1

# Pencil 바이너리 검증 (OS별)
# macOS (arm64)
ls /Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64 2>&1
# macOS (x64)
ls /Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-x64 2>&1
# Windows
ls "$LOCALAPPDATA/Programs/Pencil/resources/app.asar.unpacked/out/mcp-server-win32-x64.exe" 2>&1
# Linux
ls /opt/Pencil/resources/app.asar.unpacked/out/mcp-server-linux-x64 2>&1
```

**판단 기준:**
- npm 패키지: 버전 번호가 출력되면 ✅, `E404`면 ❌
- HTTP MCP (Slack): HTTP 상태코드 200 또는 401/405이면 URL 유효 ✅, 000이면 ❌
- Pencil 바이너리: 파일이 존재하면 ✅, 없으면 ❌

**실패 시 자동 복구:**

1. **npm 패키지가 사라진 경우 (Playwright):**
   - `npm search mcp {키워드}` 로 대체 패키지 검색
   - 대체 패키지를 찾으면 이 스킬 파일의 패키지명을 수정
   - 다른 스킬(`/season-start` 등)에서도 같은 패키지를 참조하면 함께 수정

2. **HTTP MCP URL이 응답하지 않는 경우 (Slack):**
   - 401/405 응답은 정상 (OAuth 인증 전이므로)
   - 완전한 연결 실패(000)면 사용자에게 네트워크 확인 안내 후 건너뛰기

3. **Pencil 바이너리 경로가 변경된 경우:**
   - Pencil 앱 설치 경로에서 `mcp-server*` 바이너리를 재탐색:
     ```bash
     # macOS
     find /Applications/Pencil.app -name "mcp-server*" 2>/dev/null
     # Windows
     find "$LOCALAPPDATA/Programs/Pencil" -name "mcp-server*" 2>/dev/null
     # Linux
     find /opt/Pencil -name "mcp-server*" 2>/dev/null
     ```
   - 바이너리를 찾으면 이 스킬 파일의 경로를 수정
   - 앱 자체가 없으면 사용자에게 설치 안내 (해당 MCP 건너뛰기)

4. **스킬 파일을 수정한 경우:**
   - `fix/mcp-config-update` 브랜치 생성
   - 변경된 파일들 커밋
   - PR 자동 생성 (제목: `[fix] MCP 설정 업데이트: {변경 요약}`)
   - 사용자에게는 수정된 최신 설정으로 그대로 진행

5. **대체를 못 찾으면:**
   - 사용자에게 알리고 해당 MCP는 건너뛰기 (나머지는 계속 진행)

검증 완료 후 조용히 실행하세요 (사용자에게 보여주지 않음):

```bash
bash scripts/track.sh event 3-mcp-setup mcp-validated
```

Step 1로 진행합니다.

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 3: MCP 연결 (Claude에게 팔다리 달아주기)

```
지금까지의 Claude         MCP 연결 후 Claude
┌─────────────┐         ┌─────────────────────────┐
│             │         │           Claude          │
│  🧠 두뇌만   │  ──→    │  🧠 + 👀 + 🖐️ + 📢      │
│  있는 상태   │         │                           │
└─────────────┘         │  👀 Playwright (웹 보기)   │
                        │  🖐️ Pencil (디자인하기)    │
                        │  📢 Slack (알림 보내기)    │
                        └─────────────────────────┘
```

**쉽게 말하면:**
지금까지 Claude는 "머리만 있는 상태"였어요.
MCP를 연결하면 Claude에게 눈(웹을 볼 수 있음), 손(디자인할 수 있음),
입(메시지를 보낼 수 있음)을 달아주는 거예요.

3개를 연결할 거예요:
- **Playwright** = Claude가 웹사이트를 직접 열어보고 테스트할 수 있는 눈 👀
- **Pencil** = Claude가 디자인/프로토타입을 만들 수 있는 손 🖐️
- **Slack** = Claude가 진행 상황을 알려줄 수 있는 입 📢

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

"더 설명해주세요"를 선택하면 사용자의 추가 질문에 **어린아이도 이해할 수 있는 비유**로 답변한 뒤, 다시 같은 AskUserQuestion을 반복하세요.

### Step 3: 현재 MCP 설정 확인

현재 설정된 MCP 서버가 있는지 확인합니다.

```bash
claude mcp list
```

### Step 4: Playwright MCP 설치

Playwright는 웹 브라우저를 자동으로 조작할 수 있는 도구입니다.

```bash
# Playwright 설치
bun add -g playwright
bunx playwright install chromium
```

Claude의 MCP 설정에 Playwright를 추가합니다.
`claude mcp add` CLI를 사용해야 올바른 위치에 저장됩니다:

```bash
claude mcp add playwright -- npx @playwright/mcp
```

주의: MCP 서버 실행은 npx를 사용합니다 (MCP 프로토콜 호환성).

Playwright 추가 후 조용히 실행하세요 (사용자에게 보여주지 않음):

```bash
bash scripts/track.sh event 3-mcp-setup playwright-added
```

### Step 5: Slack MCP 설치

Slack 공식 HTTP MCP를 사용합니다. OAuth 방식이라 Bot Token 수동 관리가 필요 없습니다.

**반드시 `--client-id`와 `--callback-port`를 지정해야 합니다** (Slack이 Dynamic Client Registration을 지원하지 않으므로 사전 등록된 client-id 필수):

```bash
claude mcp add --transport http --client-id 1601185624273.8899143856786 --callback-port 3118 slack https://mcp.slack.com/mcp
```

등록 후 안내:
```
✅ Slack MCP가 등록되었습니다!

이 MCP는 OAuth 인증 방식이에요.
Claude Code를 재시작하면 처음 Slack 도구를 사용할 때
브라우저가 열리면서 Slack 로그인 화면이 나옵니다.
거기서 워크스페이스에 로그인하면 연결 완료!
```

Slack 추가 후 조용히 실행하세요 (사용자에게 보여주지 않음):

```bash
bash scripts/track.sh event 3-mcp-setup slack-added
```

### Step 6: Pencil MCP 확인

Pencil MCP는 **Pencil 앱 내부에 내장**되어 있습니다.
npm 패키지가 아니라 앱 바이너리를 직접 실행하는 방식입니다.

Step 0에서 이미 바이너리 경로를 검증했으므로, 그 결과를 사용합니다.

**Pencil 바이너리가 발견된 경우** — `claude mcp add-json` CLI로 MCP 설정에 추가:
```bash
claude mcp add-json pencil '{"command":"{Step 0에서 찾은 바이너리 경로}","args":["--app","desktop"]}'
```

OS별 바이너리 경로 참고:
| OS | 경로 |
|----|------|
| macOS (Apple Silicon) | `/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64` |
| macOS (Intel) | `/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-x64` |
| Windows | `%LOCALAPPDATA%\Programs\Pencil\resources\app.asar.unpacked\out\mcp-server-win32-x64.exe` |
| Linux | `/opt/Pencil/resources/app.asar.unpacked/out/mcp-server-linux-x64` |

**Pencil 앱이 없으면** 사용자에게 안내:
```
Pencil은 디자인 프로토타이핑 도구예요.
https://pencil.evolves.ai 에서 앱을 다운로드 후 설치해주세요.
설치 후 이 단계를 다시 실행하면 됩니다.
```

Pencil 추가 후 조용히 실행하세요 (사용자에게 보여주지 않음):

```bash
bash scripts/track.sh event 3-mcp-setup pencil-added
```

### Step 7: 연결 확인

`claude mcp list` 명령으로 최종 상태를 확인합니다.

**`claude mcp list` 결과 해석:**

| 상태 | 의미 | 조치 |
|------|------|------|
| `✓ Connected` | 정상 연결됨 | 없음 |
| `! Needs authentication` | OAuth 인증 대기 중 | Claude Code 재시작 후 해당 도구 사용 시 브라우저 인증 창이 열림 → 정상 |
| `✗ Failed to connect` | 연결 실패 | 아래 트러블슈팅 참조 |

- **Playwright**: `✓ Connected` 또는 목록에 표시되면 정상
- **Slack**: OAuth 방식이라 최초에는 `! Needs authentication` 이 정상. `✗ Failed to connect`면 트러블슈팅 필요
- **Pencil**: `✓ Connected` 여야 정상 (Pencil 앱이 실행 중이어야 함)

### Step 8: 트러블슈팅 (문제가 있을 때만)

`claude mcp list`에서 `✗ Failed to connect`가 뜨는 MCP가 있으면 아래 순서로 해결합니다.

**공통 해결법 — 삭제 후 재등록:**
```bash
# 1. 문제가 있는 MCP 삭제
claude mcp remove {이름}

# 2. 다시 등록 (각 MCP별 명령어는 Step 4~6 참조)
claude mcp add ...

# 3. Claude Code 재시작 (터미널에서 exit 후 claude 재실행)
```

**Slack이 `Failed to connect`일 때:**
1. `claude mcp remove slack`
2. `claude mcp add --transport http --client-id 1601185624273.8899143856786 --callback-port 3118 slack https://mcp.slack.com/mcp`
3. Claude Code 재시작
4. 재시작 후 Slack 도구를 사용하면 브라우저 인증 창이 열림

**Playwright가 목록에 안 보일 때:**
```bash
claude mcp add playwright -- npx @playwright/mcp
```

**Pencil이 `Failed to connect`일 때:**
- Pencil 앱이 설치되어 있는지 확인
- 앱을 한 번 실행한 뒤 다시 `claude mcp list` 확인

사용자에게 결과를 표로 보여주세요:

```
MCP 연결 상태:
┌──────────────┬──────────────────────┐
│ MCP 서버      │ 상태                  │
├──────────────┼──────────────────────┤
│ Playwright   │ ✅ 설정됨              │
│ Slack        │ ✅ 설정됨 (인증 대기)   │
│ Pencil       │ ✅ 설정됨              │
└──────────────┴──────────────────────┘
```

완료 추적 (조용히):
```bash
bash scripts/track.sh event 3-mcp-setup mcp-validated && \
bash scripts/track.sh update 3-mcp-setup completed
```

> 이 단계는 사용자에게 보여주지 않습니다.

```
✅ Step 3 완료! MCP가 연결되었습니다.
   이제 Claude가 웹을 보고, 디자인하고, 알림을 보낼 수 있어요.

   ⚠️ MCP 설정이 적용되려면 Claude Code를 재시작해야 합니다.
   터미널에서 exit 입력 후 claude 를 다시 실행해주세요.

   💡 Slack은 재시작 후 처음 사용할 때 브라우저 인증 창이 열립니다.
   거기서 워크스페이스에 로그인하면 연결 완료!

   다음 단계: /4-critical-ground-rule-setup 을 입력해주세요.
```
