import Foundation

@MainActor
final class GameViewModel: ObservableObject {
    @Published var state: GameState
    @Published var selectedUnitID: UUID?
    @Published var contextualActions: [String] = []

    private var engine: GameEngine

    init(initialState: GameState) {
        self.state = initialState
        self.engine = GameEngine(state: initialState)
    }

    func tap(position: Position) {
        if let unit = state.units.first(where: { $0.position == position && $0.ownerID == engine.currentPlayer.id }) {
            selectedUnitID = unit.id
            contextualActions = ["Mover", "Atacar", "Esperar"]
            return
        }

        guard let selectedUnitID else { return }
        if engine.movableTiles(for: selectedUnitID).contains(position) {
            try? engine.move(unitID: selectedUnitID, to: position)
        }
        state = engine.state
    }

    func endTurn() {
        engine.endTurn()
        state = engine.state
        selectedUnitID = nil
        contextualActions = []
    }

    func activatePower() {
        engine.activatePowerUp()
        state = engine.state
    }

    func buy(unitType: UnitType, at position: Position) {
        try? engine.buildUnit(type: unitType, at: position)
        state = engine.state
    }
}
