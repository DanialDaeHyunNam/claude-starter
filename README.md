<div align="center">

# claude-starter

**코딩 경험 없이, 슬래시 커맨드만으로 프로덕트를 완성하세요.**

Claude Code + Pencil을 활용한 오프라인 강의용 스타터 킷

[![Claude Code](https://img.shields.io/badge/Claude_Code-Powered-blueviolet?style=for-the-badge&logo=data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMjQiIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cGF0aCBkPSJNMTIgMkM2LjQ4IDIgMiA2LjQ4IDIgMTJzNC40OCAxMCAxMCAxMCAxMC00LjQ4IDEwLTEwUzE3LjUyIDIgMTIgMnoiIGZpbGw9IiNmZmYiLz48L3N2Zz4=)](https://claude.ai/code)
[![Next.js](https://img.shields.io/badge/Next.js-14+-black?style=for-the-badge&logo=next.js)](https://nextjs.org)
[![TypeScript](https://img.shields.io/badge/TypeScript-blue?style=for-the-badge&logo=typescript&logoColor=white)](https://typescriptlang.org)

</div>

---

> **clone해서 혼자 진행해도 100% OK!** 모든 슬래시 커맨드가 동일하게 동작합니다.
>
> 오프라인 강의로 함께 따라가고 싶으신 분은 [fearnot.ai](https://fearnot-ai.vercel.app/)에서 지원해주세요.

---

## 이런 분들을 위해 만들었어요

- **기획자/디자이너**인데 아이디어를 직접 구현해보고 싶은 분
- **코딩은 처음**이지만 AI로 프로덕트를 만들어보고 싶은 분
- **Claude Code**를 시작하는데 환경 설정부터 막히는 분

## 어떻게 동작하나요?

```
/0-local-setup           컴퓨터에 필요한 도구 설치
        ↓
/1-claude-md-setup       어떤 프로덕트를 만들지 정하기
        ↓
/2-directory-structure   프로젝트 폴더 구조 생성
        ↓
/3-mcp-setup             Claude에게 눈/손/입 달아주기
        ↓
/4-ground-rule-setup     코딩 규칙 세우기
        ↓
/5-detail-prd            상세 기획서 작성
        ↓
/6-prototype             Pencil로 화면 시안 만들기
        ↓
/7-implement             Claude Teams로 본격 구현
        ↓
/8-ci-cd-setup           자동 검사 + Slack 알림
        ↓
/9-deploy                Vercel에 배포
        ↓
/10-confirm              최종 확인 + 완료!
```

각 단계마다 Claude가 **쉬운 비유로 설명**해주고,
"이해했어요" 버튼을 누르면 다음으로 넘어갑니다.

## 사전 준비

### 최소 요구사항

| | macOS | Windows |
|---|---|---|
| **OS** | macOS 13 이상 | Windows 10 **64-bit** 이상 |
| **RAM** | 8GB 이상 | 8GB 이상 |
| **디스크** | 10GB 여유 공간 | 10GB 여유 공간 |
| **인터넷** | 필요 | 필요 |

> **Windows 유저 주의:** 32-bit Windows에서는 Claude Code가 작동하지 않습니다.

## 빠른 시작

### 1. 이 레포를 clone합니다

```bash
git clone https://github.com/DanialDaeHyunNam/claude-starter.git
cd claude-starter
```

### 2. Claude Code를 실행합니다

```bash
claude
```

### 3. 첫 번째 커맨드를 입력합니다

```
/0-local-setup
```

이후는 Claude가 안내합니다!

## 레포 구조

```
claude-starter/
├── CLAUDE.md                ← Claude가 읽는 프로젝트 설계도
├── README.md                ← 지금 보고 있는 이 파일
├── .gitignore
│
├── scripts/
│   ├── bootstrap_mac.sh     ← macOS 자동 설치 (brew + asdf)
│   └── bootstrap_windows.ps1← Windows 자동 설치 (Scoop + mise)
│
├── assets/
│   ├── snazzy.itermcolors   ← 터미널 컬러 테마
│   └── vscode-extensions.txt← 에디터 확장 프로그램 목록
│
├── .claude/
│   ├── settings.json        ← 플러그인 설정
│   └── skills/              ← 슬래시 커맨드 (13개)
│
└── projects/                ← 여러분의 작업 공간 (gitignored)
    └── my-awesome-app/      ← 독립 git repo로 생성됨
```

> **`projects/` 폴더**는 `.gitignore`에 포함되어 있어서
> 여러분의 프로젝트 코드가 이 강의 레포와 섞이지 않습니다.

## 설치되는 것들 (`/0-local-setup`)

| 카테고리 | macOS (brew + asdf) | Windows (Scoop + mise) |
|---------|---------------------|----------------------|
| 패키지 관리자 | Homebrew | Scoop |
| 버전 관리자 | asdf | mise (asdf 호환) |
| Node.js | 20.12.0 (asdf) | 20.12.0 (mise) |
| Bun | latest (asdf) | latest (mise) |
| Git | git (brew) | git (scoop) |
| 에디터 | VS Code + Cursor (brew cask) | VS Code + Cursor (scoop) |
| AI 도구 | Claude Code | Claude Code |
| 터미널 앱 | iTerm2 (brew cask) | Windows Terminal |
| 터미널 꾸미기 | Oh My Zsh + Powerlevel10k | Oh My Posh + paradox 테마 |
| 터미널 플러그인 | zsh-syntax-highlighting, zsh-autosuggestions | PSReadLine (기본 내장) |
| 폰트 | MesloLGS NF, FiraCode, Noto Sans Mono CJK KR | MesloLGS NF, FiraCode, NotoSansMono NF |
| 컬러 스킴 | Snazzy (iTerm2) | Snazzy (Windows Terminal) |
| GitHub CLI | gh (brew) | gh (scoop) |
| 빌드 도구 | coreutils, curl, gawk, gpg, openssl 등 | curl, coreutils, openssl, 7zip |
| VS Code 확장 | `assets/vscode-extensions.txt` 자동 설치 | 동일 |

## 포함된 플러그인

| 플러그인 | 용도 |
|---------|------|
| `clarify` | 애매한 요구사항을 구체적 스펙으로 |
| `commit-commands` | `/commit`, `/push`, `/pr` |
| `github` | GitHub 이슈/PR 관리 |
| `vercel` | `/deploy` 한 줄 배포 |
| `typescript-lsp` | 코드 실시간 오류 체크 |
| `pr-review-toolkit` | 자동 코드 리뷰 |
| `explanatory-output-style` | "왜 이렇게 했는지" 설명 |

## 도움이 필요할 때

강의 중 막히면 언제든:

```
/help-claude
```

Claude가 질문을 통해 문제를 좁혀나가고, 직접 해결해줍니다.

## 기여하기

강의 중 버그나 개선점을 발견하셨나요?

```bash
git checkout -b fix/간단한-설명
# 수정 후
git add . && git commit -m "[fix] 설명"
git push -u origin fix/간단한-설명
gh pr create
```

유의미한 PR은 검토 후 merge됩니다.

## 기술 스택

| 영역 | 기술 |
|------|------|
| Framework | Next.js 14+ (App Router) |
| Language | TypeScript |
| Styling | Tailwind CSS + shadcn/ui |
| Package Manager | bun |
| ORM | Prisma / Drizzle |
| Deployment | Vercel |
| CI/CD | GitHub Actions |
| Version Manager | asdf (macOS/Linux) / mise (Windows) |

---

<div align="center">

**Made with Claude Code**

</div>
