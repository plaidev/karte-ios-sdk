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
            name: "KarteUtilities", url: "https://sdk.karte.io/ios/swiftpm/Utilities-3.6.0/KarteUtilities.xcframework.zip", checksum: "8bb2d6a2cf4145af2cb2e42ef452163d3e545b2793086c73d713519db7530fea"
        ),
        .binaryTarget(
            name: "KarteCore", url: "https://sdk.karte.io/ios/swiftpm/Core-2.19.0/KarteCore.xcframework.zip", checksum: "8cda79b1da87baa4c198cce9299ebfa5bae7e7be5bb1914a30bbd9650210c057"
        ),
        .binaryTarget(
            name: "KarteInAppMessaging", url: "https://sdk.karte.io/ios/swiftpm/InAppMessaging-2.10.1/KarteInAppMessaging.xcframework.zip", checksum: "099fc0db4f0b49f244c45a6a74f4859ef7004efb51afe0f8d5623f788268e06d"
        ),
        .binaryTarget(
            name: "KarteVariables", url: "https://sdk.karte.io/ios/swiftpm/Variables-2.3.0/KarteVariables.xcframework.zip", checksum: "3b01304607aa2679d1caef4a2bab8acd4559179f8f7f3eec1f775953dc8da055"
        ),
        .binaryTarget(
            name: "KarteVisualTracking", url: "https://sdk.karte.io/ios/swiftpm/VisualTracking-2.8.0/KarteVisualTracking.xcframework.zip", checksum: "c4391bd1b9b2d7401a3ef8affda844902fce68669c7d9f0d2109aa8deaee0538"
        ),
        .binaryTarget(
            name: "KarteRemoteNotification", url: "https://sdk.karte.io/ios/swiftpm/RemoteNotification-2.6.0/KarteRemoteNotification.xcframework.zip", checksum: "ecc561475a95fa056058ef589695f657ce5735a4aafba7c1fe73ba33f0c870b6"
        ),
        .binaryTarget(
            name: "KarteCrashReporting", url: "https://sdk.karte.io/ios/swiftpm/CrashReporting-2.4.0/KarteCrashReporting.xcframework.zip", checksum: "a3451651ba6f14fde831ac81cebd121fc6666664df33573b2993eec2f449ffe9"
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
