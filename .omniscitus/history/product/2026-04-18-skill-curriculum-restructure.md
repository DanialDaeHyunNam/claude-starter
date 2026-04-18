# Skill Curriculum Restructure (6-prototype 제거 + find-context 추가)

**Participants**: Danial Nam, claude

## Summary
11단계였던 커리큘럼 skill 흐름을 10단계로 축소하고, 과거 맥락 검색 유틸리티 `/find-context`를 추가. 기존 `/6-prototype`이 `/5-detail-prd → /prd-collab` 내부 Pencil 와이어프레임과 기능 중복이어서 제거.

## Context
- **Background**: /5-detail-prd 가 /prd-split → /prd-collab을 호출하고, /prd-collab의 Step 9가 이미 Pencil로 저해상도 와이어프레임을 그리도록 되어 있음. /6-prototype은 같은 일을 한 번 더 하는 중복 단계였음.
- **Requirements**:
  - `/6-prototype` 삭제
  - 6번이 비면서 생기는 gap 제거 (사용자 요청으로 7~10번을 6~9번으로 앞당김)
  - `/find-context` 신규 skill: 현재 대화 주제의 과거 의사결정(why) + 교훈(lessons learned)을 docs/PRD/history에서 찾아 **출처(file:line)** 포함 리포트
- **Decisions**:
  - 폴더 리네임은 `git mv`로 처리해 히스토리 보존
  - `/find-context`는 설명→이해 확인 패턴 없이 즉시 진단을 수행하는 **유틸리티 skill** (다른 커리큘럼 skill과 다른 패턴)
  - `/find-context`는 단순 키워드 매치가 아니라 "결정/이유"와 "교훈/주의" 신호를 별도로 필터링해 의미 있는 맥락만 추출하도록 설계
  - `/9-confirm` cleanup 리스트에 `/find-context`는 **포함하지 않음** — utility skill은 수강생 프로젝트에도 남겨둠
- **Constraints**:
  - H1 제목 vs `## Step N` 커리큘럼 섹션 vs `### Step N` 내부 하위 단계가 동일 텍스트라 grep으로 일괄 치환 불가 — 각 참조를 의미 레벨별로 분류해 수동 업데이트
  - 슬라이드의 `화면 종류`, `프로토타입 (Pencil)` 같은 번호 나열은 스킬 번호와 무관하므로 건드리지 않음

## Timeline

### 2026-04-18
**Focus**: `/6-prototype` 삭제 + `/find-context` 추가 + 7~10번을 6~9번으로 앞당김 (PR #34 merged)

- `.claude/skills/6-prototype/` 삭제
- `.claude/skills/{7,8,9,10}-*` → `{6,7,8,9}-*` 리네임 (git mv)
- 각 skill 파일의 self 참조 / H1 / `## Step N` / `Step N 완료` / next-step 링크 업데이트
- 외부 참조 업데이트: `CLAUDE.md` 표, `README.md` 흐름도, `5-detail-prd`의 next-step, `growth-setup`의 트리거, `1-claude-md-setup`의 주석, `9-confirm` cleanup `rm -rf` 리스트
- `.claude/skills/find-context/SKILL.md` 신규 생성 — 주제 추론 → 문서 스캔 → why/lessons learned 신호 필터링 → 출처 포함 리포트
- `CLAUDE.md` 보조 skill 표에 `/find-context` 추가

**Learned**: 스킬 폴더 리네임 시 git mv는 디렉토리만 이동시킬 뿐, 내부 문서 참조는 자동으로 갱신되지 않음 — 각 파일의 self/next 참조, 커리큘럼 단계 번호, cleanup 리스트를 수동으로 모두 손봐야 함. 커리큘럼 step 번호와 skill 내부 sub-step 번호가 같은 표기(`Step N`)로 섞여 있어 맥락 구분이 필수.

## Pending
- [ ] `/find-context`를 실제 프로젝트에서 돌려보고 why/lessons 시그널 추출 품질 검증
- [ ] 필요하면 추가 신호 키워드(예: "rationale", "tradeoff", "후속")를 확장

## Notes
- 관련 PR: #34 ([improve] /6-prototype 제거하고 /find-context 추가, step 번호 앞당김)
- slides/v0/slides.md의 숫자 나열(`7. 화면 종류`, `8. 프로토타입`)은 스킬 번호와 무관해 유지
