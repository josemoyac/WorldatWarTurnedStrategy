import Foundation
#if canImport(GameKit)
import GameKit

public final class GameCenterTurnService: NSObject {
    public static let shared = GameCenterTurnService()

    public func authenticate() {
        GKLocalPlayer.local.authenticateHandler = { _, _ in }
    }

    public func saveTurn(state: GameState, in match: GKTurnBasedMatch, nextPlayers: [GKTurnBasedParticipant]) async throws {
        let data = try MatchSerialization.encode(state)
        try await match.endTurn(withNextParticipants: nextPlayers, turnTimeout: GKTurnTimeoutDefault, match: data)
    }

    public func loadState(from match: GKTurnBasedMatch) throws -> GameState? {
        guard let data = match.matchData else { return nil }
        return try MatchSerialization.decode(data)
    }
}
#endif
