# claude-starter

Claude를 처음 시작하는 비개발자/기획자가 로컬 셋업부터 Vercel 배포까지 슬래시 커맨드만으로 프로덕트를 완성할 수 있는 오프라인 강의용 스타터 킷.

## 레포 구조

```
claude-starter/              ← 이 레포 (강의 도구)
├── CLAUDE.md                ← 이 파일
├── .gitignore               ← projects/ 제외
├── scripts/
│   ├── bootstrap_mac.sh     ← macOS 셋업 (brew + asdf)
│   └── bootstrap_windows.ps1← Windows 셋업 (Scoop + mise)
├── assets/
│   └── snazzy.itermcolors   ← 터미널 컬러 스킴
├── .claude/
│   ├── settings.json        ← 플러그인 설정
│   └── skills/              ← 단계별 슬래시 커맨드
│       ├── 0-local-setup/
│       ├── 1-claude-md-setup/
│       ├── 2-directory-structure-setup/
│       ├── 3-mcp-setup/
│       ├── 4-critical-ground-rule-setup/
│       ├── 5-detail-prd/
│       ├── 6-prototype/
│       ├── 7-implement-by-claude-teams/
│       ├── 8-github-ci-cd-setup/
│       ├── 9-deploy/
│       ├── 10-confirm/
│       └── plugin-guide/
└── projects/                ← 수강생 작업 공간 (gitignored)
    └── {kebab-case-name}/   ← 각 수강생의 독립 프로젝트
        ├── .git/            ← 독립 git repo
        ├── CLAUDE.md        ← 프로젝트별 설계도
        └── ...
```

## 핵심 원칙

1. **이 레포는 도구 상자** — 수강생의 프로덕트 코드는 절대 이 레포에 포함되지 않음
2. **수강생 작업은 projects/ 하위에만** — `projects/`는 `.gitignore`로 제외되어 git diff 없음
3. **트러블슈팅은 PR로** — 강의 도구(scripts/, .claude/)의 버그/개선은 이 레포에 PR
4. **프로젝트 디렉토리명은 kebab-case** — GitHub 레포명이 되므로 필수

## 슬래시 커맨드 (Skill 흐름)

| # | 명령어 | 설명 |
|---|--------|------|
| 0 | `/0-local-setup` | OS별 개발 환경 설치 (brew+asdf / Scoop+mise) |
| 1 | `/1-claude-md-setup` | 프로덕트 아이디어 구체화 → CLAUDE.md 생성 |
| 2 | `/2-directory-structure-setup` | 프로젝트 폴더 구조 생성 |
| 3 | `/3-mcp-setup` | MCP 연결 (Playwright, Slack, Pencil, Claude in Chrome) |
| 4 | `/4-critical-ground-rule-setup` | 코딩 컨벤션 + Claude 협업 규칙 + 운영 규칙 |
| 5 | `/5-detail-prd` | 상세 PRD 작성 |
| 6 | `/6-prototype` | Pencil 프로토타이핑 |
| 7 | `/7-implement-by-claude-teams` | Claude Teams로 구현 |
| 8 | `/8-github-ci-cd-setup` | CI/CD + Slack 알림 |
| 9 | `/9-deploy` | Vercel 배포 + Slack 알림 |
| 10 | `/10-confirm` | 최종 승인 |
| - | `/clean-up` | 워크숍 세션 종료 후 추적 데이터 정리 (.fearnot/) |
| - | `/plugin-guide` | 설치된 플러그인 설명 |
| - | `/help-claude` | 막힌 문제 해결 (질문으로 좁혀서 진단 → 해결) |
| - | `/wrap-up` | 세션 종료 시 도메인별 작업 기록 (.claude/wrap-up/) |
| - | `/claude-basic` | Claude Code 핵심 개념 6가지 설명 (최신 확인 후 출력) |
| - | `/season-start` | 강의 시작 전 Slack에 Mac/Windows 설치 가이드 발송 |

## 설치된 플러그인

- `clarify@team-attention-plugins` — 요구사항 구체화
- `commit-commands@claude-plugins-official` — git 커밋/푸시/PR
- `github@claude-plugins-official` — GitHub 통합
- `vercel@claude-plugins-official` — Vercel 배포
- `typescript-lsp@claude-plugins-official` — TS 코드 인텔리전스
- `pr-review-toolkit@claude-plugins-official` — PR 자동 리뷰
- `explanatory-output-style@claude-plugins-official` — 코드 설명 모드

## 기술 스택 (수강생 프로젝트 기본값)

- **Framework**: Next.js 14+ (App Router)
- **Language**: TypeScript
- **Styling**: Tailwind CSS + shadcn/ui
- **ORM**: Prisma 또는 Drizzle
- **Auth**: 프로젝트별 선택
- **DB**: 프로젝트별 선택
- **Deployment**: Vercel
- **Package Manager**: bun (npm/npx 대신 bun/bunx 사용)
- **Python Package Manager**: uv (pip 대신 uv 사용)

## 대상

- 비개발자 / 기획자 (코딩 경험 거의 없는 사람)
- 목표: 배우지 않고도 Claude를 써서 프로덕트를 만들 수 있게 하는 것

## Skill 공통 규칙

- 매 step 시작 시 **도식화 + 어린아이도 이해할 예시**로 설명
- AskUserQuestion으로 "이해했어요" / "더 설명해주세요" 확인 후 진행
- OS 지원: macOS (brew+asdf), Windows (Scoop+mise), Linux (asdf)

## 버전 관리 철학

- macOS/Linux: **brew + asdf** (asdf가 최고의 환경관리 패키지)
- Windows: **Scoop + mise** (asdf 호환, `.tool-versions` 공유 가능)

## 작업 원칙 (필수)

- **재사용성 최우선**: 문서/코드 모두 재사용성 우선. 상위 문서 내용을 하위에서 반복하지 않고 레퍼런스만 건다
- **확장에 보수적**: 문서/코드를 늘리는 것에 극히 보수적으로 접근
- **임시 스크립트**: `.claude/temp/scripts/`에 생성, 1회성은 작업 후 삭제
- **디버깅**: 1가설 1검증 원칙. print/console.log로 하나씩 검증. 대규모 동시 테스트 금지

<!-- TRACKING_START -->
## Progress Tracking (Skill 진행 추적)

모든 스킬은 아래 규칙에 따라 수강생 진행상황을 fearnot-ai API로 전송한다.
추적 실패는 절대 skill 진행을 차단하지 않는다. 개별 SKILL.md에는 추적 코드를 넣지 않는다.

### 공통 규칙

- **skill 시작 시** (조용히): `bash scripts/track.sh update {skill-name} started 2>/dev/null || true`
- **skill 완료 시** (조용히): `bash scripts/track.sh update {skill-name} completed 2>/dev/null || true`
- **중요 마일스톤**: `bash scripts/track.sh event {skill-name} {type} "{detail}" 2>/dev/null || true`
- `.fearnot/participant.json` 없으면 추적 자동 스킵 (에러 없음)
- `scripts/track.sh`는 3초 타임아웃, 실패 시 exit 0 (silent failure)
- **bash가 없는 환경(Windows 등)에서는 추적을 자동으로 스킵** — 에러 무시하고 skill 진행

### 스킬별 마일스톤 이벤트

| 스킬 | 마일스톤 이벤트 |
|------|---------------|
| 0-local-setup | `os-selected "{OS}"`, `env-diagnosed`, `install-complete` |
| 1-claude-md-setup | `idea-clarified`, `project-named "{프로젝트명}"` |
| 2-directory-structure-setup | `nextjs-created`, `git-initialized` |
| 3-mcp-setup | `mcp-validated`, `playwright-added`, `slack-added`, `pencil-added` |
| 4-critical-ground-rule-setup | `rules-applied` |
| 5-detail-prd | `prd-created` |
| 6-prototype | `screen-designed "{화면명}"` (화면마다) |
| 7-implement-by-claude-teams | `feature-done "{기능명}"` (기능마다) |
| 8-github-ci-cd-setup | `repo-created "{GitHub URL}"` |
| 9-deploy | `deployed "{Vercel URL}"` |
| 10-confirm | `feature-checked "{기능명}"` (기능마다), `approved` |
| help-claude | `troubleshooting-started "{문제 카테고리}"`, `troubleshooting-resolved "{요약}"` |
<!-- TRACKING_END -->

## Git 워크플로우 (필수)

- **main 직접 push 금지** — 반드시 브랜치 → PR → squash and merge
- 브랜치 네이밍: `feat/기능`, `fix/이슈`, `improve/개선`, `docs/문서`
- PR 제목: `[feat] 기능 설명`, `[fix] 이슈 설명`, `[improve] 개선 설명`
- merge 방식: **squash and merge** (히스토리 깔끔하게)
- 이 원칙은 이 레포(claude-starter)와 수강생 프로젝트 모두 동일하게 적용
