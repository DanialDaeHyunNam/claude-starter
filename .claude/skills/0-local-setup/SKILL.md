# 0. Local Setup

앱을 만들기 위한 필수 도구 5개만 빠르게 확인/설치합니다.

## When to Use

- 사용자가 `/0-local-setup` 을 입력했을 때

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 0: 필수 도구 확인

지금부터 앱을 만들기 위해 꼭 필요한 도구 5개만 확인할 거예요.

```
필수 도구 5개
┌──────────────────────────────────────────┐
│ 1. Claude Code  ← 지금 쓰고 있는 AI 도우미 │
│ 2. Git          ← 코드 저장소 (타임머신)    │
│ 3. Node.js      ← 앱을 돌리는 엔진         │
│ 4. Bun          ← 빠른 패키지 관리자        │
│ 5. gh           ← GitHub 연결 도구         │
└──────────────────────────────────────────┘
```

**쉽게 말하면:**
가게를 차리려면 최소한 전기, 수도, 가스는 들어와야 하죠?
이 5개가 앱을 만들기 위한 "전기, 수도, 가스"예요.

> 터미널 꾸미기, 에디터, 폰트 등 전체 환경 설정은
> `/bootstrap-packages` 로 별도 진행할 수 있습니다.

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

"더 설명해주세요"를 선택하면 사용자의 추가 질문에 **어린아이도 이해할 수 있는 비유**로 답변한 뒤, 다시 같은 AskUserQuestion을 반복하세요.

### Step 3: OS 확인 + 환경 진단

먼저 Bash 도구로 OS를 자동 감지하세요:

```bash
uname -s
```

- `Darwin` → macOS
- `MINGW*` 또는 `MSYS*` → Windows (Git Bash)
- `Linux` → Linux

**macOS / Linux인 경우** Bash 도구로 진단:

```bash
echo "=== 필수 도구 확인 ===" && \
echo "1. Claude Code: $(claude --version 2>/dev/null || echo '❌ 미설치')" && \
echo "2. Git: $(git --version 2>/dev/null || echo '❌ 미설치')" && \
echo "3. Node.js: $(node --version 2>/dev/null || echo '❌ 미설치')" && \
echo "4. Bun: $(bun --version 2>/dev/null || echo '❌ 미설치')" && \
echo "5. gh: $(gh --version 2>/dev/null | head -1 || echo '❌ 미설치')"
```

**Windows인 경우** 사용자에게 PowerShell에 붙여넣기 안내:

```powershell
@("claude","git","node","bun","gh") | ForEach-Object {
    $v = try { & $_ --version 2>$null | Select-Object -First 1 } catch { $null }
    if ($v) { Write-Host "  ${_}: $v" -ForegroundColor Green }
    else    { Write-Host "  ${_}: 미설치" -ForegroundColor Yellow }
}
```

### Step 4: 미설치 항목 설치

진단 결과에서 **미설치인 항목만** 아래 순서로 설치합니다.
이미 설치된 항목은 건너뜁니다.

---

#### 4-1. Git

**macOS:**
```bash
# Xcode CLI Tools에 포함 (git이 없으면 자동으로 설치 팝업)
xcode-select --install 2>/dev/null || true
```

**Windows:** 사용자에게 안내
```
https://git-scm.com/download/win 에서 설치하거나,
PowerShell에서: winget install Git.Git
```

**Linux:**
```bash
sudo apt update && sudo apt install -y git
```

#### 4-2. Node.js

**macOS:**
```bash
# Homebrew가 있으면 brew로, 없으면 공식 설치 스크립트
if command -v brew >/dev/null 2>&1; then
  brew install node
else
  curl -fsSL https://nodejs.org/install.sh | bash
fi
```

**Windows:** 사용자에게 안내
```
https://nodejs.org 에서 LTS 버전 설치하거나,
PowerShell에서: winget install OpenJS.NodeJS.LTS
```

**Linux:**
```bash
curl -fsSL https://nodejs.org/install.sh | sudo bash
```

#### 4-3. Bun

**macOS / Linux:**
```bash
curl -fsSL https://bun.sh/install | bash
```

설치 후 PATH 적용:
```bash
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
```

**Windows:** 사용자에게 안내
```powershell
irm bun.sh/install.ps1 | iex
```

#### 4-4. GitHub CLI (gh)

**macOS:**
```bash
if command -v brew >/dev/null 2>&1; then
  brew install gh
else
  # brew 없으면 직접 다운로드 안내
  echo "https://cli.github.com 에서 설치해주세요"
fi
```

**Windows:** 사용자에게 안내
```powershell
winget install GitHub.cli
```

**Linux:**
```bash
sudo apt install -y gh 2>/dev/null || \
  (curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
  sudo apt update && sudo apt install -y gh)
```

### Step 5: 최종 확인

모든 설치가 끝나면 Step 3의 진단 명령을 다시 실행하여 결과를 표로 정리:

```
┌─────────────┬──────────┬─────────┐
│ 도구         │ 상태     │ 버전     │
├─────────────┼──────────┼─────────┤
│ Claude Code  │ ✅       │ x.x.x   │
│ Git          │ ✅       │ x.x.x   │
│ Node.js      │ ✅       │ x.x.x   │
│ Bun          │ ✅       │ x.x.x   │
│ gh           │ ✅       │ x.x.x   │
└─────────────┴──────────┴─────────┘
```

- 모두 ✅ → Step 6으로
- ❌ 있으면 → 해당 항목 재설치 안내

### Step 6: 플러그인 설치

Claude Code 플러그인을 설치합니다.
Bash 도구로 **순서대로** 실행하세요:

**1) clarify 플러그인용 마켓플레이스 등록**

```bash
claude plugin marketplace add team-attention/plugins-for-claude-natives 2>/dev/null || true
```

**2) 모든 플러그인 설치**

```bash
claude plugin install clarify@team-attention-plugins 2>/dev/null || true
claude plugin install vercel@claude-plugins-official 2>/dev/null || true
claude plugin install github@claude-plugins-official 2>/dev/null || true
claude plugin install commit-commands@claude-plugins-official 2>/dev/null || true
claude plugin install typescript-lsp@claude-plugins-official 2>/dev/null || true
claude plugin install pr-review-toolkit@claude-plugins-official 2>/dev/null || true
claude plugin install explanatory-output-style@claude-plugins-official 2>/dev/null || true
```

**3) 설치 확인**

```bash
claude plugin list
```

7개 플러그인이 모두 `enabled`로 표시되는지 확인하세요.

### Step 7: Status Bar 설정

Claude Code 하단에 유용한 정보(모델명, 컨텍스트 사용률, 라인 수 등)를 표시합니다.

```
예시:
 claude-starter | Opus 4.6 (1M context) | +1126 lines | ctx:13% | 5h:44% 7d:7%
```

**macOS / Linux:**

Bash 도구로 실행:
```bash
# statusline 스크립트 생성
cat > ~/.claude/statusline-command.sh << 'STATUSLINE_EOF'
#!/usr/bin/env bash
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
five_h=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_d=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

DIM="\033[2m"
RST="\033[0m"
SEP=" ${DIM}|${RST} "

# Workspace (folder name only)
cwd="${cwd##*/}"

# Context color
ctx_part=""
if [ -n "$used" ]; then
  used_int=${used%.*}
  if [ "$used_int" -ge 80 ]; then
    cc="\033[31m"
  elif [ "$used_int" -ge 50 ]; then
    cc="\033[33m"
  else
    cc="\033[32m"
  fi
  ctx_part="${SEP}${cc}ctx:${used_int}%${RST}"
fi

# Rate limits (only when available)
rl_part=""
if [ -n "$five_h" ] || [ -n "$seven_d" ]; then
  rl_parts=""
  if [ -n "$five_h" ]; then
    five_int=${five_h%.*}
    rl_parts="5h:${five_int}%"
  fi
  if [ -n "$seven_d" ]; then
    seven_int=${seven_d%.*}
    rl_parts="${rl_parts:+$rl_parts }7d:${seven_int}%"
  fi
  rl_part="${SEP}\033[38;5;178m${rl_parts}${RST}"
fi

printf '%b' "\033[33m${cwd}${RST}${SEP}\033[35m${model}${RST}${SEP}\033[36m+${lines_added} lines${RST}${ctx_part}${rl_part}"
STATUSLINE_EOF

chmod +x ~/.claude/statusline-command.sh
```

그 다음, `~/.claude/settings.json`에 statusLine 설정을 추가합니다.
**기존 settings.json이 있으면 statusLine 키만 추가하고, 다른 설정은 건드리지 않습니다.**

Bash 도구로 실행:
```bash
# jq가 있으면 안전하게 merge, 없으면 안내
if command -v jq >/dev/null 2>&1; then
  SETTINGS=~/.claude/settings.json
  if [ -f "$SETTINGS" ]; then
    jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline-command.sh"}}' "$SETTINGS" > "${SETTINGS}.tmp" && mv "${SETTINGS}.tmp" "$SETTINGS"
  else
    echo '{"statusLine": {"type": "command", "command": "~/.claude/statusline-command.sh"}}' > "$SETTINGS"
  fi
  echo "✅ statusLine 설정 완료"
else
  echo "⚠️ jq가 설치되어 있지 않습니다. 수동으로 설정해주세요."
fi
```

**Windows:** 사용자에게 안내
```
Windows에서는 아래 내용을 ~/.claude/settings.json에 추가해주세요:

"statusLine": {
  "type": "command",
  "command": "bash ~/.claude/statusline-command.sh"
}

statusline-command.sh 파일은 Git Bash에서 동일하게 생성하면 됩니다.
```

사용자에게 안내:
```
✅ Status Bar가 설정되었습니다!
Claude Code를 다시 시작하면 하단에 아래 정보가 표시됩니다:

  폴더명 | 모델명 | 추가한 줄 수 | 컨텍스트 사용률 | 요금 한도

컨텍스트가 50% 넘으면 노란색, 80% 넘으면 빨간색으로 바뀌어요.
```

### Step 8: 레포 구조 안내 + 마무리

사용자에게 아래를 설명하세요:

```
이 레포와 여러분의 프로덕트는 "나란히" 존재해요
┌─────────────────────────────────────────┐
│ workspace/                              │
│ ├── claude-starter/  (이 레포 = 강의 도구)│
│ │   ├── scripts/     ← 설치 스크립트    │
│ │   ├── helper/      ← 검증된 템플릿    │
│ │   └── .claude/     ← skill, 플러그인  │
│ │                                       │
│ └── my-app/          ← 여러분의 프로젝트 │
│     ├── .git         ← 독립 저장소       │
│     └── ...                             │
└─────────────────────────────────────────┘
```

이 레포는 여러분을 도와주는 **도구 상자**예요.
여러분이 만드는 프로젝트는 claude-starter **바깥의 sibling(형제) 폴더**로 만들어집니다.
도구 상자와 작품이 완전히 분리되어 있어서 git/파일 경로가 섞이지 않아요.

```
✅ Step 0 완료! 필수 도구가 모두 준비되었습니다.

💡 터미널 꾸미기, 에디터, 폰트 등 전체 환경 설정을 원하시면
   나중에 /bootstrap-packages 를 실행해주세요.

다음 단계: /1-claude-md-setup 을 입력해주세요.
```
