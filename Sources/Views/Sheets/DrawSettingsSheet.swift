import SwiftUI

struct DrawSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var drawingMode: DrawingMode
    @Binding var inkStyle: InkStyle
    @Binding var inkColor: Color
    @Binding var strokeWidth: CGFloat
    @Binding var strokeOpacity: Double

    let clearDrawings: () -> Void
    let undoDrawing: () -> Void
    let redoDrawing: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Drawing Tools") {
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

                Section("Canvas Actions") {
                    Button("Undo Drawing") { undoDrawing() }
                    Button("Redo Drawing") { redoDrawing() }
                    Button("Clear Drawings", role: .destructive) { clearDrawings() }
                }
            }
            .navigationTitle("Draw Settings")
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
