import SwiftUI

struct SoccerFieldView: View {
    var body: some View {
        // Draw the pitch in one pass so there are no view seams that can look like fake center lines.
        Canvas { context, size in
            let canvasRect = CGRect(origin: .zero, size: size)
            let roundedPath = RoundedRectangle(cornerRadius: 18).path(in: canvasRect)
            context.fill(
                roundedPath,
                with: .linearGradient(
                    Gradient(colors: [Color(red: 0.10, green: 0.47, blue: 0.20), Color(red: 0.06, green: 0.34, blue: 0.15)]),
                    startPoint: CGPoint(x: canvasRect.midX, y: canvasRect.minY),
                    endPoint: CGPoint(x: canvasRect.midX, y: canvasRect.maxY)
                )
            )

            let stripeCount = 12
            let stripeHeight = size.height / CGFloat(stripeCount)
            for stripe in 0..<stripeCount where stripe.isMultiple(of: 2) {
                let stripeRect = CGRect(
                    x: 0,
                    y: CGFloat(stripe) * stripeHeight,
                    width: size.width,
                    height: stripeHeight
                )
                context.fill(Path(stripeRect), with: .color(.white.opacity(0.05)))
            }

            let fieldRect = canvasRect.insetBy(dx: 8, dy: 8)
            let strokeStyle = StrokeStyle(lineWidth: 2)
            let white = GraphicsContext.Shading.color(.white.opacity(0.95))

            context.stroke(Path(fieldRect), with: white, style: strokeStyle)
            context.stroke(SoccerPitchPathBuilder.halfwayLine(in: fieldRect), with: white, style: strokeStyle)
            context.stroke(SoccerPitchPathBuilder.centerCircle(in: fieldRect), with: white, style: strokeStyle)
            context.stroke(SoccerPitchPathBuilder.topPenaltyArea(in: fieldRect), with: white, style: strokeStyle)
            context.stroke(SoccerPitchPathBuilder.bottomPenaltyArea(in: fieldRect), with: white, style: strokeStyle)
            context.stroke(SoccerPitchPathBuilder.topGoalArea(in: fieldRect), with: white, style: strokeStyle)
            context.stroke(SoccerPitchPathBuilder.bottomGoalArea(in: fieldRect), with: white, style: strokeStyle)
            context.stroke(SoccerPitchPathBuilder.topPenaltyArc(in: fieldRect), with: white, style: strokeStyle)
            context.stroke(SoccerPitchPathBuilder.bottomPenaltyArc(in: fieldRect), with: white, style: strokeStyle)
            context.fill(SoccerPitchPathBuilder.spots(in: fieldRect), with: .color(.white))
        }
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
