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
            name: "KarteUtilities", url: "https://sdk.karte.io/ios/swiftpm/Utilities-3.15.0/KarteUtilities-6a83b84d.xcframework.zip", checksum: "95b17c4ce40f8579f355ef185b5f353e06e46d5bfd401328823f01773b156596"
        ),
        .binaryTarget(
            name: "KarteCore", url: "https://sdk.karte.io/ios/swiftpm/Core-2.38.0/KarteCore-6a83b84d.xcframework.zip", checksum: "951a6c6e10fc5277a04f9a613798f7af7a1b4006f7622c062199b41c71509ded"
        ),
        .binaryTarget(
            name: "KarteInAppMessaging", url: "https://sdk.karte.io/ios/swiftpm/InAppMessaging-2.28.0/KarteInAppMessaging-6a83b84d.xcframework.zip", checksum: "597b381a615aa3b4b7a1d834ca04209372b183719b8474753eacdfa281e39c1e"
        ),
        .binaryTarget(
            name: "KarteVariables", url: "https://sdk.karte.io/ios/swiftpm/Variables-2.14.0/KarteVariables-6a83b84d.xcframework.zip", checksum: "4f5d5f3a947247d473bd20843a7208351e3743102e302caccd032e643ead2054"
        ),
        .binaryTarget(
            name: "KarteVisualTracking", url: "https://sdk.karte.io/ios/swiftpm/VisualTracking-2.15.0/KarteVisualTracking-6a83b84d.xcframework.zip", checksum: "9f6dbccbe3744e0b10d96b9f0478237218c1585aa926e2761827563de083c0bd"
        ),
        .binaryTarget(
            name: "KarteInbox", url: "https://sdk.karte.io/ios/swiftpm/Inbox-0.5.0/KarteInbox-6a83b84d.xcframework.zip", checksum: "c8f81a833925b019c1e9c1b5bc10c5e85d085202e8df8eb2aee22cf5d17dca7c"
        ),
        .binaryTarget(
            name: "KarteInAppFrame", url: "https://sdk.karte.io/ios/swiftpm/InAppFrame-0.8.0/KarteInAppFrame-6a83b84d.xcframework.zip", checksum: "c9f0a99c7eb829054e142e34698062c4c112c5d8a6b827143cf55e4396f2e81d"
        ),
        .binaryTarget(
            name: "KarteRemoteNotification", url: "https://sdk.karte.io/ios/swiftpm/RemoteNotification-2.15.0/KarteRemoteNotification-6a83b84d.xcframework.zip", checksum: "64c7704dd896cbce205bd3c9a1b3072ce0919e6d580961d4ca743b3fc7628386"
        ),
        .binaryTarget(
            name: "KarteCrashReporting", url: "https://sdk.karte.io/ios/swiftpm/CrashReporting-2.12.0/KarteCrashReporting-6a83b84d.xcframework.zip", checksum: "99306c03fc5d70efd87ae3d8a60b8a3125ab6cc39f7c489677cb18c1f7714384"
        ),
        .target(
            name: "KarteCrashReportingTarget", 
            dependencies: ["KarteCrashReporter", "KarteCrashReporting"],
            path: "KarteCrashReporting/SwiftPM"
        ),
        .binaryTarget(
            name: "KarteNotificationServiceExtension", url: "https://sdk.karte.io/ios/swiftpm/NotificationServiceExtension-1.4.0/KarteNotificationServiceExtension-6a83b84d.xcframework.zip", checksum: "6151894a8a55909dab9036e8b4499afcc1be0e1f162b5b345a060747add4f658"
        ),
        .binaryTarget(
            name: "KarteDebugger", url: "https://sdk.karte.io/ios/swiftpm/Debugger-1.2.0/KarteDebugger-6a83b84d.xcframework.zip", checksum: "487b6c747a31cfaa61600c8924b1d61b025f84d4c1bf13f6768c4cefd8fda71d"
        ),
    ]
)
