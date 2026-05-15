// swift-tools-version: 5.9
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .unsafeFlags([
        "-Xfrontend", "-internalize-at-link",
        "-Xfrontend", "-lto=llvm-full",
        "-Xfrontend", "-conditional-runtime-records"
    ])
]

let linkerSettings: [LinkerSetting] = [
    .unsafeFlags(["-Xlinker", "-dead_strip"])
]

let package = Package(
    name: "GodotHapticFeedback",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "GodotHapticFeedback", type: .dynamic, targets: ["GodotHapticFeedback"]),
    ],
    dependencies: [
        .package(name: "SwiftGodot", path: "../../SwiftGodot"),
    ],
    targets: [
        .target(
            name: "GodotHapticFeedback",
            dependencies: [
                .product(name: "SwiftGodotRuntime", package: "SwiftGodot"),
            ],
            swiftSettings: swiftSettings,
            linkerSettings: linkerSettings
        ),
    ]
)
