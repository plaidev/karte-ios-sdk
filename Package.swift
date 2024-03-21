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
            name: "KarteUtilities", url: "https://sdk.karte.io/ios/swiftpm/Utilities-3.12.0/KarteUtilities.xcframework.zip", checksum: "850abc71a8bc28e415f4b11e3072ff741a1d908c13b951a4676bc2e675eaf634"
        ),
        .binaryTarget(
            name: "KarteCore", url: "https://sdk.karte.io/ios/swiftpm/Core-2.26.0/KarteCore.xcframework.zip", checksum: "dfde8c87cac44f7121ae462383f338ab45b980fab2bc35f667f03fad1f2e25ba"
        ),
        .binaryTarget(
            name: "KarteInAppMessaging", url: "https://sdk.karte.io/ios/swiftpm/InAppMessaging-2.17.0/KarteInAppMessaging.xcframework.zip", checksum: "a4c9bf7c72902d69801026bdc47351f21690b8c6168d29b2bc2d3f9babd46dc9"
        ),
        .binaryTarget(
            name: "KarteVariables", url: "https://sdk.karte.io/ios/swiftpm/Variables-2.8.0/KarteVariables.xcframework.zip", checksum: "2bc86b4bd691e7231bc46cdd76bf1969c50470a0c577051aa8a996bac97aa45d"
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
            name: "KarteCrashReporting", url: "https://sdk.karte.io/ios/swiftpm/CrashReporting-2.7.1/KarteCrashReporting.xcframework.zip", checksum: "392e8e53e32c217657de1c14f6bbe975f0a86ebaf1a3b005825261e56f17e2bd"
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
