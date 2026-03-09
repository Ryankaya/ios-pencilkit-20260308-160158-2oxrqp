import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TacticsBoardViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 10) {
                    topPanel

                    GeometryReader { geometry in
                        let fieldSize = FieldLayout.measuredFieldSize(in: geometry.size)

                        ZStack {
                            SoccerFieldView()

                            PencilCanvasRepresentable(
                                canvasView: viewModel.canvasView,
                                tool: viewModel.activeTool,
                                isDrawingEnabled: viewModel.interactionMode == .draw
                            )

                            ForEach($viewModel.players) { $player in
                                PlayerMarkerView(
                                    player: $player,
                                    isSelected: viewModel.selectedPlayerID == player.id,
                                    fieldSize: fieldSize,
                                    isEditable: viewModel.interactionMode == .players,
                                    homeColor: viewModel.homeTeamColor,
                                    awayColor: viewModel.awayTeamColor,
                                    onLongPress: {
                                        guard viewModel.interactionMode == .players else { return }
                                        viewModel.beginNamingPlayer(id: player.id, currentName: player.name)
                                    }
                                )
                                .onTapGesture {
                                    guard viewModel.interactionMode == .players else { return }
                                    viewModel.selectPlayer(player.id)
                                }
                            }
                        }
                        .frame(width: fieldSize.width, height: fieldSize.height)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .shadow(color: .black.opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    bottomOverlay
                }
                .padding(.horizontal, 12)
                .padding(.top, 10)
                .padding(.bottom, 12)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $viewModel.isDrawSettingsPresented) {
                DrawSettingsSheet(
                    drawingMode: $viewModel.drawingMode,
                    inkStyle: $viewModel.inkStyle,
                    inkColor: $viewModel.inkColor,
                    strokeWidth: $viewModel.strokeWidth,
                    strokeOpacity: $viewModel.strokeOpacity,
                    clearDrawings: viewModel.clearDrawing,
                    undoDrawing: viewModel.undoDrawing,
                    redoDrawing: viewModel.redoDrawing
                )
            }
            .sheet(isPresented: $viewModel.isPlayerSettingsPresented) {
                PlayerSettingsSheet(
                    homeTeamSize: $viewModel.homeTeamSize,
                    awayTeamSize: $viewModel.awayTeamSize,
                    homeFormation: $viewModel.homeFormation,
                    awayFormation: $viewModel.awayFormation,
                    homeTeamColor: $viewModel.homeTeamColor,
                    awayTeamColor: $viewModel.awayTeamColor,
                    notes: $viewModel.notes,
                    applyKickoffLineup: viewModel.applyKickoffLineup,
                    flipTeamSides: viewModel.flipTeamSides,
                    renumberTeams: viewModel.renumberTeams
                )
            }
            .alert("Player Name", isPresented: $viewModel.isNameEditorPresented) {
                TextField("Name", text: $viewModel.playerNameDraft)
                Button("Save") {
                    viewModel.savePlayerName()
                }
                Button("Clear", role: .destructive) {
                    viewModel.clearPlayerName()
                }
                Button("Cancel", role: .cancel) {
                    viewModel.cancelNameEditing()
                }
            } message: {
                Text("Long press a player to show a name below the marker.")
            }
            .onAppear {
                viewModel.initializeIfNeeded()
            }
        }
    }

    private var topPanel: some View {
        HStack(spacing: 10) {
            TeamCountPill(
                title: "Home",
                count: viewModel.homePlayerCount,
                color: viewModel.homeTeamColor
            )

            Spacer()

            TeamCountPill(
                title: "Away",
                count: viewModel.awayPlayerCount,
                color: viewModel.awayTeamColor
            )
        }
        .padding(10)
        .background(.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 12))
    }

    private var bottomOverlay: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                ForEach(InteractionMode.allCases, id: \.self) { mode in
                    IconControlButton(
                        systemName: mode.systemImage,
                        accessibilityLabel: mode.title,
                        tint: .green,
                        isActive: viewModel.interactionMode == mode
                    ) {
                        viewModel.interactionMode = mode
                    }
                }
                Spacer(minLength: 0)
            }

            if viewModel.interactionMode == .draw {
                drawControlBar
            } else {
                playerControlBar
            }

            if viewModel.interactionMode == .players, let selectedIndex = viewModel.selectedIndex {
                selectedPlayerBar(index: selectedIndex)
            }
        }
        .padding(10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(.white.opacity(0.18), lineWidth: 1)
        )
    }

    private var drawControlBar: some View {
        HStack(spacing: 8) {
            ForEach(DrawingMode.allCases, id: \.self) { mode in
                IconControlButton(
                    systemName: mode.systemImage,
                    accessibilityLabel: mode.title,
                    tint: .yellow,
                    isActive: viewModel.drawingMode == mode
                ) {
                    viewModel.drawingMode = mode
                }
            }

            Spacer(minLength: 0)

            IconControlButton(
                systemName: "slider.horizontal.3",
                accessibilityLabel: "Draw Settings",
                tint: .green
            ) {
                viewModel.isDrawSettingsPresented = true
            }

            IconControlButton(
                systemName: "arrow.uturn.backward",
                accessibilityLabel: "Undo"
            ) {
                viewModel.undoDrawing()
            }

            IconControlButton(
                systemName: "arrow.uturn.forward",
                accessibilityLabel: "Redo"
            ) {
                viewModel.redoDrawing()
            }

            IconControlButton(
                systemName: "trash",
                accessibilityLabel: "Clear Drawing",
                tint: .red,
                role: .destructive
            ) {
                viewModel.clearDrawing()
            }
        }
    }

    private var playerControlBar: some View {
        HStack(spacing: 8) {
            IconControlButton(
                systemName: "person.3.fill",
                accessibilityLabel: "Player Settings",
                tint: .green
            ) {
                viewModel.isPlayerSettingsPresented = true
            }

            IconControlButton(
                systemName: "soccerball",
                accessibilityLabel: "Apply Kickoff"
            ) {
                viewModel.applyKickoffLineup()
            }

            IconControlButton(
                systemName: "arrow.triangle.2.circlepath",
                accessibilityLabel: "Flip Team Sides"
            ) {
                viewModel.flipTeamSides()
            }

            IconControlButton(
                systemName: "number.circle",
                accessibilityLabel: "Renumber Teams"
            ) {
                viewModel.renumberTeams()
            }

            Spacer(minLength: 0)
        }
    }

    private func selectedPlayerBar(index: Int) -> some View {
        HStack(spacing: 8) {
            IconControlButton(
                systemName: "minus.circle",
                accessibilityLabel: "Decrease Number"
            ) {
                viewModel.decreasePlayerNumber(at: index)
            }

            Text("\(viewModel.players[index].number)")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(.white)
                .frame(minWidth: 34)

            IconControlButton(
                systemName: "plus.circle",
                accessibilityLabel: "Increase Number"
            ) {
                viewModel.increasePlayerNumber(at: index)
            }

            Spacer(minLength: 0)

            IconControlButton(
                systemName: "house.fill",
                accessibilityLabel: "Set Home Team",
                tint: viewModel.homeTeamColor,
                isActive: viewModel.players[index].team == .home
            ) {
                viewModel.setPlayerTeam(at: index, team: .home)
            }

            IconControlButton(
                systemName: "flag.fill",
                accessibilityLabel: "Set Away Team",
                tint: viewModel.awayTeamColor,
                isActive: viewModel.players[index].team == .away
            ) {
                viewModel.setPlayerTeam(at: index, team: .away)
            }
        }
    }
}
