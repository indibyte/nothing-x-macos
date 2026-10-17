// swift-tools-version:5.9
// Builds the app without Xcode (Command Line Tools only). Use scripts/build-app.sh
// to produce a runnable "Nothing X.app"; Xcode users can keep using the .xcodeproj.
import PackageDescription

let package = Package(
    name: "NothingX",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(path: "NothingProtocol"),
    ],
    targets: [
        // Named to match the Xcode module, which the sources reference directly.
        .executableTarget(
            name: "Nothing_X_MacOS",
            dependencies: [.product(name: "NothingProtocol", package: "NothingProtocol")],
            path: "Nothing X MacOS",
            exclude: [
                "Assets.xcassets",
                "Preview Content",
                "resources",
                "Nothing_X_MacOS.entitlements",
                "exportOptions.plist",
            ]
        ),
    ]
)
