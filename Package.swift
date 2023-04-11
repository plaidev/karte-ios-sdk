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
        .package(name: "PLCrashReporter", url: "https://github.com/plaidev/PLCrashReporter.git", from: "1.8.2-spm")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .binaryTarget(
            name: "KarteUtilities", url: "https://sdk.karte.io/ios/swiftpm/Utilities-3.8.0/KarteUtilities.xcframework.zip", checksum: "25a79be34f4ce6674dee005e4dfe68f05992f7a29dfc9d5e423b34b6fb1c7c00"
        ),
        .binaryTarget(
            name: "KarteCore", url: "https://sdk.karte.io/ios/swiftpm/Core-2.22.0/KarteCore.xcframework.zip", checksum: "1ab30a737d892650ab5decd08a319f64c5d584f19c33500dcabe35acdcf462dc"
        ),
        .binaryTarget(
            name: "KarteInAppMessaging", url: "https://sdk.karte.io/ios/swiftpm/InAppMessaging-2.14.0/KarteInAppMessaging.xcframework.zip", checksum: "c7a59febf5d41a45bc72aa3de9e25239c7ebef9be780ecbafdada975edc84d72"
        ),
        .binaryTarget(
            name: "KarteVariables", url: "https://sdk.karte.io/ios/swiftpm/Variables-2.5.0/KarteVariables.xcframework.zip", checksum: "429e479e32e4d0d0cb63569e75d0d81e1b756fba5fde21d95d353cf8e241ab92"
        ),
        .binaryTarget(
            name: "KarteVisualTracking", url: "https://sdk.karte.io/ios/swiftpm/VisualTracking-2.10.0/KarteVisualTracking.xcframework.zip", checksum: "7833a1e1b27f5df6cab28d2e9520db0ee473286ef70fc044af42089f39b29f38"
        ),
        .binaryTarget(
            name: "KarteInbox", url: "https://sdk.karte.io/ios/swiftpm/Inbox-0.1.0/KarteInbox.xcframework.zip", checksum: "09850b4f66bca44e95e6cd3f15cd42a56137d6b4143108a8ac33b6b49aff3920"
        ),
        .binaryTarget(
            name: "KarteRemoteNotification", url: "https://sdk.karte.io/ios/swiftpm/RemoteNotification-2.9.0/KarteRemoteNotification.xcframework.zip", checksum: "17a9aaee633786ce2a7c004640ba71ebcd94e1df390bc5f92cea10184f103cfa"
        ),
        .binaryTarget(
            name: "KarteCrashReporting", url: "https://sdk.karte.io/ios/swiftpm/CrashReporting-2.4.0/KarteCrashReporting.xcframework.zip", checksum: "ab53a6706a67f231be8ceca19859170858f721d3f9cf8bab8b99f2ace6852e76"
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
