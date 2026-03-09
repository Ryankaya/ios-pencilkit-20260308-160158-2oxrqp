import CoreGraphics

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
