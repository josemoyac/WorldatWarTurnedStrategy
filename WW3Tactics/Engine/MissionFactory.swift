import Foundation

public enum MissionFactory {
    public static func campaignMissions() -> [Mission] {
        (1...10).map(makeMission)
    }

    public static func makeMission(id: Int) -> Mission {
        let p1 = PlayerState(displayName: "Task Force Atlas", faction: .atlasUnion, commander: Commander.roster[0], funds: 3000)
        let p2 = PlayerState(displayName: "Crimson Echo", faction: .redDawnPact, commander: Commander.roster[min(3, max(0, id - 1) % 4)], funds: 3000)

        let state = GameState(
            boardWidth: 16,
            boardHeight: 16,
            players: [p1, p2],
            units: defaultUnits(p1: p1.id, p2: p2.id, missionID: id),
            tiles: defaultMap(p1: p1.id, p2: p2.id)
        )

        return Mission(
            id: id,
            title: id <= 2 ? "Tutorial \(id)" : "Operación \(id)",
            briefing: briefing(for: id),
            gameState: state,
            guidedObjectives: objectives(for: id)
        )
    }

    private static func briefing(for id: Int) -> String {
        switch id {
        case 1: return "Aprende movimiento y ataque básico en zona segura."
        case 2: return "Captura una ciudad, recibe ingresos y produce una unidad."
        case 10: return "Asalto final: captura la HQ enemiga para terminar la campaña."
        default: return "Misión táctica \(id): combina control territorial y combate."
        }
    }

    private static func objectives(for id: Int) -> [String] {
        switch id {
        case 1: return ["Selecciona infantería", "Muévete a casilla resaltada", "Ataca objetivo marcado"]
        case 2: return ["Captura ciudad", "Finaliza turno para cobrar ingresos", "Compra infantería en base"]
        case 10: return ["Derrota total o captura HQ"]
        default: return ["Elimina resistencia enemiga", "Controla al menos 3 ciudades"]
        }
    }

    private static func defaultUnits(p1: UUID, p2: UUID, missionID: Int) -> [UnitState] {
        var units = [
            UnitState(ownerID: p1, type: .infantry, position: Position(x: 2, y: 2)),
            UnitState(ownerID: p1, type: .tank, position: Position(x: 3, y: 2)),
            UnitState(ownerID: p2, type: .infantry, position: Position(x: 12, y: 12)),
            UnitState(ownerID: p2, type: .tank, position: Position(x: 11, y: 12))
        ]
        if missionID >= 5 { units.append(UnitState(ownerID: p2, type: .artillery, position: Position(x: 10, y: 11))) }
        if missionID >= 8 { units.append(UnitState(ownerID: p1, type: .copter, position: Position(x: 4, y: 4))) }
        return units
    }

    private static func defaultMap(p1: UUID, p2: UUID) -> [TileState] {
        var tiles: [TileState] = []
        for y in 0..<16 {
            for x in 0..<16 {
                let type: TileType = (x == y || x + y == 15) ? .road : .plain
                tiles.append(TileState(position: Position(x: x, y: y), type: type))
            }
        }
        let specials: [(Position, TileType, UUID?)] = [
            (Position(x: 1, y: 1), .hq, p1),
            (Position(x: 14, y: 14), .hq, p2),
            (Position(x: 2, y: 1), .base, p1),
            (Position(x: 13, y: 14), .base, p2),
            (Position(x: 6, y: 6), .city, nil),
            (Position(x: 9, y: 9), .city, nil)
        ]
        for (position, type, owner) in specials {
            if let idx = tiles.firstIndex(where: { $0.position == position }) {
                tiles[idx].type = type
                tiles[idx].ownerID = owner
            }
        }
        return tiles
    }
}
