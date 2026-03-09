import SwiftUI

struct IconControlButton: View {
    let systemName: String
    let accessibilityLabel: String
    var tint: Color = .white
    var isActive: Bool = false
    var role: ButtonRole? = nil
    let action: () -> Void

    var body: some View {
        Group {
            if let role {
                Button(role: role, action: action) {
                    buttonBody
                }
            } else {
                Button(action: action) {
                    buttonBody
                }
            }
        }
        .accessibilityLabel(accessibilityLabel)
    }

    private var buttonBody: some View {
        Image(systemName: systemName)
            .font(.system(size: 17, weight: .semibold))
            .symbolRenderingMode(.hierarchical)
            .frame(width: 42, height: 42)
            .foregroundStyle(isActive ? Color.black.opacity(0.85) : tint.opacity(0.95))
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isActive ? tint : Color.white.opacity(0.13))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
    }
}
