// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Karte",
    platforms: [
        .iOS(.v12)
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
        .package(name: "PLCrashReporter", url: "https://github.com/plaidev/PLCrashReporter.git", from: "1.11.0-patch")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "KarteUtilities", url: "https://sdk.karte.io/ios/swiftpm/Utilities-3.10.0/KarteUtilities.xcframework.zip", checksum: "7c105587bc17c73aa88127cd46d11a1925a61cb3ddf8bf5e5b3524fd5fabae25"
        ),
        .binaryTarget(
            name: "KarteCore", url: "https://sdk.karte.io/ios/swiftpm/Core-2.24.0/KarteCore.xcframework.zip", checksum: "ebd5a8b1b371c8ccb069acbd196527760c81e3981d9760493330e5312c30593a"
        ),
        .binaryTarget(
            name: "KarteInAppMessaging", url: "https://sdk.karte.io/ios/swiftpm/InAppMessaging-2.16.0/KarteInAppMessaging.xcframework.zip", checksum: "bc9cbd169afaa81e9fcf18c0da6be2a2554e0f01fd51d63c9cee33db28562314"
        ),
        .binaryTarget(
            name: "KarteVariables", url: "https://sdk.karte.io/ios/swiftpm/Variables-2.7.0/KarteVariables.xcframework.zip", checksum: "497fae7d76d4dc1b35fab38557e8d66e4d1ac7b750b353c69917dcf949073865"
        ),
        .binaryTarget(
            name: "KarteVisualTracking", url: "https://sdk.karte.io/ios/swiftpm/VisualTracking-2.12.0/KarteVisualTracking.xcframework.zip", checksum: "03364a75282667223acd96c4132afd173e12cf6da6f87a98855842d5e8d2c605"
        ),
        .binaryTarget(
            name: "KarteInbox", url: "https://sdk.karte.io/ios/swiftpm/Inbox-0.1.0/KarteInbox.xcframework.zip", checksum: "09850b4f66bca44e95e6cd3f15cd42a56137d6b4143108a8ac33b6b49aff3920"
        ),
        .binaryTarget(
            name: "KarteRemoteNotification", url: "https://sdk.karte.io/ios/swiftpm/RemoteNotification-2.11.0/KarteRemoteNotification.xcframework.zip", checksum: "58bde3ca6ff813de18787b9dbe3b3b4e3ff9ddbe1713fb941b6be6d34a196ef6"
        ),
        .binaryTarget(
            name: "KarteCrashReporting", url: "https://sdk.karte.io/ios/swiftpm/CrashReporting-2.7.0/KarteCrashReporting.xcframework.zip", checksum: "fb5432cd2095e7a3f7829c5f5bbd5523f22646c4bff126f02b7f96b888257891"
        ),
        .target(
            name: "KarteCrashReportingTarget", 
            dependencies: ["PLCrashReporter", "KarteCrashReporting"],
            path: "KarteCrashReporting/SwiftPM"
        ),
        .binaryTarget(
            name: "KarteNotificationServiceExtension", url: "https://sdk.karte.io/ios/swiftpm/NotificationServiceExtension-1.2.0/KarteNotificationServiceExtension.xcframework.zip", checksum: "6810dc9af039b44c84d2ef2535cc6050ed0917a57d236e7a7d0dddae6e9d15b4"
        ),
    ]
)
