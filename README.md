# Soccer Game Planner (PencilKit)

A practical iOS tactics app focused on soccer planning.

This version is redesigned to support **both teams (home + opponent)**, configurable team sizes (like **11v11**, **8v8**), and a cleaner **menu/sheet-driven UI** so controls are hidden until needed.

## Core Features

- Accurate soccer field background with pitch markings.
- Two-team planning on the same field:
  - Home team markers
  - Opponent team markers
- Configurable team sizes (`5...11` each) for formats such as:
  - `11v11`
  - `9v9`
  - `8v8`
  - `7v7`
  - `5v5`
- Draggable numbered players with editable number and team.
- Compact UI with opener sheets:
  - `Teams` sheet for size/preset/actions
  - `Tools` sheet for drawing setup
- PencilKit tactical drawing:
  - Ink / Eraser / Lasso
  - Ink type, color, width, opacity
  - Undo / Redo / Clear drawing
- Notes section for tactical details.

## Why This Matches the Request

- The planner is now explicitly soccer-field-first.
- Opponent team planning is enabled by default.
- Team-size formats are configurable, including 11v11 and 8v8.
- Unnecessary always-visible buttons were removed from the main screen.
- Controls are hidden behind opener-style sheets for cleaner interaction.

## Apple Documentation Links

- https://developer.apple.com/documentation/pencilkit
- https://developer.apple.com/documentation/pencilkit/pkcanvasview
- https://developer.apple.com/documentation/pencilkit/pkinkingtool
- https://developer.apple.com/documentation/swiftui/sheet

## Run

1. `xcodegen generate`
2. Open `ios-pencilkit-20260308-160158-2oxrqp.xcodeproj`.
3. Run on iOS 17+ simulator/device.
