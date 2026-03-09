import SwiftUI
import PencilKit
import UIKit

struct ContentView: View {
    @State private var canvasView = PKCanvasView()

    @State private var interactionMode: InteractionMode = .draw

    @State private var drawingMode: DrawingMode = .ink
    @State private var inkStyle: InkStyle = .pen
    @State private var inkColor: Color = .yellow
    @State private var strokeWidth: CGFloat = 5
    @State private var strokeOpacity: Double = 0.9
    @State private var homeTeamColor: Color = Color(red: 0.82, green: 0.13, blue: 0.16)
    @State private var awayTeamColor: Color = Color(red: 0.10, green: 0.40, blue: 0.90)

    @State private var homeTeamSize: Int = 11
    @State private var awayTeamSize: Int = 11
    @State private var homeFormation: Formation = .fourThreeThree
    @State private var awayFormation: Formation = .fourThreeThree
    @State private var players: [PlayerToken] = LineupFactory.makePlayers(
        homeSize: 11,
        awaySize: 11,
        homeFormation: .fourThreeThree,
        awayFormation: .fourThreeThree
    )

    @State private var selectedPlayerID: UUID?
    @State private var notes: String = "Kickoff lineup loaded. Draw pressing lines, passing lanes, and defensive shape."
    @State private var isControlSheetPresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 10) {
                    topPanel
                    modePanel

                    GeometryReader { geometry in
                        let fieldSize = measuredFieldSize(in: geometry.size)

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
                                    fieldSize: fieldSize,
                                    isEditable: interactionMode == .players,
                                    homeColor: homeTeamColor,
                                    awayColor: awayTeamColor
                                )
                                .onTapGesture {
                                    guard interactionMode == .players else { return }
                                    selectedPlayerID = player.id
                                }
                            }
                        }
                        .frame(width: fieldSize.width, height: fieldSize.height)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    bottomOverlay
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 12)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isControlSheetPresented) {
                CoachMenuSheet(
                    homeTeamSize: $homeTeamSize,
                    awayTeamSize: $awayTeamSize,
                    homeFormation: $homeFormation,
                    awayFormation: $awayFormation,
                    homeTeamColor: $homeTeamColor,
                    awayTeamColor: $awayTeamColor,
                    drawingMode: $drawingMode,
                    inkStyle: $inkStyle,
                    inkColor: $inkColor,
                    strokeWidth: $strokeWidth,
                    strokeOpacity: $strokeOpacity,
                    notes: $notes,
                    applyKickoffLineup: applyKickoffLineup,
                    flipTeamSides: flipTeamSides,
                    renumberTeams: renumberTeams,
                    clearDrawings: { canvasView.drawing = PKDrawing() },
                    undoDrawing: { canvasView.undoManager?.undo() },
                    redoDrawing: { canvasView.undoManager?.redo() }
                )
            }
            .onChange(of: interactionMode) { _, mode in
                if mode == .draw {
                    selectedPlayerID = nil
                }
            }
        }
    }

    private var activeTool: PKTool {
        switch drawingMode {
        case .ink:
            return PKInkingTool(
                inkStyle.pkInkType,
                color: UIColor(inkColor).withAlphaComponent(strokeOpacity),
                width: strokeWidth
            )
        case .eraser:
            return PKEraserTool(.vector)
        case .lasso:
            return PKLassoTool()
        }
    }

    private var topPanel: some View {
        HStack(spacing: 10) {
            TeamCountPill(
                title: "Home",
                count: players.filter { $0.team == .home }.count,
                color: homeTeamColor
            )

            Spacer()

            Button {
                isControlSheetPresented = true
            } label: {
                Label("Menu", systemImage: "line.3.horizontal.decrease.circle.fill")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            Spacer()

            TeamCountPill(
                title: "Away",
                count: players.filter { $0.team == .away }.count,
                color: awayTeamColor
            )
        }
        .padding(10)
        .background(.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 12))
    }

    private var modePanel: some View {
        VStack(spacing: 10) {
            Picker("Interaction", selection: $interactionMode) {
                ForEach(InteractionMode.allCases, id: \.self) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Text("Initial layout keeps each team in its own half. You can change team colors from Menu.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.82))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(10)
        .background(.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var bottomOverlay: some View {
        if interactionMode == .players, let selectedIndex {
            HStack(spacing: 12) {
                Stepper(
                    "#\(players[selectedIndex].number)",
                    value: $players[selectedIndex].number,
                    in: 1...99
                )
                .foregroundStyle(.white)

                Picker("Team", selection: $players[selectedIndex].team) {
                    ForEach(TeamSide.allCases, id: \.self) { team in
                        Text(team.title).tag(team)
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding(10)
            .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 12))
        } else {
            Text(interactionMode == .draw ?
                 "Draw mode: sketch arrows and zones directly over the soccer pitch." :
                    "Players mode: drag markers and tap one to edit jersey/team.")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.84))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.black.opacity(0.45), in: Capsule())
        }
    }

    private var selectedIndex: Int? {
        guard let selectedPlayerID else { return nil }
        return players.firstIndex { $0.id == selectedPlayerID }
    }

    private func measuredFieldSize(in container: CGSize) -> CGSize {
        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 24
        let maxWidth = max(120, container.width - (horizontalPadding * 2))
        let maxHeight = max(240, container.height - (verticalPadding * 2))

        let widthToLengthRatio = SoccerPitchMetrics.width / SoccerPitchMetrics.length
        let width = min(maxWidth, maxHeight * widthToLengthRatio)
        let height = width / widthToLengthRatio

        return CGSize(width: width, height: height)
    }

    private func applyKickoffLineup() {
        players = LineupFactory.makePlayers(
            homeSize: homeTeamSize,
            awaySize: awayTeamSize,
            homeFormation: homeFormation,
            awayFormation: awayFormation
        )
        selectedPlayerID = nil
    }

    private func flipTeamSides() {
        for index in players.indices {
            players[index].y = 1 - players[index].y
        }
    }

    private func renumberTeams() {
        var homeNumber = 1
        var awayNumber = 1

        for index in players.indices {
            if players[index].team == .home {
                players[index].number = homeNumber
                homeNumber += 1
            } else {
                players[index].number = awayNumber
                awayNumber += 1
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

    var pkInkType: PKInkingTool.InkType {
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
        case .home: return Color(red: 0.82, green: 0.13, blue: 0.16)
        case .away: return Color(red: 0.10, green: 0.40, blue: 0.90)
        }
    }
}

enum Formation: String, CaseIterable, Identifiable {
    case fourThreeThree = "4-3-3"
    case fourFourTwo = "4-4-2"
    case fourTwoThreeOne = "4-2-3-1"

    var id: String { rawValue }
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

struct TeamCountPill: View {
    let title: String
    let count: Int
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 9, height: 9)
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
    let isEditable: Bool
    let homeColor: Color
    let awayColor: Color

    private let markerSize: CGFloat = 36

    var body: some View {
        markerBody
            .frame(width: markerSize, height: markerSize)
            .position(x: player.x * fieldSize.width, y: player.y * fieldSize.height)
            .gesture(dragGesture)
            .allowsHitTesting(isEditable)
            .shadow(color: .black.opacity(0.28), radius: 2, x: 0, y: 1)
    }

    private var markerBody: some View {
        ZStack {
            Circle()
                .fill(player.team == .home ? homeColor : awayColor)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: isSelected ? 3 : 1.6)
                )

            Text("\(player.number)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard isEditable else { return }
                player.x = clamp(value.location.x / max(fieldSize.width, 1), min: 0.04, max: 0.96)
                player.y = clamp(value.location.y / max(fieldSize.height, 1), min: 0.04, max: 0.96)
            }
    }
}

struct SoccerFieldView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [Color(red: 0.10, green: 0.47, blue: 0.20), Color(red: 0.06, green: 0.34, blue: 0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            GeometryReader { geometry in
                let stripeHeight = geometry.size.height / 12

                ForEach(0..<12, id: \.self) { stripe in
                    Rectangle()
                        .fill(stripe.isMultiple(of: 2) ? .white.opacity(0.05) : .clear)
                        .frame(height: stripeHeight)
                        .position(
                            x: geometry.size.width / 2,
                            y: (CGFloat(stripe) + 0.5) * stripeHeight
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 18))

            SoccerFieldLinesShape()
                .stroke(.white.opacity(0.95), lineWidth: 2)
                .padding(8)

            SoccerSpotMarks()
                .fill(.white)
                .padding(8)
        }
    }
}

enum SoccerPitchMetrics {
    static let length: CGFloat = 105
    static let width: CGFloat = 68
    static let penaltyAreaDepth: CGFloat = 16.5
    static let penaltyAreaWidth: CGFloat = 40.32
    static let goalAreaDepth: CGFloat = 5.5
    static let goalAreaWidth: CGFloat = 18.32
    static let centerCircleRadius: CGFloat = 9.15
    static let penaltyMarkDistance: CGFloat = 11
}

struct SoccerFieldLinesShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let fieldRect = rect

        path.addRect(fieldRect)

        let centerRadius = scaleX(SoccerPitchMetrics.centerCircleRadius, in: fieldRect)
        let center = CGPoint(x: x(34, in: fieldRect), y: y(52.5, in: fieldRect))
        path.addEllipse(in: CGRect(
            x: center.x - centerRadius,
            y: center.y - centerRadius,
            width: centerRadius * 2,
            height: centerRadius * 2
        ))

        let penaltyLeftX = (SoccerPitchMetrics.width - SoccerPitchMetrics.penaltyAreaWidth) / 2
        let goalLeftX = (SoccerPitchMetrics.width - SoccerPitchMetrics.goalAreaWidth) / 2

        path.addRect(CGRect(
            x: x(penaltyLeftX, in: fieldRect),
            y: y(0, in: fieldRect),
            width: scaleX(SoccerPitchMetrics.penaltyAreaWidth, in: fieldRect),
            height: scaleY(SoccerPitchMetrics.penaltyAreaDepth, in: fieldRect)
        ))

        path.addRect(CGRect(
            x: x(penaltyLeftX, in: fieldRect),
            y: y(SoccerPitchMetrics.length - SoccerPitchMetrics.penaltyAreaDepth, in: fieldRect),
            width: scaleX(SoccerPitchMetrics.penaltyAreaWidth, in: fieldRect),
            height: scaleY(SoccerPitchMetrics.penaltyAreaDepth, in: fieldRect)
        ))

        path.addRect(CGRect(
            x: x(goalLeftX, in: fieldRect),
            y: y(0, in: fieldRect),
            width: scaleX(SoccerPitchMetrics.goalAreaWidth, in: fieldRect),
            height: scaleY(SoccerPitchMetrics.goalAreaDepth, in: fieldRect)
        ))

        path.addRect(CGRect(
            x: x(goalLeftX, in: fieldRect),
            y: y(SoccerPitchMetrics.length - SoccerPitchMetrics.goalAreaDepth, in: fieldRect),
            width: scaleX(SoccerPitchMetrics.goalAreaWidth, in: fieldRect),
            height: scaleY(SoccerPitchMetrics.goalAreaDepth, in: fieldRect)
        ))

        let topPenaltyCenter = CGPoint(
            x: x(SoccerPitchMetrics.width / 2, in: fieldRect),
            y: y(SoccerPitchMetrics.penaltyMarkDistance, in: fieldRect)
        )
        let bottomPenaltyCenter = CGPoint(
            x: x(SoccerPitchMetrics.width / 2, in: fieldRect),
            y: y(SoccerPitchMetrics.length - SoccerPitchMetrics.penaltyMarkDistance, in: fieldRect)
        )

        let arcRadius = scaleX(SoccerPitchMetrics.centerCircleRadius, in: fieldRect)
        let deltaY = SoccerPitchMetrics.penaltyAreaDepth - SoccerPitchMetrics.penaltyMarkDistance
        let angle = Angle(radians: Double(asin(deltaY / SoccerPitchMetrics.centerCircleRadius)))

        path.addArc(
            center: topPenaltyCenter,
            radius: arcRadius,
            startAngle: angle,
            endAngle: .degrees(180) - angle,
            clockwise: false
        )

        path.addArc(
            center: bottomPenaltyCenter,
            radius: arcRadius,
            startAngle: .degrees(180) + angle,
            endAngle: .degrees(360) - angle,
            clockwise: false
        )

        return path
    }

    private func x(_ meters: CGFloat, in rect: CGRect) -> CGFloat {
        rect.minX + (meters / SoccerPitchMetrics.width) * rect.width
    }

    private func y(_ meters: CGFloat, in rect: CGRect) -> CGFloat {
        rect.minY + (meters / SoccerPitchMetrics.length) * rect.height
    }

    private func scaleX(_ meters: CGFloat, in rect: CGRect) -> CGFloat {
        (meters / SoccerPitchMetrics.width) * rect.width
    }

    private func scaleY(_ meters: CGFloat, in rect: CGRect) -> CGFloat {
        (meters / SoccerPitchMetrics.length) * rect.height
    }
}

struct SoccerSpotMarks: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        addSpot(to: &path, xMeters: SoccerPitchMetrics.width / 2, yMeters: SoccerPitchMetrics.length / 2, in: rect)
        addSpot(to: &path, xMeters: SoccerPitchMetrics.width / 2, yMeters: SoccerPitchMetrics.penaltyMarkDistance, in: rect)
        addSpot(to: &path, xMeters: SoccerPitchMetrics.width / 2, yMeters: SoccerPitchMetrics.length - SoccerPitchMetrics.penaltyMarkDistance, in: rect)

        return path
    }

    private func addSpot(to path: inout Path, xMeters: CGFloat, yMeters: CGFloat, in rect: CGRect) {
        let x = rect.minX + (xMeters / SoccerPitchMetrics.width) * rect.width
        let y = rect.minY + (yMeters / SoccerPitchMetrics.length) * rect.height
        path.addEllipse(in: CGRect(x: x - 2.5, y: y - 2.5, width: 5, height: 5))
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

struct CoachMenuSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var homeTeamSize: Int
    @Binding var awayTeamSize: Int
    @Binding var homeFormation: Formation
    @Binding var awayFormation: Formation
    @Binding var homeTeamColor: Color
    @Binding var awayTeamColor: Color

    @Binding var drawingMode: DrawingMode
    @Binding var inkStyle: InkStyle
    @Binding var inkColor: Color
    @Binding var strokeWidth: CGFloat
    @Binding var strokeOpacity: Double
    @Binding var notes: String

    let applyKickoffLineup: () -> Void
    let flipTeamSides: () -> Void
    let renumberTeams: () -> Void
    let clearDrawings: () -> Void
    let undoDrawing: () -> Void
    let redoDrawing: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Match Setup") {
                    Stepper("Home Players: \(homeTeamSize)", value: $homeTeamSize, in: 5...11)
                    Stepper("Away Players: \(awayTeamSize)", value: $awayTeamSize, in: 5...11)

                    Text("Current setup: \(homeTeamSize)v\(awayTeamSize)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach([11, 9, 8, 7, 5], id: \.self) { size in
                                Button("\(size)v\(size)") {
                                    homeTeamSize = size
                                    awayTeamSize = size
                                    applyKickoffLineup()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }

                    Button("Apply Kickoff Lineup") {
                        applyKickoffLineup()
                    }
                }

                if homeTeamSize == 11 || awayTeamSize == 11 {
                    Section("11v11 Formation Design") {
                        if homeTeamSize == 11 {
                            Picker("Home", selection: $homeFormation) {
                                ForEach(Formation.allCases) { formation in
                                    Text(formation.rawValue).tag(formation)
                                }
                            }
                        }

                        if awayTeamSize == 11 {
                            Picker("Away", selection: $awayFormation) {
                                ForEach(Formation.allCases) { formation in
                                    Text(formation.rawValue).tag(formation)
                                }
                            }
                        }
                    }
                }

                Section("Team Colors") {
                    ColorPicker("Home Color", selection: $homeTeamColor)
                    ColorPicker("Away Color", selection: $awayTeamColor)
                }

                Section("Drawing") {
                    Picker("Mode", selection: $drawingMode) {
                        ForEach(DrawingMode.allCases, id: \.self) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    if drawingMode == .ink {
                        Picker("Ink Style", selection: $inkStyle) {
                            ForEach(InkStyle.allCases, id: \.self) { style in
                                Text(style.title).tag(style)
                            }
                        }

                        ColorPicker("Ink Color", selection: $inkColor)

                        VStack(alignment: .leading) {
                            Text("Stroke Width: \(Int(strokeWidth))")
                            Slider(value: $strokeWidth, in: 1...24, step: 1)
                        }

                        VStack(alignment: .leading) {
                            Text("Opacity: \(Int(strokeOpacity * 100))%")
                            Slider(value: $strokeOpacity, in: 0.2...1, step: 0.05)
                        }
                    }
                }

                Section("Actions") {
                    Button("Undo Drawing") { undoDrawing() }
                    Button("Redo Drawing") { redoDrawing() }
                    Button("Flip Team Sides") { flipTeamSides() }
                    Button("Renumber Both Teams") { renumberTeams() }
                    Button("Clear Drawings", role: .destructive) { clearDrawings() }
                }

                Section("Tactical Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Coach Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

enum LineupFactory {
    static func makePlayers(homeSize: Int, awaySize: Int, homeFormation: Formation, awayFormation: Formation) -> [PlayerToken] {
        let home = makeTeamPlayers(count: homeSize, team: .home, formation: homeFormation)
        let away = makeTeamPlayers(count: awaySize, team: .away, formation: awayFormation)
        return home + away
    }

    private static func makeTeamPlayers(count: Int, team: TeamSide, formation: Formation) -> [PlayerToken] {
        let safeCount = max(5, min(11, count))

        if safeCount == 11 {
            let anchors = anchorsForEleven(formation: formation)
            return anchors.map { anchor in
                PlayerToken(
                    team: team,
                    number: anchor.number,
                    x: anchor.x,
                    y: mappedY(anchor.y, for: team)
                )
            }
        }

        let anchors = anchorsForSmallSided(count: safeCount)
        return anchors.map { anchor in
            PlayerToken(
                team: team,
                number: anchor.number,
                x: anchor.x,
                y: mappedY(anchor.y, for: team)
            )
        }
    }

    private static func mappedY(_ y: CGFloat, for team: TeamSide) -> CGFloat {
        team == .home ? y : 1 - y
    }

    private static func anchorsForEleven(formation: Formation) -> [LineupAnchor] {
        switch formation {
        case .fourThreeThree:
            return [
                LineupAnchor(number: 1, x: 0.50, y: 0.94),
                LineupAnchor(number: 3, x: 0.18, y: 0.82),
                LineupAnchor(number: 5, x: 0.38, y: 0.81),
                LineupAnchor(number: 4, x: 0.62, y: 0.81),
                LineupAnchor(number: 2, x: 0.82, y: 0.82),
                LineupAnchor(number: 6, x: 0.50, y: 0.72),
                LineupAnchor(number: 8, x: 0.35, y: 0.67),
                LineupAnchor(number: 10, x: 0.65, y: 0.67),
                LineupAnchor(number: 11, x: 0.22, y: 0.58),
                LineupAnchor(number: 9, x: 0.50, y: 0.56),
                LineupAnchor(number: 7, x: 0.78, y: 0.58)
            ]

        case .fourFourTwo:
            return [
                LineupAnchor(number: 1, x: 0.50, y: 0.94),
                LineupAnchor(number: 3, x: 0.18, y: 0.82),
                LineupAnchor(number: 5, x: 0.38, y: 0.81),
                LineupAnchor(number: 4, x: 0.62, y: 0.81),
                LineupAnchor(number: 2, x: 0.82, y: 0.82),
                LineupAnchor(number: 11, x: 0.18, y: 0.70),
                LineupAnchor(number: 6, x: 0.38, y: 0.68),
                LineupAnchor(number: 8, x: 0.62, y: 0.68),
                LineupAnchor(number: 7, x: 0.82, y: 0.70),
                LineupAnchor(number: 10, x: 0.40, y: 0.58),
                LineupAnchor(number: 9, x: 0.60, y: 0.58)
            ]

        case .fourTwoThreeOne:
            return [
                LineupAnchor(number: 1, x: 0.50, y: 0.94),
                LineupAnchor(number: 3, x: 0.18, y: 0.82),
                LineupAnchor(number: 5, x: 0.38, y: 0.81),
                LineupAnchor(number: 4, x: 0.62, y: 0.81),
                LineupAnchor(number: 2, x: 0.82, y: 0.82),
                LineupAnchor(number: 6, x: 0.42, y: 0.71),
                LineupAnchor(number: 8, x: 0.58, y: 0.71),
                LineupAnchor(number: 11, x: 0.22, y: 0.63),
                LineupAnchor(number: 10, x: 0.50, y: 0.62),
                LineupAnchor(number: 7, x: 0.78, y: 0.63),
                LineupAnchor(number: 9, x: 0.50, y: 0.56)
            ]
        }
    }

    private static func anchorsForSmallSided(count: Int) -> [LineupAnchor] {
        let lineShapes: [Int]

        switch count {
        case 5: lineShapes = [1, 2, 1]
        case 6: lineShapes = [2, 2, 1]
        case 7: lineShapes = [2, 3, 1]
        case 8: lineShapes = [3, 2, 2]
        case 9: lineShapes = [3, 3, 2]
        case 10: lineShapes = [4, 3, 2]
        default: lineShapes = [4, 3, 3]
        }

        var anchors: [LineupAnchor] = [LineupAnchor(number: 1, x: 0.50, y: 0.94)]
        var numberCursor = 2

        let backY: CGFloat = 0.82
        let frontY: CGFloat = 0.58

        for (lineIndex, countInLine) in lineShapes.enumerated() {
            let progress = lineShapes.count == 1 ? 0 : CGFloat(lineIndex) / CGFloat(lineShapes.count - 1)
            let y = backY - ((backY - frontY) * progress)
            let xPositions = evenlySpacedX(count: countInLine)

            for x in xPositions {
                anchors.append(LineupAnchor(number: numberCursor, x: x, y: y))
                numberCursor += 1
            }
        }

        return Array(anchors.prefix(count))
    }

    private static func evenlySpacedX(count: Int) -> [CGFloat] {
        guard count > 1 else { return [0.5] }

        let minX: CGFloat = 0.18
        let maxX: CGFloat = 0.82
        let step = (maxX - minX) / CGFloat(count - 1)

        return (0..<count).map { index in
            minX + (CGFloat(index) * step)
        }
    }
}

struct LineupAnchor {
    var number: Int
    var x: CGFloat
    var y: CGFloat
}

private func clamp(_ value: CGFloat, min lower: CGFloat, max upper: CGFloat) -> CGFloat {
    Swift.min(upper, Swift.max(lower, value))
}
