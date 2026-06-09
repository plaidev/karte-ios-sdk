// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Karte",
    platforms: [
        .iOS(.v15)
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
            name: "KarteInbox",
            targets: ["KarteInbox", "KarteCore", "KarteUtilities"]
        ),
        .library(
            name: "KarteInAppFrame",
            targets: ["KarteInAppFrame", "KarteCore", "KarteVariables", "KarteUtilities"]
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
        ),
        .library(
            name: "KarteDebugger",
            targets: ["KarteDebugger", "KarteCore", "KarteUtilities"]
        ),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "KarteCrashReporter", url: "https://github.com/plaidev/KartePLCrashReporter.git", from: "1.13.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "KarteUtilities", url: "https://sdk.karte.io/ios/swiftpm/Utilities-3.14.0/KarteUtilities.xcframework.zip", checksum: "4deded76d6d2e4ba46f95091ed0e9cfe27c7bdb0262c584f79316ca8d42ee132"
        ),
        .binaryTarget(
            name: "KarteCore", url: "https://sdk.karte.io/ios/swiftpm/Core-2.36.0/KarteCore.xcframework.zip", checksum: "b15a109b07f9b9bf40dd4d63c57d7533801cc64d909ab85fca0c0d7a593da84f"
        ),
        .binaryTarget(
            name: "KarteInAppMessaging", url: "https://sdk.karte.io/ios/swiftpm/InAppMessaging-2.26.0/KarteInAppMessaging.xcframework.zip", checksum: "a6af8805a220ba59d21ab55ce3c42808a62d851b1aba2d674381c152c22d52d1"
        ),
        .binaryTarget(
            name: "KarteVariables", url: "https://sdk.karte.io/ios/swiftpm/Variables-2.13.0/KarteVariables.xcframework.zip", checksum: "ff0160de60f16e6a4cef8ae7a2d9da7470d189923ddf673e9327cf443a7f5318"
        ),
        .binaryTarget(
            name: "KarteVisualTracking", url: "https://sdk.karte.io/ios/swiftpm/VisualTracking-2.14.0/KarteVisualTracking.xcframework.zip", checksum: "72a0b9233e5bee78b9b9972fbdf9c0ab88e0377351557400285526b379ab53e8"
        ),
        .binaryTarget(
            name: "KarteInbox", url: "https://sdk.karte.io/ios/swiftpm/Inbox-0.4.0/KarteInbox.xcframework.zip", checksum: "08b48fa294ef655d413e8e957c2e20af74026d169df06619cbe2ed23141bbf78"
        ),
        .binaryTarget(
            name: "KarteInAppFrame", url: "https://sdk.karte.io/ios/swiftpm/InAppFrame-0.7.0/KarteInAppFrame.xcframework.zip", checksum: "495c2837fb10870ede607de7658c40dd9dd2d9e0f0230531067ddee77cf25654"
        ),
        .binaryTarget(
            name: "KarteRemoteNotification", url: "https://sdk.karte.io/ios/swiftpm/RemoteNotification-2.14.0/KarteRemoteNotification.xcframework.zip", checksum: "3cee3bd3685b4a9f52fdd67fddfed5891d611094408a3f2fdfe9247797b690c2"
        ),
        .binaryTarget(
            name: "KarteCrashReporting", url: "https://sdk.karte.io/ios/swiftpm/CrashReporting-2.11.1/KarteCrashReporting.xcframework.zip", checksum: "f5bdec2ff6ce6f1dc5e132e61fe1e62bad924512b3e3e05eba05d1be26a1f4f6"
        ),
        .target(
            name: "KarteCrashReportingTarget", 
            dependencies: ["KarteCrashReporter", "KarteCrashReporting"],
            path: "KarteCrashReporting/SwiftPM"
        ),
        .binaryTarget(
            name: "KarteNotificationServiceExtension", url: "https://sdk.karte.io/ios/swiftpm/NotificationServiceExtension-1.3.0/KarteNotificationServiceExtension.xcframework.zip", checksum: "076f1b36be2e9fe38a16bb1a3483e81debdc9bfc83d443e095242fb71558197c"
        ),
        .binaryTarget(
            name: "KarteDebugger", url: "https://sdk.karte.io/ios/swiftpm/Debugger-1.1.0/KarteDebugger.xcframework.zip", checksum: "b6e36115db49f20f7bb4077f041c3cd3c46cdf7c70cdfb03b24e499c0b9d8502"
        ),
    ]
)
