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

import KarteUtilities
import UIKit

/// ページビューを管理するためのサービスです。
///
/// **SDK内部で利用するクラスであり、通常のSDK利用でこちらのクラスを利用することはありません。**
public class PvService {
    @Injected(name: "pv_service.pv_id_bucket")
    var pvIdBucket: PvIdBucket

    @Injected(name: "pv_service.original_pv_id_bucket")
    var originalPvIdBucket: PvIdBucket

    /// 指定された `SceneId` をキーに現在のページビューIDにアクセスします。
    ///
    /// - Parameter sceneId: `SceneId`
    /// - Returns: 現在のページビューIDを返します。
    public func pvId(forSceneId sceneId: SceneId) -> PvId {
        if let pvId = pvIdBucket.pvId(forKey: sceneId) {
            return pvId
        }
        return originalPvId(forSceneId: sceneId)
    }

    /// 指定された `SceneId` をキーに現在のオリジナルページビューIDにアクセスします。
    ///
    /// オリジナルページビューIDは、シーン毎に一度だけ作成されるIDで、当該シーンが破棄されるまで有効です。
    /// - Parameter sceneId: `SceneId`
    /// - Returns: 現在のオリジナルページビューIDを返します。
    public func originalPvId(forSceneId sceneId: SceneId) -> PvId {
        if let pvId = originalPvIdBucket.pvId(forKey: sceneId) {
            return pvId
        }

        let pvId = PvId.generate()
        originalPvIdBucket.set(pvId, forKey: sceneId)

        return pvId
    }

    /// 指定された `SceneId` をキーにページビューIDを更新します。
    ///
    /// - Parameter sceneId: `SceneId`
    /// - Returns: 更新されたページビューIDを返します。
    @discardableResult
    public func renewPvId(forSceneId sceneId: SceneId) -> PvId {
        let pvId = PvId.generate()
        pvIdBucket.set(pvId, forKey: sceneId)
        return pvId
    }

    /// 指定された `SceneId` をキーにページビューIDを更新します。<br>
    /// 併せてサブモジュールに対してページビューIDの更新を伝達します。
    ///
    /// - Parameter sceneId: `SceneId`
    public func changePv(_ sceneId: SceneId) {
        resetIfNeeded(forSceneId: sceneId)
        renewPvId(forSceneId: sceneId)
    }

    private func resetIfNeeded(forSceneId sceneId: SceneId) {
        let pvId = self.pvId(forSceneId: sceneId)
        let originalPvId = self.originalPvId(forSceneId: sceneId)
        guard pvId != originalPvId else {
            return
        }
        KarteApp.shared.modules.forEach { module in
            if case let .action(module) = module {
                module.reset(sceneId: sceneId)
            }
        }
    }

    deinit {
    }
}

extension Resolver {
    static func registerPvService() {
        register(name: "pv_service.generator") { PvIdGenerator() as IdGenerator }
        register(name: "pv_service.pv_id_bucket") { PvIdBucket() }
        register(name: "pv_service.original_pv_id_bucket") { PvIdBucket() }
    }
}
