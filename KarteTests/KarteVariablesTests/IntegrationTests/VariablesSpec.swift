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
import Mockingjay
import KarteUtilities
@testable import KarteCore
@testable import KarteVariables

class VariablesSpec: QuickSpec {
    
    override func spec() {        
        var configuration: KarteCore.Configuration!
        var fetchStubBuilder1: Builder!
        var fetchStubBuilder2: Builder!
        var fetchStubBuilder3: Builder!
        var fetchStubBuilder4: Builder!
        var otherStubBuilder: Builder!
        
        beforeSuite {
            configuration = Configuration { (configuration) in
                configuration.isSendInitializationEventEnabled = false
            }
            fetchStubBuilder1 = StubBuilder(spec: self, resource: .variables1).build()
            fetchStubBuilder2 = StubBuilder(spec: self, resource: .variables2).build()
            fetchStubBuilder3 = StubBuilder(spec: self, resource: .variables3).build()
            fetchStubBuilder4 = StubBuilder(spec: self, resource: .variables4).build()
            otherStubBuilder = StubBuilder(spec: self, resource: .empty).build()
        }
        
        describe("a variables") {
            describe("its occurred _message_ready event") {
                describe("action is control group") {
                    var event: Event!
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: fetchStubBuilder3)
                        
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        Variables.fetch()

                        module.wait()
                        
                        event = StubActionModule(self, metadata: metadata, builder: otherStubBuilder).wait().event(.messageReady)
                    }
                    
                    it("campaign_id is match") {
                        expect(event.values.string(forKeyPath: "message.campaign_id")).to(equal("5e7dab7215bd5200119c9658"))
                    }
                    
                    it("shorten_id is match") {
                        expect(event.values.string(forKeyPath: "message.shorten_id")).to(equal("__5e7dab7215bd5200119c9658"))
                    }
                    
                    it("response_id is match") {
                        expect(event.values.string(forKeyPath: "message.response_id")).to(equal("2020-03-27T14:25:37.151Z___5e7dab7215bd5200119c9658"))
                    }
                    
                    it("response_timestamp is match") {
                        expect(event.values.string(forKeyPath: "message.response_timestamp")).to(equal("2020-03-27T14:25:37.151Z"))
                    }
                    
                    it("event_hashes is match") {
                        expect(event.values.string(forKeyPath: "message.trigger.event_hashes")).to(equal("a001"))
                    }
                    
                    it("no_action is match") {
                        expect(event.values.bool(forKeyPath: "no_action")).to(beFalse())
                    }
                }
                
                describe("action is not control group") {
                    var event: Event!
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: fetchStubBuilder2)
                        
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        Variables.fetch()

                        module.wait()
                        
                        event = StubActionModule(self, metadata: metadata, builder: otherStubBuilder).wait().event(.messageReady)
                    }
                    
                    it("campaign_id is match") {
                        expect(event.values.string(forKeyPath: "message.campaign_id")).to(equal("5b750a095db3aa091ed1f590"))
                    }
                    
                    it("shorten_id is match") {
                        expect(event.values.string(forKeyPath: "message.shorten_id")).to(equal("14kU"))
                    }
                    
                    it("response_id is match") {
                        expect(event.values.string(forKeyPath: "message.response_id")).to(equal("2019-11-24T02:05:12.616Z_14kU"))
                    }
                    
                    it("response_timestamp is match") {
                        expect(event.values.string(forKeyPath: "message.response_timestamp")).to(equal("2019-11-24T02:05:12.616Z"))
                    }
                    
                    it("event_hashes is match") {
                        expect(event.values.string(forKeyPath: "message.trigger.event_hashes")).to(equal("a001"))
                    }
                    
                    it("no_action is match") {
                        expect(event.values.bool(forKeyPath: "no_action")).to(beFalse())
                    }
                }
                
                
                describe("no action") {
                    var event: Event!
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: fetchStubBuilder4)
                        
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        Variables.fetch()

                        module.wait()
                        
                        event = StubActionModule(self, metadata: metadata, builder: otherStubBuilder).wait().event(.messageReady)
                    }
                    
                    it("campaign_id is match") {
                        expect(event.values.string(forKeyPath: "message.campaign_id")).to(equal("5b750a095db3aa091ed1f590"))
                    }
                    
                    it("shorten_id is match") {
                        expect(event.values.string(forKeyPath: "message.shorten_id")).to(equal("14kU"))
                    }
                       
                    it("response_id is match") {
                        expect(event.values.string(forKeyPath: "message.response_id")).to(equal("2019-11-24T02:05:12.616Z_14kU"))
                    }
                    
                    it("response_timestamp is match") {
                        expect(event.values.string(forKeyPath: "message.response_timestamp")).to(equal("2019-11-24T02:05:12.616Z"))
                    }
                    
                    it("event_hashes is match") {
                        expect(event.values.string(forKeyPath: "message.trigger.event_hashes")).to(equal("a001"))
                    }

                    it("no_action is match") {
                        expect(event.values.bool(forKeyPath: "no_action")).to(beTrue())
                    }
                    
                    it("reason is match") {
                        expect(event.values.string(forKeyPath: "reason")).to(equal("foo"))
                    }
                }
            }
            
            describe("its fetch") {
                beforeEachWithMetadata { (metadata) in
                    let module = StubActionModule(self, metadata: metadata, builder: fetchStubBuilder1)
                    
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                    Variables.fetch()

                    module.wait()
                    
                    StubActionModule(self, metadata: metadata, builder: otherStubBuilder).wait()
                }

                describe("get All Keys") {
                    it ("get all keys") {
                        let keys = Variables.getAllKeys()
                        expect(keys.contains("var1")).to(beTrue())
                        expect(keys.contains("var2")).to(beTrue())
                        expect(keys.contains("var3")).to(beTrue())
                        expect(keys.contains("var4")).to(beFalse())
                    }
                }

                describe("clear All Cache") {
                    it ("clear All Cache") {
                        Variables.clearCacheAll()
                        let variable1 = Variable(name: "var1")
                        let variable2 = Variable(name: "var2")
                        expect(variable1.value).to(beNil())
                        expect(variable2.value).to(beNil())
                    }
                }

                describe("clear Cache By Key") {
                    it ("clear Cache By Key") {
                        Variables.clearCache(forKey: "var1")
                        let variable1 = Variable(name: "var1")
                        let variable2 = Variable(name: "var2")
                        expect(variable1.value).to(beNil())
                        expect(variable2.value).toNot(beNil())
                    }
                }


                describe("retrieve variable") {
                    it("var1 is not nil") {
                        let variable = Variable(name: "var1")
                        expect(variable.value).toNot(beNil())
                    }

                    it("var1 is `変数1`") {
                        let variable = Variable(name: "var1")
                        expect(variable.string).to(equal("変数1"))
                    }

                    it("var2 is not nil") {
                        let variable = Variable(name: "var2")
                        expect(variable.value).toNot(beNil())
                    }

                    it("var2 is `変数2a`") {
                        let variable = Variable(name: "var2")
                        expect(variable.string).to(equal("変数2a"))
                    }
                    
                    it("var3 is not nil") {
                        let variable = Variable(name: "var3")
                        expect(variable.value).toNot(beNil())
                    }
                    
                    it("var3 is `変数3`") {
                        let variable = Variable(name: "var3")
                        expect(variable.string).to(equal("変数3a"))
                    }
                }
                
                describe("clear variables") {
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: fetchStubBuilder2)

                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        Variables.fetch()

                        module.wait()
                        
                        StubActionModule(self, metadata: metadata, builder: otherStubBuilder).wait()
                    }

                    it("var1 is nil") {
                        let variable = Variable(name: "var1")
                        expect(variable.value).to(beNil())
                    }

                    it("var2 is nil") {
                        let variable = Variable(name: "var2")
                        expect(variable.value).to(beNil())
                    }

                    it("var3 is not nil") {
                        let variable = Variable(name: "var3")
                        expect(variable.value).toNot(beNil())
                    }

                    it("var3 is `変数3b`") {
                        let variable = Variable(name: "var3")
                        expect(variable.string).to(equal("変数3b"))
                    }

                    it("var4 is not nil") {
                        let variable = Variable(name: "var4")
                        expect(variable.value).toNot(beNil())
                    }

                    it("var4 is `変数4`") {
                        let variable = Variable(name: "var4")
                        expect(variable.string).to(equal("変数4"))
                    }
                }

                describe("override variables") {
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: fetchStubBuilder2)

                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        Tracker.track(event: Event(.view(viewName: "foo", title: "bar", values: [:])))

                        module.wait()
                        
                        StubActionModule(self, metadata: metadata, builder: otherStubBuilder).wait()
                    }

                    it("var1 is not nil") {
                        let variable = Variable(name: "var1")
                        expect(variable.value).toNot(beNil())
                    }

                    it("var1 is `変数1`") {
                        let variable = Variable(name: "var1")
                        expect(variable.string).to(equal("変数1"))
                    }

                    it("var2 is not nil") {
                        let variable = Variable(name: "var2")
                        expect(variable.value).toNot(beNil())
                    }

                    it("var2 is `変数2a`") {
                        let variable = Variable(name: "var2")
                        expect(variable.string).to(equal("変数2a"))
                    }

                    it("var3 is not nil") {
                        let variable = Variable(name: "var3")
                        expect(variable.value).toNot(beNil())
                    }

                    it("var3 is `変数3b`") {
                        let variable = Variable(name: "var3")
                        expect(variable.string).to(equal("変数3b"))
                    }

                    it("var4 is not nil") {
                        let variable = Variable(name: "var4")
                        expect(variable.value).toNot(beNil())
                    }

                    it("var4 is `変数4`") {
                        let variable = Variable(name: "var4")
                        expect(variable.string).to(equal("変数4"))
                    }
                }
                
                describe("default lastFetch information") {
                    beforeEachWithMetadata { (metadata) in
                        UserDefaults.standard.removeObject(forKey: .lastFetchStatus)
                        UserDefaults.standard.removeObject(forKey: .lastFetchTime)
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                    }

                    it("lastFetchStatus is notyet") {
                        let lastFetchStatus = Variables.lastFetchStatus
                        expect(lastFetchStatus).to(equal(.nofetchYet))
                    }
                    it("lastFetchTime is nil") {
                        let lastFetchTime = Variables.lastFetchTime
                        expect(lastFetchTime).to(beNil())
                    }
                    
                    it("hasSuccessfulLastFetch returns false") {
                        let hasSuccessfulLastFetch = Variables.hasSuccessfulLastFetch(inSeconds: 100)
                        expect(hasSuccessfulLastFetch).to(beFalse())
                    }
                }
                
                describe("update lastFetch information") {
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: fetchStubBuilder2)

                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        Variables.fetch()

                        module.wait()
                        
                        StubActionModule(self, metadata: metadata, builder: otherStubBuilder).wait()
                    }

                    it("lastFetchTime is not nil") {
                        let lastFetchTime = Variables.lastFetchTime
                        expect(lastFetchTime).toNot(beNil())
                    }
                    
                    it("lastFetchStatus is success") {
                        let lastFetchStatus = Variables.lastFetchStatus
                        expect(lastFetchStatus).to(equal(.success))
                    }

                    it("hasSuccessfulLastFetch returns true") {
                        let hasSuccessfulLastFetch = Variables.hasSuccessfulLastFetch(inSeconds: 1)
                        expect(hasSuccessfulLastFetch).to(beTrue())
                        
                        let hasSuccessfulLastFetch60 = Variables.hasSuccessfulLastFetch(inSeconds: 60)
                        expect(hasSuccessfulLastFetch60).to(beTrue())
                    }
                    
                    it("hasSuccessfulLastFetch returns false") {
                        Thread.sleep(until: Date(timeIntervalSinceNow: 1))
                        let hasSuccessfulLastFetch = Variables.hasSuccessfulLastFetch(inSeconds: 1)
                        expect(hasSuccessfulLastFetch).to(beFalse())
                    }
                    
                    it("hasSuccessfulLastFetch returns false when specify minus value") {
                        let hasSuccessfulLastFetch = Variables.hasSuccessfulLastFetch(inSeconds: -60)
                        expect(hasSuccessfulLastFetch).to(beFalse())
                    }
                }
            }
            
            describe("its fetchCompletion") {
                context("when online") {
                    var result: Bool!
                    beforeEachWithMetadata { (metadata) in
                        let module = StubActionModule(self, metadata: metadata, builder: fetchStubBuilder1)
                        
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        Variables.fetch { (isSuccess) in
                            result = isSuccess
                        }

                        module.wait()
                        
                        StubActionModule(self, metadata: metadata, builder: otherStubBuilder).wait()
                    }
                    
                    it("result is true") {
                        expect(result).to(beTrue())
                    }
                }
                context("when offline") {
                    var result: Bool!
                    beforeEachWithMetadata { (metadata) in
                        
                        Resolver.root = Resolver.submock
                        Resolver.root.register(Bool.self, name: "isReachable") {
                            false
                        }
                        
                        let module = StubActionModule(self, metadata: metadata, builder: fetchStubBuilder1)
                        
                        KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                        Variables.fetch { (isSuccess) in
                            result = isSuccess
                            module.finish()
                        }

                        module.wait()
                    }
                    
                    afterEach {
                        Resolver.root = Resolver.mock
                    }
                    
                    it("result is false") {
                        expect(result).to(beFalse())
                    }

                    it("lastFetchTime is not nil") {
                        let lastFetchTime = Variables.lastFetchTime
                        expect(lastFetchTime).toNot(beNil())
                    }
                    
                    it("lastFetchStatus is failure") {
                        let lastFetchStatus = Variables.lastFetchStatus
                        expect(lastFetchStatus).to(equal(.failure))
                    }
                    
                    it("hasSuccessfulLastFetch returns false") {
                        let hasSuccessfulLastFetch = Variables.hasSuccessfulLastFetch(inSeconds: 10)
                        expect(hasSuccessfulLastFetch).to(beFalse())
                    }
                }
            }
        }
    }
}
