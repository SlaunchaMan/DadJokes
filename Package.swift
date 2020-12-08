// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "DadJokes",
    platforms: [
        .macOS(.v10_12)
    ],
    products: [
        .library(
            name: "DadJokesCore",
            targets: ["DadJokesCore"]
        ),
        .executable(
            name: "DadJokes",
            targets: ["DadJokes"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/Alamofire/Alamofire",
            from: "5.0.0"
        ),
        .package(
            url: "https://github.com/AliSoftware/OHHTTPStubs",
            from: "9.0.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "0.0.4"
        ),
        .package(
            url: "https://github.com/SlaunchaMan/GCDWebServer",
            .branch("swift-package-manager")
        ),
        .package(
            url: "https://github.com/lukaskubanek/LoremIpsum",
            from: "2.0.0"
        )
    ],
    targets: [
        .target(
            name: "DadJokesCore",
            dependencies: [
                "Alamofire",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                )
            ]
        ),
        .testTarget(
            name: "DadJokesCoreTests",
            dependencies: [
                "Alamofire",
                "DadJokesCore",
                "OHHTTPStubs",
                .product(
                    name: "OHHTTPStubsSwift",
                    package: "OHHTTPStubs"
                )
            ]
        ),
        .target(
            name: "DadJokes",
            dependencies: [
                "DadJokesCore"
            ]
        ),
        .testTarget(
            name: "DadJokesTests",
            dependencies: [
                "DadJokes",
                "GCDWebServer",
                "LoremIpsum"
            ]
        )
    ]
)
