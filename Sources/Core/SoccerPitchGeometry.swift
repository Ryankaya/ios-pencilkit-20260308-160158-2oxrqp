import SwiftUI

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

enum SoccerPitchPathBuilder {
    static func halfwayLine(in rect: CGRect) -> Path {
        var path = Path()
        let halfwayY = y(52.5, in: rect)
        path.move(to: CGPoint(x: rect.minX, y: halfwayY))
        path.addLine(to: CGPoint(x: rect.maxX, y: halfwayY))
        return path
    }

    static func centerCircle(in rect: CGRect) -> Path {
        var path = Path()
        let centerRadius = scaleX(SoccerPitchMetrics.centerCircleRadius, in: rect)
        let center = CGPoint(x: x(34, in: rect), y: y(52.5, in: rect))
        path.addEllipse(in: CGRect(
            x: center.x - centerRadius,
            y: center.y - centerRadius,
            width: centerRadius * 2,
            height: centerRadius * 2
        ))
        return path
    }

    static func topPenaltyArea(in rect: CGRect) -> Path {
        var path = Path()
        let penaltyLeftX = (SoccerPitchMetrics.width - SoccerPitchMetrics.penaltyAreaWidth) / 2
        path.addRect(CGRect(
            x: x(penaltyLeftX, in: rect),
            y: y(0, in: rect),
            width: scaleX(SoccerPitchMetrics.penaltyAreaWidth, in: rect),
            height: scaleY(SoccerPitchMetrics.penaltyAreaDepth, in: rect)
        ))
        return path
    }

    static func bottomPenaltyArea(in rect: CGRect) -> Path {
        var path = Path()
        let penaltyLeftX = (SoccerPitchMetrics.width - SoccerPitchMetrics.penaltyAreaWidth) / 2
        path.addRect(CGRect(
            x: x(penaltyLeftX, in: rect),
            y: y(SoccerPitchMetrics.length - SoccerPitchMetrics.penaltyAreaDepth, in: rect),
            width: scaleX(SoccerPitchMetrics.penaltyAreaWidth, in: rect),
            height: scaleY(SoccerPitchMetrics.penaltyAreaDepth, in: rect)
        ))
        return path
    }

    static func topGoalArea(in rect: CGRect) -> Path {
        var path = Path()
        let goalLeftX = (SoccerPitchMetrics.width - SoccerPitchMetrics.goalAreaWidth) / 2
        path.addRect(CGRect(
            x: x(goalLeftX, in: rect),
            y: y(0, in: rect),
            width: scaleX(SoccerPitchMetrics.goalAreaWidth, in: rect),
            height: scaleY(SoccerPitchMetrics.goalAreaDepth, in: rect)
        ))
        return path
    }

    static func bottomGoalArea(in rect: CGRect) -> Path {
        var path = Path()
        let goalLeftX = (SoccerPitchMetrics.width - SoccerPitchMetrics.goalAreaWidth) / 2
        path.addRect(CGRect(
            x: x(goalLeftX, in: rect),
            y: y(SoccerPitchMetrics.length - SoccerPitchMetrics.goalAreaDepth, in: rect),
            width: scaleX(SoccerPitchMetrics.goalAreaWidth, in: rect),
            height: scaleY(SoccerPitchMetrics.goalAreaDepth, in: rect)
        ))
        return path
    }

    static func topPenaltyArc(in rect: CGRect) -> Path {
        var path = Path()
        let topPenaltyCenter = CGPoint(
            x: x(SoccerPitchMetrics.width / 2, in: rect),
            y: y(SoccerPitchMetrics.penaltyMarkDistance, in: rect)
        )

        let arcRadius = scaleX(SoccerPitchMetrics.centerCircleRadius, in: rect)
        let deltaY = SoccerPitchMetrics.penaltyAreaDepth - SoccerPitchMetrics.penaltyMarkDistance
        let angle = Angle(radians: Double(asin(deltaY / SoccerPitchMetrics.centerCircleRadius)))

        path.addArc(
            center: topPenaltyCenter,
            radius: arcRadius,
            startAngle: angle,
            endAngle: .degrees(180) - angle,
            clockwise: false
        )
        return path
    }

    static func bottomPenaltyArc(in rect: CGRect) -> Path {
        var path = Path()
        let bottomPenaltyCenter = CGPoint(
            x: x(SoccerPitchMetrics.width / 2, in: rect),
            y: y(SoccerPitchMetrics.length - SoccerPitchMetrics.penaltyMarkDistance, in: rect)
        )
        let arcRadius = scaleX(SoccerPitchMetrics.centerCircleRadius, in: rect)
        let deltaY = SoccerPitchMetrics.penaltyAreaDepth - SoccerPitchMetrics.penaltyMarkDistance
        let angle = Angle(radians: Double(asin(deltaY / SoccerPitchMetrics.centerCircleRadius)))
        path.addArc(
            center: bottomPenaltyCenter,
            radius: arcRadius,
            startAngle: .degrees(180) + angle,
            endAngle: .degrees(360) - angle,
            clockwise: false
        )
        return path
    }

    static func spots(in rect: CGRect) -> Path {
        var path = Path()

        addSpot(to: &path, xMeters: SoccerPitchMetrics.width / 2, yMeters: SoccerPitchMetrics.length / 2, in: rect)
        addSpot(to: &path, xMeters: SoccerPitchMetrics.width / 2, yMeters: SoccerPitchMetrics.penaltyMarkDistance, in: rect)
        addSpot(to: &path, xMeters: SoccerPitchMetrics.width / 2, yMeters: SoccerPitchMetrics.length - SoccerPitchMetrics.penaltyMarkDistance, in: rect)

        return path
    }

    private static func addSpot(to path: inout Path, xMeters: CGFloat, yMeters: CGFloat, in rect: CGRect) {
        let x = rect.minX + (xMeters / SoccerPitchMetrics.width) * rect.width
        let y = rect.minY + (yMeters / SoccerPitchMetrics.length) * rect.height
        path.addEllipse(in: CGRect(x: x - 2.5, y: y - 2.5, width: 5, height: 5))
    }

    private static func x(_ meters: CGFloat, in rect: CGRect) -> CGFloat {
        rect.minX + (meters / SoccerPitchMetrics.width) * rect.width
    }

    private static func y(_ meters: CGFloat, in rect: CGRect) -> CGFloat {
        rect.minY + (meters / SoccerPitchMetrics.length) * rect.height
    }

    private static func scaleX(_ meters: CGFloat, in rect: CGRect) -> CGFloat {
        (meters / SoccerPitchMetrics.width) * rect.width
    }

    private static func scaleY(_ meters: CGFloat, in rect: CGRect) -> CGFloat {
        (meters / SoccerPitchMetrics.length) * rect.height
    }
}
