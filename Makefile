# ──────────────────────────────────────────────
# Claude Starter — Slide Deck
# ──────────────────────────────────────────────
# Usage:
#   make slides              # latest version
#   make slides VERSION=v0   # specific version
# ──────────────────────────────────────────────

SLIDES_DIR := slides

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
