import SwiftUI

struct SettingsView: View {
    @AppStorage("showGrid") private var showGrid = true

    var body: some View {
        Form {
            Toggle("Mostrar cuadrícula", isOn: $showGrid)
            Text("MVP iOS 17+ SwiftUI + SpriteKit + GameKit.")
                .font(.caption)
        }
        .navigationTitle("Ajustes")
    }
}
