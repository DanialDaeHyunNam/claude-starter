# 8. Deploy

Vercel에 배포하고 Slack으로 배포 완료 알림을 보내는 단계입니다.

## When to Use

- 사용자가 `/8-deploy` 를 입력했을 때

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 8: 세상에 공개하기 (배포)

```
지금: 내 컴퓨터에서만 동작       배포 후: 전 세계 누구나 접속
┌──────────────┐              ┌─────────────────────┐
│ 💻 localhost  │              │ 🌍 your-app.vercel  │
│  :3000       │     ──→      │    .app             │
│ (나만 볼 수   │   Vercel     │  (누구나 볼 수 있음)  │
│  있음)        │              │                     │
└──────────────┘              └─────────────────────┘
```

**쉽게 말하면:**
지금까지 만든 앱은 여러분 컴퓨터에서만 돌아갔어요.
이번엔 **인터넷에 올려서** 누구나 주소만 치면 볼 수 있게 하는 거예요.

Vercel이라는 서비스가 이걸 무료로 해줘요.
GitHub에 코드를 올리면 자동으로 배포까지 해줍니다!

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "다음 단계로 넘어갑니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

### Step 3: Vercel 설정

Vercel CLI가 설치되어 있는지 확인합니다.

```bash
vercel --version 2>/dev/null || bun add -g vercel
```

Vercel 로그인:
```bash
vercel login
```

### Step 4: Vercel 프로젝트 연결

```bash
vercel link
```

또는 `/vercel-setup` 플러그인 skill을 활용할 수 있습니다.

### Step 5: Neon Postgres 프로비저닝 + 환경 변수

로컬에서는 SQLite를 썼지만, Vercel 배포에는 Neon Postgres를 사용합니다.

**5-1. Neon 연결 (Vercel Marketplace)**

```bash
vercel integration add neon
```

이 명령이 안 되면 Vercel 대시보드에서 Storage → Create Database → Neon 으로 연결하도록 안내.

**5-2. 환경 변수 가져오기**

Neon 연결 후 Vercel에 자동 생성된 `DATABASE_URL` 등을 로컬로 가져옵니다:

```bash
vercel env pull .env.local
```

이 명령은 Vercel에 설정된 환경 변수를 `.env.local` 파일로 다운로드합니다.

**5-3. .gitignore 보호 확인**

`.env*` 파일이 절대 git에 올라가지 않도록 확인합니다:

```bash
grep -q "^\.env" .gitignore || echo -e "\n.env\n.env.*\n!.env.example" >> .gitignore
```

Bash 도구로 보호 상태 확인:
```bash
git check-ignore .env .env.local .env.production 2>/dev/null
```

3개 모두 출력되면 OK. 하나라도 빠지면 `.gitignore`에 추가.

**5-4. Prisma 스키마를 Postgres로 전환**

배포용으로 `prisma/schema.prisma`의 datasource를 변경합니다:

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}
```

그리고 마이그레이션 생성 + 적용:
```bash
bunx prisma migrate dev --name init
```

**5-5. 추가 환경 변수**

프로젝트에 다른 환경 변수가 필요한 경우 (API 키 등) Vercel에 추가합니다:

```bash
vercel env add {KEY} production
```

### Step 6: 프로덕션 배포

```bash
vercel --prod
```

또는 `/deploy` 플러그인 skill을 활용할 수 있습니다.

배포 URL을 확인합니다.

### Step 7: GitHub Actions에 자동 배포 추가

push할 때마다 자동 배포되도록 GitHub Actions에 deploy job을 추가합니다.

`.github/workflows/ci.yml`에 deploy job 추가:
```yaml
  deploy:
    name: Deploy to Vercel
    runs-on: ubuntu-latest
    needs: [lint, build]
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4
      - uses: oven-sh/setup-bun@v2
      - run: bun install --frozen-lockfile
      - name: Deploy to Vercel
        run: |
          bun add -g vercel
          vercel pull --yes --environment=production --token=${{ secrets.VERCEL_TOKEN }}
          vercel build --prod --token=${{ secrets.VERCEL_TOKEN }}
          DEPLOY_URL=$(vercel deploy --prebuilt --prod --token=${{ secrets.VERCEL_TOKEN }})
          echo "DEPLOY_URL=$DEPLOY_URL" >> $GITHUB_ENV
```

필요한 시크릿 설정:
```bash
gh secret set VERCEL_TOKEN --body "{vercel-token}"
gh secret set VERCEL_ORG_ID --body "{org-id}"
gh secret set VERCEL_PROJECT_ID --body "{project-id}"
```

### Step 8: 최종 확인

```
✅ Step 8 완료! 배포가 완료되었습니다.

🌍 배포 URL: {URL}
🔄 자동 배포: main 브랜치 push 시 자동 배포 설정됨

다음 단계: /9-confirm 을 입력해주세요.
```
