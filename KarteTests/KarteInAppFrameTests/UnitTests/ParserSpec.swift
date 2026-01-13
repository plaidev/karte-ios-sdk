//
//  Copyright 2024 PLAID, Inc.
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

@testable import KarteInAppFrame

final class ParserSpec: QuickSpec {
    override class func spec() {
        describe("VariableParser") {
            describe("its parse") {
                context("for carouselWithMargin") {
                    let url = Bundle(for: self).url(forResource: "iaf_carousel_with_margin", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    
                    it("can parse data into rendering arg") {
                        guard let arg = VariableParser.parse(for: "dummyKey", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        expect(arg.version).to(equal(.v1))
                        expect(arg.componentType).to(equal(.iafCarousel))
                        expect(arg.content).to(beAKindOf(InAppFrameModel.self))
                    }
                    
                    it("can parse data with corresponding properties") {
                        guard let arg = VariableParser.parse(for: "dummy", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        let config = (arg.content as? InAppCarouselModel)?.config
                        expect(config?.templateType).to(equal(.carouselWithMargin))
                        expect(config?.ratio).to(equal(120))
                        expect(config?.bannerHeight).to(equal(180))
                        expect(config?.radius).to(equal(8))
                        expect(config?.spacing).to(equal(24))
                        expect(config?.paddingTop).to(equal(14))
                        expect(config?.paddingBottom).to(equal(14))
                        expect(config?.autoplaySpeed).to(equal(5))
                        
                        expect(config?.paddingStart).to(beNil())
                        expect(config?.paddingEnd).to(beNil())
                    }
                    
                    it("can parse data with various link url") {
                        guard let arg = VariableParser.parse(for: "dummy", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        let data = (arg.content as? InAppCarouselModel)?.data
                        let exampleLinkUrl = data?[0].linkUrl
                        expect(exampleLinkUrl).to(equal("https://example.com"))
                        let emptyLinkUrl = data?[1].linkUrl
                        expect(emptyLinkUrl).to(equal(""))
                        let deeplink = data?[2].linkUrl
                        expect(deeplink).to(equal("karte-tracker-sample://simplepage"))
                        let customUrlScheme = data?[3].linkUrl
                        expect(customUrlScheme).to(equal("instagram://app"))
                    }
                }

                context("for carouselWithoutMargin") {
                    let url = Bundle(for: self).url(forResource: "iaf_carousel_without_margin", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    
                    it("can parse data into rendering arg") {
                        guard let arg = VariableParser.parse(for: "dummy", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        expect(arg.version).to(equal(.v1))
                        expect(arg.componentType).to(equal(.iafCarousel))
                        expect(arg.content).to(beAKindOf(InAppFrameModel.self))
                    }
                    
                    it("can parse data with corresponding properties") {
                        guard let arg = VariableParser.parse(for: "dummy", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        let config = (arg.content as? InAppCarouselModel)?.config
                        expect(config?.templateType).to(equal(.carouselWithoutMargin))
                        expect(config?.ratio).to(equal(120))
                        expect(config?.radius).to(equal(8))
                        expect(config?.paddingTop).to(equal(20))
                        expect(config?.paddingBottom).to(equal(20))
                        expect(config?.autoplaySpeed).to(equal(5))

                        expect(config?.bannerHeight).to(beNil())
                        expect(config?.spacing).to(beNil())
                        expect(config?.paddingStart).to(beNil())
                        expect(config?.paddingEnd).to(beNil())
                    }
                    
                    it("can parse data with various link url") {
                        guard let arg = VariableParser.parse(for: "dummy", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        let data = (arg.content as? InAppCarouselModel)?.data
                        let exampleLinkUrl = data?[0].linkUrl
                        expect(exampleLinkUrl).to(equal("https://example.com"))
                        let emptyLinkUrl = data?[1].linkUrl
                        expect(emptyLinkUrl).to(equal(""))
                        let deeplink = data?[2].linkUrl
                        expect(deeplink).to(equal("karte-tracker-sample://simplepage"))
                        let customUrlScheme = data?[3].linkUrl
                        expect(customUrlScheme).to(equal("instagram://app"))
                    }
                }
                
                context("for carouselWithoutPaging") {
                    let url = Bundle(for: self).url(forResource: "iaf_carousel_without_paging", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    
                    it("can parse data into rendering arg") {
                        guard let arg = VariableParser.parse(for: "dummy", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        expect(arg.version).to(equal(.v1))
                        expect(arg.componentType).to(equal(.iafCarousel))
                        expect(arg.content).to(beAKindOf(InAppFrameModel.self))
                    }
                    
                    it("can parse data with corresponding properties") {
                        guard let arg = VariableParser.parse(for: "dummy", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        let config = (arg.content as? InAppCarouselModel)?.config
                        expect(config?.templateType).to(equal(.carouselWithoutPaging))
                        expect(config?.ratio).to(equal(100))
                        expect(config?.bannerHeight).to(equal(120))
                        expect(config?.radius).to(equal(8))
                        expect(config?.spacing).to(equal(10))
                        expect(config?.paddingStart).to(equal(10))
                        expect(config?.paddingEnd).to(equal(10))
                        expect(config?.paddingTop).to(equal(20))
                        expect(config?.paddingBottom).to(equal(20))

                        expect(config?.autoplaySpeed).to(beNil())
                    }
                    
                    it("can parse data with various link url") {
                        guard let arg = VariableParser.parse(for: "dummy", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        let data = (arg.content as? InAppCarouselModel)?.data
                        let exampleLinkUrl = data?[0].linkUrl
                        expect(exampleLinkUrl).to(equal("https://example.com"))
                        let emptyLinkUrl = data?[1].linkUrl
                        expect(emptyLinkUrl).to(equal(""))
                        let deeplink = data?[2].linkUrl
                        expect(deeplink).to(equal("karte-tracker-sample://simplepage"))
                        let customUrlScheme = data?[3].linkUrl
                        expect(customUrlScheme).to(equal("instagram://app"))
                    }
                }
                
                context("for simpleBanner") {
                    let url = Bundle(for: self).url(forResource: "iaf_simple_banner", withExtension: "json")!
                    let data = try! Data(contentsOf: url)
                    
                    it("can parse data into rendering arg") {
                        guard let arg = VariableParser.parse(for: "dummy", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        expect(arg.version).to(equal(.v1))
                        expect(arg.componentType).to(equal(.iafCarousel))
                        expect(arg.content).to(beAKindOf(InAppFrameModel.self))
                    }
                    
                    it("can parse data with corresponding properties") {
                        guard let arg = VariableParser.parse(for: "dummy", data) else {
                            fail("Failed to parse JSON data")
                            return
                        }
                        
                        let config = (arg.content as? InAppCarouselModel)?.config
                        expect(config?.templateType).to(equal(.simpleBanner))
                        expect(config?.ratio).to(equal(100))
                        expect(config?.radius).to(equal(8))
                        expect(config?.paddingStart).to(equal(10))
                        expect(config?.paddingEnd).to(equal(10))
                        expect(config?.paddingTop).to(equal(20))
                        expect(config?.paddingBottom).to(equal(20))

                        expect(config?.bannerHeight).to(beNil())
                        expect(config?.spacing).to(beNil())
                        expect(config?.autoplaySpeed).to(beNil())
                    }
                }

            }
        }
    }
}
