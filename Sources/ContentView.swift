import SwiftUI
import PencilKit
import UIKit

struct ContentView: View {
    @State private var canvasView = PKCanvasView()

    @State private var interactionMode: InteractionMode = .draw
    @State private var drawingMode: DrawingMode = .ink
    @State private var inkStyle: InkStyle = .pen
    @State private var inkColor: Color = .red
    @State private var strokeWidth: CGFloat = 6
    @State private var strokeOpacity: Double = 0.9

    @State private var homeTeamSize: Int = 11
    @State private var awayTeamSize: Int = 11
    @State private var players: [PlayerToken] = FormationBuilder.generate(homeCount: 11, awayCount: 11)
    @State private var selectedPlayerID: UUID?

    @State private var notes: String = "Drag players in Players mode. Draw arrows, zones, and movement patterns in Draw mode."

    @State private var isTeamSheetPresented = false
    @State private var isDrawSheetPresented = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                topControls

                GeometryReader { geometry in
                    ZStack {
                        SoccerFieldView()

                        PencilCanvasRepresentable(
                            canvasView: $canvasView,
                            tool: activeTool,
                            isDrawingEnabled: interactionMode == .draw
                        )

                        ForEach($players) { $player in
                            PlayerMarkerView(
                                player: $player,
                                isSelected: selectedPlayerID == player.id,
                                fieldSize: geometry.size
                            )
                            .allowsHitTesting(interactionMode == .players)
                            .onTapGesture {
                                if interactionMode == .players {
                                    selectedPlayerID = player.id
                                }
                            }
                        }

                        matchInfoOverlay
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.18), lineWidth: 1)
                    )
                }
                .frame(minHeight: 420)

                if interactionMode == .players {
                    selectedPlayerEditor
                }

                notesPanel
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color(red: 0.04, green: 0.08, blue: 0.06), Color(red: 0.02, green: 0.05, blue: 0.04)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationTitle("Soccer Game Planner")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isTeamSheetPresented) {
                TeamSetupSheet(
                    homeTeamSize: $homeTeamSize,
                    awayTeamSize: $awayTeamSize,
                    applyTeamSize: applyTeamSize,
                    usePreset: usePreset,
                    flipSides: flipSides,
                    renumberTeams: renumberTeams
                )
            }
            .sheet(isPresented: $isDrawSheetPresented) {
                DrawingToolsSheet(
                    drawingMode: $drawingMode,
                    inkStyle: $inkStyle,
                    inkColor: $inkColor,
                    strokeWidth: $strokeWidth,
                    strokeOpacity: $strokeOpacity,
                    undo: { canvasView.undoManager?.undo() },
                    redo: { canvasView.undoManager?.redo() },
                    clearDrawing: { canvasView.drawing = PKDrawing() }
                )
            }
            .onChange(of: interactionMode) { _, newValue in
                if newValue == .draw {
                    selectedPlayerID = nil
                }
            }
        }
    }

    private var activeTool: PKTool {
        switch drawingMode {
        case .ink:
            return PKInkingTool(
                inkStyle.pkType,
                color: UIColor(inkColor).withAlphaComponent(strokeOpacity),
                width: strokeWidth
            )
        case .eraser:
            return PKEraserTool(.vector)
        case .lasso:
            return PKLassoTool()
        }
    }

    private var topControls: some View {
        VStack(spacing: 10) {
            HStack {
                Picker("Mode", selection: $interactionMode) {
                    ForEach(InteractionMode.allCases, id: \.self) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.segmented)

                Button {
                    isTeamSheetPresented = true
                } label: {
                    Label("Teams", systemImage: "person.3.sequence.fill")
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

                if interactionMode == .draw {
                    Button {
                        isDrawSheetPresented = true
                    } label: {
                        Label("Tools", systemImage: "slider.horizontal.3")
                    }
                    .buttonStyle(.bordered)
                }
            }

            if interactionMode == .players {
                Text("Players mode: drag markers, tap one to edit number/team.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Text("Draw mode: sketch movement and areas directly on the pitch.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(10)
        .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 12))
    }

    private var matchInfoOverlay: some View {
        VStack {
            HStack {
                TeamBadge(title: "Home", color: TeamSide.home.color, count: players.filter { $0.team == .home }.count)
                Spacer()
                TeamBadge(title: "Away", color: TeamSide.away.color, count: players.filter { $0.team == .away }.count)
            }
            Spacer()
        }
        .padding(10)
        .allowsHitTesting(false)
    }

    private var selectedPlayerEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Selected Player")
                .font(.headline)
                .foregroundStyle(.white)

            if let index = selectedPlayerIndex {
                HStack(spacing: 12) {
                    Stepper("Number: \(players[index].number)", value: $players[index].number, in: 1...99)
                        .foregroundStyle(.white)

                    Picker("Team", selection: $players[index].team) {
                        ForEach(TeamSide.allCases, id: \.self) { team in
                            Text(team.title).tag(team)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            } else {
                Text("Tap a player marker to edit it.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.82))
            }
        }
        .padding(10)
        .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 12))
    }

    private var notesPanel: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Plan Notes")
                .font(.headline)
                .foregroundStyle(.white)

            TextEditor(text: $notes)
                .frame(height: 88)
                .padding(6)
                .background(.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 10))
        }
        .padding(10)
        .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 12))
    }

    private var selectedPlayerIndex: Int? {
        guard let selectedPlayerID else { return nil }
        return players.firstIndex(where: { $0.id == selectedPlayerID })
    }

    private func applyTeamSize() {
        players = FormationBuilder.generate(homeCount: homeTeamSize, awayCount: awayTeamSize)
        selectedPlayerID = nil
    }

    private func usePreset(size: Int) {
        homeTeamSize = size
        awayTeamSize = size
        applyTeamSize()
    }

    private func flipSides() {
        for index in players.indices {
            players[index].y = 1 - players[index].y
        }
    }

    private func renumberTeams() {
        var homeCounter = 1
        var awayCounter = 1

        for index in players.indices {
            if players[index].team == .home {
                players[index].number = homeCounter
                homeCounter += 1
            } else {
                players[index].number = awayCounter
                awayCounter += 1
            }
        }
    }
}

enum InteractionMode: CaseIterable {
    case draw
    case players

    var title: String {
        switch self {
        case .draw: return "Draw"
        case .players: return "Players"
        }
    }
}

enum DrawingMode: CaseIterable {
    case ink
    case eraser
    case lasso

    var title: String {
        switch self {
        case .ink: return "Ink"
        case .eraser: return "Eraser"
        case .lasso: return "Lasso"
        }
    }
}

enum InkStyle: CaseIterable {
    case pen
    case marker
    case pencil
    case monoline

    var title: String {
        switch self {
        case .pen: return "Pen"
        case .marker: return "Marker"
        case .pencil: return "Pencil"
        case .monoline: return "Mono"
        }
    }

    var pkType: PKInkingTool.InkType {
        switch self {
        case .pen: return .pen
        case .marker: return .marker
        case .pencil: return .pencil
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

    var color: Color {
        switch self {
        case .home: return Color(red: 0.84, green: 0.13, blue: 0.16)
        case .away: return Color(red: 0.07, green: 0.44, blue: 0.91)
        }
    }
}

struct PlayerToken: Identifiable {
    let id: UUID
    var team: TeamSide
    var number: Int
    var x: CGFloat
    var y: CGFloat

    init(id: UUID = UUID(), team: TeamSide, number: Int, x: CGFloat, y: CGFloat) {
        self.id = id
        self.team = team
        self.number = number
        self.x = x
        self.y = y
    }
}

enum FormationBuilder {
    static func generate(homeCount: Int, awayCount: Int) -> [PlayerToken] {
        let safeHome = max(5, min(11, homeCount))
        let safeAway = max(5, min(11, awayCount))
        return buildTeam(count: safeHome, team: .home) + buildTeam(count: safeAway, team: .away)
    }

    private static func buildTeam(count: Int, team: TeamSide) -> [PlayerToken] {
        guard count > 0 else { return [] }

        var teamPlayers: [PlayerToken] = []
        teamPlayers.reserveCapacity(count)

        let goalkeeperY: CGFloat = 0.92
        teamPlayers.append(PlayerToken(team: team, number: 1, x: 0.5, y: goalkeeperY))

        let outfieldCount = max(0, count - 1)
        guard outfieldCount > 0 else { return mirroredIfNeeded(teamPlayers, for: team) }

        let lines = lineDistribution(forOutfieldCount: outfieldCount)
        let defensiveY: CGFloat = 0.78
        let attackingY: CGFloat = 0.30

        for (lineIndex, playersInLine) in lines.enumerated() {
            let y: CGFloat
            if lines.count == 1 {
                y = 0.56
            } else {
                let progress = CGFloat(lineIndex) / CGFloat(lines.count - 1)
                y = defensiveY - (progress * (defensiveY - attackingY))
            }

            let xPositions = evenlySpacedPositions(count: playersInLine)
            for x in xPositions {
                let jerseyNumber = teamPlayers.count + 1
                teamPlayers.append(PlayerToken(team: team, number: jerseyNumber, x: x, y: y))
            }
        }

        return mirroredIfNeeded(teamPlayers, for: team)
    }

    private static func mirroredIfNeeded(_ players: [PlayerToken], for team: TeamSide) -> [PlayerToken] {
        guard team == .away else { return players }
        return players.map { player in
            PlayerToken(
                id: player.id,
                team: player.team,
                number: player.number,
                x: player.x,
                y: 1 - player.y
            )
        }
    }

    private static func lineDistribution(forOutfieldCount outfieldCount: Int) -> [Int] {
        switch outfieldCount {
        case 0: return []
        case 1: return [1]
        case 2: return [2]
        case 3: return [2, 1]
        case 4: return [2, 2]
        case 5: return [2, 2, 1]
        case 6: return [3, 2, 1]
        case 7: return [3, 2, 2]
        case 8: return [3, 3, 2]
        case 9: return [4, 3, 2]
        default: return [4, 3, 3]
        }
    }

    private static func evenlySpacedPositions(count: Int) -> [CGFloat] {
        guard count > 1 else { return [0.5] }

        let minX: CGFloat = 0.14
        let maxX: CGFloat = 0.86
        let spacing = (maxX - minX) / CGFloat(count - 1)

        return (0..<count).map { index in
            minX + (CGFloat(index) * spacing)
        }
    }
}

struct TeamBadge: View {
    let title: String
    let color: Color
    let count: Int

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text("\(title): \(count)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.black.opacity(0.45), in: Capsule())
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
                .fill(player.team.color)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: isSelected ? 3 : 1.4)
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
        .shadow(color: .black.opacity(0.24), radius: 2, x: 0, y: 1)
    }
}

struct SoccerFieldView: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.12, green: 0.51, blue: 0.22), Color(red: 0.07, green: 0.36, blue: 0.16)],
                    startPoint: .top,
                    endPoint: .bottom
                )

                ForEach(0..<10, id: \.self) { stripe in
                    Rectangle()
                        .fill(stripe.isMultiple(of: 2) ? .white.opacity(0.05) : .clear)
                        .frame(height: height / 10)
                        .position(x: width / 2, y: (height / 10) * (CGFloat(stripe) + 0.5))
                }

                SoccerFieldLines()
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

struct SoccerFieldLines: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let inset: CGFloat = 3
        let field = rect.insetBy(dx: inset, dy: inset)

        path.addRect(field)

        path.move(to: CGPoint(x: field.midX, y: field.minY))
        path.addLine(to: CGPoint(x: field.midX, y: field.maxY))

        let centerCircleRadius = field.width * 0.14
        path.addEllipse(
            in: CGRect(
                x: field.midX - centerCircleRadius,
                y: field.midY - centerCircleRadius,
                width: centerCircleRadius * 2,
                height: centerCircleRadius * 2
            )
        )

        let penaltyWidth = field.width * 0.58
        let penaltyHeight = field.height * 0.18
        let penaltyX = field.midX - (penaltyWidth / 2)

        path.addRect(CGRect(x: penaltyX, y: field.maxY - penaltyHeight, width: penaltyWidth, height: penaltyHeight))
        path.addRect(CGRect(x: penaltyX, y: field.minY, width: penaltyWidth, height: penaltyHeight))

        let goalBoxWidth = field.width * 0.30
        let goalBoxHeight = field.height * 0.08
        let goalBoxX = field.midX - (goalBoxWidth / 2)

        path.addRect(CGRect(x: goalBoxX, y: field.maxY - goalBoxHeight, width: goalBoxWidth, height: goalBoxHeight))
        path.addRect(CGRect(x: goalBoxX, y: field.minY, width: goalBoxWidth, height: goalBoxHeight))

        let arcRadius = field.width * 0.12
        path.addArc(
            center: CGPoint(x: field.midX, y: field.maxY - penaltyHeight),
            radius: arcRadius,
            startAngle: .degrees(200),
            endAngle: .degrees(340),
            clockwise: false
        )

        path.addArc(
            center: CGPoint(x: field.midX, y: field.minY + penaltyHeight),
            radius: arcRadius,
            startAngle: .degrees(20),
            endAngle: .degrees(160),
            clockwise: false
        )

        return path
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

struct TeamSetupSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var homeTeamSize: Int
    @Binding var awayTeamSize: Int

    let applyTeamSize: () -> Void
    let usePreset: (Int) -> Void
    let flipSides: () -> Void
    let renumberTeams: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Team Size") {
                    Stepper("Home Players: \(homeTeamSize)", value: $homeTeamSize, in: 5...11)
                    Stepper("Away Players: \(awayTeamSize)", value: $awayTeamSize, in: 5...11)
                    Text("Current Match: \(homeTeamSize) v \(awayTeamSize)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Apply Team Size") {
                        applyTeamSize()
                    }
                }

                Section("Quick Presets") {
                    HStack {
                        ForEach([11, 9, 8, 7, 5], id: \.self) { size in
                            Button("\(size)v\(size)") {
                                usePreset(size)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }

                Section("Actions") {
                    Button("Flip Team Sides") {
                        flipSides()
                    }

                    Button("Renumber Both Teams") {
                        renumberTeams()
                    }
                }
            }
            .navigationTitle("Teams")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

struct DrawingToolsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var drawingMode: DrawingMode
    @Binding var inkStyle: InkStyle
    @Binding var inkColor: Color
    @Binding var strokeWidth: CGFloat
    @Binding var strokeOpacity: Double

    let undo: () -> Void
    let redo: () -> Void
    let clearDrawing: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Drawing Mode") {
                    Picker("Mode", selection: $drawingMode) {
                        ForEach(DrawingMode.allCases, id: \.self) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if drawingMode == .ink {
                    Section("Ink") {
                        Picker("Type", selection: $inkStyle) {
                            ForEach(InkStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }

                        ColorPicker("Color", selection: $inkColor)

                        VStack(alignment: .leading) {
                            Text("Width: \(Int(strokeWidth))")
                            Slider(value: $strokeWidth, in: 1...24, step: 1)
                        }

                        VStack(alignment: .leading) {
                            Text("Opacity: \(Int(strokeOpacity * 100))%")
                            Slider(value: $strokeOpacity, in: 0.2...1, step: 0.05)
                        }
                    }
                }

                Section("Actions") {
                    Button("Undo") { undo() }
                    Button("Redo") { redo() }
                    Button("Clear All Drawings", role: .destructive) { clearDrawing() }
                }
            }
            .navigationTitle("Drawing Tools")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

private func clamp(_ value: CGFloat, min lower: CGFloat, max upper: CGFloat) -> CGFloat {
    Swift.min(upper, Swift.max(lower, value))
}
