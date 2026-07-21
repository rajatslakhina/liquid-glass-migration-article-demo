// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "GlassAuditKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(name: "GlassAuditKit", targets: ["GlassAuditKit"])
    ],
    targets: [
        .target(name: "GlassAuditKit"),
        .testTarget(
            name: "GlassAuditKitTests",
            dependencies: ["GlassAuditKit"]
        )
    ]
)
