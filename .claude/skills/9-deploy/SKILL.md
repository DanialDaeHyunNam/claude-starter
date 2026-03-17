# 9. Deploy

Vercel에 배포하고 Slack으로 배포 완료 알림을 보내는 단계입니다.

## When to Use

- 사용자가 `/9-deploy` 를 입력했을 때

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 9: 세상에 공개하기 (배포)

```
지금: 내 컴퓨터에서만 동작       배포 후: 전 세계 누구나 접속
┌──────────────┐              ┌─────────────────────┐
│ 💻 localhost  │              │ 🌍 your-app.vercel  │
│  :3000       │     ──→      │    .app             │
│ (나만 볼 수   │   Vercel     │  (누구나 볼 수 있음)  │
│  있음)        │              │                     │
└──────────────┘              └─────────────────────┘
                                       ↓
                              📢 Slack: "배포 완료! 🎉"
                                 + PR 링크 포함
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
cd projects/{프로젝트명}
vercel link
```

또는 `/vercel-setup` 플러그인 skill을 활용할 수 있습니다.

### Step 5: 환경 변수 설정

프로젝트에 환경 변수가 필요한 경우 (DB URL, API 키 등) Vercel에 설정합니다.

```bash
cd projects/{프로젝트명}
vercel env add DATABASE_URL production
```

필요한 환경 변수 목록은 CLAUDE.md와 `.env.example`을 참고합니다.

### Step 6: 프로덕션 배포

```bash
cd projects/{프로젝트명}
vercel --prod
```

또는 `/deploy` 플러그인 skill을 활용할 수 있습니다.

배포 URL을 확인합니다.

### Step 7: Slack 배포 완료 알림

배포가 완료되면 Slack에 알림을 보냅니다.

3번 step에서 Slack MCP가 설정되어 있으면 MCP를 통해 메시지를 보냅니다.
설정되어 있지 않으면 사용자에게 수동으로 공유하도록 안내합니다.

Slack 메시지 내용:
```
🚀 배포 완료!

프로젝트: {프로젝트명}
URL: {배포 URL}
시간: {현재 시간}

최종 PR: {PR URL 또는 직접 push인 경우 커밋 URL}
```

### Step 8: GitHub Actions에 자동 배포 추가

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
      - name: Slack 배포 알림
        if: always()
        uses: 8398a7/action-slack@v3
        with:
          status: ${{ job.status }}
          text: |
            🚀 배포 ${{ job.status == 'success' && '완료!' || '실패' }}
            URL: ${{ env.DEPLOY_URL || 'N/A' }}
            PR: ${{ github.event.pull_request.html_url || github.sha }}
          webhook_url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

필요한 시크릿 설정:
```bash
cd projects/{프로젝트명}
gh secret set VERCEL_TOKEN --body "{vercel-token}"
gh secret set VERCEL_ORG_ID --body "{org-id}"
gh secret set VERCEL_PROJECT_ID --body "{project-id}"
```

### Step 9: 최종 확인

```
✅ Step 9 완료! 배포가 완료되었습니다.

🌍 배포 URL: {URL}
📢 Slack 알림: 전송 완료
🔄 자동 배포: main 브랜치 push 시 자동 배포 설정됨

다음 단계: /10-confirm 을 입력해주세요.
```
