import SpriteKit
import SwiftUI

final class GameScene: SKScene {
    var onTileTapped: ((Position) -> Void)?
    var state: GameState? { didSet { redraw() } }

    private let tileSize: CGFloat = 24

    override func didMove(to view: SKView) {
        anchorPoint = CGPoint(x: 0, y: 0)
        backgroundColor = .black
        redraw()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let p = Position(x: Int(location.x / tileSize), y: Int(location.y / tileSize))
        onTileTapped?(p)
    }

    private func redraw() {
        removeAllChildren()
        guard let state else { return }
        for tile in state.tiles {
            let node = SKShapeNode(rectOf: CGSize(width: tileSize - 1, height: tileSize - 1))
            node.fillColor = color(for: tile.type)
            node.position = CGPoint(x: CGFloat(tile.position.x) * tileSize + tileSize / 2, y: CGFloat(tile.position.y) * tileSize + tileSize / 2)
            node.strokeColor = .clear
            addChild(node)
        }

        for unit in state.units {
            let node = SKShapeNode(rectOf: CGSize(width: tileSize - 6, height: tileSize - 6), cornerRadius: 3)
            node.fillColor = color(forUnit: unit)
            node.position = CGPoint(x: CGFloat(unit.position.x) * tileSize + tileSize / 2, y: CGFloat(unit.position.y) * tileSize + tileSize / 2)
            node.strokeColor = .white
            addChild(node)
        }
    }

    private func color(for type: TileType) -> UIColor {
        switch type {
        case .plain: return .init(red: 0.36, green: 0.57, blue: 0.31, alpha: 1)
        case .forest: return .init(red: 0.21, green: 0.41, blue: 0.21, alpha: 1)
        case .mountain: return .darkGray
        case .road: return .brown
        case .city: return .lightGray
        case .base: return .systemOrange
        case .hq: return .systemRed
        case .sea: return .systemBlue
        case .river: return .cyan
        }
    }

    private func color(forUnit unit: UnitState) -> UIColor {
        unit.ownerID == state?.players.first?.id ? .systemTeal : .systemPink
    }
}
