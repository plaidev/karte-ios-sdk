//
//  Copyright 2022 PLAID, Inc.
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
@testable import KarteInAppMessaging

@MainActor
class IAMProcessPoolSpec: QuickSpec {
    override class func spec() {
        describe("Check wether it can be created a process") {
            context("SceneId exists with specific id in pool") {
                it("`canCreateProcess` returns false") {
                    let pool = IAMProcessPool()
                    let process = IAMProcess(view: UIView(), configuration: IAMProcessConfiguration(app: KarteApp.shared))
                    pool.storeProcess(process)
                    expect(pool.processes.isEmpty).to(beFalse())
                    expect(pool.canCreateProcess(sceneId: SceneId("DEFAULT"))).to(beFalse())
                }
            }
            context("SceneId does not exists with specific id in pool") {
                context("when there is connected scene with the same id") {
                    // TBD, Write a test as soon as we figure out how to make the condition of it.
                }
                context("when there is no connected scene with the same id") {
                    it("`canCreateProcess` returns false due to pool.processes is blank") {
                        let pool = IAMProcessPool()
                        expect(pool.processes.isEmpty).to(beTrue())
                        expect(pool.canCreateProcess(sceneId: SceneId("DEFAULT"))).to(beFalse())
                    }
                }
            }
        }
        describe("Retrive a process with SceneId") {
            context("If the process is matched with id of view") {
                it("`retrieveProcess` returns the IAMProcess") {
                    let pool = IAMProcessPool()
                    let process = IAMProcess(view: UIView(), configuration: IAMProcessConfiguration(app: KarteApp.shared))
                    pool.storeProcess(process)
                    let actual = pool.retrieveProcess(sceneId: SceneId("DEFAULT"))
                    expect(actual).toNot(beNil())
                    expect(actual?.sceneId.identifier).to(equal("DEFAULT"))
                }
            }
            context("If the process is not matched with id of view") {
                it("`retrieveProcess` returns nil") {
                    let pool = IAMProcessPool()
                    let process = IAMProcess(view: UIView(), configuration: IAMProcessConfiguration(app: KarteApp.shared))
                    process.sceneId.identifier = "NOT DEFAULT"
                    pool.storeProcess(process)
                    let actual = pool.retrieveProcess(sceneId: SceneId("DEFAULT"))
                    expect(actual).to(beNil())
                }
            }
        }
        describe("Retrive a process with View") {
            context("If the process is matched with id of view") {
                it("`retrieveProcess` returns the IAMProcess") {
                    let pool = IAMProcessPool()
                    let view = UIView()
                    let process = IAMProcess(view: view, configuration: IAMProcessConfiguration(app: KarteApp.shared))
                    pool.storeProcess(process)
                    let actual = pool.retrieveProcess(view: view)
                    expect(actual).toNot(beNil())
                    expect(actual?.sceneId.identifier).to(equal("DEFAULT"))
                }
            }
            context("If the process is not matched with id of view") {
                it("`retrieveProcess` returns nil") {
                    let pool = IAMProcessPool()
                    let view = UIView()
                    let process = IAMProcess(view: view, configuration: IAMProcessConfiguration(app: KarteApp.shared))
                    process.sceneId.identifier = "NOT DEFAULT"
                    pool.storeProcess(process)
                    let actual = pool.retrieveProcess(view: view)
                    expect(actual).to(beNil())
                }
            }
        }
        describe("Store a process") {
            context("When a process is stored") {
                it("`pool.processes` has the process after `storeProcess`") {
                    let pool = IAMProcessPool()
                    let process = IAMProcess(view: UIView(), configuration: IAMProcessConfiguration(app: KarteApp.shared))
                    expect(pool.processes.isEmpty).to(beTrue())
                    pool.storeProcess(process)
                    expect(pool.processes.isEmpty).toNot(beTrue())
                }
            }
        }
        describe("Remove a process") {
            context("When a process is removed with SceneId ") {
                it("`pool.processes` has not the process after execute `removeProcess`") {
                    let pool = IAMProcessPool()
                    let process = IAMProcess(view: UIView(), configuration: IAMProcessConfiguration(app: KarteApp.shared))
                    pool.storeProcess(process)
                    expect(pool.processes.isEmpty).toNot(beTrue())
                    pool.removeProcess(sceneId: SceneId("DEFAULT"))
                    expect(pool.processes.isEmpty).to(beTrue())
                }
            }
        }
    }
}
