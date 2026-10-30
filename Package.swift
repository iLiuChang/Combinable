// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "Combinable",
    platforms: [.iOS(.v13)],
    products: [
        .library(name: "Combinable", targets: ["Combinable"])
    ],
    targets: [
        .target(
            name: "Combinable",
            path: "Sources",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        )
    ]
)
