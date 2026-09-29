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
import UIKit
@testable import KarteCore

class NativeSDKConfigServiceTests: XCTestCase {
    private static let cdnURL = URL(string: "https://cdn.example.com")!

    private func makeUserDefaults(testMethodName: String) -> UserDefaults {
        let suiteName = "io.karte.test.NativeSDKConfigService.\(testMethodName)"
        let userDefaults = UserDefaults(suiteName: suiteName)!
        addTeardownBlock {
            userDefaults.removePersistentDomain(forName: suiteName)
        }
        return userDefaults
    }

    private func makeRepository(testMethodName: String) -> (DefaultNativeSDKConfigRepository, UserDefaults) {
        let userDefaults = makeUserDefaults(testMethodName: testMethodName)
        return (DefaultNativeSDKConfigRepository(userDefaults: userDefaults), userDefaults)
    }

    // MARK: - isEnabled(_:default:)

    func testIsEnabledReturnsDefaultWhenFlagAbsent() {
        let service = NativeSDKConfigService(
            appKey: APP_KEY,
            cdnURL: Self.cdnURL,
            repository: makeRepository(testMethodName: "testIsEnabledReturnsDefaultWhenFlagAbsent").0
        )
        XCTAssertFalse(service.isEnabled("absent_flag", default: false))
    }

    func testIsEnabledReturnsCachedValue() throws {
        let (repository, userDefaults) = makeRepository(testMethodName: "testIsEnabledReturnsCachedValue")
        userDefaults.set(try JSONEncoder().encode(NativeSDKConfigCache(flags: ["flag_a": true, "flag_b": false], fetchedAt: Date(), ttl: 3600)), forKey: .nativeSDKConfig)
        let service = NativeSDKConfigService(appKey: APP_KEY, cdnURL: Self.cdnURL, repository: repository)
        XCTAssertTrue(service.isEnabled("flag_a", default: false))
        XCTAssertFalse(service.isEnabled("flag_b", default: true))
    }

    // MARK: - fetchIfNeeded()

    func testFetchIfNeededFetchesWhenCacheExpired() throws {
        let (repository, userDefaults) = makeRepository(testMethodName: "testFetchIfNeededFetchesWhenCacheExpired")
        userDefaults.set(try JSONEncoder().encode(NativeSDKConfigCache(flags: ["old_flag": false], fetchedAt: Date().addingTimeInterval(-301), ttl: 300)), forKey: .nativeSDKConfig)

        let configuration = Configuration { configuration in
            configuration.isSendInitializationEventEnabled = false
        }
        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
        addTeardownBlock { KarteApp.shared.teardown() }

        let trackBuilder = StubBuilder(spec: Self.self, resource: .empty).build()
        let module = StubActionModule(metadata: name, builder: trackBuilder)

        let fetchCompletedExp = expectation(description: "fetch completed")
        let fetcher = StubNativeSDKConfigFetcher(
            result: .success(NativeSDKConfigResponse(flags: ["feature_a": true, "feature_b": false], ttl: 1800)),
            onFetch: { fetchCompletedExp.fulfill() }
        )
        let service = NativeSDKConfigService(
            appKey: APP_KEY,
            cdnURL: Self.cdnURL,
            repository: repository,
            fetcher: fetcher
        )

        service.fetchIfNeeded()
        wait(for: [fetchCompletedExp], timeout: 5.0)

        XCTAssertEqual(fetcher.requests.count, 1)
        XCTAssertEqual(fetcher.requests[0].baseURL, Self.cdnURL)
        let data = try XCTUnwrap(userDefaults.object(forKey: .nativeSDKConfig) as? Data)
        let cache = try JSONDecoder().decode(NativeSDKConfigCache.self, from: data)
        XCTAssertTrue(try XCTUnwrap(cache.flags["feature_a"]))
        XCTAssertFalse(try XCTUnwrap(cache.flags["feature_b"]))
        XCTAssertNil(cache.flags["old_flag"])
        XCTAssertEqual(cache.ttl, 1800)
        XCTAssertTrue(service.isEnabled("feature_a", default: false))
        XCTAssertFalse(service.isEnabled("feature_b", default: true))

        // NOTE: _fetch_native_sdk_configイベントが送信される。
        module.wait(timeout: 5.0)
        let event = try XCTUnwrap(module.event(.fetchNativeSDKConfig))
        XCTAssertEqual(event.eventName, .fetchNativeSDKConfig)
        XCTAssertTrue(try XCTUnwrap(event.values.bool(forKeyPath: "flags.feature_a")))
        XCTAssertFalse(try XCTUnwrap(event.values.bool(forKeyPath: "flags.feature_b")))
    }

    func testFetchIfNeededSkipsFetchWhenCacheNotExpired() throws {
        let (repository, userDefaults) = makeRepository(testMethodName: "testFetchIfNeededSkipsFetchWhenCacheNotExpired")
        userDefaults.set(try JSONEncoder().encode(NativeSDKConfigCache(flags: ["feature_a": true], fetchedAt: Date(), ttl: 3600)), forKey: .nativeSDKConfig)
        let fetcher = StubNativeSDKConfigFetcher()
        let service = NativeSDKConfigService(
            appKey: APP_KEY,
            cdnURL: Self.cdnURL,
            repository: repository,
            fetcher: fetcher
        )

        service.fetchIfNeeded()

        XCTAssertTrue(fetcher.requests.isEmpty)
        XCTAssertTrue(service.isEnabled("feature_a", default: false))
    }

    func testFetchKeepsStaleCacheOnNetworkFailure() throws {
        let (repository, userDefaults) = makeRepository(testMethodName: "testFetchKeepsStaleCacheOnNetworkFailure")
        userDefaults.set(try JSONEncoder().encode(NativeSDKConfigCache(flags: ["existing_flag": true], fetchedAt: Date().addingTimeInterval(-301), ttl: 300)), forKey: .nativeSDKConfig)
        let fetchCompletedExp = expectation(description: "fetch completed")
        let fetcher = StubNativeSDKConfigFetcher(
            result: .failure(message: "network error"),
            onFetch: { fetchCompletedExp.fulfill() }
        )
        let service = NativeSDKConfigService(
            appKey: APP_KEY,
            cdnURL: Self.cdnURL,
            repository: repository,
            fetcher: fetcher
        )

        service.fetchIfNeeded()
        wait(for: [fetchCompletedExp], timeout: 5.0)

        XCTAssertEqual(fetcher.requests.count, 1)
        XCTAssertEqual(fetcher.requests[0].baseURL, Self.cdnURL)
        let data = try XCTUnwrap(userDefaults.object(forKey: .nativeSDKConfig) as? Data)
        let cache = try JSONDecoder().decode(NativeSDKConfigCache.self, from: data)
        XCTAssertTrue(try XCTUnwrap(cache.flags["existing_flag"]))
        XCTAssertTrue(service.isEnabled("existing_flag", default: false))
    }

    // MARK: - observation lifecycle

    func testObservationLifecycle() {
        // NOTE: フェッチによりテストが複雑化しないようにするため、有効なキャッシュをセットしている。
        let repository = StubNativeSDKConfigRepository(
            cache: NativeSDKConfigCache(flags: [:], fetchedAt: Date(), ttl: 3600)
        )
        let service = NativeSDKConfigService(
            appKey: APP_KEY,
            cdnURL: Self.cdnURL,
            repository: repository
        )
        XCTAssertEqual(repository.loadCount, 1)
        service.startObserving()

        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        XCTAssertEqual(repository.loadCount, 2) // init + fetchIfNeeded

        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        XCTAssertEqual(repository.loadCount, 3) // fetchIfNeeded

        service.stopObserving()

        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        XCTAssertEqual(repository.loadCount, 3) // fetchIfNeeded is not called
    }
}

private final class StubNativeSDKConfigRepository: NativeSDKConfigRepository {
    var cache: NativeSDKConfigCache?
    private(set) var loadCount = 0

    init(cache: NativeSDKConfigCache? = nil) {
        self.cache = cache
    }

    func load() -> NativeSDKConfigCache? {
        loadCount += 1
        return cache
    }

    func save(_ cache: NativeSDKConfigCache) {
        self.cache = cache
    }
}

private final class StubNativeSDKConfigFetcher: NativeSDKConfigFetcher {
    private let result: NativeSDKConfigFetchResult
    private let onFetch: (() -> Void)?
    private(set) var requests: [NativeSDKConfigRequest] = []

    init(
        result: NativeSDKConfigFetchResult = .success(NativeSDKConfigResponse(flags: [:], ttl: 300)),
        onFetch: (() -> Void)? = nil
    ) {
        self.result = result
        self.onFetch = onFetch
    }

    func fetch(_ request: NativeSDKConfigRequest) async -> NativeSDKConfigFetchResult {
        requests.append(request)
        onFetch?()
        return result
    }
}
