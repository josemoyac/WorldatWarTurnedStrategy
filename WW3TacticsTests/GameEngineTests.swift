import XCTest
@testable import GameEngineCore

final class GameEngineTests: XCTestCase {
    func testDamageCalculation() {
        let attacker = UnitState(ownerID: UUID(), type: .tank, hp: 10, position: .init(x: 0, y: 0))
        let defender = UnitState(ownerID: UUID(), type: .infantry, hp: 10, position: .init(x: 1, y: 0))
        let damage = GameEngine.computeDamage(attacker: attacker, defender: defender, defenderTile: .plain, isPowerActive: false, commanderPower: .tankRush)
        XCTAssertEqual(damage, 7)
    }

    func testValidMovementByTerrain() {
        let p1 = PlayerState(displayName: "A", faction: .atlasUnion, commander: Commander.roster[0])
        let p2 = PlayerState(displayName: "B", faction: .redDawnPact, commander: Commander.roster[1])
        let unit = UnitState(ownerID: p1.id, type: .tank, position: .init(x: 0, y: 0))
        let tiles = [
            TileState(position: .init(x: 0, y: 0), type: .plain),
            TileState(position: .init(x: 1, y: 0), type: .mountain),
            TileState(position: .init(x: 0, y: 1), type: .road)
        ]
        let state = GameState(boardWidth: 2, boardHeight: 2, players: [p1,p2], units: [unit], tiles: tiles)
        let engine = GameEngine(state: state)
        let moves = engine.movableTiles(for: unit.id)
        XCTAssertTrue(moves.contains(.init(x: 0, y: 1)))
        XCTAssertFalse(moves.contains(.init(x: 1, y: 0)))
    }

    func testCaptureCity() throws {
        let p1 = PlayerState(displayName: "A", faction: .atlasUnion, commander: Commander.roster[0], powerActiveTurns: 1)
        let p2 = PlayerState(displayName: "B", faction: .redDawnPact, commander: Commander.roster[1])
        let infantry = UnitState(ownerID: p1.id, type: .infantry, position: .init(x: 0, y: 0))
        let city = TileState(position: .init(x: 0, y: 0), type: .city, ownerID: p2.id, capturePoints: 10)
        var engine = GameEngine(state: .init(boardWidth: 1, boardHeight: 1, players: [p1,p2], units: [infantry], tiles: [city]))
        try engine.capture(with: infantry.id)
        XCTAssertEqual(engine.state.tiles.first?.ownerID, p1.id)
    }

    func testSerializationRoundTrip() throws {
        let mission = MissionFactory.makeMission(id: 3)
        let data = try MatchSerialization.encode(mission.gameState)
        let decoded = try MatchSerialization.decode(data)
        XCTAssertEqual(decoded.boardWidth, 16)
        XCTAssertEqual(decoded.players.count, 2)
        XCTAssertEqual(decoded.units.count, mission.gameState.units.count)
    }
}
