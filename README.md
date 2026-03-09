# Soccer Game Planner (PencilKit)

A practical soccer tactics board for iOS built with SwiftUI + PencilKit.

## What Changed (Soccer-Accurate Redesign)

- Initial screen now opens as a full soccer pitch with realistic proportions.
- Pitch markings are based on real dimensions:
  - Full field ratio: `68m x 105m`
  - Center circle
  - Penalty areas
  - Goal areas
  - Penalty marks
  - Penalty arcs
- Both teams are placed on the field at launch with soccer-style kickoff lineups.
- Default kickoff is `11v11` with proper formation-based spacing.

## Team and Match Features

- Home + Away team markers simultaneously on one field.
- Team sizes adjustable from `5...11` per side.
- Quick presets: `11v11`, `9v9`, `8v8`, `7v7`, `5v5`.
- For 11-player teams, formation options:
  - `4-3-3`
  - `4-4-2`
  - `4-2-3-1`
- Player markers are draggable in Players mode.
- Tap a marker to edit jersey number and team.

## Cleaner UI (Menu-Driven)

- Main screen is now pitch-first with minimal controls.
- Extra controls are hidden in a single **Coach Menu** sheet:
  - Match setup and lineups
  - Drawing tools
  - Notes and quick actions

## Drawing Features

- PencilKit drawing over the pitch:
  - Ink, Eraser, Lasso
  - Ink style, color, width, opacity
  - Undo / Redo / Clear drawings

## Apple Documentation Links

- https://developer.apple.com/documentation/pencilkit
- https://developer.apple.com/documentation/pencilkit/pkcanvasview
- https://developer.apple.com/documentation/pencilkit/pkinkingtool
- https://developer.apple.com/documentation/swiftui/sheet

## Run

1. `xcodegen generate`
2. Open `ios-pencilkit-20260308-160158-2oxrqp.xcodeproj` in Xcode.
3. Run on iOS 17+ simulator/device.
