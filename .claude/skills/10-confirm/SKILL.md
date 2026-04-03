# 10. Confirm

배포된 결과물을 사용자가 최종 확인하고 승인하는 단계입니다.

## When to Use

- 사용자가 `/10-confirm` 을 입력했을 때

## Instructions

### Step 1: 이 단계가 뭔지 설명하기

아래 내용을 출력하세요:

---

## Step 10: 최종 확인

```
  여기까지 온 여정
  ─────────────────────────────────────────
  0. 컴퓨터 셋팅        ✅
  1. 프로젝트 방향       ✅
  2. 폴더 구조          ✅
  3. MCP 연결           ✅
  4. 규칙 세우기         ✅
  5. 상세 기획서         ✅
  6. 프로토타입          ✅
  7. 구현               ✅
  8. CI/CD             ✅
  9. 배포               ✅
  ─────────────────────────────────────────
  10. 👉 지금 여기: 최종 확인!
```

**쉽게 말하면:**
모든 공사가 끝나고 입주 전 **최종 점검**을 하는 거예요.
물이 잘 나오는지, 전기가 들어오는지, 문이 잘 열리는지 확인하듯이
배포된 앱이 제대로 동작하는지 하나씩 체크합니다.

---

### Step 2: 이해 여부 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "위 설명을 이해하셨나요?"
- header: "이해 확인"
- options:
  - label: "이해했어요" / description: "최종 확인을 시작합니다"
  - label: "더 설명해주세요" / description: "궁금한 점을 직접 입력해주세요"

### Step 3: 배포 URL 확인

배포된 URL에 접속 가능한지 확인합니다.

```bash
cd projects/{프로젝트명}
DEPLOY_URL=$(vercel inspect 2>/dev/null | grep "url" | head -1 || echo "")
echo "배포 URL: $DEPLOY_URL"
curl -s -o /dev/null -w "%{http_code}" "$DEPLOY_URL"
```

### Step 4: 기능별 체크리스트

PRD에서 정의한 핵심 기능을 하나씩 체크합니다.

`projects/{프로젝트명}/docs/PRD.md`를 읽어서 Phase 1 기능 목록을 가져오고,
각 기능에 대해 AskUserQuestion으로 확인:

- question: "{기능명} 이 정상 동작하나요?"
- options:
  - label: "정상 동작" / description: "문제없이 잘 됩니다"
  - label: "문제 있음" / description: "어떤 문제인지 알려주세요"

"문제 있음" 선택 시:
- 사용자 피드백을 받아 수정
- 수정 후 재배포
- 다시 확인

### Step 5: 최종 승인

모든 기능이 확인되면:

AskUserQuestion으로 최종 승인:
- question: "모든 것이 만족스러우신가요? 이 프���젝트를 완료 처리할까요?"
- header: "최종 승인"
- options:
  - label: "승인합니다!" / description: "프로젝트를 완료 처리합니다"
  - label: "아직 수정할 게 있어요" / description: "추가 수정 사항을 알려주���요"

### Step 6: 워크숍 스킬 정리

워크숍 진행용 스킬(0~10번)은 이제 필요 없으므로 프로젝트에서 제거합니다.

사용자에게 안내:
```
워크숍 진행용 슬래시 커맨드(0~10번)를 정리합니다.
이 명령들은 워크숍에서만 필요했고,
앞으로는 /help-claude, /prd-collab, /cto-council 등만 사용하게 됩니다.
```

Bash 도구로 실행:
```bash
# 워크숍 전용 스킬 제거
rm -rf .claude/skills/0-local-setup
rm -rf .claude/skills/1-claude-md-setup
rm -rf .claude/skills/2-directory-structure-setup
rm -rf .claude/skills/3-mcp-setup
rm -rf .claude/skills/4-critical-ground-rule-setup
rm -rf .claude/skills/5-detail-prd
rm -rf .claude/skills/6-prototype
rm -rf .claude/skills/7-implement-by-claude-teams
rm -rf .claude/skills/8-github-ci-cd-setup
rm -rf .claude/skills/9-deploy
rm -rf .claude/skills/10-confirm
rm -rf .claude/skills/season-start
rm -rf .claude/skills/claude-basic
rm -rf .claude/skills/plugin-guide
rm -rf .claude/skills/bootstrap-packages
```

### Step 7: 완료 리포트

정리가 끝나면 최종 리포트를 출력합니다:

```
🎉 축하합니다! 프로젝트가 완료되었습니다!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 프로젝트: {프로젝트명}
🌍 배포 URL: {URL}
🔗 GitHub: {repo URL}

📊 완료된 기능:
  ✅ {기능 1}
  ✅ {기능 2}
  ...

🛠️ 사용된 기술:
  Next.js + TypeScript + Tailwind + shadcn/ui + ...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🧹 워크숍 스킬 정리 완료

앞으로 쓸 수 있는 명령어:
  /help-claude     — 막힌 문제 해결
  /prd-collab      — 새 기능 기획
  /prd-split       — 큰 아이디어 쪼개기
  /cto-council     — 기술 질문
  /growth-setup    — SEO + Analytics
  /wrap-up         — 세션 기록
  /follow-up       — 후속 점검

수정/추가하고 싶은 게 있으면 언제든
이 폴더에서 claude 를 실행하세요!
```

Slack에도 완료 알림:
```
🎉 프로젝트 완료!
프로젝트: {프로젝트명}
URL: {배포 URL}
```
