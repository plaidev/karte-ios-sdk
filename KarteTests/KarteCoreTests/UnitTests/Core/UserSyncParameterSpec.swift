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
import WebKit
import KarteUtilities
@testable import KarteCore

let url = URL(string: "https://example.com/dummy")!

func GetQueryItem(with url: URL?) -> UserSync? {
    guard let url = url else {
        return nil
    }
    
    let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
    guard let items = components?.queryItems else {
        return nil
    }
    guard let item = items.first(where: { $0.name == "_k_ntvsync_b" }), let value = item.value else {
        return nil
    }
    
    let restoreData = Data(base64Encoded: value)
    let restoreString = String(data: restoreData!, encoding: .utf8)
    return GetQueryItem(with: restoreString)
}

func GetQueryItem(with query: String?) -> UserSync? {
    guard let data = query?.data(using: .utf8) else {
        return nil
    }
    let parameter = try? createJSONDecoder().decode(UserSync.self, from: data)
    return parameter
}

class UserSyncSpec: QuickSpec {
    
    override class func spec() {
        describe("sync webview") {
            context("When a karte app is not setup") {
                context("a rawValue") {
                    it("rawValue is nil") {
                        let parameter = UserSync().rawValue
                        expect(parameter).to(beNil())
                    }
                }
                
                context("a appendingQueryParameter") {
                    it("appendingQueryParameter is `https://example.com/dummy`") {
                        let ret = UserSync.appendingQueryParameter(url.absoluteString)
                        expect(ret).to(equal(url.absoluteString))
                    }
                    
                    it("appendingQueryParameter is `https://example.com/dummy`") {
                        let ret = UserSync.appendingQueryParameter(url)
                        expect(ret.absoluteString).to(equal(url.absoluteString))
                    }
                }
            }
            
            context("When a karte app is setup") {
                beforeEach {
                    let configuration = KarteCore.Configuration { (configuration) in
                        configuration.isSendInitializationEventEnabled = false
                    }
                    KarteApp.setup(appKey: APP_KEY, configuration: configuration)
                }
                
                context("a rawValue") {
                    var parameter: String!
                    var now: Date!

                    beforeEach {
                        now = Date()
                        parameter = UserSync(now).rawValue
                    }
                    
                    it("visitorId is `dummy_visitor_id`") {
                        expect(GetQueryItem(with: parameter)?.visitorId).to(equal("dummy_visitor_id"))
                    }
                    it("app_info.version_name is `1.0.0`") {
                        expect(GetQueryItem(with: parameter)?.appInfo?.versionName).to(equal("1.0.0"))
                    }
                    
                    it("app_info.version_code is `1`") {
                        expect(GetQueryItem(with: parameter)?.appInfo?.versionCode).to(equal("1"))
                    }
                    
                    it("app_info.karte_sdk_version is `1.0.0`") {
                        expect(GetQueryItem(with: parameter)?.appInfo?.karteSdkVersion).to(equal("1.0.0"))
                    }
                    
                    it("app_info.system_info.os is `iOS`") {
                        expect(GetQueryItem(with: parameter)?.appInfo?.systemInfo.os).to(equal("iOS"))
                    }
                    
                    it("app_info.system_info.os_version is `13.0`") {
                        expect(GetQueryItem(with: parameter)?.appInfo?.systemInfo.osVersion).to(equal("13.0"))
                    }
                    
                    it("app_info.system_info.device is `iPhone`") {
                        expect(GetQueryItem(with: parameter)?.appInfo?.systemInfo.device).to(equal("iPhone"))
                    }
                    
                    it("app_info.system_info.model is `iPhone10,3`") {
                        expect(GetQueryItem(with: parameter)?.appInfo?.systemInfo.model).to(equal("iPhone10,3"))
                    }
                    
                    it("app_info.system_info.bundle_id is `io.karte`") {
                        expect(GetQueryItem(with: parameter)?.appInfo?.systemInfo.bundleId).to(equal("io.karte"))
                    }
                    
                    it("app_info.system_info.language is `ja-JP`") {
                        expect(GetQueryItem(with: parameter)?.appInfo?.systemInfo.language).to(equal("ja-JP"))
                    }
                    
                    it("app_info.system_info.idfv is `dummy_idfv`") {
                        expect(GetQueryItem(with: parameter)?.appInfo?.systemInfo.idfv).to(equal("dummy_idfv"))
                    }
                    
                    it("timestamp is `Date()`") {
                        expect(GetQueryItem(with: parameter)?.timestamp).to(beCloseTo(now, within: 0.0001))
                    }
                    
                    it("deactivate is false") {
                        expect(GetQueryItem(with: parameter)?.deactivate).to(beFalse())
                    }
                }
                
                context("a appendingQueryParameter") {
                    var syncUrl: URL!
                    var now: Date!

                    beforeEach {
                        now = Date()
                        syncUrl = UserSync(now).appendingQueryParameter(url)
                    }
                    
                    it("scheme is `https`") {
                        expect(syncUrl?.scheme).to(equal("https"))
                    }
                    
                    it("host is `example.com`") {
                        expect(syncUrl?.host).to(equal("example.com"))
                    }
                    
                    it("path is `/dummy`") {
                        expect(syncUrl?.path).to(equal("/dummy"))
                    }
                    
                    it("visitorId is `dummy_visitor_id`") {
                        expect(GetQueryItem(with: syncUrl)?.visitorId).to(equal("dummy_visitor_id"))
                    }
                    
                    it("app_info.version_name is `1.0.0`") {
                        expect(GetQueryItem(with: syncUrl)?.appInfo?.versionName).to(equal("1.0.0"))
                    }
                    
                    it("app_info.version_code is `1`") {
                        expect(GetQueryItem(with: syncUrl)?.appInfo?.versionCode).to(equal("1"))
                    }
                    
                    it("app_info.karte_sdk_version is `1.0.0`") {
                        expect(GetQueryItem(with: syncUrl)?.appInfo?.karteSdkVersion).to(equal("1.0.0"))
                    }
                    
                    it("app_info.system_info.os is `iOS`") {
                        expect(GetQueryItem(with: syncUrl)?.appInfo?.systemInfo.os).to(equal("iOS"))
                    }
                    
                    it("app_info.system_info.os_version is `13.0`") {
                        expect(GetQueryItem(with: syncUrl)?.appInfo?.systemInfo.osVersion).to(equal("13.0"))
                    }
                    
                    it("app_info.system_info.device is `iPhone`") {
                        expect(GetQueryItem(with: syncUrl)?.appInfo?.systemInfo.device).to(equal("iPhone"))
                    }
                    
                    it("app_info.system_info.model is `iPhone10,3`") {
                        expect(GetQueryItem(with: syncUrl)?.appInfo?.systemInfo.model).to(equal("iPhone10,3"))
                    }
                    
                    it("app_info.system_info.bundle_id is `io.karte`") {
                        expect(GetQueryItem(with: syncUrl)?.appInfo?.systemInfo.bundleId).to(equal("io.karte"))
                    }
                    
                    it("app_info.system_info.language is `ja-JP`") {
                        expect(GetQueryItem(with: syncUrl)?.appInfo?.systemInfo.language).to(equal("ja-JP"))
                    }
                    
                    it("app_info.system_info.idfv is `dummy_idfv`") {
                        expect(GetQueryItem(with: syncUrl)?.appInfo?.systemInfo.idfv).to(equal("dummy_idfv"))
                    }
                    
                    it("timestamp is `Date()`") {
                        expect(GetQueryItem(with: syncUrl)?.timestamp).to(beCloseTo(now, within: 0.0001))
                    }
                    
                    it("deactivate is false") {
                        expect(GetQueryItem(with: syncUrl)?.deactivate).to(beFalse())
                    }
                }
                
                context("a setUserSyncScript") {
                    it("webview is set sync script") {
                        let now = Date()
                        guard let parameter = UserSync(now).rawValue else {
                            return
                        }
                        let expectSource = "window.__karte_ntvsync = \(parameter);"
                        let webView = WKWebView(frame: .zero)
                        UserSync(now).setUserSyncScript(webView)
                        let actualSource = webView.configuration.userContentController.userScripts.first?.source
                        expect(actualSource).to(equal(expectSource))
                    }
                }
                
                context("a getUserSyncScript") {
                    it("sync script is equals rawValue") {
                        let now = Date()
                        guard let parameter = UserSync(now).rawValue else {
                            return
                        }
                        let expectSource = "window.__karte_ntvsync = \(parameter);"
                        let script = UserSync(now).getUserSyncScript()
                        expect(script).to(equal(expectSource))
                    }
                }
                
                context("when set optOut") {
                    beforeEach {
                        KarteApp.optOut()
                    }
                    
                    context("a rawValue") {
                        var parameter: String!
                        
                        beforeEach {
                            parameter = UserSync().rawValue
                        }
                        it("visitorId is nil") {
                            let visitorId = GetQueryItem(with: parameter)?.visitorId
                            expect(visitorId).to(beNil())
                        }
                        
                        it("appInfo is nil") {
                           let appInfo = GetQueryItem(with: parameter)?.appInfo
                           expect(appInfo).to(beNil())
                        }
                        
                        it("timestamp is nil") {
                            let timestamp = GetQueryItem(with: parameter)?.timestamp
                            expect(timestamp).to(beNil())
                        }
                        
                        it("deactivate is true") {
                            let deactivate = GetQueryItem(with: parameter)?.deactivate
                            expect(deactivate).to(beTrue())
                        }
                    }
                }
            }
        }
    }
}
