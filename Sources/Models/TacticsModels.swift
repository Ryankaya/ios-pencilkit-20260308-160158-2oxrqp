import SwiftUI
import PencilKit

enum InteractionMode: CaseIterable {
    case draw
    case players

    var title: String {
        switch self {
        case .draw: return "Draw"
        case .players: return "Players"
        }
    }

    var systemImage: String {
        switch self {
        case .draw: return "pencil.tip"
        case .players: return "person.2.fill"
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

    var systemImage: String {
        switch self {
        case .ink: return "pencil.line"
        case .eraser: return "eraser"
        case .lasso: return "lasso"
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
    var name: String?

    init(id: UUID = UUID(), team: TeamSide, number: Int, x: CGFloat, y: CGFloat, name: String? = nil) {
        self.id = id
        self.team = team
        self.number = number
        self.x = x
        self.y = y
        self.name = name
    }
}

struct LineupAnchor {
    var number: Int
    var x: CGFloat
    var y: CGFloat
}
