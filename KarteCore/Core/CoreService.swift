//
//  Copyright 2020 PLAID, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      https://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import KarteUtilities
import AppTrackingTransparency

internal class CoreService {
    lazy var appInfo: AppInfo = {
        AppInfo()
    }()

    lazy var pvService: PvService = {
        PvService()
    }()
    lazy var versionService: VersionService = {
        VersionService()
    }()

    private lazy var visitorIdService: VisitorIdService = {
        VisitorIdService()
    }()
    private lazy var optOutService: OptOutService = {
        OptOutService(configuration: configuration)
    }()
    private var _configuration: Configuration

    var configuration: Configuration {
        // swiftlint:disable:next force_cast
        return _configuration.copy() as! Configuration
    }

    var visitorId: String {
        visitorIdService.visitorId
    }

    var isEnabled: Bool {
        guard configuration._appKey.isValid else {
            let errorMessage = "Invalid APP_KEY is set: \(configuration._appKey.value)"
            assertionFailure(errorMessage)
            Logger.error(tag: .core, message: errorMessage)
            return false
        }

        guard isSupportedOsVersion else {
            Logger.info(tag: .core, message: "Initializing was canceled because os version is under 9.0.0.")
            return false
        }

        guard hasValidSelector else {
            Logger.error(tag: .core, message: "Initializing was canceled because can not find valid selector sdk needed.")
            return false
        }

        guard !configuration.isDryRun else {
            Logger.warn(tag: .core, message: "======================================================================")
            Logger.warn(tag: .core, message: "Running mode is dry run.")
            Logger.warn(tag: .core, message: "======================================================================\n")
            return false
        }

        guard !JailbreakDetection.isJailbroken else {
            Logger.warn(tag: .core, message: "Cancel initialization because a device jailbreak has been detected.")
            return false
        }

        return true
    }

    var isSupportedOsVersion: Bool {
        let version = OperatingSystemVersion(majorVersion: 9, minorVersion: 0, patchVersion: 0)
        return ProcessInfo.processInfo.isOperatingSystemAtLeast(version)
    }

    var installationStatus: InstallationStatus {
        versionService.installationStatus
    }

    var isOptOut: Bool {
        optOutService.isOptOut
    }

    var hasValidSelector: Bool {
        Resolver.resolve(SelectorDetector.self).detect()
    }

    init(configuration: Configuration) {
        self._configuration = configuration.copy() as! Configuration
        // swiftlint:disable:previous force_cast
    }

    func optIn() {
        optOutService.optIn()
    }

    func optOut() {
        optOutService.optOut()
    }

    func optOutTemporarily() {
        optOutService.optOutTemporarily()
    }

    func renewVisitorId() {
        visitorIdService.renew()
    }

    @available(iOS 14, *)
    func sendATTStatus(attStatus: ATTrackingManager.AuthorizationStatus) {
        ATTService.sendATTStatus(attStatus: attStatus)
    }

    func teardown() {
        visitorIdService.clean()
        versionService.clean()

        if let name = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: name)
            UserDefaults.standard.synchronize()
        }

        KarteApp.libraries.forEach { library in
            library.unconfigure(app: KarteApp.shared)
        }
    }

    deinit {
    }
}

extension Resolver {
    static func registerSelectorDetector() {
        let selectorDetector = DefaultSelectorDetector()
        register { selectorDetector as SelectorDetector }
    }
}
