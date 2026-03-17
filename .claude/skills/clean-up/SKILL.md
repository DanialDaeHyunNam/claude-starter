# Clean Up

워크숍 세션 종료 후 추적 관련 아티팩트를 정리하는 스킬입니다.

## When to Use

- 사용자가 `/clean-up` 을 입력했을 때
- 워크숍 당일 세션이 끝난 후 다음 프로젝트를 위해 정리할 때

## Instructions

### Step 1: 정리 대상 확인

Bash 도구로 현재 추적 상태를 확인하세요 (조용히):

```bash
echo "=== Clean-up 대상 확인 ===" && \
if [ -f .fearnot/participant.json ]; then \
  echo "participant.json: $(cat .fearnot/participant.json)"; \
else \
  echo "participant.json: 없음 (이미 정리됨)"; \
fi && \
if grep -q "TRACKING_START" CLAUDE.md 2>/dev/null; then \
  echo "CLAUDE.md: Progress Tracking 섹션 있음"; \
else \
  echo "CLAUDE.md: Progress Tracking 섹션 없음 (이미 정리됨)"; \
fi
```

### Step 2: 사용자 확인

AskUserQuestion 도구를 사용하여 질문하세요:

- question: "워크숍 추적 데이터를 정리할까요? (다음 프로젝트를 위해 초기화합니다)"
- header: "Clean Up"
- options:
  - label: "정리해주세요" / description: ".fearnot/ + CLAUDE.md 추적 섹션을 정리합니다"
  - label: "아직이요" / description: "나중에 /clean-up 으로 다시 실행할 수 있어요"

### Step 3: 정리 실행

"정리해주세요"를 선택하면:

1. `.fearnot/` 삭제:
```bash
rm -rf .fearnot/
```

2. CLAUDE.md에서 `<!-- TRACKING_START -->` ~ `<!-- TRACKING_END -->` 구간 제거:
```bash
sed -i '' '/<!-- TRACKING_START -->/,/<!-- TRACKING_END -->/d' CLAUDE.md
```

3. CLAUDE.md 슬래시 커맨드 테이블에서 `/clean-up` 행 제거:
```bash
sed -i '' '/clean-up/d' CLAUDE.md
```

### Step 4: 완료 안내

```
✅ Clean-up 완료!

🧹 정리된 항목:
   - .fearnot/ (참여자 추적 데이터)
   - CLAUDE.md Progress Tracking 섹션
   - CLAUDE.md /clean-up 커맨드 행

이제 새로운 프로젝트를 시작할 준비가 되었습니다.
/1-claude-md-setup 부터 다시 시작하세요!
```
