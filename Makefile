# ──────────────────────────────────────────────
# Claude Starter
# ──────────────────────────────────────────────
# Usage:
#   make slides              # latest version
#   make slides VERSION=v0   # specific version
#   make claude              # tmux + claude (Teams split-pane)
#   make claude PROJECT=my-app  # 특정 프로젝트에서 실행
# ──────────────────────────────────────────────

SLIDES_DIR := slides
PROJECT ?=

# Default: highest version (sorted, last wins)
VERSION ?= $(shell ls -d $(SLIDES_DIR)/v* 2>/dev/null | sort -V | tail -1 | xargs basename)

DECK := $(SLIDES_DIR)/$(VERSION)/slides.md

.PHONY: slides slides-install

slides-install:
	@if [ ! -d "$(SLIDES_DIR)/node_modules" ]; then \
		echo "Installing slidev dependencies ..."; \
		cd $(SLIDES_DIR) && bun install; \
	fi

slides: slides-install
	@if [ -z "$(VERSION)" ]; then \
		echo "Error: No slide versions found in $(SLIDES_DIR)/"; exit 1; \
	fi
	@if [ ! -f "$(DECK)" ]; then \
		echo "Error: $(DECK) not found"; exit 1; \
	fi
	@echo "Opening slides/$(VERSION) ..."
	@cd $(SLIDES_DIR) && bunx slidev $(VERSION)/slides.md --open

# ──────────────────────────────────────────────
# Claude Code (Teams split-pane via tmux)
# ──────────────────────────────────────────────
.PHONY: claude

claude:
	@if ! command -v tmux >/dev/null 2>&1; then \
		echo "Error: tmux not found. Install: brew install tmux (Mac) / scoop install tmux (Win)"; exit 1; \
	fi
	@if [ -n "$$TMUX" ]; then \
		echo "Already inside tmux. Run claude directly."; exit 1; \
	fi
	$(eval WORK_DIR := $(if $(PROJECT),projects/$(PROJECT),.))
	@if [ "$(WORK_DIR)" != "." ] && [ ! -d "$(WORK_DIR)" ]; then \
		echo "Error: $(WORK_DIR) not found"; exit 1; \
	fi
	@echo "Starting tmux + claude in $(WORK_DIR) ..."
	@tmux new-session -s claude -c "$(CURDIR)/$(WORK_DIR)" "claude --dangerously-skip-permissions"
