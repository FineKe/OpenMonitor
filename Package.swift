// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "OpenMonitor",
    platforms: [
        .macOS(.v11)
    ],
    products: [
        .executable(name: "OpenMonitor", targets: ["OpenMonitor"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "OpenMonitor",
            dependencies: [],
            path: "OpenMonitor"
        )
    ]
) 
