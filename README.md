# World at War: Turned Strategy (MVP)

Juego táctico por turnos en cuadrícula inspirado en el *feeling* de clásicos de estrategia, con estética retro moderna y assets placeholder originales.

## Stack
- Swift
- SwiftUI (menús y flujo)
- SpriteKit (render tablero)
- Motor de reglas puro Swift (`GameEngine`)
- Serialización `Codable -> JSON Data` para partidas asíncronas
- GameKit Turn-Based Matches (capa preparada en `GameCenterTurnService`)

## Estructura
- `WW3Tactics/Domain`: modelos (`GameState`, `PlayerState`, `UnitState`, `TileState`, `Commander`, `MatchSettings`)
- `WW3Tactics/Engine`: reglas del juego, daño, movimiento, captura, economía, campaña de 10 misiones
- `WW3Tactics/Rendering`: `GameScene` SpriteKit
- `WW3Tactics/ViewModels`: MVVM simple
- `WW3Tactics/Views`: Home, Historia, Online, Hotseat, Ajustes
- `WW3Tactics/Online`: serialización + integración Game Center
- `WW3TacticsTests`: tests unitarios

## Abrir en Xcode
1. Abre `Package.swift` en Xcode 15+ (iOS 17 SDK).
2. Crea un target iOS App si quieres ejecutar directamente la app SwiftUI con los archivos de `WW3Tactics/App`, `Views`, `ViewModels`, `Rendering`.
3. Alternativamente, integra estos archivos en un proyecto iOS nuevo y conserva `Domain/Engine/Online` como módulo core.

## Game Center (Turn-Based)
1. En Apple Developer, habilita Game Center para el Bundle ID.
2. En Xcode, activa capability **Game Center**.
3. Asegura que `GKLocalPlayer.local.authenticateHandler` se invoca al inicio.
4. Para cada turno, serializa estado con `MatchSerialization.encode` y llama `endTurn`.

## Hotseat
- Desde Home -> **Hotseat**.
- Inicia misión 10 en modo local de 2 jugadores para pruebas rápidas sin conexión.

## Serialización de partida
- `MatchSerialization.encode(_:)` transforma `GameState` a `Data` JSON ordenado.
- `MatchSerialization.decode(_:)` rehidrata estado para continuar turno.
- Este `Data` es el valor a guardar en `GKTurnBasedMatch.matchData`.

## Mecánicas incluidas (MVP)
- Mapa 16x16 configurable
- Terrenos: llanura, bosque, montaña, carretera, ciudad, base, HQ, mar, río
- Unidades: infantería, tanque, artillería, recon, transporte, aérea (copter)
- Captura por infantería
- Economía por ciudades
- Compra en base
- 4 comandantes con Power Up y barra de energía
- Campaña de 10 misiones (tutorial en 1 y 2; objetivo final en 10)

## Tests
```bash
swift test
```

