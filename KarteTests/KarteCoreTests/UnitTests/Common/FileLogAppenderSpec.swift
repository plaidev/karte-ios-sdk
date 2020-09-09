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

import Quick
import Nimble
@testable import KarteCore

class MockTodaySupplier : TodaySupplier{
    override var today: Date {
        let calendar = Calendar(identifier: .gregorian)
        return calendar.date(from: DateComponents(year: 2020, month: 4, day: 10, hour: 21, minute: 0, second: 0))!
    }
}
let todayFile = "2020-04-10_test.log"
let testFiles = ["2020-04-11_test.log","2020-04-09_test.log","2020-04-08_test.log","2020-04-07_test.log","2020-04-06_test.log"]

class FileLogAppenderSpec: QuickSpec {

    override func spec() {
        let fileLogAppender = FileLogAppender(MockTodaySupplier())

        beforeSuite {
            (testFiles + [todayFile]).forEach{
                FileManager.default.createFile(atPath: fileLogAppender.logDir.appendingPathComponent($0).path, contents: nil)
            }
        }
        afterSuite {
            (testFiles + [todayFile]).forEach{
                try? FileManager.default.removeItem(at: fileLogAppender.logDir.appendingPathComponent($0))
            }
        }

        it("working dir is support/io.karte/log") {
            expect(fileLogAppender.logDir.path)
                .to(equal(try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("io.karte/log", isDirectory: true).path))
        }
        it("temp file name starts with 2020-04-10") {
            expect(fileLogAppender.tempFile().lastPathComponent)
            .to(equal(todayFile))
        }
        it("post files contains all test files.") {
            expect(fileLogAppender.postFiles().map{$0.lastPathComponent})
            .to(contain(testFiles))
        }
        it("post files do not contains today's file.") {
            expect(fileLogAppender.postFiles().map{$0.lastPathComponent})
                .notTo(contain(todayFile))
        }
        it("garbage files contains only old files.") {
            expect(fileLogAppender.garbageFiles().map{$0.lastPathComponent})
            .to(contain("2020-04-06_test.log"))
            expect(fileLogAppender.logDir.path)
            .notTo(contain(["2020-04-07_test.log", todayFile]))
        }
    }
}
