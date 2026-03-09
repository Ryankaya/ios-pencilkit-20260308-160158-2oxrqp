import SwiftUI
import PencilKit

struct PencilCanvasRepresentable: UIViewRepresentable {
    let canvasView: PKCanvasView
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
