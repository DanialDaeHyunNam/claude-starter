# 3. MCP Setup

Claude가 외부 도구들과 연결되도록 MCP(Model Context Protocol) 서버를 설정하는 단계입니다.

## When to Use

- 사용자가 `/3-mcp-setup` 을 입력했을 때

## Instructions

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
                        │  🌐 Chrome (웹 조작하기)   │
                        └─────────────────────────┘
```

**쉽게 말하면:**
지금까지 Claude는 "머리만 있는 상태"였어요.
MCP를 연결하면 Claude에게 눈(웹을 볼 수 있음), 손(디자인할 수 있음),
입(메시지를 보낼 수 있음)을 달아주는 거예요.

4개를 연결할 거예요:
- **Playwright** = Claude가 웹사이트를 직접 열어보고 테스트할 수 있는 눈 👀
- **Pencil** = Claude가 디자인/프로토타입을 만들 수 있는 손 🖐️
- **Slack** = Claude가 진행 상황을 알려줄 수 있는 입 📢
- **Claude in Chrome** = Claude가 크롬 브라우저를 직접 조작할 수 있는 리모컨 🌐

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
      "args": ["@anthropic-ai/mcp-playwright"]
    }
  }
}
```

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
   - `channels:read` (채널 목록 읽기)
   - `channels:history` (메시지 히스토리)
5. "Install to Workspace" → Bot User OAuth Token 복사 (xoxb-...)

토큰을 받으면 MCP 설정에 추가:
```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "{사용자가 입력한 토큰}"
      }
    }
  }
}
```

### Step 6: Pencil MCP 확인

Pencil MCP는 이 레포에 이미 설정되어 있을 수 있습니다.
현재 설정에 pencil이 있는지 확인하세요.

```bash
cat .claude/settings.local.json 2>/dev/null | grep -i pencil
```

없으면 사용자에게 안내:
```
Pencil은 디자인 프로토타이핑 도구예요.
Pencil 앱이 설치되어 있어야 MCP 연결이 가능합니다.
```

Pencil MCP 설정 추가:
```json
{
  "mcpServers": {
    "pencil": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-pencil"]
    }
  }
}
```

### Step 7: Claude in Chrome MCP 설치

Chrome 브라우저를 Claude가 직접 조작할 수 있게 합니다.

AskUserQuestion으로 질문:
- question: "Chrome 브라우저를 Claude가 조작할 수 있도록 설정할까요?"
- header: "Chrome 연동"
- options:
  - label: "네, 설정해주세요" / description: "Claude가 Chrome에서 웹 페이지를 직접 조작할 수 있게 됩니다"
  - label: "나중에 할게요" / description: "Chrome 연결을 건너뛰고 다음으로"

설정 시 MCP에 추가:
```json
{
  "mcpServers": {
    "chrome": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-chrome"]
    }
  }
}
```

### Step 8: MCP 설정 통합 및 저장

위에서 설정한 모든 MCP 서버를 하나의 `~/.claude/settings.local.json`에 통합하여 저장합니다.

기존 설정이 있으면 병합하고, 없으면 새로 생성합니다.

최종 형태 예시:
```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-playwright"]
    },
    "slack": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "xoxb-..."
      }
    },
    "pencil": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-pencil"]
    },
    "chrome": {
      "command": "npx",
      "args": ["@anthropic-ai/mcp-chrome"]
    }
  }
}
```

### Step 9: 연결 확인

설정이 완료되면 사용자에게 결과를 표로 보여주세요:

```
MCP 연결 상태:
┌──────────────┬─────────┐
│ MCP 서버      │ 상태     │
├──────────────┼─────────┤
│ Playwright   │ ✅ 설정됨 │
│ Slack        │ ✅/⏭️    │
│ Pencil       │ ✅ 설정됨 │
│ Chrome       │ ✅/⏭️    │
└──────────────┴─────────┘
```

```
✅ Step 3 완료! MCP가 연결되었습니다.
   이제 Claude가 웹을 보고, 디자인하고, 알림을 보낼 수 있어요.

   참고: MCP 설정이 적용되려면 Claude Code를 재시작해야 합니다.
   터미널에서 'claude' 를 다시 실행해주세요.

   다음 단계: /4-critical-ground-rule-setup 을 입력해주세요.
```
