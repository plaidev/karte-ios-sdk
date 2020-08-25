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

/// ログを出力するための構造体です。
public struct Logger {
    /// タグを定義するための構造体です。
    public struct Tag {
        var rawValue: String
        var version: String

        /// タグを生成します。
        /// - Parameters:
        ///   - rawValue: タグ名
        ///   - bundle: リソースバンドル
        public init(_ rawValue: String, bundle: Bundle) {
            self.rawValue = rawValue
            self.version = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?"
        }

        /// タグを生成します。
        /// - Parameters:
        ///   - rawValue: タグ名
        ///   - version: バージョン
        public init(_ rawValue: String, version: String) {
            self.rawValue = rawValue
            self.version = version
        }
    }

    struct Log {
        let level: LogLevel
        let tag: Tag
        let message: String
        let file: String
        let function: String
        let line: Int
    }

    private static var shared = Logger()

    var level: LogLevel = .error
    var isEnabled: Bool = true
    let appenders: [LogAppender] = [ConsoleLogAppender(), FileLogAppender()]

    private init() {
    }
}

extension Logger {
    /// ログレベルの取得および設定を行います。
    public static var level: LogLevel {
        get {
            shared.level
        }
        set {
            shared.level = newValue
        }
    }

    /// ログ出力有無の取得および設定を行います。
    public static var isEnabled: Bool {
        get {
            shared.isEnabled
        }
        set {
            shared.isEnabled = newValue
        }
    }

    /// ログ(Error)を出力します。
    /// - Parameters:
    ///   - tag: タグ
    ///   - message: メッセージ
    ///   - file: ファイル名
    ///   - function: 関数名
    ///   - line: 行番号
    public static func error(tag: Tag, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(.error, tag: tag, message: message, file: file, function: function, line: line)
    }

    /// ログ(Warn)を出力します。
    /// - Parameters:
    ///   - tag: タグ
    ///   - message: メッセージ
    ///   - file: ファイル名
    ///   - function: 関数名
    ///   - line: 行番号
    public static func warn(tag: Tag, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(.warn, tag: tag, message: message, file: file, function: function, line: line)
    }

    /// ログ(Info)を出力します。
    /// - Parameters:
    ///   - tag: タグ
    ///   - message: メッセージ
    ///   - file: ファイル名
    ///   - function: 関数名
    ///   - line: 行番号
    public static func info(tag: Tag, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(.info, tag: tag, message: message, file: file, function: function, line: line)
    }

    /// ログ(Debug)を出力します。
    /// - Parameters:
    ///   - tag: タグ
    ///   - message: メッセージ
    ///   - file: ファイル名
    ///   - function: 関数名
    ///   - line: 行番号
    public static func debug(tag: Tag, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(.debug, tag: tag, message: message, file: file, function: function, line: line)
    }

    /// ログ(Verbose)を出力します。
    /// - Parameters:
    ///   - tag: タグ
    ///   - message: メッセージ
    ///   - file: ファイル名
    ///   - function: 関数名
    ///   - line: 行番号
    public static func verbose(tag: Tag, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(.verbose, tag: tag, message: message, file: file, function: function, line: line)
    }

    private func log(_ level: LogLevel, tag: Tag, message: String, file: String, function: String, line: Int) {
        // swiftlint:disable:previous function_parameter_count
        let log = Log(level: level, tag: tag, message: message, file: file, function: function, line: line)
        appenders.forEach {
            $0.append(log)
        }
    }
}
