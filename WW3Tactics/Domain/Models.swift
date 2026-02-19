import Foundation

public enum Faction: String, Codable, CaseIterable, Identifiable {
    case atlasUnion
    case redDawnPact
    case helixLeague
    case nomadFront

    public var id: String { rawValue }
}

public enum TileType: String, Codable, CaseIterable {
    case plain, forest, mountain, road, city, base, hq, sea, river

    public var defenseStars: Int {
        switch self {
        case .plain: 1
        case .forest: 2
        case .mountain: 4
        case .road: 0
        case .city, .base, .hq: 3
        case .sea, .river: 0
        }
    }
}

public struct Position: Codable, Hashable {
    public var x: Int
    public var y: Int

    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

public struct TileState: Codable {
    public var position: Position
    public var type: TileType
    public var ownerID: UUID?
    public var capturePoints: Int

    public init(position: Position, type: TileType, ownerID: UUID? = nil, capturePoints: Int = 20) {
        self.position = position
        self.type = type
        self.ownerID = ownerID
        self.capturePoints = capturePoints
    }
}

public enum UnitType: String, Codable, CaseIterable {
    case infantry, tank, artillery, recon, transport, copter

    public var cost: Int {
        switch self {
        case .infantry: 1000
        case .tank: 7000
        case .artillery: 6000
        case .recon: 4000
        case .transport: 5000
        case .copter: 9000
        }
    }

    public var movement: Int {
        switch self {
        case .infantry: 3
        case .tank: 6
        case .artillery: 5
        case .recon: 8
        case .transport: 6
        case .copter: 6
        }
    }

    public var attackRange: ClosedRange<Int> {
        switch self {
        case .artillery: 2...3
        default: 1...1
        }
    }
}

public struct UnitState: Codable, Identifiable {
    public var id: UUID
    public var ownerID: UUID
    public var type: UnitType
    public var hp: Int
    public var position: Position
    public var hasActed: Bool

    public init(id: UUID = UUID(), ownerID: UUID, type: UnitType, hp: Int = 10, position: Position, hasActed: Bool = false) {
        self.id = id
        self.ownerID = ownerID
        self.type = type
        self.hp = hp
        self.position = position
        self.hasActed = hasActed
    }
}

public enum CommanderPowerType: String, Codable {
    case infantryCaptureBoost
    case tankRush
    case artilleryOverwatch
    case economicSurge
}

public struct Commander: Codable, Identifiable {
    public var id: String
    public var displayName: String
    public var lore: String
    public var powerName: String
    public var powerCost: Int
    public var powerType: CommanderPowerType

    public static let roster: [Commander] = [
        Commander(id: "naia", displayName: "Naia Voss", lore: "Veterana de operaciones urbanas. Su doctrina favorece infantería y tomas rápidas.", powerName: "Bandera de Asalto", powerCost: 60, powerType: .infantryCaptureBoost),
        Commander(id: "bram", displayName: "Bram Kovac", lore: "Especialista en blindados de reacción rápida.", powerName: "Columna Relámpago", powerCost: 70, powerType: .tankRush),
        Commander(id: "iris", displayName: "Iris Hale", lore: "Experta en fuego indirecto y control de zona.", powerName: "Malla de Fuego", powerCost: 65, powerType: .artilleryOverwatch),
        Commander(id: "orion", displayName: "Orion Sayeed", lore: "Logística extrema: maximiza economía en campaña larga.", powerName: "Pulso Industrial", powerCost: 55, powerType: .economicSurge)
    ]
}

public struct PlayerState: Codable, Identifiable {
    public var id: UUID
    public var displayName: String
    public var faction: Faction
    public var commander: Commander
    public var funds: Int
    public var powerMeter: Int
    public var powerActiveTurns: Int
    public var isDefeated: Bool

    public init(id: UUID = UUID(), displayName: String, faction: Faction, commander: Commander, funds: Int = 0, powerMeter: Int = 0, powerActiveTurns: Int = 0, isDefeated: Bool = false) {
        self.id = id
        self.displayName = displayName
        self.faction = faction
        self.commander = commander
        self.funds = funds
        self.powerMeter = powerMeter
        self.powerActiveTurns = powerActiveTurns
        self.isDefeated = isDefeated
    }
}

public struct MatchSettings: Codable {
    public var mapName: String
    public var maxPlayers: Int
    public var turnTimeLimitSeconds: Int?
    public var isHotseat: Bool

    public init(mapName: String, maxPlayers: Int, turnTimeLimitSeconds: Int? = nil, isHotseat: Bool) {
        self.mapName = mapName
        self.maxPlayers = maxPlayers
        self.turnTimeLimitSeconds = turnTimeLimitSeconds
        self.isHotseat = isHotseat
    }
}

public struct Mission: Codable, Identifiable {
    public var id: Int
    public var title: String
    public var briefing: String
    public var gameState: GameState
    public var guidedObjectives: [String]
}

public struct GameState: Codable {
    public var boardWidth: Int
    public var boardHeight: Int
    public var turnIndex: Int
    public var day: Int
    public var players: [PlayerState]
    public var units: [UnitState]
    public var tiles: [TileState]
    public var isFinished: Bool
    public var winnerID: UUID?

    public init(boardWidth: Int, boardHeight: Int, turnIndex: Int = 0, day: Int = 1, players: [PlayerState], units: [UnitState], tiles: [TileState], isFinished: Bool = false, winnerID: UUID? = nil) {
        self.boardWidth = boardWidth
        self.boardHeight = boardHeight
        self.turnIndex = turnIndex
        self.day = day
        self.players = players
        self.units = units
        self.tiles = tiles
        self.isFinished = isFinished
        self.winnerID = winnerID
    }
}
