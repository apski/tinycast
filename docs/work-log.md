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
- Two SwiftUI `DragGesture` edge handles (`ClipboardHeightResizeHandle` on the bottom edge,
  `ClipboardWidthResizeHandle` on the trailing edge, both in `RootPaletteView.swift`), each calling a
  discrete `PaletteWindowController.resizeClipboardHeight`/`resizeClipboardWidth(to:commit:)` —
  a direct `panel.setFrame` per drag tick, committed to `AppSettings` only on release.
- **This deliberately is not AppKit's native `.resizable`/live window-edge resize.** An earlier
  version added `.resizable` to `PalettePanel`'s `styleMask` in clipboard mode so the OS's own
  edge/corner drag (and an Accessibility-driven resize, e.g. a modifier-drag window manager like
  Moves/Rectangle/Loop) would work. It crashed: dragging an edge live sent the process straight into
  `abort()` — `NSHostingView.updateAnimatedWindowSize` → `windowDidLayout` →
  `_postWindowNeedsUpdateConstraints` throwing `NSInternalInconsistencyException`, uncaught,
  `EXC_CRASH`/`SIGABRT`. Confirmed via `~/Library/Logs/DiagnosticReports/Tinycast-*.ips`: the crash
  sits entirely inside AppKit/SwiftUI's own `_setFrameCommon:display:fromServer:` (the "fromServer"
  live-resize-tracking path) — not in any of our delegate code, and it survived an interim fix that
  deferred our own `windowDidResize` correction by a run-loop tick. An `NSHostingView`-backed
  borderless panel with `hosting.sizingOptions = []` (see `PalettePanel.swift`, needed so the top
  edge doesn't drift on a content swap) just doesn't survive a live/interactive AppKit resize on this
  OS build. A gesture-driven, one-shot `setFrame` never enters that "fromServer" tracked path, so it
  doesn't crash — the trade-off is that a resize can only come from inside the app; an external
  modifier-drag tool has nothing to grab, since AX-settable size also needs `.resizable`.

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
