// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "herald-ios-firebase",
    // macOS is listed so the tests can run with `swift test` on a Mac.
    platforms: [.iOS(.v15), .macOS(.v13)],
    products: [
        .library(name: "HeraldFirebase", targets: ["HeraldFirebase"])
    ],
    dependencies: [
        .package(url: "https://github.com/MkhytarMkhoian/herald-ios", from: "1.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "12.0.0"),
    ],
    targets: [
        .target(
            name: "HeraldFirebase",
            dependencies: [
                .product(name: "HeraldCore", package: "herald-ios"),
                .product(name: "FirebaseAnalytics", package: "firebase-ios-sdk"),
            ]
        ),
        .testTarget(
            name: "HeraldFirebaseTests",
            dependencies: [
                "HeraldFirebase",
                .product(name: "HeraldTesting", package: "herald-ios"),
            ]
        ),
    ]
)
