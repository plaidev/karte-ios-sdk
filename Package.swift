// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Karte",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "KarteCore",
            targets: ["KarteCore", "KarteUtilities"]
        ),
        .library(
            name: "KarteInAppMessaging",
            targets: ["KarteInAppMessaging", "KarteCore", "KarteUtilities"]
        ),
        .library(
            name: "KarteVariables",
            targets: ["KarteVariables", "KarteCore", "KarteUtilities"]
        ),
        .library(
            name: "KarteVisualTracking",
            targets: ["KarteVisualTracking", "KarteCore", "KarteUtilities"]
        ),
        .library(
            name: "KarteRemoteNotification",
            targets: ["KarteRemoteNotification", "KarteCore", "KarteUtilities"]
        ),
        .library(
            name: "KarteCrashReporting",
            type: .static,
            targets: ["KarteCrashReportingTarget", "KarteCore", "KarteUtilities"]
        ),
        .library(
            name: "KarteNotificationServiceExtension",
            targets: ["KarteNotificationServiceExtension"]
        )
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PLCrashReporter", url: "https://github.com/plaidev/PLCrashReporter.git", from: "1.8.2-spm")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "KarteUtilities", url: "https://sdk.karte.io/ios/swiftpm/Utilities-3.6.0/KarteUtilities.xcframework.zip", checksum: "0f899403ff016c9b7ad9ecccb1a1d77e02eb7b1123f51c0839e5b6dede40a9de"
        ),
        .binaryTarget(
            name: "KarteCore", url: "https://sdk.karte.io/ios/swiftpm/Core-2.20.0/KarteCore.xcframework.zip", checksum: "7f84114d562c899909e1c558f6f36e8dff5342466c09b1a98724f59cec9ebedf"
        ),
        .binaryTarget(
            name: "KarteInAppMessaging", url: "https://sdk.karte.io/ios/swiftpm/InAppMessaging-2.10.1/KarteInAppMessaging.xcframework.zip", checksum: "9989b81af19a70be1ec683c4099d4cd6265bc7afc973d6fca37fc18a7ad846a2"
        ),
        .binaryTarget(
            name: "KarteVariables", url: "https://sdk.karte.io/ios/swiftpm/Variables-2.3.0/KarteVariables.xcframework.zip", checksum: "1cf146b905825c59b7ce5590a8dd20a73ad887f929563c1ff5aa486b4c188626"
        ),
        .binaryTarget(
            name: "KarteVisualTracking", url: "https://sdk.karte.io/ios/swiftpm/VisualTracking-2.8.0/KarteVisualTracking.xcframework.zip", checksum: "1a71e7ac59d31a9632f01b982fd663b706ea0a8e4d90576f039ef7a4ce8ca2b0"
        ),
        .binaryTarget(
            name: "KarteRemoteNotification", url: "https://sdk.karte.io/ios/swiftpm/RemoteNotification-2.6.0/KarteRemoteNotification.xcframework.zip", checksum: "cd571abd67a038f5d79aeb6692fc0d00c95ebd7741d0fe950c49f5dda867fe81"
        ),
        .binaryTarget(
            name: "KarteCrashReporting", url: "https://sdk.karte.io/ios/swiftpm/CrashReporting-2.4.0/KarteCrashReporting.xcframework.zip", checksum: "a0261cc0eaa98017f6439fc8f83fe9373c338aae5777fb6d52558ccfce0472cd"
        ),
        .target(
            name: "KarteCrashReportingTarget", 
            dependencies: ["PLCrashReporter", "KarteCrashReporting"],
            path: "KarteCrashReporting/SwiftPM"
        ),
        .binaryTarget(
            name: "KarteNotificationServiceExtension", url: "https://sdk.karte.io/ios/swiftpm/NotificationServiceExtension-1.0.0/KarteNotificationServiceExtension.xcframework.zip", checksum: "91310af814444d2a70f5cb390d64f8f73fe1b7e943e759326cd58a8152b988c9"
        ),
    ]
)
