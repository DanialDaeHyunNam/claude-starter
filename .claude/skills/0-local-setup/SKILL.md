# 0. Local Setup

컴퓨터에 필요한 도구들을 설치하는 첫 번째 단계입니다.

## When to Use

- 사용자가 `/0-local-setup` 을 입력했을 때

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 0: 컴퓨터 셋팅

지금부터 여러분의 컴퓨터에 개발에 필요한 모든 도구를 설치할 거예요.

```
여러분의 컴퓨터          설치되는 것들
┌──────────┐     ┌──────────────────────────────────┐
│          │     │ 기본 도구: Git, Homebrew, Xcode   │
│  🖥️      │ ←── │ 런타임: Node.js, Bun              │
│          │     │ 앱: VS Code/Cursor                │
│          │     │ AI: Claude Code                    │
│          │     │ 쉘: Oh My Zsh + Powerlevel10k     │
└──────────┘     └──────────────────────────────────┘
```

**쉽게 말하면:**
새 가게를 차리려면 인테리어, 주방 기구, 계산대, 간판이 필요하죠?
앱을 만들기 위한 "가게 인테리어"를 하는 단계예요.
버튼 하나로 모든 게 자동 설치됩니다!

- **Homebrew** = 앱스토어 같은 건데 개발 도구 전용이에요
- **asdf** = Node.js 등의 버전을 관리하는 리모컨 (채널 돌리듯 버전을 바꿀 수 있어요)
- **Node.js** = 앱을 돌리는 엔진
- **Claude Code** = 코딩을 대신 해주는 AI 도우미
- **Oh My Zsh / Oh My Posh** = 터미널을 예쁘고 편하게 만들어주는 꾸미기 도구 (Mac은 Zsh, Windows는 Posh)

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

"더 설명해주세요"를 선택하면 사용자의 추가 질문에 **어린아이도 이해할 수 있는 비유**로 답변한 뒤, 다시 같은 AskUserQuestion을 반복하세요.

### Step 3: 이 레포의 구조 안내

사용자에게 아래를 설명하세요:

```
이 레포의 구조
┌─────────────────────────────────────────┐
│ claude-starter/  (이 레포 = 강의 도구)    │
│ ├── scripts/     ← 설치 스크립트         │
│ ├── assets/      ← 설정 파일들           │
│ ├── .claude/     ← skill, 플러그인       │
│ │                                       │
│ └── projects/    ← 여러분의 작업 공간     │
│     └── my-app/  ← 여러분의 프로젝트     │
│         ├── .git ← 독립 저장소           │
│         └── ...                         │
└─────────────────────────────────────────┘
```

이 레포는 여러분을 도와주는 **도구 상자**예요.
여러분이 만드는 프로젝트는 `projects/` 폴더 안에 따로 만들어집니다.
도구 상자와 여러분의 작품은 완전히 분리되어 있어서 섞일 걱정이 없어요!

그리고 강의 중에 발견한 개선점이나 버그가 있으면,
이 레포에 PR(Pull Request)을 올려서 공유할 수 있어요.
유용한 개선은 강사가 검토 후 반영합니다.

### Step 3.5: 개발 환경 경험 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "현재 터미널에서 Claude Code를 실행하고 계신 거죠? 개발 환경(터미널, 에디터 등)은 어떤 상태인가요?"
- header: "개발 환경 확인"
- options:
  - label: "처음이에요" / description: "터미널이나 개발 도구를 직접 설정해본 적 없어요"
  - label: "이미 갖춰져 있어요" / description: "iTerm/터미널, 에디터, Node.js 등 나만의 환경이 있어요"

**"이미 갖춰져 있어요"를 선택한 경우:**

환경 설치(Step 4~5)를 건너뛰고, Step 5.5(플러그인 설치) → Step 6(최종 확인)으로 이동합니다.

사용자에게 안내:
```
👍 이미 개발 환경을 갖추고 계시군요!
환경 설치 단계는 건너뛰고, 필요한 것만 확인하겠습니다.
```

→ Step 5.5로 이동 (플러그인 설치)
→ Step 6으로 이동 (최종 확인)

**"처음이에요"를 선택한 경우:** Step 4로 정상 진행합니다.

### Step 4: OS 선택

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "어떤 컴퓨터를 사용하고 계신가요?"
- header: "운영체제"
- options:
  - label: "macOS" / description: "맥북, 아이맥 등 애플 컴퓨터"
  - label: "Windows" / description: "삼성, LG, 레노버 등 일반 PC/노트북"
  - label: "Linux" / description: "우분투 등 리눅스 운영체제"

### Step 5: OS별 설치 진행

---

#### macOS를 선택한 경우

이 레포에 포함된 `scripts/bootstrap_mac.sh` 스크립트를 사용합니다.

**4-1. 환경 진단부터 수행**

설치 실행 전에 먼저 현재 환경을 Bash 도구로 진단하세요:

```bash
echo "=== 환경 진단 ===" && \
echo "OS: $(sw_vers -productName) $(sw_vers -productVersion)" && \
echo "Shell: $SHELL" && \
echo "Homebrew: $(brew --version 2>/dev/null | head -1 || echo '미설치')" && \
echo "Xcode CLI: $(xcode-select -p 2>/dev/null || echo '미설치')" && \
echo "--- 버전 관리자 확인 ---" && \
echo "asdf: $(asdf --version 2>/dev/null || echo '미설치')" && \
echo "nvm: $(nvm --version 2>/dev/null || echo '미설치')" && \
echo "fnm: $(fnm --version 2>/dev/null || echo '미설치')" && \
echo "volta: $(volta --version 2>/dev/null || echo '미설치')" && \
echo "pyenv: $(pyenv --version 2>/dev/null || echo '미설치')" && \
echo "nodenv: $(nodenv --version 2>/dev/null || echo '미설치')" && \
echo "--- 이미 설치된 런타임 ---" && \
echo "node: $(node --version 2>/dev/null || echo '미설치')" && \
echo "python: $(python3 --version 2>/dev/null || echo '미설치')" && \
echo "mysql: $(mysql --version 2>/dev/null || echo '미설치')" && \
echo "psql: $(psql --version 2>/dev/null || echo '미설치')" && \
echo "claude: $(claude --version 2>/dev/null || echo '미설치')" && \
echo "docker: $(docker --version 2>/dev/null || echo '미설치')"
```

**4-2. 기존 버전 관리자가 있는 경우 (nvm, fnm, volta, pyenv, nodenv 등)**

asdf가 아닌 다른 버전 관리자가 발견되면:

1. 사용자에게 상황을 설명:
   "현재 [nvm/fnm/etc]이 설치되어 있네요. 이 프로젝트는 asdf로 통합 관리합니다."

2. AskUserQuestion으로 선택지 제시:
   - label: "asdf로 통합 (추천)" / description: "기존 버전 관리자는 그대로 두고, asdf를 추가 설치합니다. 충돌 시 PATH 우선순위로 해결합니다."
   - label: "기존 것 유지" / description: "asdf 없이 현재 설치된 도구를 그대로 사용합니다. 나머지만 설치합니다."
   - label: "기존 것 제거 후 asdf로" / description: "기존 버전 관리자를 제거하고 asdf로 깔끔하게 시작합니다."

   **"asdf로 통합" 선택 시:**
   - 기존 버전 관리자의 PATH/init 코드가 `.zshrc`에 있으면 asdf shim 뒤로 이동
   - `bootstrap_mac.sh` 정상 실행

   **"기존 것 유지" 선택 시:**
   - 스크립트에서 asdf 관련 단계(asdf plugin, asdf install)를 건너뛰도록 안내
   - 이미 설치된 Node.js 등은 스킵
   - 없는 것만 brew나 직접 설치로 대체
   - `.zshrc` 설정에서 asdf 관련 라인 제외

   **"기존 것 제거 후 asdf로" 선택 시:**
   - 각 버전 관리자 제거 방법을 안내하고 확인 후 진행:
     - nvm: `rm -rf ~/.nvm` + `.zshrc`에서 nvm 관련 라인 제거
     - fnm: `brew uninstall fnm` 또는 `rm -rf ~/.fnm`
     - volta: `rm -rf ~/.volta` + `.zshrc`에서 volta 관련 라인 제거
     - pyenv: `brew uninstall pyenv` 또는 `rm -rf ~/.pyenv`
   - 제거 후 `bootstrap_mac.sh` 정상 실행

**4-3. 스크립트 실행**

스크립트는 이미 설치된 항목은 자동으로 스킵합니다.

```bash
cd /path/to/claude-starter && \
  NODE_VERSION=20.12.0 \
  bash scripts/bootstrap_mac.sh
```

또는 스크립트의 각 함수를 Claude가 개별 Bash 호출로 실행:
스크립트의 로직을 참고하여, 각 단계를 Bash 도구로 하나씩 실행합니다.
각 단계 실행 후 결과를 사용자에게 보여주고, 실패하면 해결 방안을 안내합니다.

---

#### Windows를 선택한 경우

이 레포에 포함된 `scripts/bootstrap_windows.ps1` 스크립트를 사용합니다.
macOS의 `brew + asdf` 구조에 대응하는 `Scoop + mise` 구조로 설치합니다.

```
macOS 구조              Windows 대응
┌──────────────┐       ┌──────────────────┐
│ Homebrew     │  ───  │ Scoop            │  (패키지 관리자)
│ asdf         │  ───  │ mise             │  (런타임 버전 관리자)
│ iTerm2       │  ───  │ Windows Terminal │  (터미널 앱)
│ Oh My Zsh    │  ───  │ Oh My Posh       │  (터미널 꾸미기)
│ Powerlevel10k│  ───  │ paradox 테마      │  (프롬프트 테마)
│ zsh-auto*    │  ───  │ PSReadLine       │  (자동완성/히스토리)
└──────────────┘       └──────────────────┘
```

**4-1. 환경 진단**

Windows에서는 Claude Code가 직접 PowerShell을 실행할 수 없으므로,
사용자에게 아래를 PowerShell에 붙여넣기 하도록 안내:

```powershell
Write-Host "=== 환경 진단 ===" -ForegroundColor Cyan
Write-Host "OS: $([System.Environment]::OSVersion.VersionString)"
Write-Host "PowerShell: $($PSVersionTable.PSVersion)"
@("scoop","git","mise","node","python","mysql","psql","claude","docker") | ForEach-Object {
    $v = try { & $_ --version 2>$null | Select-Object -First 1 } catch { $null }
    if ($v) { Write-Host "  ${_}: $v" -ForegroundColor Green }
    else    { Write-Host "  ${_}: 미설치" -ForegroundColor Yellow }
}
```

**4-2. 기존 버전 관리자 확인**

nvm-windows, volta, pyenv-win 등이 발견되면 macOS와 동일한 3가지 선택지 제시:
- "mise로 통합 (추천)" - 기존 것 두고 mise 추가, PATH 우선순위로 해결
- "기존 것 유지" - mise 없이 진행
- "기존 것 제거 후 mise로" - 제거 안내 후 진행

**4-3. 스크립트 실행 안내**

사용자에게 PowerShell에서 아래 명령어를 실행하도록 안내:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/bootstrap_windows.ps1
```

**4-4. 설치 후 수동 마무리 안내**

1. Windows Terminal 폰트 설정: MesloLGS Nerd Font
2. `gh auth login` 으로 GitHub 로그인

**4-5. PowerShell 프로필 확인**

`bootstrap_windows.ps1`이 PowerShell 프로필에 alias와 설정을 추가하지만,
스크립트 미실행 또는 프로필 리셋으로 누락될 수 있습니다.
사용자에게 PowerShell에서 아래를 실행하도록 안내하여 `claude-danger` alias가 있는지 확인합니다:

```powershell
Get-Content $PROFILE | Select-String "claude-danger"
```

**결과가 없으면** 프로필에 직접 추가하도록 안내:

```powershell
Add-Content -Path $PROFILE -Value "`nfunction claude-danger { claude --dangerously-skip-permissions @args }"
```

> `claude-danger`는 권한 확인을 건너뛰는 alias로, 워크숍에서 빠른 진행을 위해 사용합니다.

---

#### Linux (Ubuntu/Debian)를 선택한 경우

macOS와 동일하게 asdf를 사용합니다. (Linux에서 asdf 네이티브 지원)

**4-1. 시스템 업데이트 + 기본 도구**
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl build-essential zsh tmux \
  openssl libssl-dev readline-common libreadline-dev \
  sqlite3 libsqlite3-dev xz-utils zlib1g-dev \
  libbz2-dev libffi-dev liblzma-dev tk-dev \
  autoconf automake libtool pkg-config
```

**4-2. Oh My Zsh + Powerlevel10k**
```bash
# Oh My Zsh
RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

# zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# 기본 셸을 zsh로
chsh -s $(which zsh)
```

**4-3. asdf 설치**
```bash
sudo apt install -y asdf 2>/dev/null || \
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0

echo '. "$HOME/.asdf/asdf.sh"' >> ~/.zshrc
source ~/.zshrc
```

**4-4. asdf로 런타임 설치**
macOS 스크립트의 asdf 부분과 동일한 로직으로 Node.js, Bun 설치

**4-5. 나머지 도구**
```bash
# Claude Code — 슬라이드 가이드에서 사전 설치됨, 스킵

# VS Code
sudo snap install code --classic

# Cursor
# cursor.com 에서 .deb 파일 다운로드 안내

# GitHub CLI
sudo apt install -y gh

# Nerd Fonts
mkdir -p ~/.local/share/fonts
curl -fLo ~/.local/share/fonts/MesloLGSNerdFont-Regular.ttf \
  https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Regular/MesloLGSNerdFont-Regular.ttf
fc-cache -fv
```

---

### Step 5.5: Claude Code 플러그인 설치

Claude Code가 설치되어 있다면, 이 레포에서 사용하는 플러그인들을 설치합니다.
`.claude/settings.json`의 `enabledPlugins`는 이미 설치된 플러그인을 "활성화"만 하므로, 플러그인 자체를 먼저 설치해야 합니다.

Bash 도구로 아래를 **순서대로** 실행하세요:

**1) `clarify` 플러그인용 마켓플레이스 등록**

`clarify`는 별도 마켓플레이스(`team-attention-plugins`)에 있으므로 먼저 등록합니다:

```bash
claude plugin marketplace add team-attention/plugins-for-claude-natives 2>/dev/null || true
```

**2) 모든 플러그인 설치**

공식 플러그인 포함 전부 명시적으로 설치합니다 (이미 설치된 경우 자동 스킵):

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

### Step 5.6: Claude Code Teams Mode 설정

Claude가 여러 에이전트를 동시에 돌리는 Teams 모드를 시각적으로 볼 수 있도록 설정합니다.
사용자에게 아래 설명 후 진행:

```
Teams 모드란?
┌─────────────────────────────────────────────┐
│ 터미널 하나                                  │
│ ┌───────────────┐  ┌───────────────┐        │
│ │ Claude (메인)  │  │ Claude (팀원1) │        │
│ │ 전체 지휘     │  │ 로그인 기능    │        │
│ └───────────────┘  └───────────────┘        │
│ ┌───────────────┐  ┌───────────────┐        │
│ │ Claude (팀원2) │  │ Claude (팀원3) │        │
│ │ 메인 페이지    │  │ 설정 페이지    │        │
│ └───────────────┘  └───────────────┘        │
└─────────────────────────────────────────────┘
하나의 화면에서 여러 Claude가 동시에 일하는 걸 볼 수 있어요!
```

Bash 도구로 프로젝트의 `.claude/settings.json`에 설정을 추가하세요.
기존 settings.json 내용을 읽어서, `env`와 `teammateMode` 키를 머지합니다:

```bash
# 수강생 프로젝트 디렉토리의 settings.json
cd projects/{프로젝트명}/.claude

# settings.json이 없으면 생성, 있으면 기존 내용에 머지
# env에 CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 추가
# teammateMode를 tmux로 설정
```

추가할 설정 키:
```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "teammateMode": "tmux"
}
```

> **주의**: 기존 settings.json에 다른 설정이 있으면 덮어쓰지 말고 머지합니다.
> 이 설정은 수강생 프로젝트 디렉토리(`projects/{프로젝트명}/.claude/settings.json`)에 추가합니다.
> claude-starter 레포의 settings.json이 아닙니다.

### Step 6: 최종 확인

모든 설치가 끝나면 Bash 도구로 전체 상태를 확인하세요.

```bash
echo "=== 최종 설치 확인 ===" && \
echo "Node.js: $(node --version 2>/dev/null || echo '❌')" && \
echo "Bun: $(bun --version 2>/dev/null || echo '❌')" && \
echo "Git: $(git --version 2>/dev/null || echo '❌')" && \
echo "Claude: $(claude --version 2>/dev/null || echo '❌')" && \
echo "Make: $(make --version 2>/dev/null | head -1 || echo '❌')"
```

결과를 표로 정리해서 보여주세요:
- ✅ 설치 완료된 것
- ❌ 미설치 (해당 단계 재안내)

```
✅ Step 0 완료! 모든 도구가 설치되었습니다.
다음 단계: /1-claude-md-setup 을 입력해주세요.
```

### Step 7: 수동 마무리 안내 (macOS만)

macOS 사용자에게 아래 수동 작업을 안내하세요:

1. `exec zsh -l` 로 새 셸 시작
2. iTerm2 폰트 설정: MesloLGS NF + Noto Sans Mono CJK KR
3. `p10k configure` 로 터미널 테마 설정
4. `gh auth login` 으로 GitHub 로그인
