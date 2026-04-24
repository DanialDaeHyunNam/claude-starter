# claude-starter

Claude를 처음 시작하는 비개발자/기획자가 로컬 셋업부터 Vercel 배포까지 슬래시 커맨드만으로 프로덕트를 완성할 수 있는 오프라인 강의용 스타터 킷.

## 레포 구조

```
workspace/                         ← 이 레포의 부모 디렉토리
├── claude-starter/                ← 이 레포 (강의 도구)
│   ├── CLAUDE.md                  ← 이 파일
│   ├── .gitignore                 ← (legacy) projects/ 안전망
│   ├── scripts/
│   │   ├── bootstrap_mac.sh       ← macOS 셋업 (brew + asdf)
│   │   └── bootstrap_windows.ps1  ← Windows 셋업 (Scoop + mise)
│   ├── helper/                    ← 검증된 bun.lock/package.json 템플릿
│   ├── assets/
│   │   └── snazzy.itermcolors     ← 터미널 컬러 스킴
│   └── .claude/
│       ├── settings.json          ← 플러그인 설정
│       └── skills/                ← 단계별 슬래시 커맨드 (0~10 + 보조)
│
└── {kebab-case-name}/             ← 각 수강생의 독립 프로젝트 (sibling)
    ├── .git/                      ← 독립 git repo
    ├── CLAUDE.md                  ← 프로젝트별 설계도
    ├── .claude/
    │   ├── skills/                ← /1에서 복사된 스킬
    │   ├── settings.json          ← /1에서 복사된 설정
    │   └── .starter-path          ← claude-starter 절대 경로 (helper/ 접근용)
    └── ...
```

## 핵심 원칙

1. **이 레포는 도구 상자** — 수강생의 프로덕트 코드는 절대 이 레포에 포함되지 않음
2. **수강생 작업은 claude-starter 바깥 sibling 디렉토리에** — `/1-claude-md-setup`이 `../{kebab-case-name}/`으로 폴더를 만들고 세션을 전환시킴. 이후 모든 스킬은 프로젝트 폴더 안의 CWD에서 동작
3. **트러블슈팅은 PR로** — 강의 도구(scripts/, .claude/)의 버그/개선은 이 레포에 PR
4. **프로젝트 디렉토리명은 kebab-case** — GitHub 레포명이 되므로 필수

## 슬래시 커맨드 (Skill 흐름)

| # | 명령어 | 설명 |
|---|--------|------|
| 0 | `/0-local-setup` | 필수 도구 5개 확인/설치 (Git, Node.js, Bun, gh) + 플러그인 |
| 1 | `/1-claude-md-setup` | 프로덕트 아이디어 구체화 → CLAUDE.md 생성 |
| 2 | `/2-directory-structure-setup` | 프로젝트 폴더 구조 생성 |
| 3 | `/3-mcp-setup` | MCP 연결 (Playwright, Slack, Pencil, Claude in Chrome) |
| 4 | `/4-critical-ground-rule-setup` | 코딩 컨벤션 + Claude 협업 규칙 + 운영 규칙 |
| 5 | `/5-detail-prd` | 상세 PRD 작성 (`/prd-collab` 내부에서 Pencil 와이어프레임까지 함께 작성) |
| 6 | `/6-implement-by-claude-teams` | Claude Teams로 구현 |
| 7 | `/7-github-ci-cd-setup` | CI/CD + Slack 알림 |
| 8 | `/8-deploy` | Vercel 배포 + Slack 알림 |
| 9 | `/9-confirm` | 최종 승인 |
| - | `/plugin-guide` | 설치된 플러그인 설명 |
| - | `/help-claude` | 막힌 문제 해결 (질문으로 좁혀서 진단 → 해결) |
| - | `/claude-basic` | Claude Code 핵심 개념 6가지 설명 (최신 확인 후 출력) |
| - | `/bootstrap-packages` | 전체 개발 환경 설치 — 터미널 꾸미기, 에디터, 폰트 등 (선택) |
| - | `/prd-collab` | 추상→구체 12단계 PRD 협업 (경험 단위 하나를 완성) |
| - | `/prd-split` | 큰 아이디어를 경험 단위로 쪼개고 각각 /prd-collab 호출 |
| - | `/cto-council` | CTO 페르소나와 기술 Q&A (비개발자 불안감 해소) |
| - | `/growth-setup` | SEO + Google Analytics + Vercel Analytics 세팅 |
| - | `/find-context` | 현재 대화 주제 관련 과거 의사결정(why) / 교훈(lessons learned)을 문서에서 찾아 리포트 |

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
- **ORM**: Prisma
- **DB (로컬)**: SQLite (설치 불필요, file:./dev.db)
- **DB (배포)**: Neon Postgres (Vercel Marketplace 원클릭)
- **Auth**: 프로젝트별 선택
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

## Git 워크플로우 (필수)

- **main 직접 push 금지** — 반드시 브랜치 → PR → squash and merge
- 브랜치 네이밍: `feat/기능`, `fix/이슈`, `improve/개선`, `docs/문서`
- PR 제목: `[feat] 기능 설명`, `[fix] 이슈 설명`, `[improve] 개선 설명`
- merge 방식: **squash and merge** (히스토리 깔끔하게)
- 이 원칙은 이 레포(claude-starter)와 수강생 프로젝트 모두 동일하게 적용

### 🗂 Omniscitus (auto-tracking)

- **Blueprints**: 모든 Write/Edit은 PostToolUse 훅으로 자동 추적됨. `.omniscitus/blueprints/*.yaml`을 손으로 수정하지 말 것.
- **세션 종료 시**: `/wrap-up` 실행 (또는 "wrap up", "마무리"). 작업은 도메인 기반 토픽 유닛으로 분류되어 `.omniscitus/history/{domain}/`에 저장됨.
- **Pending 리뷰**: `/follow-up` — 현재 세션(최근 3일) 관련 오픈 아이템 확인.
- **Visual browser**: `/birdview` — 블루프린트 + 히스토리 + 테스트 통합 뷰어.
- **Tests**: 실제 테스트 파일은 원래 위치에 그대로 유지. `/test-add {file}`로 오버레이 `.omniscitus/tests/{mirrored-path}/meta.yaml`를 생성 — 파일 이동 없음, 프레임워크 변경 없음. LLM 판정 프롬프트 테스트는 `/test-add:prompt {name}` 사용.
- **Domain taxonomy**: `.omniscitus/ontology.yaml` (있는 경우) — /wrap-up 분류 기준 정의.
