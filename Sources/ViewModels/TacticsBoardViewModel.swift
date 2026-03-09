import SwiftUI
import PencilKit
import UIKit

@MainActor
final class TacticsBoardViewModel: ObservableObject {
    let canvasView = PKCanvasView()

    @Published var interactionMode: InteractionMode = .draw {
        didSet {
            guard interactionMode == .draw else { return }
            selectedPlayerID = nil
            isNameEditorPresented = false
            namingPlayerID = nil
        }
    }

    @Published var drawingMode: DrawingMode = .ink
    @Published var inkStyle: InkStyle = .pen
    @Published var inkColor: Color = .yellow
    @Published var strokeWidth: CGFloat = 5
    @Published var strokeOpacity: Double = 0.9
    @Published var homeTeamColor: Color = Color(red: 0.82, green: 0.13, blue: 0.16)
    @Published var awayTeamColor: Color = Color(red: 0.10, green: 0.40, blue: 0.90)

    @Published var homeTeamSize: Int = 11
    @Published var awayTeamSize: Int = 11
    @Published var homeFormation: Formation = .fourThreeThree
    @Published var awayFormation: Formation = .fourThreeThree
    @Published var players: [PlayerToken] = LineupFactory.makePlayers(
        homeSize: 11,
        awaySize: 11,
        homeFormation: .fourThreeThree,
        awayFormation: .fourThreeThree
    )

    @Published var selectedPlayerID: UUID?
    @Published var notes: String = "Kickoff lineup loaded. Draw pressing lines, passing lanes, and defensive shape."
    @Published var isDrawSettingsPresented = false
    @Published var isPlayerSettingsPresented = false
    @Published var isNameEditorPresented = false
    @Published var playerNameDraft: String = ""

    private var namingPlayerID: UUID?
    private var didInitializeScreen = false

    var activeTool: PKTool {
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

    var homePlayerCount: Int {
        players.filter { $0.team == .home }.count
    }

    var awayPlayerCount: Int {
        players.filter { $0.team == .away }.count
    }

    var selectedIndex: Int? {
        guard let selectedPlayerID else { return nil }
        return players.firstIndex { $0.id == selectedPlayerID }
    }

    func initializeIfNeeded() {
        guard !didInitializeScreen else { return }
        didInitializeScreen = true
        clearDrawing()
        applyKickoffLineup()
    }

    func selectPlayer(_ id: UUID) {
        selectedPlayerID = id
    }

    func beginNamingPlayer(id: UUID, currentName: String?) {
        selectedPlayerID = id
        namingPlayerID = id
        playerNameDraft = currentName ?? ""
        isNameEditorPresented = true
    }

    func cancelNameEditing() {
        namingPlayerID = nil
    }

    func savePlayerName() {
        guard let index = namingPlayerIndex else { return }
        let trimmed = playerNameDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        players[index].name = trimmed.isEmpty ? nil : trimmed
        namingPlayerID = nil
    }

    func clearPlayerName() {
        guard let index = namingPlayerIndex else { return }
        players[index].name = nil
        playerNameDraft = ""
        namingPlayerID = nil
    }

    func applyKickoffLineup() {
        let existingNames = players.reduce(into: [String: String]()) { nameMap, player in
            guard let trimmedName = player.name?.trimmingCharacters(in: .whitespacesAndNewlines), !trimmedName.isEmpty else {
                return
            }
            let key = playerNameKey(team: player.team, number: player.number)
            if nameMap[key] == nil {
                nameMap[key] = trimmedName
            }
        }

        var updatedPlayers = LineupFactory.makePlayers(
            homeSize: homeTeamSize,
            awaySize: awayTeamSize,
            homeFormation: homeFormation,
            awayFormation: awayFormation
        )

        for index in updatedPlayers.indices {
            let key = playerNameKey(team: updatedPlayers[index].team, number: updatedPlayers[index].number)
            updatedPlayers[index].name = existingNames[key]
        }

        players = updatedPlayers
        selectedPlayerID = nil
        namingPlayerID = nil
        playerNameDraft = ""
        isNameEditorPresented = false
    }

    func flipTeamSides() {
        for index in players.indices {
            players[index].y = 1 - players[index].y
        }
    }

    func renumberTeams() {
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

    func decreasePlayerNumber(at index: Int) {
        guard players.indices.contains(index) else { return }
        players[index].number = max(1, players[index].number - 1)
    }

    func increasePlayerNumber(at index: Int) {
        guard players.indices.contains(index) else { return }
        players[index].number = min(99, players[index].number + 1)
    }

    func setPlayerTeam(at index: Int, team: TeamSide) {
        guard players.indices.contains(index) else { return }
        players[index].team = team
    }

    func clearDrawing() {
        canvasView.drawing = PKDrawing()
    }

    func undoDrawing() {
        canvasView.undoManager?.undo()
    }

    func redoDrawing() {
        canvasView.undoManager?.redo()
    }

    private var namingPlayerIndex: Int? {
        guard let namingPlayerID else { return nil }
        return players.firstIndex { $0.id == namingPlayerID }
    }

    private func playerNameKey(team: TeamSide, number: Int) -> String {
        "\(team == .home ? "H" : "A")-\(number)"
    }
}
