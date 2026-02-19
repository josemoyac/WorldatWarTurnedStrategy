import Foundation

public enum EngineError: Error {
    case invalidUnit
    case notCurrentPlayer
    case invalidMove
    case insufficientFunds
    case invalidTarget
}

public struct GameEngine {
    public private(set) var state: GameState

    public init(state: GameState) {
        self.state = state
    }

    public var currentPlayer: PlayerState { state.players[state.turnIndex] }

    public func tile(at position: Position) -> TileState? {
        state.tiles.first { $0.position == position }
    }

    public func unit(at position: Position) -> UnitState? {
        state.units.first { $0.position == position }
    }

    public func movableTiles(for unitID: UUID) -> Set<Position> {
        guard let movingUnit = state.units.first(where: { $0.id == unitID }) else { return [] }
        let move = modifiedMovement(for: movingUnit)
        var visited: [Position: Int] = [movingUnit.position: 0]
        var queue: [Position] = [movingUnit.position]

        while !queue.isEmpty {
            let current = queue.removeFirst()
            let cost = visited[current, default: Int.max]
            for next in neighbors(of: current) {
                guard isInside(next), let tile = tile(at: next) else { continue }
                let step = movementCost(for: tile.type, unit: movingUnit)
                if step == Int.max { continue }
                let nextCost = cost + step
                if nextCost <= move && nextCost < visited[next, default: Int.max] && unit(at: next) == nil {
                    visited[next] = nextCost
                    queue.append(next)
                }
            }
        }
        return Set(visited.keys)
    }

    public func attackableTiles(for unitID: UUID) -> Set<Position> {
        guard let unit = state.units.first(where: { $0.id == unitID }) else { return [] }
        let range = modifiedRange(for: unit)
        var positions = Set<Position>()
        for x in 0..<state.boardWidth {
            for y in 0..<state.boardHeight {
                let p = Position(x: x, y: y)
                let distance = abs(p.x - unit.position.x) + abs(p.y - unit.position.y)
                if range.contains(distance) { positions.insert(p) }
            }
        }
        return positions
    }

    public mutating func move(unitID: UUID, to position: Position) throws {
        guard let index = state.units.firstIndex(where: { $0.id == unitID }) else { throw EngineError.invalidUnit }
        var unit = state.units[index]
        guard unit.ownerID == currentPlayer.id else { throw EngineError.notCurrentPlayer }
        guard !unit.hasActed else { throw EngineError.invalidMove }
        guard movableTiles(for: unitID).contains(position) else { throw EngineError.invalidMove }
        unit.position = position
        state.units[index] = unit
    }

    public mutating func attack(attackerID: UUID, targetPosition: Position) throws {
        guard let attackerIndex = state.units.firstIndex(where: { $0.id == attackerID }) else { throw EngineError.invalidUnit }
        var attacker = state.units[attackerIndex]
        guard attacker.ownerID == currentPlayer.id else { throw EngineError.notCurrentPlayer }
        guard !attacker.hasActed else { throw EngineError.invalidMove }

        guard let defenderIndex = state.units.firstIndex(where: { $0.position == targetPosition }) else { throw EngineError.invalidTarget }
        let defender = state.units[defenderIndex]
        guard defender.ownerID != attacker.ownerID else { throw EngineError.invalidTarget }
        guard attackableTiles(for: attackerID).contains(targetPosition) else { throw EngineError.invalidTarget }

        let damage = Self.computeDamage(attacker: attacker, defender: defender, defenderTile: tile(at: defender.position)?.type ?? .plain, isPowerActive: currentPlayer.powerActiveTurns > 0, commanderPower: currentPlayer.commander.powerType)

        attacker.hasActed = true
        state.units[attackerIndex] = attacker

        var target = defender
        target.hp = max(0, target.hp - damage)
        if target.hp == 0 {
            state.units.remove(at: defenderIndex)
            state.players[state.turnIndex].powerMeter += 20
        } else {
            state.units[defenderIndex] = target
            state.players[state.turnIndex].powerMeter += 10
        }

        validateVictory()
    }

    public mutating func capture(with unitID: UUID) throws {
        guard let unit = state.units.first(where: { $0.id == unitID }) else { throw EngineError.invalidUnit }
        guard unit.type == .infantry else { throw EngineError.invalidMove }
        guard !unit.hasActed else { throw EngineError.invalidMove }
        guard let tileIndex = state.tiles.firstIndex(where: { $0.position == unit.position }) else { throw EngineError.invalidTarget }

        let eligible: [TileType] = [.city, .base, .hq]
        guard eligible.contains(state.tiles[tileIndex].type) else { throw EngineError.invalidTarget }

        var captureValue = unit.hp
        if currentPlayer.commander.powerType == .infantryCaptureBoost && currentPlayer.powerActiveTurns > 0 {
            captureValue += 5
        }

        state.tiles[tileIndex].capturePoints -= captureValue
        if state.tiles[tileIndex].capturePoints <= 0 {
            state.tiles[tileIndex].ownerID = currentPlayer.id
            state.tiles[tileIndex].capturePoints = 20
            state.players[state.turnIndex].powerMeter += 15
            if state.tiles[tileIndex].type == .hq { state.isFinished = true; state.winnerID = currentPlayer.id }
        }

        if let idx = state.units.firstIndex(where: { $0.id == unitID }) {
            state.units[idx].hasActed = true
        }
    }

    public mutating func buildUnit(type: UnitType, at basePosition: Position) throws {
        guard let tile = tile(at: basePosition), tile.type == .base, tile.ownerID == currentPlayer.id else { throw EngineError.invalidTarget }
        guard unit(at: basePosition) == nil else { throw EngineError.invalidTarget }
        guard state.players[state.turnIndex].funds >= type.cost else { throw EngineError.insufficientFunds }

        state.players[state.turnIndex].funds -= type.cost
        state.units.append(UnitState(ownerID: currentPlayer.id, type: type, position: basePosition, hasActed: true))
    }

    public mutating func activatePowerUp() {
        guard state.players[state.turnIndex].powerMeter >= currentPlayer.commander.powerCost else { return }
        state.players[state.turnIndex].powerMeter -= currentPlayer.commander.powerCost
        state.players[state.turnIndex].powerActiveTurns = 1
    }

    public mutating func endTurn() {
        applyIncome()
        for idx in state.units.indices where state.units[idx].ownerID == currentPlayer.id {
            state.units[idx].hasActed = false
        }
        if state.players[state.turnIndex].powerActiveTurns > 0 {
            state.players[state.turnIndex].powerActiveTurns -= 1
        }
        state.turnIndex = (state.turnIndex + 1) % state.players.count
        if state.turnIndex == 0 { state.day += 1 }
        validateVictory()
    }

    private mutating func applyIncome() {
        let incomePerCity = (currentPlayer.commander.powerType == .economicSurge && currentPlayer.powerActiveTurns > 0) ? 1500 : 1000
        let ownedCities = state.tiles.filter { $0.ownerID == currentPlayer.id && [.city, .base, .hq].contains($0.type) }.count
        state.players[state.turnIndex].funds += ownedCities * incomePerCity
    }

    private mutating func validateVictory() {
        let livingOwners = Set(state.units.map(\.ownerID))
        for idx in state.players.indices {
            if !livingOwners.contains(state.players[idx].id) { state.players[idx].isDefeated = true }
        }
        let active = state.players.filter { !$0.isDefeated }
        if active.count == 1 {
            state.isFinished = true
            state.winnerID = active.first?.id
        }
    }

    private func isInside(_ p: Position) -> Bool {
        p.x >= 0 && p.x < state.boardWidth && p.y >= 0 && p.y < state.boardHeight
    }

    private func neighbors(of p: Position) -> [Position] {
        [Position(x: p.x + 1, y: p.y), Position(x: p.x - 1, y: p.y), Position(x: p.x, y: p.y + 1), Position(x: p.x, y: p.y - 1)]
    }

    private func movementCost(for tile: TileType, unit: UnitState) -> Int {
        switch tile {
        case .sea:
            return unit.type == .copter ? 1 : Int.max
        case .river:
            return unit.type == .infantry ? 2 : (unit.type == .copter ? 1 : Int.max)
        case .mountain:
            return unit.type == .infantry ? 2 : (unit.type == .copter ? 1 : Int.max)
        case .forest:
            return unit.type == .tank ? 2 : 1
        default:
            return 1
        }
    }

    private func modifiedMovement(for unit: UnitState) -> Int {
        if currentPlayer.commander.powerType == .tankRush && currentPlayer.powerActiveTurns > 0 && unit.type == .tank {
            return unit.type.movement + 1
        }
        return unit.type.movement
    }

    private func modifiedRange(for unit: UnitState) -> ClosedRange<Int> {
        guard currentPlayer.commander.powerType == .artilleryOverwatch,
              currentPlayer.powerActiveTurns > 0,
              unit.type == .artillery else {
            return unit.type.attackRange
        }
        return unit.type.attackRange.lowerBound...min(4, unit.type.attackRange.upperBound + 1)
    }

    public static func computeDamage(attacker: UnitState, defender: UnitState, defenderTile: TileType, isPowerActive: Bool, commanderPower: CommanderPowerType) -> Int {
        let base: Int
        switch (attacker.type, defender.type) {
            case (.infantry, .tank): base = 2
            case (.tank, .infantry): base = 8
            case (.artillery, _): base = 7
            case (.recon, .infantry): base = 6
            default: base = 5
        }
        let hpFactor = Double(attacker.hp) / 10.0
        var final = Int((Double(base) * hpFactor).rounded())
        final -= defenderTile.defenseStars
        if isPowerActive && commanderPower == .infantryCaptureBoost && attacker.type == .infantry {
            final += 2
        }
        return max(1, final)
    }
}
