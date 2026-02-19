import SwiftUI

struct OnlineLobbyView: View {
    @State private var selectedMap = "Continental Rift"
    @State private var players = 2

    var body: some View {
        Form {
            Picker("Mapa", selection: $selectedMap) {
                Text("Continental Rift").tag("Continental Rift")
                Text("Frozen Strait").tag("Frozen Strait")
            }
            Stepper("Jugadores: \(players)", value: $players, in: 2...8)
            Text("Invitación y turnos asíncronos usan Game Center Turn-Based Matches.")
                .font(.caption)
            Button("Crear / Continuar partida") {
                // Hook con GKTurnBasedMatchmakerViewController en app real.
            }
        }
        .navigationTitle("Online")
    }
}
