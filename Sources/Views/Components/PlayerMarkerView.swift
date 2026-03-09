import SwiftUI

struct PlayerMarkerView: View {
    @Binding var player: PlayerToken
    let isSelected: Bool
    let fieldSize: CGSize
    let isEditable: Bool
    let homeColor: Color
    let awayColor: Color
    let onLongPress: () -> Void

    private let markerSize: CGFloat = 36

    var body: some View {
        markerBody
            .frame(width: markerSize, height: markerSize)
            .overlay(alignment: .bottom) {
                if let playerName = displayName {
                    Text(playerName)
                        .font(.system(size: 9, weight: .semibold, design: .rounded))
                        .lineLimit(1)
                        .allowsTightening(true)
                        .minimumScaleFactor(0.6)
                        .fixedSize(horizontal: true, vertical: false)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 1)
                        .background(.black.opacity(0.6), in: Capsule())
                        .offset(y: 20)
                }
            }
            .position(x: player.x * fieldSize.width, y: player.y * fieldSize.height)
            .gesture(dragGesture)
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.45)
                    .onEnded { _ in
                        guard isEditable else { return }
                        onLongPress()
                    }
            )
            .allowsHitTesting(isEditable)
            .shadow(color: .black.opacity(0.28), radius: 2, x: 0, y: 1)
    }

    private var markerBody: some View {
        ZStack {
            Circle()
                .fill(player.team == .home ? homeColor : awayColor)
                .overlay(
                    Circle()
                        .stroke(.white, lineWidth: isSelected ? 3 : 1.6)
                )

            Text("\(player.number)")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                guard isEditable else { return }
                player.x = clamp(value.location.x / max(fieldSize.width, 1), min: 0.04, max: 0.96)
                player.y = clamp(value.location.y / max(fieldSize.height, 1), min: 0.04, max: 0.96)
            }
    }

    private var displayName: String? {
        guard let playerName = player.name?.trimmingCharacters(in: .whitespacesAndNewlines), !playerName.isEmpty else {
            return nil
        }
        return playerName
    }
}
