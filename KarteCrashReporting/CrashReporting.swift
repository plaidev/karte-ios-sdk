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
import KarteCore
import KarteCrashReporter

/// CrashReportingモジュールクラスです。
@objc(KRTCrashReporting)
public class CrashReporting: NSObject {
    private static let shared = CrashReporting()
    private var crashReporter: KRTPLCrashReporter?

    /// ローダークラスが Objective-Cランライムに追加されたタイミングで呼び出されるメソッドです。
    /// 本メソッドが呼び出されたタイミングで、`KarteApp` クラスに本クラスをライブラリとして登録します。
    @objc
    public class func _krt_load() {
        KarteApp.register(library: self)
    }

    deinit {
    }
}

extension CrashReporting: Library {
    public static var name: String {
        "crash_reporting"
    }

    public static var version: String {
        KRTCrashReportingCurrentLibraryVersion()
    }

    public static var isPublic: Bool {
        true
    }

    public static func configure(app: KarteApp) {
        shared.configure(app: app)
        shared.report()
    }

    public static func unconfigure(app: KarteApp) {
    }
}

extension CrashReporting {
    private var isDebuggerAtacched: Bool {
        var info = kinfo_proc()
        var infoSize = MemoryLayout.size(ofValue: info)
        var name: [Int32] = Array(repeating: 0, count: 4)

        name[0] = CTL_KERN
        name[1] = KERN_PROC
        name[2] = KERN_PROC_PID
        name[3] = getpid()

        if sysctl(&name, 4, &info, &infoSize, nil, 0) == -1 {
            return false
        }

        if (info.kp_proc.p_flag & P_TRACED) == 0 {
            return false
        }

        return true
    }

    private func configure(app: KarteApp) {
        if isDebuggerAtacched {
            Logger.info(tag: .crashReporting, message: "Crash reporter is not enabled because the debugger is attached.")
            return
        }

        let config = KRTPLCrashReporterConfig(
            signalHandlerType: .mach,
            symbolicationStrategy: PLCrashReporterSymbolicationStrategy(rawValue: 0),
            shouldRegisterUncaughtExceptionHandler: true
        )
        guard let crashReporter = KRTPLCrashReporter(configuration: config) else {
            Logger.error(tag: .crashReporting, message: "Failed to initialize crash reporter.")
            return
        }

        do {
            try crashReporter.enableAndReturnError()
            Logger.info(tag: .crashReporting, message: "Enabled crash reporter.")
        } catch {
            Logger.error(tag: .crashReporting, message: "Failed to enable crash reporter. \(error.localizedDescription)")
        }

        self.crashReporter = crashReporter
    }

    private func report() {
        guard let crashReporter = crashReporter, crashReporter.hasPendingCrashReport() else {
            return
        }

        guard let data = try? crashReporter.loadPendingCrashReportDataAndReturnError() else {
            Logger.error(tag: .crashReporting, message: "Failed to load pending crash report.")
            return
        }

        guard let crashReport = try? KRTPLCrashReport(data: data) else {
            Logger.error(tag: .crashReporting, message: "Failed to create crash report.")
            return
        }

        guard let crashEvent = CrashEventConverter.convert(from: crashReport) else {
            return
        }

        Tracker.track(event: crashEvent)
        crashReporter.purgePendingCrashReport()
    }
}

extension Logger.Tag {
    static let crashReporting = Logger.Tag("CRASH", version: KRTCrashReportingCurrentLibraryVersion())
}
