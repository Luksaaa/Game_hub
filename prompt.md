# Target Point LLM Orientation Prompt

Use this document to understand the current Flutter project before making changes. The user communicates in Croatian, but source code, class names, widget names, labels, comments, and technical identifiers should stay in English.

## Product Goal

Target Point is a darts scoring app. The main interaction is a large clickable dartboard. The player taps the field they hit, and the app records the throw, calculates the score, handles the turn, and updates the match state.

The app should eventually support:

- Guest usage without login.
- Optional Google/email account login.
- Local player profiles and recurring player groups.
- Match presets.
- Match history and statistics.
- Local-first storage with later cloud sync.

## Current Project Shape

The app is currently implemented mostly in:

- `lib/main.dart`
- `test/widget_test.dart`

There are no extra state management packages or backend integrations yet. Keep early changes simple and avoid introducing dependencies unless they clearly solve a real problem.

## Current Features

- Clickable dartboard rendered with `CustomPainter`.
- Hit detection from tap coordinates.
- X01 and Count up game modes.
- Starting score choices: `301`, `501`, `701`.
- Finish rules: `Single`, `Double`, `Master`.
- Preset players: `Marko`, `Luka`, `Borna`.
- Three darts per turn.
- Automatic turn commit after the third dart.
- Manual `Save turn`.
- `Undo` for pending hits.
- `Miss` button.
- X01 bust logic.
- Player average per turn.
- Responsive mobile/desktop layout.
- System light/dark mode.
- App icons updated across Android, iOS, macOS, web, and Windows.

## Important Classes And Responsibilities

### `TargetPointApp`

Root widget. Defines:

- `MaterialApp`
- `themeMode: ThemeMode.system`
- light theme
- dark theme
- home screen: `DartMatchScreen`

Do not replace `ThemeMode.system` unless the user asks for manual theme switching.

### `AppPalette`

Small theme helper used for custom UI colors outside Flutter's default color scheme.

Responsibilities:

- Provide light and dark colors.
- Keep custom widgets readable in both system modes.
- Centralize repeated colors for panels, cards, text, borders, and dartboard colors.

When adding custom UI, prefer `AppPalette.of(context)` instead of hardcoding new colors.

### `GameMode`

Enum for supported game modes:

- `x01` - starts from a score like 501 and counts down to 0.
- `countUp` - starts at 0 and accumulates points.

### `OutRule`

Enum for X01 finish rules:

- `singleOut`
- `doubleOut`
- `masterOut`

### `SegmentBand`

Enum describing which part of the board was hit:

- `miss`
- `single`
- `double`
- `triple`
- `outerBull`
- `bull`

### `DartHit`

Represents one dart throw.

Fields:

- `label` - display label, for example `T20`, `D16`, `S5`, `25`, `BULL`, `MISS`.
- `score` - numeric value of the hit.
- `band` - `SegmentBand`.
- `number` - board number when applicable.

Derived helpers:

- `isMiss`
- `isDouble`

### `PlayerScore`

Represents a player in the current match.

Fields:

- `name`
- `remaining`
- `totalScored`
- `turns`
- `isWinner`

`turns` is a list of turns, where each turn is a list of `DartHit`.

### `GameSettings`

Current match settings:

- `mode`
- `startingScore`
- `outRule`

### `DartMatchScreen`

Main stateful match screen.

Responsibilities:

- Own current game settings.
- Own current player scores.
- Own pending turn hits.
- Handle hit input.
- Handle undo.
- Handle miss.
- Commit turns.
- Apply X01 bust and finish logic.
- Reset match when settings change.
- Choose desktop or mobile layout.

Important methods:

- `_handleHit(DartHit hit)` - adds a pending hit and auto-commits after three darts.
- `_undoLastHit()` - removes the last pending hit.
- `_addMiss()` - records a zero-point miss.
- `_commitTurn()` - saves current turn into player history and updates score.
- `_isValidFinish(int remaining, DartHit hit)` - validates X01 finishing throw.
- `_advanceTurn()` - moves to the next player unless the match is won.
- `_resetMatch()` - rebuilds game state with optional changed settings.

### `_MobileTopBar`

Mobile-only top header.

Contains:

- app logo
- `Target Point` title
- `Darts scorer` subtitle
- search icon placeholder
- new match/reset icon
- profile avatar with current player's initial

The search action is currently a placeholder.

### `_BoardPanel`

Main game area.

Contains:

- `_CurrentTurnHeader`
- clickable `Dartboard`
- action row with `Undo`, `Miss`, `Save turn`

### `_CurrentTurnHeader`

Displays:

- current player name
- current remaining score
- three dart slots
- turn total
- match or bust message

### `_ControlPanel`

Settings and players panel.

Contains:

- optional header on desktop
- game mode segmented control
- starting score chips
- finish rule segmented control
- player cards
- local session status text

On mobile, the title header is hidden because `_MobileTopBar` already shows the app identity.

### `Dartboard`

Gesture wrapper around the painted board.

Responsibilities:

- Read available square size.
- Convert tap location into a `DartHit` using `DartboardGeometry.hitTest`.
- Render `DartboardPainter`.

### `DartboardGeometry`

Pure-ish geometry/scoring helper.

Responsibilities:

- Map tap coordinates to dartboard score.
- Determine board number from angle.
- Determine single/double/triple/bull/miss from distance.

Current dartboard number order:

```text
20, 1, 18, 4, 13, 6, 10, 15, 2, 17, 3, 19, 7, 16, 8, 11, 14, 9, 12, 5
```

Important ratios:

- outside board: `> 0.98` = `MISS`
- bull: `<= 0.055`
- outer bull: `<= 0.12`
- triple ring: `0.52` to `0.62`
- double ring: `>= 0.84`

### `DartboardPainter`

Draws the board with `Canvas`.

Responsibilities:

- Draw board rings.
- Draw segment colors.
- Draw segment numbers.
- Draw wire lines.
- Draw bull and outer bull.

It receives `AppPalette` so the board border/wire colors can adapt to light/dark mode.

## UI Notes

- The current mobile layout is intentionally compact.
- The dartboard should remain the main visual and interaction surface.
- Avoid oversized marketing sections.
- Prefer tool-like UI focused on playing and scoring.
- Keep buttons and repeated controls stable in size.
- Avoid making nested cards.
- Keep labels in English.

## Testing

Current tests in `test/widget_test.dart` cover:

- recording a center dartboard hit as `BULL`
- undoing a pending hit
- rendering on a narrow mobile viewport
- rendering with system dark theme

Run:

```powershell
flutter analyze
flutter test
```

## Known Limitations

- No persistence yet.
- No editable players yet.
- No match history yet.
- No authentication yet.
- Search button has no behavior.
- Match state is in one stateful widget and should eventually be extracted once persistence or more screens are added.

## Preferred Next Implementation Order

1. Extract models and scoring logic from `lib/main.dart` into smaller files.
2. Add editable local players.
3. Add local match history.
4. Add match presets.
5. Add storage.
6. Add account/login flow.
7. Add cloud sync.

Keep each change narrow and preserve working tests.
