//
//  Copyright 2023 PLAID, Inc.
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
import UIKit

struct JailbreakDetection {
    static var isJailbroken: Bool {
        #if !targetEnvironment(simulator)
        if isFileExists(atPath: "/Applications/Cydia.app") {
            return true
        }
        if isFileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib") {
            return true
        }
        if isFileExists(atPath: "/bin/bash") {
            return true
        }
        if isFileExists(atPath: "/usr/sbin/sshd") {
            return true
        }
        if isFileExists(atPath: "/etc/apt") {
            return true
        }
        if isFileExists(atPath: "/usr/bin/ssh") {
            return true
        }

        // Check if the app can access outside of its sandbox
        if (try? ".".write(toFile: "/private/jailbreak.txt", atomically: true, encoding: .utf8)) != nil {
            return true
        }

        // Check if the app can open a Cydia's URL scheme
        if let url = URL(string: "cydia://package/com.example.package"), UIApplication.shared.canOpenURL(url) {
            return true
        }
        #endif

        return false
    }

    static func isFileExists(atPath path: String) -> Bool {
        let handle = fopen(path, "r")
        guard handle == nil else {
            fclose(handle)
            return true
        }
        return FileManager.default.fileExists(atPath: path)
    }
}
