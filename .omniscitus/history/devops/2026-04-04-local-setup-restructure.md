# /0-local-setup 경량화 + DB 기본값 통일

**Participants**: Danial Nam, claude

## Summary
`/0-local-setup`을 필수 5개(Claude Code, Git, Node.js, Bun, gh)만 설치하는 경량 버전으로 변경하고, 기존 전체 설치는 `/bootstrap-packages`로 분리. 추가로 DB 기본값을 SQLite(로컬) + Neon Postgres(배포)로 확정하여 매번 묻는 블락커를 제거.

## Context
- **Background**: 100명 동시 강의에서 `/0-local-setup`이 시간이 너무 오래 걸리고, 사용자 환경(기존 nvm, fnm 등)에 따라 결과가 제각각. DB 선택도 매번 물어보는 게 진행 블락커였음.
- **Decisions**:
  - 필수 도구를 5개로 축소 — `/1`~`/10` 흐름 역추적 결과 실제 필수는 이것뿐 (tmux도 Teams 시각화용일 뿐 필수 아님)
  - 전체 설치는 `/bootstrap-packages` 보조 skill로 분리
  - DB 기본값을 SQLite(로컬 개발) + Neon Postgres(배포)로 고정
- **Constraints**:
  - macOS `bootstrap_mac.sh`에서 `gh` 누락되어 있었음 (Windows는 있었음) — bug fix로 함께 반영
  - Prisma는 datasource provider만 바꾸면 SQLite ↔ Postgres 전환 가능해야 정책이 성립

## Timeline

### 2026-04-04
**Focus**: /0-local-setup 경량화, /bootstrap-packages 분리, DB 기본값 통일

- 필수 5개 + 옵션 선택 구조로 `/0-local-setup` 재설계
- `/bootstrap-packages` 신규 skill로 전체 설치 이관
- DB 기본값 SQLite + Neon으로 확정, 물음 단계 제거

**Learned**:
- 흐름을 역추적하면 실제로 필수인 것과 편의용을 구분 가능
- 기존 설치 유틸은 OS 간 일관성 점검 필수 (`gh` 누락처럼 한쪽만 반영된 케이스 흔함)

## Pending
- [ ] `/bootstrap-packages` 실제 실행 테스트 (Mac/Windows)
- [ ] `/8-deploy`의 Neon 프로비저닝 흐름 실전 테스트 (당시 `/9-deploy`, 스텝 번호 앞당김으로 변경됨)
- [ ] Linux용 `bootstrap_linux.sh` 스크립트 작성 검토

## Notes
- 관련 PR: #22 (/0-local-setup 경량화 + /bootstrap-packages 분리), #23 (DB 기본값 통일)
- Legacy 포맷(top-level `history/`)에서 2026-04-18에 `.omniscitus/history/`로 이전하며 5섹션 포맷으로 재구성
