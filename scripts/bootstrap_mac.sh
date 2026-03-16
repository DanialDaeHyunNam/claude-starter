#!/usr/bin/env bash
set -Eeuo pipefail

# =========================================================
# bootstrap_mac.sh
# =========================================================

CURRENT_STEP=0
STEP_START_TS=0

DEFAULT_NODE_VERSION="20.12.0"
DEFAULT_PYTHON_VERSION="3.9.1"
DEFAULT_MYSQL_VERSION="8.0.34"
DEFAULT_POSTGRES_VERSION="17.6"

BUN_VERSION="latest"
UV_VERSION="latest"
AWSCLI_VERSION="latest"

NODE_VERSION="${NODE_VERSION:-}"
PYTHON_VERSION="${PYTHON_VERSION:-}"
MYSQL_VERSION="${MYSQL_VERSION:-}"
POSTGRES_VERSION="${POSTGRES_VERSION:-}"

# Optional tool flags (0=skip, 1=install)
INSTALL_PYTHON="${INSTALL_PYTHON:-0}"
INSTALL_MYSQL="${INSTALL_MYSQL:-0}"
INSTALL_POSTGRES="${INSTALL_POSTGRES:-0}"
INSTALL_DOCKER="${INSTALL_DOCKER:-0}"
INSTALL_AWSCLI="${INSTALL_AWSCLI:-0}"
INSTALL_CHROME="${INSTALL_CHROME:-0}"
INSTALL_PGADMIN="${INSTALL_PGADMIN:-0}"

ZSHRC="${HOME}/.zshrc"
OHMYZSH_DIR="${HOME}/.oh-my-zsh"
ZSH_CUSTOM_DIR="${OHMYZSH_DIR}/custom"
P10K_DIR="${ZSH_CUSTOM_DIR}/themes/powerlevel10k"

ASDF_DIR="${HOME}/.asdf"

LOG_DIR="${HOME}/.bootstrap-logs"
LOG_FILE="${LOG_DIR}/bootstrap-$(date +%Y%m%d-%H%M%S).log"

mkdir -p "${LOG_DIR}"
touch "${ZSHRC}"

exec > >(tee -a "${LOG_FILE}") 2>&1

bold()   { printf "\033[1m%s\033[0m\n" "$1"; }
cyan()   { printf "\033[1;36m%s\033[0m\n" "$1"; }
green()  { printf "\033[1;32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[1;33m%s\033[0m\n" "$1"; }
red()    { printf "\033[1;31m%s\033[0m\n" "$1"; }

append_if_missing() {
  local file="$1"
  local line="$2"
  touch "$file"
  grep -Fqx "$line" "$file" 2>/dev/null || printf '%s\n' "$line" >> "$file"
}

calc_total_steps() {
  local total=16  # base required steps
  [[ "${INSTALL_PYTHON}" == "1" ]] && total=$((total + 2))  # python + uv
  [[ "${INSTALL_AWSCLI}" == "1" ]] && total=$((total + 1))
  [[ "${INSTALL_MYSQL}" == "1" ]] && total=$((total + 1))
  [[ "${INSTALL_POSTGRES}" == "1" ]] && total=$((total + 1))
  echo "$total"
}

TOTAL_STEPS=0

start_step() {
  CURRENT_STEP=$((CURRENT_STEP + 1))
  STEP_START_TS=$(date +%s)
  echo
  cyan "[$CURRENT_STEP/$TOTAL_STEPS] $1"
}

finish_step() {
  local end_ts elapsed
  end_ts=$(date +%s)
  elapsed=$((end_ts - STEP_START_TS))
  green "✔ 완료 (${elapsed}s)"
}

on_error() {
  local exit_code=$?
  local line_no="${1:-unknown}"
  echo
  red "✖ 실패: ${CURRENT_STEP}/${TOTAL_STEPS} 단계, line ${line_no}, exit code ${exit_code}"
  yellow "로그 파일: ${LOG_FILE}"
  exit "${exit_code}"
}
trap 'on_error $LINENO' ERR

prompt_versions() {
  echo
  bold "설치할 기본 버전을 입력해줘. 엔터면 기본값 사용."

  if [[ -z "${NODE_VERSION}" ]]; then
    read -r -p "Node.js version [${DEFAULT_NODE_VERSION}]: " NODE_VERSION
  fi
  NODE_VERSION="${NODE_VERSION:-$DEFAULT_NODE_VERSION}"

  if [[ "${INSTALL_PYTHON}" == "1" && -z "${PYTHON_VERSION}" ]]; then
    read -r -p "Python version [${DEFAULT_PYTHON_VERSION}]: " PYTHON_VERSION
  fi
  PYTHON_VERSION="${PYTHON_VERSION:-$DEFAULT_PYTHON_VERSION}"

  if [[ "${INSTALL_MYSQL}" == "1" && -z "${MYSQL_VERSION}" ]]; then
    read -r -p "MySQL version [${DEFAULT_MYSQL_VERSION}]: " MYSQL_VERSION
  fi
  MYSQL_VERSION="${MYSQL_VERSION:-$DEFAULT_MYSQL_VERSION}"

  if [[ "${INSTALL_POSTGRES}" == "1" && -z "${POSTGRES_VERSION}" ]]; then
    read -r -p "Postgres version [${DEFAULT_POSTGRES_VERSION}]: " POSTGRES_VERSION
  fi
  POSTGRES_VERSION="${POSTGRES_VERSION:-$DEFAULT_POSTGRES_VERSION}"

  echo "선택된 버전:"
  echo "  Node.js  : ${NODE_VERSION}"
  [[ "${INSTALL_PYTHON}" == "1" ]] && echo "  Python   : ${PYTHON_VERSION}"
  [[ "${INSTALL_MYSQL}" == "1" ]] && echo "  MySQL    : ${MYSQL_VERSION}"
  [[ "${INSTALL_POSTGRES}" == "1" ]] && echo "  Postgres : ${POSTGRES_VERSION}"
}

ensure_xcode_cli_tools() {
  if xcode-select -p >/dev/null 2>&1; then
    echo "Xcode Command Line Tools: already installed"
    return 0
  fi

  yellow "Xcode Command Line Tools가 없어 설치를 시작합니다."
  xcode-select --install || true
  yellow "설치 창에서 완료해 주세요. 완료되면 자동으로 계속 진행합니다."

  local waited=0
  local interval=20
  local timeout=3600

  while ! xcode-select -p >/dev/null 2>&1; do
    sleep "${interval}"
    waited=$((waited + interval))
    echo " ... waiting for Command Line Tools (${waited}s elapsed)"
    if (( waited >= timeout )); then
      red "Xcode Command Line Tools 설치 대기 시간이 초과되었습니다."
      return 1
    fi
  done

  echo "Xcode Command Line Tools 설치 확인 완료"
}

ensure_sudo() {
  sudo -v
}

ensure_xcode_license() {
  if sudo xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
    echo "Xcode license / first launch already handled"
    return 0
  fi

  yellow "Xcode license / first launch 자동 처리 시도 중..."
  sudo xcodebuild -license accept || true
  sudo xcodebuild -runFirstLaunch || true

  if sudo xcodebuild -checkFirstLaunchStatus >/dev/null 2>&1; then
    echo "Xcode license / first launch 처리 완료"
    return 0
  fi

  red "Xcode license / first launch 자동 처리 실패"
  yellow "직접 아래 명령 실행 후 다시 시도:"
  yellow "  sudo xcodebuild -license"
  yellow "  sudo xcodebuild -runFirstLaunch"
  return 1
}

setup_homebrew_env() {
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    red "brew not found"
    return 1
  fi
}

install_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    echo "Homebrew already installed"
  else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  setup_homebrew_env

  if [[ -x /opt/homebrew/bin/brew ]]; then
    append_if_missing "${ZSHRC}" 'eval "$(/opt/homebrew/bin/brew shellenv)"'
  elif [[ -x /usr/local/bin/brew ]]; then
    append_if_missing "${ZSHRC}" 'eval "$(/usr/local/bin/brew shellenv)"'
  fi
}

install_formula_if_needed() {
  local formula="$1"
  if brew list --formula "$formula" >/dev/null 2>&1; then
    echo "formula already installed: $formula"
  else
    brew install "$formula"
  fi
}

install_cask_if_needed() {
  local cask="$1"
  local app_path="${2:-}"

  if brew list --cask "$cask" >/dev/null 2>&1; then
    echo "cask already installed by Homebrew: $cask"
    return 0
  fi

  if [[ -n "$app_path" && -e "$app_path" ]]; then
    echo "cask skipped (app already exists): $cask -> $app_path"
    return 0
  fi

  brew install --cask "$cask"
}

install_font_cask_best_effort() {
  local cask="$1"
  if brew list --cask "$cask" >/dev/null 2>&1; then
    echo "font cask already installed: $cask"
    return 0
  fi

  if brew install --cask "$cask"; then
    echo "font installed: $cask"
  else
    yellow "font install skipped/failed: $cask (continuing)"
  fi
}

install_brew_packages() {
  brew update

  install_formula_if_needed git
  install_formula_if_needed coreutils
  install_formula_if_needed bash
  install_formula_if_needed curl
  install_formula_if_needed gawk
  install_formula_if_needed gpg
  install_formula_if_needed openssl@3
  install_formula_if_needed readline
  install_formula_if_needed sqlite3
  install_formula_if_needed xz
  install_formula_if_needed zlib
  install_formula_if_needed tcl-tk
  install_formula_if_needed pkg-config
  install_formula_if_needed autoconf
  install_formula_if_needed automake
  install_formula_if_needed libtool
  install_formula_if_needed bison
  install_formula_if_needed icu4c
  install_formula_if_needed zstd
  install_formula_if_needed asdf

  install_cask_if_needed iterm2 "/Applications/iTerm.app"
  install_cask_if_needed cursor "/Applications/Cursor.app"
  install_cask_if_needed visual-studio-code "/Applications/Visual Studio Code.app"

  [[ "${INSTALL_CHROME}" == "1" ]] && install_cask_if_needed google-chrome "/Applications/Google Chrome.app"
  [[ "${INSTALL_DOCKER}" == "1" ]] && install_cask_if_needed docker-desktop "/Applications/Docker.app"
  [[ "${INSTALL_PGADMIN}" == "1" ]] && install_cask_if_needed pgadmin4 "/Applications/pgAdmin 4.app"

  install_font_cask_best_effort font-meslo-lg-nerd-font
  install_font_cask_best_effort font-fira-code
  install_font_cask_best_effort font-noto-sans-mono-cjk-kr
}

install_oh_my_zsh() {
  if [[ -d "${OHMYZSH_DIR}" ]]; then
    echo "Oh My Zsh already installed"
    return 0
  fi

  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_powerlevel10k() {
  mkdir -p "${ZSH_CUSTOM_DIR}/themes"

  if [[ -d "${P10K_DIR}" ]]; then
    echo "Powerlevel10k already installed"
  else
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${P10K_DIR}"
  fi
}

install_zsh_plugins() {
  mkdir -p "${ZSH_CUSTOM_DIR}/plugins"

  if [[ ! -d "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting" ]]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
      "${ZSH_CUSTOM_DIR}/plugins/zsh-syntax-highlighting"
  else
    echo "plugin already installed: zsh-syntax-highlighting"
  fi

  if [[ ! -d "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions" ]]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions \
      "${ZSH_CUSTOM_DIR}/plugins/zsh-autosuggestions"
  else
    echo "plugin already installed: zsh-autosuggestions"
  fi
}

configure_shell_files() {
  # Base .zshrc
  cat > "${ZSHRC}" <<'BASEOF'
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  asdf
)

source "$ZSH/oh-my-zsh.sh"

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv 2>/dev/null || true)"

export PATH="$HOME/.local/bin:$PATH"
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
export PATH="$HOME/.bun/bin:$PATH"

alias python=python3
alias pip=pip3
alias ll="ls -lah"
alias claude-danger='claude --dangerously-skip-permissions'

env_context() {
  if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
  fi
}
alias dotenv-prod=env_context

local_env_context() {
  if [ -f .env.local ]; then
    export $(grep -v '^#' .env.local | xargs)
  fi
}
alias dotenv=local_env_context
BASEOF

  # Optional: MySQL PATH
  if [[ "${INSTALL_MYSQL}" == "1" ]]; then
    printf '\nexport PATH="$HOME/.asdf/installs/mysql/%s/bin:$PATH"\n' "${MYSQL_VERSION}" >> "${ZSHRC}"
  fi

  # Optional: PostgreSQL PATH + PGDATA
  if [[ "${INSTALL_POSTGRES}" == "1" ]]; then
    printf '\nexport PATH="$HOME/.asdf/installs/postgres/%s/bin:$PATH"\n' "${POSTGRES_VERSION}" >> "${ZSHRC}"
    printf 'export PGDATA="$HOME/.asdf/installs/postgres/%s/data"\n' "${POSTGRES_VERSION}" >> "${ZSHRC}"
  fi
}

write_p10k_config() {
  if [[ -f "${HOME}/.p10k.zsh" ]]; then
    echo ".p10k.zsh already exists, keeping it"
    return 0
  fi

  cat > "${HOME}/.p10k.zsh" <<'EOF'
'builtin' 'local' '-a' 'p10k_config_opts'
[[ ! -o 'aliases' ]] || p10k_config_opts+=('aliases')
[[ ! -o 'sh_glob' ]] || p10k_config_opts+=('sh_glob')
[[ ! -o 'no_brace_expand' ]] || p10k_config_opts+=('no_brace_expand')
'builtin' 'setopt' 'no_aliases' 'no_sh_glob' 'brace_expand'

() {
  emulate -L zsh -o extended_glob
  typeset -g POWERLEVEL9K_MODE=nerdfont-complete
  typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
  typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=''
  typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX='❯ '
  typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(dir vcs)
  typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status command_execution_time node_version python_version asdf time)
  typeset -g POWERLEVEL9K_SHORTEN_STRATEGY=truncate_to_unique
  typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M}'
  typeset -g POWERLEVEL9K_COMMAND_EXECUTION_TIME_THRESHOLD=3
  typeset -g POWERLEVEL9K_STATUS_OK=false
  typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
EOF
}

ensure_asdf_on_path() {
  if command -v asdf >/dev/null 2>&1; then
    return 0
  fi

  setup_homebrew_env

  if command -v asdf >/dev/null 2>&1; then
    return 0
  fi

  red "asdf command not found"
  return 1
}

install_asdf_plugins() {
  ensure_asdf_on_path

  asdf plugin list | grep -qx "nodejs" || asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git
  asdf plugin list | grep -qx "bun" || asdf plugin add bun https://github.com/cometkim/asdf-bun.git

  if [[ "${INSTALL_PYTHON}" == "1" ]]; then
    asdf plugin list | grep -qx "python" || asdf plugin add python https://github.com/asdf-community/asdf-python.git
    asdf plugin list | grep -qx "uv" || asdf plugin add uv https://github.com/asdf-community/asdf-uv.git
  fi

  if [[ "${INSTALL_AWSCLI}" == "1" ]]; then
    asdf plugin list | grep -qx "awscli" || asdf plugin add awscli https://github.com/MetricMike/asdf-awscli.git
  fi

  if [[ "${INSTALL_MYSQL}" == "1" ]]; then
    asdf plugin list | grep -qx "mysql" || asdf plugin add mysql https://github.com/iroddis/asdf-mysql.git
  fi

  if [[ "${INSTALL_POSTGRES}" == "1" ]]; then
    asdf plugin list | grep -qx "postgres" || asdf plugin add postgres https://github.com/smashedtoatoms/asdf-postgres.git
  fi
}

asdf_install_if_needed() {
  local plugin="$1"
  local version="$2"

  if asdf list "$plugin" 2>/dev/null | sed 's/^[[:space:]]*//' | grep -qx "$version"; then
    echo "$plugin $version already installed"
  else
    asdf install "$plugin" "$version"
  fi
}

install_node() {
  asdf_install_if_needed nodejs "${NODE_VERSION}"
  asdf set -u nodejs "${NODE_VERSION}"
  asdf reshim nodejs
}

install_python() {
  export LDFLAGS="-L$(brew --prefix zlib)/lib -L$(brew --prefix readline)/lib -L$(brew --prefix sqlite3)/lib -L$(brew --prefix openssl@3)/lib"
  export CPPFLAGS="-I$(brew --prefix zlib)/include -I$(brew --prefix readline)/include -I$(brew --prefix sqlite3)/include -I$(brew --prefix openssl@3)/include"
  export PKG_CONFIG_PATH="$(brew --prefix zlib)/lib/pkgconfig:$(brew --prefix readline)/lib/pkgconfig:$(brew --prefix sqlite3)/lib/pkgconfig:$(brew --prefix openssl@3)/lib/pkgconfig"

  asdf_install_if_needed python "${PYTHON_VERSION}"
  asdf set -u python "${PYTHON_VERSION}"
  asdf reshim python
}

install_bun() {
  asdf install bun "${BUN_VERSION}" || true
  asdf set -u bun "${BUN_VERSION}"
  asdf reshim bun
}

install_uv() {
  asdf install uv "${UV_VERSION}" || true
  asdf set -u uv "${UV_VERSION}"
  asdf reshim uv
}

install_awscli() {
  asdf install awscli "${AWSCLI_VERSION}" || true
  asdf set -u awscli "${AWSCLI_VERSION}"
  asdf reshim awscli
}

install_mysql() {
  asdf_install_if_needed mysql "${MYSQL_VERSION}"
  asdf set -u mysql "${MYSQL_VERSION}"
  asdf reshim mysql

  local mysql_base="${HOME}/.asdf/installs/mysql/${MYSQL_VERSION}"
  local mysql_data="${mysql_base}/data"

  mkdir -p "${mysql_data}"

  if [[ -x "${mysql_base}/bin/mysqld" ]]; then
    if [[ ! -d "${mysql_data}/mysql" ]]; then
      echo "Initializing MySQL data directory..."
      "${mysql_base}/bin/mysqld" \
        --initialize \
        --basedir="${mysql_base}" \
        --datadir="${mysql_data}" || true
    else
      echo "MySQL already initialized"
    fi
  fi
}

install_postgres() {
  asdf_install_if_needed postgres "${POSTGRES_VERSION}"
  asdf set -u postgres "${POSTGRES_VERSION}"
  asdf reshim postgres

  local pg_base="${HOME}/.asdf/installs/postgres/${POSTGRES_VERSION}"
  local pg_data="${pg_base}/data"

  mkdir -p "${pg_data}"

  if [[ -x "${pg_base}/bin/initdb" ]]; then
    if [[ ! -f "${pg_data}/PG_VERSION" ]]; then
      echo "Initializing PostgreSQL data directory..."
      "${pg_base}/bin/initdb" -D "${pg_data}" -E UTF8 || true
    else
      echo "Postgres already initialized"
    fi
  fi
}

install_vscode_extensions() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local ext_file="${script_dir}/../assets/vscode-extensions.txt"

  if [[ ! -f "$ext_file" ]]; then
    yellow "vscode-extensions.txt not found at: $ext_file"
    return 0
  fi

  # VS Code에 설치
  if command -v code >/dev/null 2>&1; then
    echo "Installing extensions to VS Code..."
    while IFS= read -r ext; do
      ext="$(echo "$ext" | xargs)"  # trim whitespace
      [[ -z "$ext" || "$ext" == \#* ]] && continue
      if code --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
        echo "  already installed: $ext"
      else
        code --install-extension "$ext" --force 2>/dev/null || yellow "  failed: $ext"
      fi
    done < "$ext_file"
  else
    yellow "VS Code (code) command not found, skipping VS Code extensions"
  fi

  # Cursor에도 동일하게 설치
  if command -v cursor >/dev/null 2>&1; then
    echo "Installing extensions to Cursor..."
    while IFS= read -r ext; do
      ext="$(echo "$ext" | xargs)"
      [[ -z "$ext" || "$ext" == \#* ]] && continue
      if cursor --list-extensions 2>/dev/null | grep -qi "^${ext}$"; then
        echo "  already installed: $ext"
      else
        cursor --install-extension "$ext" --force 2>/dev/null || yellow "  failed: $ext"
      fi
    done < "$ext_file"
  else
    yellow "Cursor command not found, skipping Cursor extensions"
  fi
}

import_iterm_colorscheme() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  local colors_file="${script_dir}/../assets/snazzy.itermcolors"

  if [[ ! -f "$colors_file" ]]; then
    yellow "snazzy.itermcolors not found at: $colors_file"
    return 0
  fi

  # iTerm2에 컬러 프리셋 임포트
  if [[ -d "/Applications/iTerm.app" ]]; then
    open "$colors_file" 2>/dev/null || true
    echo "Snazzy color scheme imported to iTerm2"

    # Default Profile에 Snazzy 적용 (PlistBuddy 사용)
    local iterm_plist="${HOME}/Library/Preferences/com.googlecode.iterm2.plist"
    if [[ -f "$iterm_plist" ]]; then
      # 약간의 딜레이 후 적용 (open이 처리될 시간)
      sleep 2
      defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string ""
      echo "iTerm2 color scheme set to Snazzy (재시작 후 적용)"
    fi
  else
    echo "iTerm2 not installed yet, skipping color import"
  fi
}

install_claude_code() {
  if command -v claude >/dev/null 2>&1; then
    echo "Claude Code already installed"
    return 0
  fi

  curl -fsSL https://claude.ai/install.sh | bash || true
}

set_default_shell_zsh() {
  if [[ "${SHELL:-}" == "/bin/zsh" ]]; then
    echo "Default shell already zsh"
    return 0
  fi

  chsh -s /bin/zsh || true
}

run_p10k_configure_best_effort() {
  if command -v zsh >/dev/null 2>&1; then
    zsh -lic 'command -v p10k >/dev/null 2>&1 && p10k configure || true' || true
  fi
}

print_versions() {
  echo
  bold "==================== versions ===================="
  echo "brew      : $(brew --version | head -n 1 || true)"
  echo "git       : $(git --version || true)"
  echo "asdf      : $(asdf --version || true)"
  echo "node      : $(zsh -lic 'node -v' 2>/dev/null || true)"
  echo "bun       : $(zsh -lic 'bun --version' 2>/dev/null || true)"
  echo "claude    : $(zsh -lic 'claude --version' 2>/dev/null || echo 'restart shell required')"

  [[ "${INSTALL_PYTHON}" == "1" ]] && echo "python    : $(zsh -lic 'python --version' 2>/dev/null || true)"
  [[ "${INSTALL_PYTHON}" == "1" ]] && echo "uv        : $(zsh -lic 'uv --version' 2>/dev/null || true)"
  [[ "${INSTALL_AWSCLI}" == "1" ]] && echo "aws       : $(zsh -lic 'aws --version' 2>/dev/null || true)"
  [[ "${INSTALL_MYSQL}" == "1" ]] && echo "mysql     : $(zsh -lic 'mysql --version' 2>/dev/null || true)"
  [[ "${INSTALL_POSTGRES}" == "1" ]] && echo "postgres  : $(zsh -lic 'psql --version' 2>/dev/null || true)"
  echo "=================================================="
  echo
}

print_manual_steps() {
  cat <<EOF

========================================================
수동 마무리 체크리스트
========================================================

[1] 새 셸 시작
  exec zsh -l

[2] iTerm2 폰트 설정
iTerm2 → Settings → Profiles → Text
- Font: MesloLGS NF
- Use a different font for non-ASCII text: 체크
- Non-ASCII Font: Noto Sans Mono CJK KR

[3] powerlevel10k
  p10k configure

EOF

  if [[ "${INSTALL_MYSQL}" == "1" ]]; then
    cat <<EOF
[MySQL] 시작 예시
  mysqld --basedir="\$HOME/.asdf/installs/mysql/${MYSQL_VERSION}" --datadir="\$HOME/.asdf/installs/mysql/${MYSQL_VERSION}/data" &

EOF
  fi

  if [[ "${INSTALL_POSTGRES}" == "1" ]]; then
    cat <<EOF
[Postgres] 시작 예시
  pg_ctl -D "\$HOME/.asdf/installs/postgres/${POSTGRES_VERSION}/data" start

EOF
  fi

  cat <<EOF
[dotenv] aliases
  dotenv
  dotenv-prod

[Claude Code] 로그인
  claude

EOF

  if [[ "${INSTALL_AWSCLI}" == "1" ]]; then
    cat <<EOF
[AWS] 설정
  aws configure

EOF
  fi

  cat <<EOF
[확인]
  ll
  which node
  which bun
EOF

  [[ "${INSTALL_MYSQL}" == "1" ]] && echo "  which mysql"
  [[ "${INSTALL_POSTGRES}" == "1" ]] && echo "  which psql"
  [[ "${INSTALL_POSTGRES}" == "1" ]] && echo "  echo \$PGDATA"

  cat <<EOF

[로그 파일]
  ${LOG_FILE}

========================================================
EOF
}

main() {
  TOTAL_STEPS=$(calc_total_steps)

  prompt_versions

  start_step "Xcode Command Line Tools 확인"
  ensure_xcode_cli_tools
  finish_step

  start_step "sudo 권한 확인"
  ensure_sudo
  finish_step

  start_step "Xcode license / first launch 확인"
  ensure_xcode_license
  finish_step

  start_step "Homebrew 설치"
  install_homebrew
  finish_step

  start_step "brew formula / cask 설치"
  install_brew_packages
  finish_step

  start_step "Oh My Zsh 설치"
  install_oh_my_zsh
  finish_step

  start_step "Powerlevel10k 설치"
  install_powerlevel10k
  finish_step

  start_step "zsh plugin 설치"
  install_zsh_plugins
  finish_step

  start_step "shell 파일 설정"
  configure_shell_files
  write_p10k_config
  finish_step

  start_step "기본 shell 을 zsh 로 설정"
  set_default_shell_zsh
  finish_step

  start_step "asdf plugin 설치"
  install_asdf_plugins
  finish_step

  start_step "asdf nodejs ${NODE_VERSION} 설치 + global"
  install_node
  finish_step

  start_step "asdf bun ${BUN_VERSION} 설치 + global"
  install_bun
  finish_step

  if [[ "${INSTALL_PYTHON}" == "1" ]]; then
    start_step "asdf python ${PYTHON_VERSION} 설치 + global"
    install_python
    finish_step

    start_step "asdf uv ${UV_VERSION} 설치 + global"
    install_uv
    finish_step
  fi

  if [[ "${INSTALL_AWSCLI}" == "1" ]]; then
    start_step "asdf awscli ${AWSCLI_VERSION} 설치 + global"
    install_awscli
    finish_step
  fi

  if [[ "${INSTALL_MYSQL}" == "1" ]]; then
    start_step "asdf mysql ${MYSQL_VERSION} 설치 + 초기화"
    install_mysql
    finish_step
  fi

  if [[ "${INSTALL_POSTGRES}" == "1" ]]; then
    start_step "asdf postgres ${POSTGRES_VERSION} 설치 + 초기화"
    install_postgres
    finish_step
  fi

  start_step "Claude Code 설치"
  install_claude_code
  finish_step

  start_step "VS Code / Cursor extension 설치"
  install_vscode_extensions
  finish_step

  start_step "iTerm2 Snazzy 컬러 스킴 적용 + p10k 설정"
  import_iterm_colorscheme
  run_p10k_configure_best_effort
  finish_step

  print_versions
  print_manual_steps

  green "전체 완료!"
  echo
  yellow "⚠️  지금 바로 새 쉘을 시작해야 설정이 적용됩니다."
  yellow "   아래 명령어를 직접 입력해주세요:"
  echo
  bold "   exec zsh -l"
  echo
  yellow "   (exec zsh -l 을 해야 .zshrc가 로드됩니다. exec zsh 만 하면 안 됩니다!)"
  yellow "   그 다음 p10k configure 로 터미널 테마를 설정하세요."
}

main "$@"

# 스크립트 종료 후 자동으로 zsh 로그인 쉘 전환 시도
if [[ "${SHELL:-}" != "/bin/zsh" ]] || [[ -z "${ZSH_VERSION:-}" ]]; then
  echo
  bold "자동으로 zsh 로그인 쉘을 시작합니다..."
  exec zsh -l
fi
