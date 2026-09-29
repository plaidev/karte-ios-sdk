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

import Foundation
import UIKit
import KarteUtilities

actor NativeSDKConfigFetchGuard {
    private var isFetching = false

    @discardableResult
    func use(_ block: () async -> Void) async -> Bool {
        guard !isFetching else { return false }
        isFetching = true
        defer { isFetching = false }
        await block()
        return true
    }
}

class NativeSDKConfigService {
    private let appKey: String
    private let cdnURL: URL
    private let repository: any NativeSDKConfigRepository
    private let fetcher: any NativeSDKConfigFetcher
    private let cachedFlags = ConcurrentDictionary<String, Bool>()
    private let fetchGuard = NativeSDKConfigFetchGuard()

    init(
        appKey: String,
        cdnURL: URL,
        repository: any NativeSDKConfigRepository = DefaultNativeSDKConfigRepository(),
        fetcher: any NativeSDKConfigFetcher = DefaultNativeSDKConfigFetcher()
    ) {
        self.appKey = appKey
        self.cdnURL = cdnURL
        self.repository = repository
        self.fetcher = fetcher
        // NOTE: 「起動直後」および「フェッチ失敗時のフォールバック」のために、キャッシュ済みの値をセットする。
        if let stored = repository.load() {
            cachedFlags.updateAll(stored.flags)
        }
    }

    deinit {
        stopObserving()
    }

    func isEnabled(_ name: String, default defaultValue: Bool) -> Bool {
        cachedFlags.value(forKey: name, default: defaultValue)
    }

    func startObserving() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        // didBecomeActiveNotificationはアプリ起動直後にも発火する。
        // そのため、初回フェッチもNotificationCenter経由で行われる。
        // initをブロックしないよう、ここで`fetchIfNeeded`を呼んではならない。
    }

    // NOTE: deinitのみでremoveObserverするのでも基本的には問題ないと思われるが、
    // 万が一NativeSDKConfigServiceが解放されなかった場合に備えて、stopObserving()で明示的に解放している。
    func stopObserving() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func handleBecomeActive() {
        fetchIfNeeded()
    }

    func fetchIfNeeded() {
        let cache = repository.load()
        if let cache, !cache.isExpired() {
            cachedFlags.updateAll(cache.flags)
            return
        }

        Task { [weak self] in
            guard let self else { return }
            await fetchGuard.use {
                await self.performFetch()
            }
        }
    }

    private func performFetch() async {
        let request = NativeSDKConfigRequest(baseURL: cdnURL, appKey: appKey)
        switch await fetcher.fetch(request) {
        case .success(let response):
            repository.save(NativeSDKConfigCache(flags: response.flags, fetchedAt: Date(), ttl: response.ttl))
            cachedFlags.updateAll(response.flags)
            _ = await MainActor.run {
                Tracker.track(event: Event(.fetchNativeSDKConfig(flags: response.flags)))
            }
        case .failure(let message):
            Logger.debug(tag: .core, message: message)
        }
    }
}

enum NativeSDKConfigFetchResult {
    case success(NativeSDKConfigResponse)
    case failure(message: String)
}

protocol NativeSDKConfigFetcher {
    func fetch(_ request: NativeSDKConfigRequest) async -> NativeSDKConfigFetchResult
}

final class DefaultNativeSDKConfigFetcher: NativeSDKConfigFetcher {
    private static let maxAttempts = 3

    typealias Sleep = (UInt64) async -> Void
    private let sleep: Sleep

    init(sleep: @escaping Sleep = { nanoseconds in try? await Task.sleep(nanoseconds: nanoseconds) }) {
        self.sleep = sleep
    }

    func fetch(_ request: NativeSDKConfigRequest) async -> NativeSDKConfigFetchResult {
        var errorMessage: String?
        for attempt in 1...Self.maxAttempts {
            switch await fetchOnce(request) {
            case .success(let response):
                return .success(response)
            case .terminalFailure(let terminalMessage):
                return .failure(message: terminalMessage)
            case .retryableFailure(let retryMessage):
                errorMessage = retryMessage
                if attempt < Self.maxAttempts {
                    Logger.debug(
                        tag: .core,
                        message: "NativeSDKConfig fetch failed (attempt \(attempt)): \(retryMessage). Retrying..."
                    )
                    await sleepBeforeRetry(attempt: attempt)
                }
            }
        }
        return .failure(message: errorMessage ?? "NativeSDKConfig fetch failed after 3 attempts with unexpected error")
    }

    private enum FetchOnceResult {
        case success(NativeSDKConfigResponse)
        case retryableFailure(String)
        case terminalFailure(String)
    }

    private func fetchOnce(_ request: NativeSDKConfigRequest) async -> FetchOnceResult {
        return switch await withCheckedContinuation({ continuation in
            Session.send(request) { response in
                continuation.resume(returning: response)
            }
        }) {
        case .success(let response):
            .success(response)
        case .failure(let error):
            mapFailure(error)
        }
    }

    private func mapFailure(_ error: NetworkingError) -> FetchOnceResult {
        return switch error.underlyingNetworkingError {
        case .requestFailed(let inner):
            .retryableFailure(String(describing: inner))
        case .invalidStatusCode(let statusCode) where (500...599).contains(statusCode):
            .retryableFailure(String(describing: error.underlyingNetworkingError))
        case .invalidStatusCode(let statusCode):
            .terminalFailure("NativeSDKConfig fetch failed: HTTP \(statusCode)")
        case .noData, .invalidResponse, .responseError, .invalidURL, .requestBuildFailed, .unexpectedObject:
            .terminalFailure("NativeSDKConfig fetch failed: \(String(describing: error.underlyingNetworkingError))")
        }
    }

    private func sleepBeforeRetry(attempt: Int) async {
        let randomFactor = Double.random(in: 0.5...1.5)
        let nanoseconds = NativeSDKConfigRetryInterval.nanoseconds(forAttempt: attempt, randomFactor: randomFactor)
        await sleep(nanoseconds)
    }
}

private extension NetworkingError {
    var underlyingNetworkingError: NetworkingError {
        if case .responseError(let inner as NetworkingError) = self {
            return inner
        }
        return self
    }
}

enum NativeSDKConfigRetryInterval {
    // NOTE: 初回 + リトライ (2回まで) で、最大で3回リクエストを試行する。
    // 1回目のインターバルは250〜750msの間、2回目のインターバルは1〜3秒の間である。
    static func nanoseconds(forAttempt attempt: Int, randomFactor: Double) -> UInt64 {
        let retryIntervalSec = 0.5
        let multiplier = 4.0
        let interval = retryIntervalSec * pow(multiplier, Double(attempt - 1))
        return UInt64(interval * randomFactor * 1_000_000_000)
    }
}
