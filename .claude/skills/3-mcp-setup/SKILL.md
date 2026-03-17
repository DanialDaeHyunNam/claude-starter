# 3. MCP Setup

Claude가 외부 도구들과 연결되도록 MCP(Model Context Protocol) 서버를 설정하는 단계입니다.

## When to Use

- 사용자가 `/3-mcp-setup` 을 입력했을 때

## Instructions

### Step 0: MCP 유효성 사전 검증 (사용자에게 보이지 않게 진행)

사용자에게 설명하기 **전에**, 이 스킬에 적힌 MCP 설정이 여전히 유효한지 검증합니다.
이 단계는 사용자에게 출력하지 않고 조용히 진행하세요.

**검증 대상:**

| MCP | 유형 | 현재 설정 |
|-----|------|----------|
| Playwright | npm 패키지 | `@playwright/mcp` |
| Slack | npm 패키지 | `@modelcontextprotocol/server-slack` |
| Pencil | 앱 바이너리 | macOS: `/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64` |

**검증 방법:**
```bash
# npm 패키지 검증
npm view @playwright/mcp version 2>&1
npm view @modelcontextprotocol/server-slack version 2>&1

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
- Pencil 바이너리: 파일이 존재하면 ✅, 없으면 ❌

**실패 시 자동 복구:**

1. **npm 패키지가 사라진 경우:**
   - `npm search mcp {키워드}` 로 대체 패키지 검색
   - 대체 패키지를 찾으면 이 스킬 파일의 패키지명을 수정
   - 다른 스킬(`/season-start` 등)에서도 같은 패키지를 참조하면 함께 수정

2. **Pencil 바이너리 경로가 변경된 경우:**
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

3. **스킬 파일을 수정한 경우:**
   - `fix/mcp-config-update` 브랜치 생성
   - 변경된 파일들 커밋
   - PR 자동 생성 (제목: `[fix] MCP 설정 업데이트: {변경 요약}`)
   - 사용자에게는 수정된 최신 설정으로 그대로 진행

4. **대체를 못 찾으면:**
   - 사용자에게 알리고 해당 MCP는 건너뛰기 (나머지는 계속 진행)

검증 완료 후 Step 1로 진행합니다.

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
cat ~/.claude/settings.local.json 2>/dev/null || echo "{}"
```

그리고 프로젝트 레벨 설정도 확인:
```bash
cat .claude/settings.local.json 2>/dev/null || echo "{}"
```

### Step 4: Playwright MCP 설치

Playwright는 웹 브라우저를 자동으로 조작할 수 있는 도구입니다.

```bash
# Playwright 설치
bun add -g playwright
bunx playwright install chromium
```

Claude의 MCP 설정에 Playwright를 추가합니다.
`~/.claude/settings.local.json`에 아래를 추가:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp"]
    }
  }
}
```

> ⚠️ 패키지명 주의: `@playwright/mcp`가 공식 패키지입니다.
> `@anthropic-ai/mcp-playwright`는 npm에 존재하지 않습니다.

주의: MCP 서버 실행은 npx를 사용합니다 (MCP 프로토콜 호환성).

### Step 5: Slack MCP 설치

Slack 연결을 위해 사용자에게 Slack Bot Token이 필요합니다.

AskUserQuestion으로 질문:
- question: "Slack 알림을 받을 워크스페이스의 Bot Token이 있으신가요?"
- header: "Slack 설정"
- options:
  - label: "네, 토큰이 있어요" / description: "Slack Bot Token (xoxb-로 시작)을 입력해주세요"
  - label: "아니요, 만드는 법을 알려주세요" / description: "Slack App 생성부터 안내합니다"
  - label: "나중에 할게요" / description: "Slack 연결을 건너뛰고 다음으로"

**"아니요"** 선택 시 안내:
1. https://api.slack.com/apps 접속
2. "Create New App" → "From scratch"
3. App 이름 입력 (예: "Claude Bot"), 워크스페이스 선택
4. "OAuth & Permissions" → Bot Token Scopes 추가:
   - `chat:write` (메시지 보내기)
   - `chat:write.public` (초대 없이도 public 채널에 메시지 보내기)
   - `channels:read` (채널 목록 읽기)
   - `channels:history` (메시지 히스토리)
5. "Install to Workspace" → Bot User OAuth Token 복사 (xoxb-...)

토큰을 받으면 MCP 설정에 추가:
```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "{사용자가 입력한 토큰}"
      }
    }
  }
}
```

> ⚠️ 패키지명 주의: `@modelcontextprotocol/server-slack`이 공식 패키지입니다.
> `@anthropic-ai/mcp-slack`은 npm에 존재하지 않습니다.

### Step 6: Pencil MCP 확인

Pencil MCP는 **Pencil 앱 내부에 내장**되어 있습니다.
npm 패키지가 아니라 앱 바이너리를 직접 실행하는 방식입니다.

Step 0에서 이미 바이너리 경로를 검증했으므로, 그 결과를 사용합니다.

**Pencil 바이너리가 발견된 경우** — 찾은 경로로 MCP 설정에 추가:
```json
{
  "mcpServers": {
    "pencil": {
      "command": "{Step 0에서 찾은 바이너리 경로}",
      "args": ["--app", "desktop"]
    }
  }
}
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

> ⚠️ 주의: Pencil MCP는 npm 패키지가 아닙니다.
> 반드시 앱 내장 바이너리 경로를 사용해야 합니다. 경로가 바뀌면 Step 0에서 자동 탐색합니다.

### Step 7: MCP 설정 통합 및 저장

위에서 설정한 모든 MCP 서버를 하나의 `~/.claude/settings.local.json`에 통합하여 저장합니다.

기존 설정이 있으면 병합하고, 없으면 새로 생성합니다.

최종 형태 예시 (macOS Apple Silicon 기준):
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp"]
    },
    "slack": {
      "command": "npx",
      "args": ["@modelcontextprotocol/server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-..."
      }
    },
    "pencil": {
      "command": "/Applications/Pencil.app/Contents/Resources/app.asar.unpacked/out/mcp-server-darwin-arm64",
      "args": ["--app", "desktop"]
    }
  }
}
```

> 실제 설정 시에는 Step 0에서 검증된 패키지명과 바이너리 경로를 사용하세요.
> OS와 아키텍처에 따라 Pencil 바이너리 경로가 다릅니다.

### Step 8: 연결 확인

설정이 완료되면 사용자에게 결과를 표로 보여주세요:

```
MCP 연결 상태:
┌──────────────┬─────────┐
│ MCP 서버      │ 상태     │
├──────────────┼─────────┤
│ Playwright   │ ✅ 설정됨 │
│ Slack        │ ✅/⏭️    │
│ Pencil       │ ✅ 설정됨 │
└──────────────┴─────────┘
```

```
✅ Step 3 완료! MCP가 연결되었습니다.
   이제 Claude가 웹을 보고, 디자인하고, 알림을 보낼 수 있어요.

   참고: MCP 설정이 적용되려면 Claude Code를 재시작해야 합니다.
   터미널에서 'claude' 를 다시 실행해주세요.

   다음 단계: /4-critical-ground-rule-setup 을 입력해주세요.
```
