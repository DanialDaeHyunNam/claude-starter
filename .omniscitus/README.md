# .omniscitus/

Codebase world model for [omniscitus](https://omniscitus.vercel.app/).
Tracks blueprints (per-file), history (per-topic), and tests.

## Uninstall

To remove omniscitus cleanly:

1. **Run `/omniscitus-uninstall` first** (recommended — surgical cleanup)
2. **Then** `/plugin uninstall omniscitus`

If `/omniscitus-uninstall` is not available for some reason, manual
cleanup using the recorded anchor:

```bash
# Restore the files we touched to their pre-migration state
ANCHOR=$(grep 'sha:' .omniscitus/migrate/anchor.yaml | head -1 | awk '{print $2}')
for path in $(grep 'path:' .omniscitus/migrate/anchor.yaml | awk '{print $3}' | sort -u); do
  git checkout "$ANCHOR" -- "$path" 2>/dev/null || rm -f "$path"
done
rm -rf .omniscitus
```

## Inspection

- `blueprints/` — every tracked file, with authorship, change count, purpose.
- `history/` — topic-based units, grouped by domain. `_weekly/` holds rolled-up summaries.
- `tests/` — meta.yaml overlays (code) and prompt-meta.yaml (prompt eval).
- `ontology.yaml` — domain taxonomy for /wrap-up classification.
- `migrate/anchor.yaml` — pre-migration SHA + footprint of files we changed outside this folder.

Open `/birdview` for the visual browser.
