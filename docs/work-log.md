# Fork work log

Features added on **this fork** (`apski/tinycast`, branch `apski-enhancements`), on top of upstream
Tinycast (`abue-ammar/tinycast`). Newest first. Not part of upstream — expect this file itself to
conflict on a merge occasionally; just keep both sides' entries.

One entry per feature: what changed, why, and the commit that carries it.

## 2026-09-17 — Launcher: assign an alias from the ⌘K Actions menu

- Any persistent launcher row's Actions menu (⌘K / right-click) now has an **Assign Alias** item
  (titled **Change Alias** when one is already set). It prompts via `core.promptText` and writes
  through the existing `AliasStore` (`core.aliases.setAlias(_, for: app.preferenceKey)`) — a blank
  value clears it, so assign/change/clear are one item. Works for every `AppEntry.Kind`, not just
  system actions.
- No new model/store/matcher: aliasing already existed and was reachable only from Settings (each
  `LauncherItemRow` renders `AliasField`); this adds the inline launcher entry point that was
  missing. Gated by the same `isPersistent` (`!CommandCatalog.isQueryDriven`) check as Favorites —
  a query-driven row lives only for its query, so no preference could outlive it.

Commit: `6406f6b`

## 2026-09-16 — Clipboard: natively resizable window, both axes, position remembered

- The clipboard screen's window is natively resizable (drag any edge or corner, and AX tools /
  modifier-drag window managers like Moves work too), clamped to
  `Theme.Size.clipboardWindowWidthRange` (750–1100pt) and `...HeightRange` (475–900pt). Every other
  screen keeps the fixed panel size; `PaletteWindowController.positionPanel` only reads the clipboard
  width/height when `core.palette.mode == .clipboard`.
- Size persists per Mac in `AppSettings.clipboardWindowWidth`/`clipboardWindowHeight` (nil = default);
  position persists via the existing `palettePosition` path — `windowDidMove`/`windowDidResize` now
  record the top-left after *any* move, not only our own drag handle, so a window moved by an external
  tool re-opens where it was left. All excluded from settings backups as machine-local geometry.
- **Making native `.resizable` work took getting past a crash.** A first attempt added `.resizable`
  to `PalettePanel`'s existing `[.borderless, …]` `styleMask`; dragging an edge live aborted inside
  AppKit's own resize cycle — `NSHostingView.updateAnimatedWindowSize` → `windowDidLayout` →
  `_postWindowNeedsUpdateConstraints` throwing `NSInternalInconsistencyException`, uncaught,
  `EXC_CRASH`/`SIGABRT` (confirmed via `~/Library/Logs/DiagnosticReports/Tinycast-*.ips`; the whole
  stack is Apple frameworks, none of our code). The fix: give the panel a real `.titled` style mask
  but hide the title bar completely (`titleVisibility = .hidden`, `titlebarAppearsTransparent`,
  `titlebarSeparatorStyle = .none`, and `hideTitleBarChrome()` hides the three traffic-light
  buttons). A borderless `NSHostingView` panel has no title-bar constraint scaffolding, and that is
  what AppKit's live-resize path trips over; a titled-but-hidden one has it and survives.
  `hideTitleBarChrome()` is re-run whenever `positionPanel` toggles `.resizable`, since a style-mask
  change can grow the buttons back.
- Clamping is native: `positionPanel` sets `panel.minSize`/`maxSize` to the clipboard ranges while
  resizable (and pins both to the fixed size otherwise), so AppKit enforces the bounds mid-drag with
  no `windowWillResize` delegate policing the size. `windowDidResize`/`windowDidMove` only *record*
  the result — they never call `setFrame`, which is what fought the live drag in an interim version.
  `isSettingFrame` guards our own programmatic `setFrame` in `positionPanel` so its delegate
  callbacks don't get persisted as user drags.
- Note: synthetic CGEvent drags do not model native edge-resize faithfully (they blew past `maxSize`
  and grew symmetrically in a probe) — this was verified by real mouse dragging, not the probe.

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
