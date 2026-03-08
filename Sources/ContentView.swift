import SwiftUI
import PencilKit

struct ContentView: View {
    @State private var canvasView = PKCanvasView()
    @State private var selectedTool: ToolKind = .pen
    @State private var strokeWidth: CGFloat = 6

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Picker("Tool", selection: $selectedTool) {
                    ForEach(ToolKind.allCases, id: \.self) { tool in
                        Text(tool.title).tag(tool)
                    }
                }
                .pickerStyle(.segmented)

                Button("Clear") {
                    canvasView.drawing = PKDrawing()
                }
                .buttonStyle(.borderedProminent)
            }

            HStack {
                Text("Stroke \(Int(strokeWidth))")
                Slider(value: $strokeWidth, in: 1...20, step: 1)
            }

            PencilCanvasRepresentable(canvasView: $canvasView, tool: selectedTool.makeTool(width: strokeWidth))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.secondary.opacity(0.4), lineWidth: 1)
                )
                .padding(.bottom, 8)
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
    }
}

enum ToolKind: CaseIterable {
    case pen
    case pencil
    case marker

    var title: String {
        switch self {
        case .pen: return "Pen"
        case .pencil: return "Pencil"
        case .marker: return "Marker"
        }
    }

    func makeTool(width: CGFloat) -> PKTool {
        switch self {
        case .pen:
            return PKInkingTool(.pen, color: .systemBlue, width: width)
        case .pencil:
            return PKInkingTool(.pencil, color: .label, width: width)
        case .marker:
            return PKInkingTool(.marker, color: .systemOrange, width: width)
        }
    }
}

struct PencilCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    let tool: PKTool

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.backgroundColor = .secondarySystemBackground
        canvasView.drawingPolicy = .anyInput
        canvasView.alwaysBounceVertical = false
        canvasView.isOpaque = true
        canvasView.tool = tool
        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.tool = tool
    }
}
