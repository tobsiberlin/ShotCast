// swift-tools-version: 5.9
// EN: Package manifest for ShotCast
// DE: Paket-Manifest für ShotCast

import PackageDescription

let package = Package(
    name: "ShotCast",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "ShotCast",
            targets: ["ShotCast"]
        )
    ],
    targets: [
        .executableTarget(
            name: "ShotCast",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "ShotCastTests",
            dependencies: ["ShotCast"]
        )
    ]
)