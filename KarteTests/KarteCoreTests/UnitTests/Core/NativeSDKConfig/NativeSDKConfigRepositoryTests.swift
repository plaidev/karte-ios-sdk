//
//  Copyright 2026 PLAID, Inc.
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

import XCTest
import KarteUtilities
@testable import KarteCore

class NativeSDKConfigRepositoryTests: XCTestCase {
    private let suiteName = "io.karte.test.NativeSDKConfigRepositoryTests"

    private func makeRepository() -> (DefaultNativeSDKConfigRepository, UserDefaults) {
        let userDefaults = UserDefaults(suiteName: suiteName)!
        userDefaults.removePersistentDomain(forName: suiteName)
        addTeardownBlock {
            userDefaults.removePersistentDomain(forName: self.suiteName)
        }
        return (DefaultNativeSDKConfigRepository(userDefaults: userDefaults), userDefaults)
    }

    private func writeCache(_ cache: NativeSDKConfigCache, to userDefaults: UserDefaults) throws {
        userDefaults.set(try JSONEncoder().encode(cache), forKey: .nativeSDKConfig)
    }

    func testLoadReturnsNilWhenNoCacheExists() {
        let (repository, _) = makeRepository()
        XCTAssertNil(repository.load())
    }

    func testLoadDecodesStoredCache() throws {
        let (repository, userDefaults) = makeRepository()
        let fetchedAt = Date(timeIntervalSince1970: 1_000_000)
        try writeCache(NativeSDKConfigCache(flags: ["flagA": true, "flagB": false], fetchedAt: fetchedAt, ttl: 3600), to: userDefaults)

        let loaded = try XCTUnwrap(repository.load())
        XCTAssertTrue(try XCTUnwrap(loaded.flags["flagA"]))
        XCTAssertFalse(try XCTUnwrap(loaded.flags["flagB"]))
        XCTAssertEqual(loaded.fetchedAt.timeIntervalSince1970, fetchedAt.timeIntervalSince1970, accuracy: 0.001)
    }

    func testLoadReturnsNilAndClearsDataOnDecodeFailure() {
        let (repository, userDefaults) = makeRepository()
        userDefaults.set("corrupt".data(using: .utf8)!, forKey: .nativeSDKConfig)

        XCTAssertNil(repository.load())
        XCTAssertNil(userDefaults.object(forKey: .nativeSDKConfig))
    }

    func testSavePersistsCacheToUserDefaults() throws {
        let (repository, userDefaults) = makeRepository()
        let fetchedAt = Date(timeIntervalSince1970: 2_000_000)
        repository.save(NativeSDKConfigCache(flags: ["flagA": true, "flagB": false], fetchedAt: fetchedAt, ttl: 3600))

        let data = try XCTUnwrap(userDefaults.object(forKey: .nativeSDKConfig) as? Data)
        let decoded = try JSONDecoder().decode(NativeSDKConfigCache.self, from: data)
        XCTAssertTrue(try XCTUnwrap(decoded.flags["flagA"]))
        XCTAssertFalse(try XCTUnwrap(decoded.flags["flagB"]))
        XCTAssertEqual(decoded.fetchedAt.timeIntervalSince1970, fetchedAt.timeIntervalSince1970, accuracy: 0.001)
    }

    func testSaveOverwritesPreviousCache() throws {
        let (repository, userDefaults) = makeRepository()
        let firstFetchedAt = Date(timeIntervalSince1970: 1_000_000)
        let secondFetchedAt = Date(timeIntervalSince1970: 2_000_000)
        try writeCache(NativeSDKConfigCache(flags: ["flag": true], fetchedAt: firstFetchedAt, ttl: 3600), to: userDefaults)
        repository.save(NativeSDKConfigCache(flags: ["flag": false], fetchedAt: secondFetchedAt, ttl: 1800))

        let data = try XCTUnwrap(userDefaults.object(forKey: .nativeSDKConfig) as? Data)
        let decoded = try JSONDecoder().decode(NativeSDKConfigCache.self, from: data)
        XCTAssertFalse(try XCTUnwrap(decoded.flags["flag"]))
        XCTAssertEqual(decoded.fetchedAt.timeIntervalSince1970, secondFetchedAt.timeIntervalSince1970, accuracy: 0.001)
        XCTAssertEqual(decoded.ttl, 1800)
    }
}
