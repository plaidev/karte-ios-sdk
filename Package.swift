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
        .package(name: "KarteCrashReporter", url: "https://github.com/plaidev/KartePLCrashReporter.git", from: "1.12.0-patch")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "KarteUtilities", url: "https://sdk.karte.io/ios/swiftpm/Utilities-3.13.0/KarteUtilities.xcframework.zip", checksum: "bf95dd251d14ae8454288e933027003a24c346f353ee9b95839547a7b2494f52"
        ),
        .binaryTarget(
            name: "KarteCore", url: "https://sdk.karte.io/ios/swiftpm/Core-2.31.0/KarteCore.xcframework.zip", checksum: "27601a067657a566ed3a73d508480ffd2645e118b730f4ccf502d31cb2cd92bf"
        ),
        .binaryTarget(
            name: "KarteInAppMessaging", url: "https://sdk.karte.io/ios/swiftpm/InAppMessaging-2.20.0/KarteInAppMessaging.xcframework.zip", checksum: "6b0dee2f2bd2a110bc137724788ec5bf47681f2f4d09ab0a3589c68f41415c0d"
        ),
        .binaryTarget(
            name: "KarteVariables", url: "https://sdk.karte.io/ios/swiftpm/Variables-2.12.0/KarteVariables.xcframework.zip", checksum: "742912209afab7bcad05e6689723656be139c99faa34ee2734c1c1b3c38797ac"
        ),
        .binaryTarget(
            name: "KarteVisualTracking", url: "https://sdk.karte.io/ios/swiftpm/VisualTracking-2.13.0/KarteVisualTracking.xcframework.zip", checksum: "7f6c64d486f9433e13bd39bf70f2cd76216feccdce1dee5bda69b7c6ff3f4d5f"
        ),
        .binaryTarget(
            name: "KarteInbox", url: "https://sdk.karte.io/ios/swiftpm/Inbox-0.2.0/KarteInbox.xcframework.zip", checksum: "c70c0d81941a7050d3850cc4bb1feade5990497268c0a9eec488a0e071e136c1"
        ),
        .binaryTarget(
            name: "KarteInAppFrame", url: "https://sdk.karte.io/ios/swiftpm/InAppFrame-0.5.0/KarteInAppFrame.xcframework.zip", checksum: "f7e9b443496ce0a7922cde9ff34f92948e8d4aa4e255d9aeccc4a9dc0f8dd15d"
        ),
        .binaryTarget(
            name: "KarteRemoteNotification", url: "https://sdk.karte.io/ios/swiftpm/RemoteNotification-2.12.0/KarteRemoteNotification.xcframework.zip", checksum: "3efa4b98132f9fe04db00bd67d39e28ef8e10b695035b0a8fc716db892d0ff9a"
        ),
        .binaryTarget(
            name: "KarteCrashReporting", url: "https://sdk.karte.io/ios/swiftpm/CrashReporting-2.9.0/KarteCrashReporting.xcframework.zip", checksum: "583ce6969d60f8b5c543e21a8d08461b83c3e59d3d941499df03ddd2bc697b97"
        ),
        .target(
            name: "KarteCrashReportingTarget", 
            dependencies: ["KarteCrashReporter", "KarteCrashReporting"],
            path: "KarteCrashReporting/SwiftPM"
        ),
        .binaryTarget(
            name: "KarteNotificationServiceExtension", url: "https://sdk.karte.io/ios/swiftpm/NotificationServiceExtension-1.2.0/KarteNotificationServiceExtension.xcframework.zip", checksum: "6810dc9af039b44c84d2ef2535cc6050ed0917a57d236e7a7d0dddae6e9d15b4"
        ),
        .binaryTarget(
            name: "KarteDebugger", url: "https://sdk.karte.io/ios/swiftpm/Debugger-1.0.0/KarteDebugger.xcframework.zip", checksum: "32743826471f9252e6069415b0218bccacccf70d3af842841cf83dba4dacbfbe"
        ),
    ]
)
