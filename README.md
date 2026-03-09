# Soccer Game Planner (PencilKit)

A practical SwiftUI iOS tactics board for soccer coaches and players.

The app combines a **soccer field planner** with **PencilKit drawing** so you can quickly place players, sketch movement, and annotate strategy in one screen.

## What It Does

- Soccer field background with marked pitch lines.
- Draggable player markers on top of the field.
- Editable player numbers (`1...99`) and team color (Home/Away).
- Formation presets: `4-3-3`, `4-4-2`, `3-5-2`.
- Rich drawing tools powered by PencilKit:
  - Draw mode with ink type (Pen, Pencil, Marker, Monoline)
  - Color picker
  - Stroke width and opacity controls
  - Eraser mode
  - Lasso mode
  - Undo / Redo
  - Clear drawing layer
- Tactical notes panel for extra details.

## Why This Is Practical

- Build game plans before training sessions.
- Draw passing lanes, pressing triggers, and defensive shape.
- Adjust formation and player roles in real time during meetings.

## Apple Documentation Links

- https://developer.apple.com/documentation/pencilkit
- https://developer.apple.com/documentation/pencilkit/pkcanvasview
- https://developer.apple.com/documentation/pencilkit/pkinkingtool
- https://developer.apple.com/documentation/swiftui/draggesture

## Run

1. `xcodegen generate`
2. Open `ios-pencilkit-20260308-160158-2oxrqp.xcodeproj` in Xcode.
3. Run on iOS 17+ simulator/device.
