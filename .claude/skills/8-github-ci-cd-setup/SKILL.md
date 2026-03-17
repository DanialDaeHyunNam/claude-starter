# 8. GitHub CI/CD Setup

GitHub 리포지토리 생성, CI/CD 파이프라인 구성, Slack 알림 설정을 하는 단계입니다.

## When to Use

- 사용자가 `/8-github-ci-cd-setup` 을 입력했을 때

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 8: GitHub + 자동 검사 시스템 (CI/CD)

```
지금: 내 컴퓨터에만 있음     설정 후: 자동 시스템 완비
┌──────────────┐           ┌─────────────────────────┐
│ 💻 내 컴퓨터  │           │ ☁️  GitHub (코드 저장소)  │
│   에만 코드   │    ──→    │   ↓                     │
│   있음       │           │ 🤖 자동 검사 (CI)        │
│              │           │   lint ✅ → build ✅      │
│              │           │   ↓                     │
│              │           │ 📢 Slack 알림            │
│              │           │   "빌드 성공!" 🎉        │
└──────────────┘           └─────────────────────────┘
```

**쉽게 말하면:**
지금까지 만든 앱은 여러분 컴퓨터에만 있어요.
이번 단계에서는:
1. **GitHub**에 코드를 올려서 안전하게 보관하고
2. 코드를 올릴 때마다 **자동으로 검사**(오류 체크, 빌드 테스트)하고
3. 검사 결과를 **Slack으로 알려주는** 시스템을 만들어요

마치 편의점 CCTV처럼, 코드에 문제가 생기면 자동으로 알려주는 거예요!

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

### Step 3: GitHub CLI 로그인

먼저 GitHub CLI(gh)에 로그인되어 있는지 확인합니다.

```bash
gh auth status 2>&1
```

**로그인이 안 되어 있으면:**

사용자에게 안내:
```
GitHub에 로그인해야 코드를 올릴 수 있어요.
아래 명령어를 실행하면 브라우저가 열리면서 로그인할 수 있습니다.
```

```bash
gh auth login
```

로그인 과정을 안내:
1. "GitHub.com" 선택
2. "HTTPS" 선택
3. "Login with a web browser" 선택
4. 브라우저에서 코드 입력 후 인증
5. 완료 확인: `gh auth status`

**로그인이 되어 있으면** 다음 step으로 넘어갑니다.

### Step 4: GitHub 리포지토리 생성

프로젝트를 GitHub에 올립니다.

AskUserQuestion으로 공개 여부:
- question: "GitHub 저장소를 공개/비공개 중 어떻게 할까요?"
- header: "저장소 공개"
- options:
  - label: "비공개 (추천)" / description: "나만 볼 수 있음"
  - label: "공개" / description: "누구나 볼 수 있음"

```bash
cd projects/{프로젝트명}
gh repo create {kebab-case-name} --{private|public} --source=. --push
```

### Step 5: GitHub 리포지토리 설정 (PR + squash and merge)

**이 설정은 필수입니다.** main 브랜치를 보호하고 squash and merge를 기본으로 설정합니다.

```bash
cd projects/{프로젝트명}

# main 브랜치 보호: 직접 push 금지, PR 필수
gh api repos/{owner}/{repo}/branches/main/protection \
  -X PUT \
  -H "Accept: application/vnd.github+json" \
  -f "required_pull_request_reviews[dismiss_stale_reviews]=false" \
  -f "required_pull_request_reviews[require_code_owner_reviews]=false" \
  -F "required_pull_request_reviews[required_approving_review_count]=0" \
  -F "enforce_admins=false" \
  -f "restrictions=null" \
  -f "required_status_checks=null" 2>/dev/null || true

# merge 방식을 squash and merge로 설정
gh api repos/{owner}/{repo} \
  -X PATCH \
  -F allow_squash_merge=true \
  -F allow_merge_commit=false \
  -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true 2>/dev/null || true
```

사용자에게 설명:
```
GitHub 저장소 설정이 완료되었어요!

적용된 규칙:
  ✅ main 브랜치 직접 push 금지 → 반드시 PR로 진행
  ✅ merge 방식: squash and merge (히스토리가 깔끔해져요)
  ✅ merge 후 브랜치 자동 삭제

쉽게 말하면:
  코드를 바꾸고 싶으면 → 새 브랜치에서 작업 → PR 올리기 → merge
  이렇게 하면 실수로 코드가 망가질 일이 없어요!
```

프로젝트의 CLAUDE.md에도 이 원칙을 추가합니다:

```markdown
## Git 워크플로우

- **main 직접 push 금지** — 반드시 브랜치 → PR → squash and merge
- 브랜치 네이밍: `feat/기능`, `fix/이슈`, `improve/개선`
- PR 생성: `gh pr create --title "[feat] 설명" --body "..."`
- merge 방식: squash and merge
```

### Step 6: GitHub Actions CI 파이프라인 생성

프로젝트 폴더에 CI 설정 파일을 생성합니다.

```bash
mkdir -p projects/{프로젝트명}/.github/workflows
```

`.github/workflows/ci.yml`:
```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  lint:
    name: Lint
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - run: bun run lint
      - name: Slack 알림 - Lint
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: "Lint ${{ job.status == 'success' && '✅ 통과' || '❌ 실패' }}"
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - run: bun run build
      - name: Slack 알림 - Build
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: "Build ${{ job.status == 'success' && '✅ 성공' || '❌ 실패' }}"
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}

  notify-complete:
    name: 전체 완료 알림
    runs-on: ubuntu-latest
    needs: [lint, build]
    if: always()
    steps:
      - name: Slack 최종 알림
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ needs.build.result }}
          text: |
            CI 파이프라인 완료
            Lint: ${{ needs.lint.result }}
            Build: ${{ needs.build.result }}
            PR: ${{ github.event.pull_request.html_url || 'direct push' }}
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

### Step 7: Slack Webhook 설정

AskUserQuestion으로:
- question: "Slack Incoming Webhook URL이 있으신가요?"
- options:
  - label: "네, URL이 있어요" / description: "Webhook URL을 입력해주세요"
  - label: "만드는 법 알려주세요" / description: "Slack Webhook 생성 과정을 안내합니다"
  - label: "나중에 할게요" / description: "Slack 알림 없이 CI만 설정합니다"

**"만드는 법"** 선택 시:
1. https://api.slack.com/apps 접속
2. 기존 앱 선택 또는 새로 만들기
3. "Incoming Webhooks" → 활성화
4. "Add New Webhook to Workspace" → 채널 선택
5. Webhook URL 복사

Webhook URL을 받으면 GitHub Secrets에 저장:
```bash
cd projects/{프로젝트명}
gh secret set SLACK_WEBHOOK_URL --body "{webhook-url}"
```

### Step 8: 초기 push + CI 확인

```bash
cd projects/{프로젝트명}
git add .
git commit -m "ci: GitHub Actions CI/CD 파이프라인 설정"
git push
```

CI가 동작하는지 확인:
```bash
gh run list --limit 1
gh run watch
```

### Step 9: 최종 확인

```
✅ Step 8 완료! CI/CD가 설정되었습니다.

🔧 설정된 파이프라인:
  1. 코드 push/PR → 자동 Lint 검사 → Slack 알림
  2. Lint 통과 → 자동 Build 검사 → Slack 알림
  3. 전체 완료 → Slack 최종 알림

📢 Slack 알림: {설정됨/나중에 설정}
🔗 GitHub: {repo URL}

다음 단계: /9-deploy 를 입력해주세요.
```
