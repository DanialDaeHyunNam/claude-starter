# =========================================================
# bootstrap_windows.ps1
# Requires: PowerShell 5.1+ (Windows 10/11 기본 내장)
# 실행: powershell -ExecutionPolicy Bypass -File bootstrap_windows.ps1
# =========================================================

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------
# 버전 설정
# ---------------------------------------------------------
$DEFAULT_NODE_VERSION = "latest"

$BUN_VERSION = "latest"

# ---------------------------------------------------------
# 로그
# ---------------------------------------------------------
$LOG_DIR  = "$HOME\.bootstrap-logs"
$LOG_FILE = "$LOG_DIR\bootstrap-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

if (-not (Test-Path $LOG_DIR)) { New-Item -ItemType Directory -Path $LOG_DIR -Force | Out-Null }

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "HH:mm:ss"
    $line = "[$ts] $Message"
    Write-Host $line
    Add-Content -Path $LOG_FILE -Value $line
}

# ---------------------------------------------------------
# 컬러 출력
# ---------------------------------------------------------
function Write-Cyan    { param([string]$M) Write-Host $M -ForegroundColor Cyan }
function Write-Green   { param([string]$M) Write-Host $M -ForegroundColor Green }
function Write-Yellow  { param([string]$M) Write-Host $M -ForegroundColor Yellow }
function Write-Red     { param([string]$M) Write-Host $M -ForegroundColor Red }

# ---------------------------------------------------------
# 스텝 카운터
# ---------------------------------------------------------
$CURRENT_STEP  = 0
$STEP_START    = $null

function Get-TotalSteps {
    return 11
}

$TOTAL_STEPS = 0

function Start-Step {
    param([string]$Name)
    $script:CURRENT_STEP++
    $script:STEP_START = Get-Date
    Write-Host ""
    Write-Cyan "[$CURRENT_STEP/$TOTAL_STEPS] $Name"
}

function Finish-Step {
    $elapsed = [math]::Round(((Get-Date) - $STEP_START).TotalSeconds)
    Write-Green "  done (${elapsed}s)"
}

# ---------------------------------------------------------
# 유틸
# ---------------------------------------------------------
function Test-Command {
    param([string]$Cmd)
    $null -ne (Get-Command $Cmd -ErrorAction SilentlyContinue)
}

function Install-ScoopPackage {
    param([string]$Package)
    if (scoop list $Package 2>$null | Select-String $Package) {
        Write-Log "already installed: $Package"
    } else {
        Write-Log "installing: $Package"
        scoop install $Package
    }
}

# ---------------------------------------------------------
# 버전 입력
# ---------------------------------------------------------
function Prompt-Versions {
    Write-Host ""
    Write-Host "설치할 기본 버전을 입력해줘. 엔터면 기본값 사용." -ForegroundColor White

    if ([string]::IsNullOrWhiteSpace($env:NODE_VERSION)) {
        $script:NODE_VERSION = Read-Host "Node.js version [$DEFAULT_NODE_VERSION]"
    } else {
        $script:NODE_VERSION = $env:NODE_VERSION
    }
    if ([string]::IsNullOrWhiteSpace($NODE_VERSION)) { $script:NODE_VERSION = $DEFAULT_NODE_VERSION }

    Write-Host "선택된 버전:"
    Write-Host "  Node.js  : $NODE_VERSION"
}

# =========================================================
# Scoop (Homebrew 대응)
# =========================================================
function Install-Scoop {
    if (Test-Command "scoop") {
        Write-Log "Scoop already installed"
        return
    }

    Write-Log "Installing Scoop..."
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

# =========================================================
# Scoop 기본 패키지
# =========================================================
function Install-ScoopBasePackages {
    # extras bucket (GUI 앱용)
    if (-not (scoop bucket list | Select-String "extras")) {
        scoop bucket add extras
    }
    # nerd-fonts bucket
    if (-not (scoop bucket list | Select-String "nerd-fonts")) {
        scoop bucket add nerd-fonts
    }

    Install-ScoopPackage "git"
    Install-ScoopPackage "curl"
    Install-ScoopPackage "coreutils"
    Install-ScoopPackage "openssl"
    Install-ScoopPackage "7zip"
    Install-ScoopPackage "tmux"
}

# =========================================================
# mise (asdf 대응)
# =========================================================
function Install-Mise {
    if (Test-Command "mise") {
        Write-Log "mise already installed"
        return
    }

    Write-Log "Installing mise..."
    scoop install mise

    # PowerShell 프로필에 mise activate 추가
    $profilePath = $PROFILE
    $profileDir  = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Path $profilePath -Force | Out-Null }

    $miseLine = 'mise activate pwsh | Out-String | Invoke-Expression'
    if (-not (Select-String -Path $profilePath -Pattern "mise activate" -Quiet -ErrorAction SilentlyContinue)) {
        Add-Content -Path $profilePath -Value "`n# mise (asdf-compatible version manager)`n$miseLine"
        Write-Log "Added mise activation to PowerShell profile"
    }

    # 현재 세션에서도 활성화
    & mise activate pwsh | Out-String | Invoke-Expression
}

# =========================================================
# Node.js (mise)
# =========================================================
function Install-Node {
    Write-Log "Installing Node.js $NODE_VERSION via mise..."
    mise install "node@$NODE_VERSION"
    mise use --global "node@$NODE_VERSION"
    Write-Log "Node.js: $(node --version 2>$null)"
}

# =========================================================
# Bun (mise)
# =========================================================
function Install-Bun {
    Write-Log "Installing Bun via mise..."
    mise install "bun@$BUN_VERSION"
    mise use --global "bun@$BUN_VERSION"
}

# =========================================================
# 앱 설치 (GUI)
# =========================================================
function Install-Apps {
    # Windows Terminal (Win11 기본, Win10은 설치 필요)
    if (-not (Get-AppxPackage -Name "Microsoft.WindowsTerminal" -ErrorAction SilentlyContinue)) {
        Write-Log "Installing Windows Terminal..."
        Install-ScoopPackage "windows-terminal"
    } else {
        Write-Log "Windows Terminal already installed"
    }

    # VS Code
    $vscodePath = "$env:LOCALAPPDATA\Programs\Microsoft VS Code\Code.exe"
    if (-not (Test-Path $vscodePath) -and -not (Test-Command "code")) {
        Install-ScoopPackage "vscode"
    } else {
        Write-Log "VS Code already installed"
    }

    # Cursor
    $cursorPath = "$env:LOCALAPPDATA\Programs\Cursor\Cursor.exe"
    if (-not (Test-Path $cursorPath)) {
        Write-Yellow "Cursor: https://cursor.com 에서 직접 설치해주세요"
    } else {
        Write-Log "Cursor already installed"
    }

    # GitHub CLI
    Install-ScoopPackage "gh"
}

# =========================================================
# Oh My Posh + 터미널 꾸미기 (Powerlevel10k 대응)
# =========================================================
function Install-OhMyPosh {
    # Oh My Posh 설치
    if (-not (Test-Command "oh-my-posh")) {
        Write-Log "Installing Oh My Posh..."
        Install-ScoopPackage "oh-my-posh"
    } else {
        Write-Log "Oh My Posh already installed"
    }

    # Nerd Font 설치 (MesloLGS NF - Powerlevel10k와 동일 폰트)
    Write-Log "Installing Nerd Fonts..."
    scoop install nerd-fonts/Meslo-NF 2>$null
    scoop install nerd-fonts/FiraCode 2>$null
    scoop install nerd-fonts/NotoSansMono-NF 2>$null

    # PSReadLine (자동완성 - zsh-autosuggestions 대응)
    Write-Log "Configuring PSReadLine..."

    # Terminal-Icons (파일 아이콘)
    if (-not (Get-Module -ListAvailable -Name Terminal-Icons -ErrorAction SilentlyContinue)) {
        Write-Log "Installing Terminal-Icons module..."
        Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
    }

    # PowerShell 프로필 설정
    $profilePath = $PROFILE
    $profileDir  = Split-Path $profilePath -Parent
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }
    if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Path $profilePath -Force | Out-Null }

    # 기존 프로필 백업
    $backupPath = "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $profilePath -Destination $backupPath -ErrorAction SilentlyContinue

    # 프로필 작성
    $profileContent = @'
# =========================================================
# PowerShell Profile (claude-starter bootstrap)
# =========================================================

# --- Oh My Posh (Powerlevel10k 대응) ---
# 테마: paradox (p10k과 유사한 2줄 프롬프트)
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\paradox.omp.json" | Invoke-Expression

# --- PSReadLine (zsh-autosuggestions + zsh-syntax-highlighting 대응) ---
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs
Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# --- Terminal-Icons (파일 아이콘) ---
Import-Module -Name Terminal-Icons -ErrorAction SilentlyContinue

# --- mise (asdf 대응) ---
if (Get-Command mise -ErrorAction SilentlyContinue) {
    mise activate pwsh | Out-String | Invoke-Expression
}

# --- Aliases ---
Set-Alias -Name ll -Value Get-ChildItem
function which($cmd) { (Get-Command $cmd -ErrorAction SilentlyContinue).Source }
function claude-danger { claude --dangerously-skip-permissions @args }

# --- dotenv ---
function dotenv-prod {
    if (Test-Path .env) {
        Get-Content .env | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                [System.Environment]::SetEnvironmentVariable($Matches[1].Trim(), $Matches[2].Trim(), "Process")
            }
        }
    }
}

function dotenv {
    if (Test-Path .env.local) {
        Get-Content .env.local | ForEach-Object {
            if ($_ -match '^\s*([^#][^=]+)=(.*)$') {
                [System.Environment]::SetEnvironmentVariable($Matches[1].Trim(), $Matches[2].Trim(), "Process")
            }
        }
    }
}
'@

    Set-Content -Path $profilePath -Value $profileContent -Encoding UTF8
    Write-Log "PowerShell profile written to: $profilePath"
    Write-Log "Backup saved to: $backupPath"
}

# =========================================================
# Windows Terminal Snazzy 컬러 스킴 적용
# =========================================================
function Install-SnazzyColorScheme {
    # Windows Terminal settings.json 경로
    $wtSettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
    $wtPreviewPath  = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    $scoopWtPath    = "$env:LOCALAPPDATA\Microsoft\Windows Terminal\settings.json"

    # 사용 가능한 경로 찾기
    $settingsPath = $null
    foreach ($p in @($wtSettingsPath, $wtPreviewPath, $scoopWtPath)) {
        if (Test-Path $p) { $settingsPath = $p; break }
    }

    if (-not $settingsPath) {
        Write-Yellow "Windows Terminal settings.json을 찾을 수 없습니다. 수동 설정이 필요합니다."
        return
    }

    Write-Log "Windows Terminal settings found: $settingsPath"

    # 백업
    $backupPath = "$settingsPath.backup.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $settingsPath -Destination $backupPath
    Write-Log "Settings backup: $backupPath"

    # settings.json 읽기
    $settingsRaw = Get-Content -Path $settingsPath -Raw
    # 주석 제거 (Windows Terminal JSON은 주석 허용)
    $settingsClean = $settingsRaw -replace '//.*$', '' -replace '/\*[\s\S]*?\*/', ''
    $settings = $settingsClean | ConvertFrom-Json

    # Snazzy 컬러 스킴 (iTerm2 snazzy.itermcolors에서 변환)
    $snazzyScheme = @{
        name            = "Snazzy"
        background      = "#1E1F29"
        foreground      = "#EBECE6"
        cursorColor     = "#E4E4E4"
        selectionBackground = "#81A2D4C6"
        black           = "#000000"
        red             = "#FC4346"
        green           = "#50FB7C"
        yellow          = "#F0FB8C"
        blue            = "#49BAFF"
        purple          = "#FC4CB4"
        cyan            = "#8BE9FE"
        white           = "#EDEEEC"
        brightBlack     = "#555555"
        brightRed       = "#FC4346"
        brightGreen     = "#50FB7C"
        brightYellow    = "#F0FB8C"
        brightBlue      = "#49BAFF"
        brightPurple    = "#FC4CB4"
        brightCyan      = "#8BE9FE"
        brightWhite     = "#EDEEEC"
    }

    # schemes 배열이 없으면 생성
    if (-not $settings.schemes) {
        $settings | Add-Member -MemberType NoteProperty -Name "schemes" -Value @()
    }

    # 기존 Snazzy 제거 후 추가
    $settings.schemes = @($settings.schemes | Where-Object { $_.name -ne "Snazzy" }) + $snazzyScheme

    # 기본 프로필에 Snazzy 적용 + 폰트 설정
    if (-not $settings.profiles.defaults) {
        $settings.profiles | Add-Member -MemberType NoteProperty -Name "defaults" -Value @{}
    }
    $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name "colorScheme" -Value "Snazzy" -Force
    $settings.profiles.defaults | Add-Member -MemberType NoteProperty -Name "font" -Value @{
        face = "MesloLGS Nerd Font"
        size = 12
    } -Force

    # 저장
    $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath -Encoding UTF8
    Write-Green "  Snazzy color scheme applied to Windows Terminal"
    Write-Green "  Font set to MesloLGS Nerd Font (12pt)"
}

# =========================================================
# Claude Code
# =========================================================
function Install-ClaudeCode {
    if (Test-Command "claude") {
        Write-Log "Claude Code already installed"
        return
    }

    Write-Log "Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
}

# =========================================================
# 최종 확인
# =========================================================
function Print-Versions {
    Write-Host ""
    Write-Host "==================== versions ====================" -ForegroundColor White

    # Required
    $checks = @(
        @{ Name = "scoop";      Cmd = { scoop --version 2>$null | Select-Object -First 1 } },
        @{ Name = "git";        Cmd = { git --version 2>$null } },
        @{ Name = "mise";       Cmd = { mise --version 2>$null } },
        @{ Name = "node";       Cmd = { node --version 2>$null } },
        @{ Name = "bun";        Cmd = { bun --version 2>$null } },
        @{ Name = "claude";     Cmd = { claude --version 2>$null } },
        @{ Name = "oh-my-posh"; Cmd = { oh-my-posh --version 2>$null } },
        @{ Name = "gh";         Cmd = { gh --version 2>$null | Select-Object -First 1 } }
    )

    foreach ($c in $checks) {
        $ver = try { & $c.Cmd } catch { $null }
        if ($ver) {
            Write-Host ("  {0,-12}: {1}" -f $c.Name, $ver) -ForegroundColor Green
        } else {
            Write-Host ("  {0,-12}: not installed" -f $c.Name) -ForegroundColor Red
        }
    }

    Write-Host "==================================================" -ForegroundColor White
    Write-Host ""
}

function Print-ManualSteps {
    Write-Host @"

========================================================
수동 마무리 체크리스트
========================================================

[1] 새 PowerShell 세션 시작
  PowerShell을 닫고 다시 열어주세요

[2] Windows Terminal 폰트 설정
  Windows Terminal -> 설정 -> 프로필 -> 기본값 -> 모양
  - 글꼴: MesloLGS Nerd Font
  - 글꼴 크기: 12

[3] Oh My Posh 테마 변경 (선택사항)
  사용 가능한 테마 목록:
    Get-PoshThemes
  테마 변경: PowerShell 프로필에서 paradox.omp.json을
  원하는 테마 파일로 교체

[4] Claude Code 로그인
  claude

[5] GitHub 로그인
  gh auth login

"@

    Write-Host @"
[로그 파일]
  $LOG_FILE

========================================================
"@
}

# =========================================================
# Main
# =========================================================
function Main {
    $script:TOTAL_STEPS = Get-TotalSteps

    Write-Host ""
    Write-Cyan "========================================="
    Write-Cyan "  Windows Bootstrap (Scoop + mise)"
    Write-Cyan "========================================="

    Prompt-Versions

    Start-Step "Scoop 설치 (패키지 관리자)"
    Install-Scoop
    Finish-Step

    Start-Step "Scoop 기본 패키지 설치"
    Install-ScoopBasePackages
    Finish-Step

    Start-Step "mise 설치 (버전 관리자)"
    Install-Mise
    Finish-Step

    Start-Step "Node.js $NODE_VERSION 설치"
    Install-Node
    Finish-Step

    Start-Step "Bun 설치"
    Install-Bun
    Finish-Step

    Start-Step "앱 설치 (Windows Terminal, VS Code 등)"
    Install-Apps
    Finish-Step

    Start-Step "Oh My Posh + 터미널 꾸미기"
    Install-OhMyPosh
    Finish-Step

    Start-Step "Windows Terminal Snazzy 컬러 스킴 적용"
    Install-SnazzyColorScheme
    Finish-Step

    # Claude Code는 슬라이드 가이드에서 사전 설치됨 — 스킵

    Start-Step "최종 확인"
    Print-Versions
    Finish-Step

    Print-ManualSteps
    Write-Green "전체 완료! PowerShell을 재시작해주세요."
}

Main
