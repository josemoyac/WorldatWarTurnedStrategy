import Foundation

public enum MatchSerialization {
    public static func encode(_ state: GameState) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        return try encoder.encode(state)
    }

    public static func decode(_ data: Data) throws -> GameState {
        try JSONDecoder().decode(GameState.self, from: data)
    }
}
