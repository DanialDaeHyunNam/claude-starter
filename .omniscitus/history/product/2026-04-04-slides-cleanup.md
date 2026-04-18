# 슬라이드 Git 로그인 제거 + zsh 설치 옵션

**Participants**: Danial Nam, claude

## Summary
강의 슬라이드에서 Git 로그인(git config) 단계를 삭제하고, Claude Code 설치 시 `| bash`와 `| zsh` 두 옵션을 모두 안내하도록 변경.

## Context
- **Background**: Git 로그인은 강의에서 시키지 않을 예정. Claude 설치 시 bash가 없는 macOS 환경(기본 쉘이 zsh)에서 `| bash`만 안내하면 실패할 수 있음.
- **Decisions**:
  - 슬라이드에서 git config 단계 완전 제거 (강의 시간 절약 + 불필요한 단계)
  - Claude Code 설치 명령을 `| bash`와 `| zsh` 두 개 모두 노출해 사용자 쉘 환경에 맞게 선택 가능하도록
- **Constraints**:
  - macOS는 Catalina부터 기본 쉘이 zsh이므로 bash가 없을 수 있음

## Timeline

### 2026-04-04
**Focus**: 슬라이드 Git 로그인 제거, Claude Code 설치 옵션 확장

- 슬라이드에서 git config 섹션 삭제
- Claude 설치 커맨드에 `| zsh` 옵션 추가 안내

**Learned**:
- macOS Catalina+ 환경에서는 bash가 없을 수 있어 설치 스크립트의 쉘 가정 주의 필요
- 슬라이드 Step 번호를 줄이면 강의 시간도 실측으로 줄어듦

## Pending
- [ ] 슬라이드 전체 Step 번호 재점검 (다른 곳에서 "Step 3" 참조하는 곳 없는지)

## Notes
- 관련 PR: #24 (슬라이드 Git 로그인 제거 + zsh 옵션)
- Legacy 포맷(top-level `history/`)에서 2026-04-18에 `.omniscitus/history/`로 이전하며 5섹션 포맷으로 재구성
