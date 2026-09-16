# Fork work log

Features added on **this fork** (`apski/tinycast`, branch `apski-enhancements`), on top of upstream
Tinycast (`abue-ammar/tinycast`). Newest first. Not part of upstream — expect this file itself to
conflict on a merge occasionally; just keep both sides' entries.

One entry per feature: what changed, why, and the commit that carries it.

## 2026-09-16 — Clipboard: resizable window, both axes

- The clipboard screen's window can be resized wider/narrower and taller/shorter, clamped to
  `Theme.Size.clipboardWindowWidthRange` (750–1100pt) and `...HeightRange` (475–900pt). Every other
  screen keeps the fixed panel size; `PaletteWindowController.positionPanel` only reads the clipboard
  width/height when `core.palette.mode == .clipboard`.
- Both persist per Mac in `AppSettings.clipboardWindowWidth`/`clipboardWindowHeight` (nil = default),
  excluded from settings backups as machine-local geometry, same as `clipboardListWidth`/`palettePosition`.
- Resizing is native AppKit window resizing, not a custom SwiftUI drag handle: `PalettePanel`'s
  `styleMask` gains `.resizable` only while collapsed is false and the mode is `.clipboard`, so the
  OS's own edge/corner drag regions work, and so does any Accessibility-driven resize (a modifier-drag
  window manager like Moves/Rectangle/Loop, which sets the frame directly and never goes through
  `windowWillResize`). `PaletteWindowController.windowWillResize` clamps both dimensions for a live
  interactive drag; `windowDidResize` is the catch-all that corrects and persists a frame set any
  other way, guarded by `isSettingClipboardFrame` so its own correction — and every programmatic
  resize from `positionPanel` — never re-enters or gets written back to settings as if the user had
  dragged it. An earlier version used a custom SwiftUI bottom-edge `DragGesture`; that only handled
  dragging inside the app and didn't make the window resizable at the AppKit/AX level, so external
  tools like Moves couldn't grab it.
- `windowDidResize`'s correction must never call `setFrame` synchronously: doing so from inside the
  notification re-enters AppKit's live-resize display cycle and crashes
  (`NSHostingView.updateAnimatedWindowSize` mid-transaction, `EXC_CRASH`/`SIGABRT` via
  `_postWindowNeedsUpdateConstraints`). The correction now runs one `DispatchQueue.main.async` tick
  later, outside that cycle.

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
