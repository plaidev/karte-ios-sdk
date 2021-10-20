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

private let kBufferSize: Int = 10_000

internal class FileLogAppender: LogAppender {
    private var buffer = ""
    private let queue = DispatchQueue(label: "io.karte.logger.buffer", qos: .background)
    private var collector = LogFileCollector()
    private var layout = DevelopmentLogLayout()

    private var todaySupplier: TodaySupplier
    private var today: Date {
        todaySupplier.today
    }
    private var backgroundTask: BackgroundTask

    init(_ todaySupplier: TodaySupplier = TodaySupplier()) {
        self.todaySupplier = todaySupplier

        self.backgroundTask = BackgroundTask()
        self.backgroundTask.delegate = self
        self.backgroundTask.observeLifecycle()
    }

    func append(_ log: Logger.Log) {
        let message = layout.layout(log)
        let logTime = today.forLog()
        queue.async { [weak self] in
            self?.buffer.append("\(logTime) \(message)\n")
            if let count = self?.buffer.count, count > kBufferSize {
                self?.write()
            }
        }
    }

    private func write() {
        var file = tempFile()
        buffer.append(to: file)
        buffer.removeAll(keepingCapacity: true)
        if !file.isExcludedFromBackup {
            try? file.setIsExcludeFromBackup(true)
        }
    }

    private func flush() {
        queue.async { [weak self] in
            self?.write()
            self?.collector.collect(self?.postFiles() ?? [])
            self?.cleanFiles()
            self?.backgroundTask.finish()
        }
    }

    private func cleanFiles() {
        let files = garbageFiles()
        files.forEach { try? FileManager.default.removeItem(at: $0) }
    }
    deinit {}
}

extension FileLogAppender {
    var logDir: URL {
        let fileManager = FileManager.default
        // swiftlint:disable:next force_try
        let appSupportDir = try! fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        var dir = appSupportDir.appendingPathComponent("io.karte/log", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        if !dir.isExcludedFromBackup {
            try? dir.setIsExcludeFromBackup(true)
        }
        return dir
    }

    func tempFile() -> URL {
        let date = today
        let prefix = date.asPrefix()
        return filesOfLogDirectory().first {
            $0.lastPathComponent.starts(with: prefix)
        } ?? logDir.appendingPathComponent("\(prefix)_\(date.toInt()).log")
    }

    func postFiles() -> [URL] {
        filesOfLogDirectory().filter {
            !$0.lastPathComponent.starts(with: today.asPrefix())
        }
    }

    func garbageFiles() -> [URL] {
        filesOfLogDirectory().filter {
            if let prefix = today.beforeThreeDays()?.asPrefix() {
                return $0.lastPathComponent < prefix
            } else {
                return false
            }
        }
    }

    private func filesOfLogDirectory() -> [URL] {
        (try? FileManager.default.contentsOfDirectory(at: logDir, includingPropertiesForKeys: nil).filter { !$0.isDirectry }) ?? []
    }
}

extension FileLogAppender: BackgroundTaskDelegate {
    func backgroundTaskShouldStart(_ backgroundTask: BackgroundTask) -> Bool {
        true
    }

    func backgroundTaskWillStart(_ backgroundTask: BackgroundTask) {
        flush()
    }

    func backgroundTaskDidFinish(_ backgroundTask: BackgroundTask) {
    }
}

private extension DateFormatter {
    private static func from(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter
    }

    static func forFile() -> DateFormatter {
        from(format: "yyyy-MM-dd")
    }
    static func forLog() -> DateFormatter {
        from(format: "yyyy-MM-dd HH:mm:ss")
    }
}

private extension Date {
    func toInt() -> Int64 {
        Int64(self.timeIntervalSince1970 * 1_000)
    }

    func asPrefix() -> String {
        DateFormatter.forFile().string(from: self)
    }

    func forLog() -> String {
        DateFormatter.forLog().string(from: self)
    }

    func beforeThreeDays() -> Date? {
        Calendar.current.date(byAdding: .day, value: -3, to: self)
    }
}

private extension String {
    func append(to url: URL) {
        data(using: .utf8)?.append(to: url)
    }
}

private extension Data {
    @discardableResult
    func append(to url: URL) -> Bool {
        guard let stream = OutputStream(url: url, append: true) else {
            return false
        }
        stream.open()

        defer {
            stream.close()
        }
        let result = self.withUnsafeBytes {(pointer: UnsafeRawBufferPointer ) -> Int in
            guard let address = pointer.bindMemory(to: UInt8.self).baseAddress else {
                return 0
            }
            return stream.write(address, maxLength: self.count)
        }
        return (result > 0)
    }
}

private extension URL {
    var isDirectry: Bool {
        var isDir: ObjCBool = false
        if FileManager.default.fileExists(atPath: path, isDirectory: &isDir) {
            if isDir.boolValue {
                return true
            }
        }
        return false
    }

    var isExcludedFromBackup: Bool {
        let isbackup = try? resourceValues(forKeys: [.isExcludedFromBackupKey])
        return isbackup?.isExcludedFromBackup ?? false
    }

    mutating func setIsExcludeFromBackup(_ exclude: Bool) throws {
        var value: URLResourceValues = try resourceValues(forKeys: [.isExcludedFromBackupKey])
        value.isExcludedFromBackup = exclude
        try setResourceValues(value)
    }
}
