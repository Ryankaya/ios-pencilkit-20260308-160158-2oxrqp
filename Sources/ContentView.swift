import SwiftUI
import PencilKit
import UIKit

struct ContentView: View {
    @State private var canvasView = PKCanvasView()
    @State private var toolMode: ToolMode = .ink
    @State private var inkType: InkType = .pen
    @State private var selectedColor: Color = .red
    @State private var strokeWidth: CGFloat = 6
    @State private var strokeOpacity: Double = 0.9

    @State private var players: [PlayerToken] = PlayerToken.preset433()
    @State private var selectedPlayerID: UUID?
    @State private var tacticNotes: String = "Press and drag player circles to position them. Draw arrows and zones on top of the pitch."

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                drawingToolbar
                playerToolbar

                GeometryReader { geometry in
                    ZStack {
                        SoccerFieldView()

                        PencilCanvasRepresentable(
                            canvasView: $canvasView,
                            tool: activeTool,
                            isDrawingEnabled: toolMode != .select
                        )

                        ForEach($players) { $player in
                            PlayerMarkerView(
                                player: $player,
                                isSelected: player.id == selectedPlayerID,
                                fieldSize: geometry.size
                            )
                            .onTapGesture {
                                selectedPlayerID = player.id
                                toolMode = .select
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.white.opacity(0.25), lineWidth: 1)
                    )
                }
                .frame(minHeight: 380)

                selectedPlayerPanel
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(red: 0.08, green: 0.12, blue: 0.09), Color(red: 0.05, green: 0.08, blue: 0.06)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("Soccer Game Planner")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var activeTool: PKTool {
        switch toolMode {
        case .ink:
            return PKInkingTool(
                inkType.pkInkType,
                color: UIColor(selectedColor).withAlphaComponent(strokeOpacity),
                width: strokeWidth
            )
        case .eraser:
            return PKEraserTool(.vector)
        case .lasso:
            return PKLassoTool()
        case .select:
            return PKInkingTool(.pen, color: UIColor.clear, width: 1)
        }
    }

    private var drawingToolbar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Picker("Mode", selection: $toolMode) {
                    ForEach(ToolMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Button("Undo") {
                    canvasView.undoManager?.undo()
                }
                .buttonStyle(.bordered)

                Button("Redo") {
                    canvasView.undoManager?.redo()
                }
                .buttonStyle(.bordered)

                Button("Clear Draw") {
                    canvasView.drawing = PKDrawing()
                }
                .buttonStyle(.borderedProminent)
            }

            if toolMode == .ink {
                HStack(spacing: 10) {
                    Picker("Ink", selection: $inkType) {
                        ForEach(InkType.allCases, id: \.self) { ink in
                            Text(ink.title).tag(ink)
                        }
                    }
                    .pickerStyle(.segmented)

                    ColorPicker("Color", selection: $selectedColor)
                        .labelsHidden()
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Width \(Int(strokeWidth))")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        Slider(value: $strokeWidth, in: 1...24, step: 1)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Opacity \(Int(strokeOpacity * 100))%")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        Slider(value: $strokeOpacity, in: 0.2...1, step: 0.05)
                    }
                }
            }
        }
        .padding(10)
        .background(.black.opacity(0.25), in: RoundedRectangle(cornerRadius: 12))
    }

    private var playerToolbar: some View {
        HStack(spacing: 8) {
            Menu("Formation") {
                Button("4-3-3") { players = PlayerToken.preset433() }
                Button("4-4-2") { players = PlayerToken.preset442() }
                Button("3-5-2") { players = PlayerToken.preset352() }
            }
            .buttonStyle(.bordered)

            Button("Add Player") {
                let nextNumber = (players.map(\.number).max() ?? 0) + 1
                players.append(PlayerToken(number: min(nextNumber, 99), x: 0.5, y: 0.5, team: .home))
            }
            .buttonStyle(.borderedProminent)

            Button("Reset Players") {
                players = PlayerToken.preset433()
                selectedPlayerID = nil
            }
            .buttonStyle(.bordered)

            Spacer()

            Text("Players: \(players.count)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.9))
        }
    }

    private var selectedPlayerPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Player Controls")
                .font(.headline)
                .foregroundStyle(.white)

            if let selectedPlayerID,
               let selectedIndex = players.firstIndex(where: { $0.id == selectedPlayerID }) {
                HStack(spacing: 12) {
                    Stepper("#\(players[selectedIndex].number)", value: $players[selectedIndex].number, in: 1...99)
                        .foregroundStyle(.white)

                    Picker("Team", selection: $players[selectedIndex].team) {
                        ForEach(TeamSide.allCases, id: \.self) { side in
                            Text(side.title).tag(side)
                        }
                    }
                    .pickerStyle(.segmented)

                    Button("Remove") {
                        players.remove(at: selectedIndex)
                        self.selectedPlayerID = nil
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                Text("Tap a player marker to edit number/team. Switch Mode back to Draw when done repositioning.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
            }

            Text("Tactic Notes")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
            TextEditor(text: $tacticNotes)
                .frame(height: 88)
                .padding(6)
                .background(.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 10))
        }
        .padding(10)
        .background(.black.opacity(0.28), in: RoundedRectangle(cornerRadius: 12))
    }
}

enum ToolMode: CaseIterable {
    case ink
    case eraser
    case lasso
    case select

    var title: String {
        switch self {
        case .ink: return "Draw"
        case .eraser: return "Erase"
        case .lasso: return "Lasso"
        case .select: return "Players"
        }
    }
}

enum InkType: CaseIterable {
    case pen
    case pencil
    case marker
    case monoline

    var title: String {
        switch self {
        case .pen: return "Pen"
        case .pencil: return "Pencil"
        case .marker: return "Marker"
        case .monoline: return "Mono"
        }
    }

    var pkInkType: PKInkingTool.InkType {
        switch self {
        case .pen: return .pen
        case .pencil: return .pencil
        case .marker: return .marker
        case .monoline: return .monoline
        }
    }
}

enum TeamSide: CaseIterable {
    case home
    case away

    var title: String {
        switch self {
        case .home: return "Home"
        case .away: return "Away"
        }
    }

    var fillColor: Color {
        switch self {
        case .home: return Color(red: 0.87, green: 0.14, blue: 0.18)
        case .away: return Color(red: 0.09, green: 0.43, blue: 0.91)
        }
    }
}

struct PlayerToken: Identifiable {
    let id: UUID
    var number: Int
    var x: CGFloat
    var y: CGFloat
    var team: TeamSide

    init(id: UUID = UUID(), number: Int, x: CGFloat, y: CGFloat, team: TeamSide) {
        self.id = id
        self.number = number
        self.x = x
        self.y = y
        self.team = team
    }

    static func preset433() -> [PlayerToken] {
        [
            PlayerToken(number: 1, x: 0.5, y: 0.93, team: .home),
            PlayerToken(number: 2, x: 0.18, y: 0.78, team: .home),
            PlayerToken(number: 3, x: 0.38, y: 0.78, team: .home),
            PlayerToken(number: 4, x: 0.62, y: 0.78, team: .home),
            PlayerToken(number: 5, x: 0.82, y: 0.78, team: .home),
            PlayerToken(number: 6, x: 0.28, y: 0.58, team: .home),
            PlayerToken(number: 8, x: 0.5, y: 0.54, team: .home),
            PlayerToken(number: 10, x: 0.72, y: 0.58, team: .home),
            PlayerToken(number: 11, x: 0.2, y: 0.33, team: .home),
            PlayerToken(number: 9, x: 0.5, y: 0.28, team: .home),
            PlayerToken(number: 7, x: 0.8, y: 0.33, team: .home)
        ]
    }

    static func preset442() -> [PlayerToken] {
        [
            PlayerToken(number: 1, x: 0.5, y: 0.93, team: .home),
            PlayerToken(number: 2, x: 0.18, y: 0.78, team: .home),
            PlayerToken(number: 3, x: 0.38, y: 0.78, team: .home),
            PlayerToken(number: 4, x: 0.62, y: 0.78, team: .home),
            PlayerToken(number: 5, x: 0.82, y: 0.78, team: .home),
            PlayerToken(number: 11, x: 0.16, y: 0.55, team: .home),
            PlayerToken(number: 6, x: 0.38, y: 0.55, team: .home),
            PlayerToken(number: 8, x: 0.62, y: 0.55, team: .home),
            PlayerToken(number: 7, x: 0.84, y: 0.55, team: .home),
            PlayerToken(number: 9, x: 0.4, y: 0.3, team: .home),
            PlayerToken(number: 10, x: 0.6, y: 0.3, team: .home)
        ]
    }

    static func preset352() -> [PlayerToken] {
        [
            PlayerToken(number: 1, x: 0.5, y: 0.93, team: .home),
            PlayerToken(number: 3, x: 0.28, y: 0.78, team: .home),
            PlayerToken(number: 4, x: 0.5, y: 0.8, team: .home),
            PlayerToken(number: 5, x: 0.72, y: 0.78, team: .home),
            PlayerToken(number: 2, x: 0.1, y: 0.58, team: .home),
            PlayerToken(number: 6, x: 0.3, y: 0.56, team: .home),
            PlayerToken(number: 8, x: 0.5, y: 0.53, team: .home),
            PlayerToken(number: 10, x: 0.7, y: 0.56, team: .home),
            PlayerToken(number: 7, x: 0.9, y: 0.58, team: .home),
            PlayerToken(number: 11, x: 0.38, y: 0.3, team: .home),
            PlayerToken(number: 9, x: 0.62, y: 0.3, team: .home)
        ]
    }
}

struct PlayerMarkerView: View {
    @Binding var player: PlayerToken
    let isSelected: Bool
    let fieldSize: CGSize

    private let markerSize: CGFloat = 36

    var body: some View {
        ZStack {
            Circle()
                .fill(player.team.fillColor)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: isSelected ? 3 : 1.5)
                )
            Text("\(player.number)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(width: markerSize, height: markerSize)
        .position(x: player.x * fieldSize.width, y: player.y * fieldSize.height)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    player.x = clamp(value.location.x / max(fieldSize.width, 1), min: 0.03, max: 0.97)
                    player.y = clamp(value.location.y / max(fieldSize.height, 1), min: 0.03, max: 0.97)
                }
        )
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 1)
    }
}

struct SoccerFieldView: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.13, green: 0.48, blue: 0.2), Color(red: 0.08, green: 0.37, blue: 0.16)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Subtle mowing stripes for depth.
                ForEach(0..<8, id: \.self) { stripe in
                    Rectangle()
                        .fill((stripe % 2 == 0) ? .white.opacity(0.05) : .clear)
                        .frame(height: height / 8)
                        .position(x: width / 2, y: (height / 8) * (CGFloat(stripe) + 0.5))
                }

                Path { path in
                    let line: CGFloat = 2

                    path.addRoundedRect(in: CGRect(x: line, y: line, width: width - (line * 2), height: height - (line * 2)), cornerSize: CGSize(width: 6, height: 6))
                    path.move(to: CGPoint(x: width / 2, y: 0))
                    path.addLine(to: CGPoint(x: width / 2, y: height))
                    path.addEllipse(in: CGRect(x: width * 0.38, y: height * 0.42, width: width * 0.24, height: height * 0.16))

                    let boxWidth = width * 0.58
                    let boxX = (width - boxWidth) / 2
                    path.addRect(CGRect(x: boxX, y: height * 0.78, width: boxWidth, height: height * 0.22))
                    path.addRect(CGRect(x: width * 0.35, y: height * 0.89, width: width * 0.30, height: height * 0.11))

                    path.addRect(CGRect(x: boxX, y: 0, width: boxWidth, height: height * 0.22))
                    path.addRect(CGRect(x: width * 0.35, y: 0, width: width * 0.30, height: height * 0.11))

                    path.addArc(center: CGPoint(x: width / 2, y: height * 0.78), radius: width * 0.11, startAngle: .degrees(200), endAngle: .degrees(340), clockwise: false)
                    path.addArc(center: CGPoint(x: width / 2, y: height * 0.22), radius: width * 0.11, startAngle: .degrees(20), endAngle: .degrees(160), clockwise: false)
                }
                .stroke(.white.opacity(0.95), lineWidth: 2)

                Circle()
                    .fill(.white)
                    .frame(width: 5, height: 5)
                    .position(x: width / 2, y: height / 2)

                Circle()
                    .fill(.white)
                    .frame(width: 5, height: 5)
                    .position(x: width / 2, y: height * 0.84)

                Circle()
                    .fill(.white)
                    .frame(width: 5, height: 5)
                    .position(x: width / 2, y: height * 0.16)
            }
        }
    }
}

struct PencilCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let tool: PKTool
    let isDrawingEnabled: Bool

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawingPolicy = .anyInput
        canvasView.isScrollEnabled = false
        canvasView.bounces = false
        canvasView.maximumZoomScale = 1
        canvasView.minimumZoomScale = 1
        canvasView.tool = tool
        canvasView.isUserInteractionEnabled = isDrawingEnabled
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = tool
        uiView.isUserInteractionEnabled = isDrawingEnabled
    }
}

private func clamp(_ value: CGFloat, min lower: CGFloat, max upper: CGFloat) -> CGFloat {
    Swift.min(upper, Swift.max(lower, value))
}
