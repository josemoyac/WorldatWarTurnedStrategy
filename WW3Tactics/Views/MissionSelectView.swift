import SwiftUI

struct MissionSelectView: View {
    private let missions = MissionFactory.campaignMissions()

    var body: some View {
        List(missions) { mission in
            NavigationLink {
                GameContainerView(initial: mission.gameState, briefing: mission.briefing, objectives: mission.guidedObjectives)
            } label: {
                VStack(alignment: .leading) {
                    Text(mission.title)
                    Text(mission.briefing).font(.caption)
                }
            }
        }
        .navigationTitle("Campaña")
    }
}
