// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "MOSheetTransition",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(name: "MOSheetTransition",
                 targets: ["MOSheetTransition"])
    ],
    targets: [
        .target(name: "MOSheetTransition", path: "Sources")
    ],
    swiftLanguageVersions: [
        .v5
    ]
)
