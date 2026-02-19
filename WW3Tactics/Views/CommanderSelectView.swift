import SwiftUI

struct CommanderSelectView: View {
    @Binding var selected: Commander

    var body: some View {
        List(Commander.roster) { commander in
            Button {
                selected = commander
            } label: {
                VStack(alignment: .leading) {
                    Text(commander.displayName).font(.headline)
                    Text(commander.lore).font(.caption)
                    Text("Power: \(commander.powerName)").font(.caption2)
                }
            }
        }
        .navigationTitle("Comandante")
    }
}
