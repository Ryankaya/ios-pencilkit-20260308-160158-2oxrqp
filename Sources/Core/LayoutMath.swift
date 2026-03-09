import CoreGraphics

enum FieldLayout {
    static func measuredFieldSize(in container: CGSize) -> CGSize {
        let horizontalPadding: CGFloat = 16
        let verticalPadding: CGFloat = 24
        let maxWidth = max(120, container.width - (horizontalPadding * 2))
        let maxHeight = max(240, container.height - (verticalPadding * 2))

        let widthToLengthRatio = SoccerPitchMetrics.width / SoccerPitchMetrics.length
        let width = min(maxWidth, maxHeight * widthToLengthRatio)
        let height = width / widthToLengthRatio

        return CGSize(width: width, height: height)
    }
}

func clamp(_ value: CGFloat, min lower: CGFloat, max upper: CGFloat) -> CGFloat {
    Swift.min(upper, Swift.max(lower, value))
}
