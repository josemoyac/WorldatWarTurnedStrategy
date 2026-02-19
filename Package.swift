// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "WorldatWarTurnedStrategy",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "GameEngineCore", targets: ["GameEngineCore"])
    ],
    targets: [
        .target(
            name: "GameEngineCore",
            path: "WW3Tactics",
            exclude: ["App", "Rendering", "ViewModels", "Views", "Resources"],
            sources: ["Domain", "Engine", "Online"]
        ),
        .testTarget(
            name: "WW3TacticsTests",
            dependencies: ["GameEngineCore"],
            path: "WW3TacticsTests"
        )
    ]
)
