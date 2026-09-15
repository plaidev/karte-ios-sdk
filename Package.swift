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
            name: "KarteUtilities", url: "https://sdk.karte.io/ios/swiftpm/Utilities-3.16.0/KarteUtilities-6aa9d244.xcframework.zip", checksum: "bf2bb62807bbe95a7c31e7ca818b83e17b2c2ba077f4c40ab6aad2827fe0be2c"
        ),
        .binaryTarget(
            name: "KarteCore", url: "https://sdk.karte.io/ios/swiftpm/Core-2.39.0/KarteCore-6aa9d244.xcframework.zip", checksum: "022a97fab95379da5d295db02b29f402b0445d7104715399d0b24d3e2324dc11"
        ),
        .binaryTarget(
            name: "KarteInAppMessaging", url: "https://sdk.karte.io/ios/swiftpm/InAppMessaging-2.29.0/KarteInAppMessaging-6aa9d244.xcframework.zip", checksum: "4deff9e61fe7956902ec370966f38d769bd6fd779f144de8d8dcae3c72fb4b2e"
        ),
        .binaryTarget(
            name: "KarteVariables", url: "https://sdk.karte.io/ios/swiftpm/Variables-2.15.0/KarteVariables-6aa9d244.xcframework.zip", checksum: "deb043932b322eb3c9d2311d244abf3317ed9c7499ae8ce77aabb46c0a08aac4"
        ),
        .binaryTarget(
            name: "KarteVisualTracking", url: "https://sdk.karte.io/ios/swiftpm/VisualTracking-2.16.0/KarteVisualTracking-6aa9d244.xcframework.zip", checksum: "42e570528dcc3227a162b709f6e38e035b69299552728fe8acb6e8c89775b25f"
        ),
        .binaryTarget(
            name: "KarteInbox", url: "https://sdk.karte.io/ios/swiftpm/Inbox-0.5.0/KarteInbox-6a83b84d.xcframework.zip", checksum: "c8f81a833925b019c1e9c1b5bc10c5e85d085202e8df8eb2aee22cf5d17dca7c"
        ),
        .binaryTarget(
            name: "KarteInAppFrame", url: "https://sdk.karte.io/ios/swiftpm/InAppFrame-0.9.0/KarteInAppFrame-6aa9d244.xcframework.zip", checksum: "009188bb104d5a98c944f702df683524b2e81a60a8a6c340c009a45d1bb0b9aa"
        ),
        .binaryTarget(
            name: "KarteRemoteNotification", url: "https://sdk.karte.io/ios/swiftpm/RemoteNotification-2.16.0/KarteRemoteNotification-6aa9d244.xcframework.zip", checksum: "1ac456bc6b75b72562db30e128b19cdd82ede90e24f3e2ee5981ca02429a2f5a"
        ),
        .binaryTarget(
            name: "KarteCrashReporting", url: "https://sdk.karte.io/ios/swiftpm/CrashReporting-2.13.0/KarteCrashReporting-6aa9d244.xcframework.zip", checksum: "1549e7fddc4e5c067cf4c1f774de7047cb932121d49b6520eb34c984b5c7ca29"
        ),
        .target(
            name: "KarteCrashReportingTarget", 
            dependencies: ["KarteCrashReporter", "KarteCrashReporting"],
            path: "KarteCrashReporting/SwiftPM"
        ),
        .binaryTarget(
            name: "KarteNotificationServiceExtension", url: "https://sdk.karte.io/ios/swiftpm/NotificationServiceExtension-1.5.0/KarteNotificationServiceExtension-6aa9d244.xcframework.zip", checksum: "ee39d31915f8035165a83b1e493f7063ea95e17371de590eed5780af80d86ef8"
        ),
        .binaryTarget(
            name: "KarteDebugger", url: "https://sdk.karte.io/ios/swiftpm/Debugger-1.3.0/KarteDebugger-6aa9d244.xcframework.zip", checksum: "3bb92d13a6fe2d6538917c5f069db833bbd9f06fe2e0150c41c4f5930de0548a"
        ),
    ]
)
