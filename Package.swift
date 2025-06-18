// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Highlightr",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v8),
    ],
    products: [
        .library(
            name: "Highlightr",
            targets: ["Highlightr"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Highlightr",
            dependencies: [],
            path: "src",
            exclude: [
                "assets/highlighter/LICENSE",
            ],
            sources: [
                "classes",
            ],
            resources: [
                .process("assets/highlighter/highlight.min.js"),
                .process("assets/styles/.")
            ]
        ),
    ]
)
