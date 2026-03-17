# Season Start

강의 시작 시 Slack `notify-step` 채널에 Mac/Windows 유저별 Claude Code 설치 가이드를 발송합니다.

## When to Use

- 사용자가 `/season-start` 를 입력했을 때
- 새 기수/시즌 시작 시 수강생들에게 사전 안내를 보낼 때

## Instructions

### Step 1: Slack MCP 연결 확인

Slack MCP가 설정되어 있는지 확인하세요.
설정되어 있지 않으면 사용자에게 안내:

"Slack MCP가 설정되지 않았습니다. `/3-mcp-setup` 을 먼저 실행해주세요."

설정되어 있으면 다음으로 진행합니다.

### Step 1.5: 최신 설치 방법 확인

메시지를 발송하기 전에, 공식 문서에서 현재 설치 방법이 여전히 유효한지 확인합니다.

WebFetch 도구로 아래 페이지를 확인하세요:
- URL: `https://docs.anthropic.com/en/docs/claude-code/overview`
- prompt: "Claude Code 설치 방법을 Mac과 Windows 각각 알려줘. 설치 명령어, 필수 선행 조건(Node.js, Git 등), 지원 OS 요건을 포함해서."

확인할 항목:
1. **Mac 설치 명령어** — 현재 스킬: `curl -fsSL https://claude.ai/install.sh | bash`
2. **Windows 설치 명령어** — 현재 스킬: `irm https://claude.ai/install.ps1 | iex`
3. **Windows 선행 조건** — 현재 스킬: Git Bash 필수, 64-bit 필수
4. **추가된 요건** — Node.js 사전 설치 필요 여부 등

**공식 문서와 다른 점이 발견되면:**
- 사용자에게 차이점을 보여주고
- AskUserQuestion으로 "공식 문서 기준으로 수정해서 보낼까요?" 확인
- 승인 시 아래 Step 2~3의 메시지 내용을 수정하여 발송

**동일하면:** 그대로 다음 단계로 진행

### Step 2: Mac 유저 가이드 발송

Slack MCP의 `send_message` 도구로 `notify-step` 채널에 아래 메시지를 보냅니다.

**Parent 메시지:**

```
:apple: *Mac 유저분들 확인하세요!*

강의 시작 전에 Claude Code를 설치해야 합니다.
아래 스레드에 설치 방법이 있어요. 천천히 따라와주세요!
```

**Thread 답글 (parent 메시지의 thread_ts에 답글):**

```
:wrench: *Mac에서 Claude Code 설치하기*

*1단계: 터미널 열기*
• Spotlight 검색 (Cmd + Space) → "터미널" 입력 → Enter
• 또는 Finder → 응용 프로그램 → 유틸리티 → 터미널

*2단계: Claude Code 설치*
아래 명령어를 터미널에 복사-붙여넣기 하세요:
```curl -fsSL https://claude.ai/install.sh | bash```

설치가 끝나면 터미널을 닫고 다시 열어주세요.

*3단계: Claude Code 실행 확인*
터미널에 아래를 입력하세요:
```claude --version```
버전 번호가 나오면 설치 성공! :tada:

*4단계: 레포 다운로드 + Claude 실행*
```git clone https://github.com/DanialDaeHyunNam/claude-starter.git```
```cd claude-starter```
```claude```

Claude가 실행되면 준비 완료! 강의에서 만나요 :raised_hands:

:warning: *문제가 생기면?*
• `command not found: claude` → 터미널을 완전히 닫고 다시 열어보세요
• 여전히 안 되면 강사에게 알려주세요!
```

### Step 3: Windows 유저 가이드 발송

Slack MCP의 `send_message` 도구로 `notify-step` 채널에 아래 메시지를 보냅니다.

**Parent 메시지:**

```
:desktop_computer: *Windows 유저분들 확인하세요!*

강의 시작 전에 몇 가지를 설치해야 합니다.
Mac보다 단계가 조금 더 많지만, 아래 스레드를 따라오면 됩니다!
```

**Thread 답글 (parent 메시지의 thread_ts에 답글):**

```
:wrench: *Windows에서 Claude Code 설치하기*

:one: *Git 설치 (필수 선행)*
Claude Code가 내부적으로 Git Bash를 사용하기 때문에 Git을 먼저 설치해야 합니다.

1. https://git-scm.com/download/win 에서 다운로드
2. 설치할 때 이 옵션 꼭 선택: `Git from the command line and also from 3rd-party software`
3. 나머지는 기본값으로 Next → Install

:two: *PowerShell 열기 (64-bit 확인 필수!)*

:warning: *중요: 반드시 64-bit PowerShell을 열어야 합니다!*
• Windows 검색 (Win키) → `PowerShell` 입력
• "Windows PowerShell" 선택 *(x86이 붙은 것은 절대 선택하지 마세요!)*

확인 방법: PowerShell에서 아래 입력
```[Environment]::Is64BitProcess```
`True`가 나오면 정상, `False`면 x86(32bit)이니 다시 여세요.

:three: *Claude Code 설치*
PowerShell에 아래를 복사-붙여넣기:
```irm https://claude.ai/install.ps1 | iex```

설치 후 *PowerShell을 완전히 닫고 새로 열어주세요!*
(setx로 PATH가 등록되므로 재시작 필수)

:four: *설치 확인*
새 PowerShell에서:
```claude --version```
버전 번호가 나오면 성공! :tada:

:five: *레포 다운로드 + Claude 실행*
```git clone https://github.com/DanialDaeHyunNam/claude-starter.git```
```cd claude-starter```
```claude```

:warning: *자주 발생하는 문제들*

*"Claude Code does not support 32-bit Windows"*
→ x86 PowerShell을 열었습니다. 일반 PowerShell로 다시 여세요.

*"Claude Code on Windows requires git-bash"*
→ Git이 설치되지 않았습니다. 1단계부터 다시 해주세요.

*"claude : 이 시스템에서 스크립트를 실행할 수 없습니다"*
→ PowerShell에서 실행: ```Set-ExecutionPolicy RemoteSigned -Scope CurrentUser```

*`claude` 명령을 찾을 수 없음 (command not found)*
→ PowerShell을 닫고 *새로* 여세요. 그래도 안 되면:
```setx PATH "$env:PATH;$env:USERPROFILE\.local\bin"```
→ 다시 PowerShell을 닫고 새로 열기

문제가 계속되면 강사에게 알려주세요!
```

### Step 4: 발송 완료 안내

두 메시지가 모두 발송되면 사용자에게 안내:

```
✅ Slack `notify-step` 채널에 가이드가 발송되었습니다!

발송된 내용:
- 🍎 Mac 유저 가이드 (스레드)
- 🖥️ Windows 유저 가이드 (스레드)

수강생들이 스레드를 따라 Claude Code를 설치하면,
강의 시작 시 /0-local-setup 부터 진행하면 됩니다.
```
