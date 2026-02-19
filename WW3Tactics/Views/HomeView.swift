import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 14) {
                Text("World at War: Turned Strategy")
                    .font(.title2.bold())
                NavigationLink("Historia") { MissionSelectView() }
                    .buttonStyle(.borderedProminent)
                NavigationLink("Online") { OnlineLobbyView() }
                    .buttonStyle(.bordered)
                NavigationLink("Hotseat") { GameContainerView(initial: MissionFactory.makeMission(id: 10).gameState) }
                    .buttonStyle(.bordered)
                NavigationLink("Ajustes") { SettingsView() }
                    .buttonStyle(.bordered)
            }
            .padding()
        }
    }
}
