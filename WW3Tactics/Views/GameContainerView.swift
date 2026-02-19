import SwiftUI
import SpriteKit

struct GameContainerView: View {
    @StateObject private var vm: GameViewModel
    private let briefing: String?
    private let objectives: [String]

    init(initial: GameState, briefing: String? = nil, objectives: [String] = []) {
        _vm = StateObject(wrappedValue: GameViewModel(initialState: initial))
        self.briefing = briefing
        self.objectives = objectives
    }

    var body: some View {
        VStack {
            HUDView(vm: vm)
            SpriteView(scene: buildScene())
                .frame(width: 384, height: 384)
            if !objectives.isEmpty {
                VStack(alignment: .leading) {
                    Text("Objetivos").bold()
                    ForEach(objectives, id: \.self, content: Text.init)
                        .font(.caption)
                }
            }
        }
        .padding()
        .navigationTitle("Día \(vm.state.day)")
        .toolbar {
            if let briefing {
                Text(briefing).font(.caption)
            }
        }
    }

    private func buildScene() -> GameScene {
        let scene = GameScene(size: CGSize(width: 384, height: 384))
        scene.scaleMode = .fill
        scene.state = vm.state
        scene.onTileTapped = { vm.tap(position: $0) }
        return scene
    }
}

struct HUDView: View {
    @ObservedObject var vm: GameViewModel

    var body: some View {
        HStack {
            Text("Turno: \(vm.state.players[vm.state.turnIndex].displayName)")
            Spacer()
            Text("$\(vm.state.players[vm.state.turnIndex].funds)")
            Button("Power Up") { vm.activatePower() }
                .disabled(vm.state.players[vm.state.turnIndex].powerMeter < vm.state.players[vm.state.turnIndex].commander.powerCost)
            Button("Fin turno") { vm.endTurn() }
        }
        .font(.caption)
    }
}
