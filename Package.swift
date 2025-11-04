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
            name: "KarteCore", url: "https://sdk.karte.io/ios/swiftpm/Core-2.33.0/KarteCore.xcframework.zip", checksum: "3434f62755ab99b6f8221fd725ec4af82547a580bf74b2200cec9a93a348ee30"
        ),
        .binaryTarget(
            name: "KarteInAppMessaging", url: "https://sdk.karte.io/ios/swiftpm/InAppMessaging-2.24.0/KarteInAppMessaging.xcframework.zip", checksum: "bee9e8be783bae375c1110b5830ddd76834eee672abdf05d1261c8a5bf9e6f11"
        ),
        .binaryTarget(
            name: "KarteVariables", url: "https://sdk.karte.io/ios/swiftpm/Variables-2.13.0/KarteVariables.xcframework.zip", checksum: "ff0160de60f16e6a4cef8ae7a2d9da7470d189923ddf673e9327cf443a7f5318"
        ),
        .binaryTarget(
            name: "KarteVisualTracking", url: "https://sdk.karte.io/ios/swiftpm/VisualTracking-2.14.0/KarteVisualTracking.xcframework.zip", checksum: "72a0b9233e5bee78b9b9972fbdf9c0ab88e0377351557400285526b379ab53e8"
        ),
        .binaryTarget(
            name: "KarteInbox", url: "https://sdk.karte.io/ios/swiftpm/Inbox-0.3.1/KarteInbox.xcframework.zip", checksum: "73bf408c03cfcd1ff20a677864dca6d3c52e889766dc7402e7b96fc5492f8ad0"
        ),
        .binaryTarget(
            name: "KarteInAppFrame", url: "https://sdk.karte.io/ios/swiftpm/InAppFrame-0.6.0/KarteInAppFrame.xcframework.zip", checksum: "a9b1f8741f590efbc5f5fae4e0d1959b6bd58d02ad8504e2b0a36b8163940fe9"
        ),
        .binaryTarget(
            name: "KarteRemoteNotification", url: "https://sdk.karte.io/ios/swiftpm/RemoteNotification-2.13.0/KarteRemoteNotification.xcframework.zip", checksum: "713a2777cfc218810a0c19594f2bc8b55e7e7530c63b5a12d9df233e2c19b549"
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
