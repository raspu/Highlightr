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
            path: "Pod",
            exclude: [
                "Assets/Highlighter/LICENSE",
            ],
            sources: [
                "Classes",
            ],
            resources: [
                .process("Assets/Highlighter/highlight.min.js"),
                .process("Assets/styles/.")
            ]
        ),
    ]
)
