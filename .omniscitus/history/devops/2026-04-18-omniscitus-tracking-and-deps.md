# Omniscitus Tracking 정책 결정 + helper 의존성 bump

**Participants**: Danial Nam, claude

## Summary
helper 템플릿의 shadcn/lucide-react 마이너 버전 업데이트와 함께, omniscitus 플러그인이 생성하는 `.omniscitus/` 디렉토리를 레포에서 어떻게 다룰지 최종 확정. 처음엔 gitignore로 처리했다가, 사용자 판단으로 **blueprints를 추적 자산으로 공유**하는 방향으로 방침 변경.

## Context
- **Background**: 세션 시작 시 `.omniscitus/`가 untracked 상태였고 `.claude/wrap-up/`이 이미 gitignore되어 있어 "같은 성격의 런타임 데이터인가?"라는 판단 분기가 발생. 동시에 helper/package.json이 shadcn 4.1.1 → 4.2.0, lucide-react 1.7.0 → 1.8.0 마이너 bump 상태로 남아 있었음.
- **Requirements**:
  - helper 템플릿 의존성을 최신 마이너로 동기화 (수강생 프로젝트에 복사되는 기준)
  - `.omniscitus/` 처리 방침 확정: 커밋 vs gitignore
- **Decisions**:
  - (1차) `.omniscitus/`를 gitignore에 추가 — `_root.yaml`이 timestamps/change_count를 포함해 세션마다 diff가 튀고, 이미 gitignore된 `.claude/wrap-up/`과 동일 성격이라 판단 (PR #35)
  - (2차, 사용자 지시) blueprints는 **레포 공유 자산**으로 추적. `.gitignore`에서 `.omniscitus/` 라인 제거하고 `_root.yaml`, `_claude.yaml` 커밋 (PR #36)
  - helper deps와 gitignore 추가는 PR #35에 묶음 (chore 성격으로 묶는 판단)
- **Constraints**:
  - GitHub branch protection으로 main 직접 push 금지, PR + squash merge 필수

## Timeline

### 2026-04-18
**Focus**: helper 의존성 bump + .omniscitus/ gitignore → 재추적 (PR #35, #36 merged)

- helper/package.json, helper/bun.lock: lucide-react ^1.7.0 → ^1.8.0, shadcn ^4.1.1 → ^4.2.0
- **PR #35**: `.gitignore`에 `.omniscitus/` 추가 + helper deps bump
- **PR #36**: 방침 변경으로 `.gitignore`에서 `.omniscitus/` 라인 제거하고 `_root.yaml`, `_claude.yaml` 커밋
- 모든 PR을 squash and merge로 정리, 로컬/원격 브랜치 정리

**Learned**: 런타임 자동 생성 파일을 레포에 포함할지 여부는 단순히 "diff가 튀는가"만으로 판단하면 안 됨. 공유 자산으로 볼 수 있다면 (예: 팀이 blueprint를 참조) 추적하는 게 나음. 플러그인 데이터에 대한 결정은 플러그인이 어떻게 쓰이는지 문맥이 필요해 사용자에게 직접 확인하는 게 안전.

## Pending
- [ ] `.omniscitus/` 추적이 여러 세션/여러 사용자 간 conflict를 유발하는지 관찰 — 필요 시 timestamps/change_count 필드를 blueprint에서 제외하는 정책 도입 고려

## Notes
- 관련 PR: #35 ([chore] helper 의존성 bump + .omniscitus/ gitignore 추가), #36 ([chore] .omniscitus/ 추적 대상에 추가)
- `.omniscitus/blueprints/_root.yaml`은 세션마다 timestamps/change_count가 갱신되므로, 팀 작업 시 merge conflict가 날 수 있음 — 실제 사용 패턴 관찰 후 재조정
