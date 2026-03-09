import SwiftUI

struct PlayerSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var homeTeamSize: Int
    @Binding var awayTeamSize: Int
    @Binding var homeFormation: Formation
    @Binding var awayFormation: Formation
    @Binding var homeTeamColor: Color
    @Binding var awayTeamColor: Color
    @Binding var notes: String

    let applyKickoffLineup: () -> Void
    let flipTeamSides: () -> Void
    let renumberTeams: () -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("Match Setup") {
                    Stepper("Home Players: \(homeTeamSize)", value: $homeTeamSize, in: 5...11)
                    Stepper("Away Players: \(awayTeamSize)", value: $awayTeamSize, in: 5...11)

                    Text("Current setup: \(homeTeamSize)v\(awayTeamSize)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach([11, 9, 8, 7, 5], id: \.self) { size in
                                Button("\(size)v\(size)") {
                                    homeTeamSize = size
                                    awayTeamSize = size
                                    applyKickoffLineup()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }

                    Button("Apply Kickoff Lineup") {
                        applyKickoffLineup()
                    }
                }

                if homeTeamSize == 11 || awayTeamSize == 11 {
                    Section("11v11 Formation Design") {
                        if homeTeamSize == 11 {
                            Picker("Home", selection: $homeFormation) {
                                ForEach(Formation.allCases) { formation in
                                    Text(formation.rawValue).tag(formation)
                                }
                            }
                        }

                        if awayTeamSize == 11 {
                            Picker("Away", selection: $awayFormation) {
                                ForEach(Formation.allCases) { formation in
                                    Text(formation.rawValue).tag(formation)
                                }
                            }
                        }
                    }
                }

                Section("Team Colors") {
                    ColorPicker("Home Color", selection: $homeTeamColor)
                    ColorPicker("Away Color", selection: $awayTeamColor)
                }

                Section("Team Actions") {
                    Button("Flip Team Sides") { flipTeamSides() }
                    Button("Renumber Both Teams") { renumberTeams() }
                }

                Section("Tactical Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Player Settings")
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
