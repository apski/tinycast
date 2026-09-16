# Fork work log

Features added on **this fork** (`apski/tinycast`, branch `apski-enhancements`), on top of upstream
Tinycast (`abue-ammar/tinycast`). Newest first. Not part of upstream — expect this file itself to
conflict on a merge occasionally; just keep both sides' entries.

One entry per feature: what changed, why, and the commit that carries it.

## 2026-09-16 — Clipboard: skip pins on open, pin descriptions, resizable split

- Opening the clipboard screen (or clearing its filter/query) selects the first unpinned entry
  instead of the top pin. New `PaletteScreen.resetSelection()` hook, overridden by `ClipboardScreen`.
- Pins can carry a short description, set from the row's Actions menu, shown under the row title.
  New `pin_note` column on `items` (guarded migration in `ClipboardStore.migratePinNoteColumn()`),
  a new `DialogController.promptText` for the single-field prompt, and it round-trips through backups.
- The clip list/preview divider is draggable; the split width persists per Mac (excluded from
  settings backups as machine-local geometry, like palette position).
- Added `Scripts/install-local.sh`: builds a signed Release build and installs it over
  `/Applications/Tinycast.app` directly, so a local build carries forward the same settings/history
  instead of running as the isolated `Tinycast Dev.app` debug channel.

Commit: `21cdf52`
