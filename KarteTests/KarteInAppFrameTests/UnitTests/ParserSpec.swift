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

import XCTest

@testable import KarteInAppFrame

final class ParserSpec: XCTestCase {
    func testParseCarouselWithMargin() throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "iaf_carousel_with_margin", withExtension: "json"))
        let data = try Data(contentsOf: url)
        guard let arg = VariableParser.parse(for: "dummyKey", data) else {
            XCTFail("Failed to parse JSON data")
            return
        }

        XCTAssertEqual(arg.version, .v1, "version")
        XCTAssertEqual(arg.componentType, .iafCarousel, "componentType")
        XCTAssertTrue(arg.content is any InAppFrameModel, "content is InAppFrameModel")

        let config = (arg.content as? InAppCarouselModel)?.config
        XCTAssertEqual(config?.templateType, .carouselWithMargin, "templateType")
        XCTAssertEqual(config?.ratio, 120, "ratio")
        XCTAssertEqual(config?.bannerHeight, 180, "bannerHeight")
        XCTAssertEqual(config?.radius, 8, "radius")
        XCTAssertEqual(config?.spacing, 24, "spacing")
        XCTAssertEqual(config?.paddingTop, 14, "paddingTop")
        XCTAssertEqual(config?.paddingBottom, 14, "paddingBottom")
        XCTAssertEqual(config?.autoplaySpeed, 5, "autoplaySpeed")
        XCTAssertNil(config?.paddingStart, "paddingStart")
        XCTAssertNil(config?.paddingEnd, "paddingEnd")

        let contents = (arg.content as? InAppCarouselModel)?.data
        XCTAssertEqual(contents?[0].linkUrl, "https://example.com", "linkUrl[0]")
        XCTAssertEqual(contents?[1].linkUrl, "", "linkUrl[1]")
        XCTAssertEqual(contents?[2].linkUrl, "karte-tracker-sample://simplepage", "linkUrl[2]")
        XCTAssertEqual(contents?[3].linkUrl, "instagram://app", "linkUrl[3]")
    }

    func testParseCarouselWithoutMargin() throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "iaf_carousel_without_margin", withExtension: "json"))
        let data = try Data(contentsOf: url)
        guard let arg = VariableParser.parse(for: "dummy", data) else {
            XCTFail("Failed to parse JSON data")
            return
        }

        XCTAssertEqual(arg.version, .v1, "version")
        XCTAssertEqual(arg.componentType, .iafCarousel, "componentType")
        XCTAssertTrue(arg.content is any InAppFrameModel, "content is InAppFrameModel")

        let config = (arg.content as? InAppCarouselModel)?.config
        XCTAssertEqual(config?.templateType, .carouselWithoutMargin, "templateType")
        XCTAssertEqual(config?.ratio, 120, "ratio")
        XCTAssertEqual(config?.radius, 8, "radius")
        XCTAssertEqual(config?.paddingTop, 20, "paddingTop")
        XCTAssertEqual(config?.paddingBottom, 20, "paddingBottom")
        XCTAssertEqual(config?.autoplaySpeed, 5, "autoplaySpeed")
        XCTAssertNil(config?.bannerHeight, "bannerHeight")
        XCTAssertNil(config?.spacing, "spacing")
        XCTAssertNil(config?.paddingStart, "paddingStart")
        XCTAssertNil(config?.paddingEnd, "paddingEnd")

        let contents = (arg.content as? InAppCarouselModel)?.data
        XCTAssertEqual(contents?[0].linkUrl, "https://example.com", "linkUrl[0]")
        XCTAssertEqual(contents?[1].linkUrl, "", "linkUrl[1]")
        XCTAssertEqual(contents?[2].linkUrl, "karte-tracker-sample://simplepage", "linkUrl[2]")
        XCTAssertEqual(contents?[3].linkUrl, "instagram://app", "linkUrl[3]")
    }

    func testParseCarouselWithoutPaging() throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "iaf_carousel_without_paging", withExtension: "json"))
        let data = try Data(contentsOf: url)
        guard let arg = VariableParser.parse(for: "dummy", data) else {
            XCTFail("Failed to parse JSON data")
            return
        }

        XCTAssertEqual(arg.version, .v1, "version")
        XCTAssertEqual(arg.componentType, .iafCarousel, "componentType")
        XCTAssertTrue(arg.content is any InAppFrameModel, "content is InAppFrameModel")

        let config = (arg.content as? InAppCarouselModel)?.config
        XCTAssertEqual(config?.templateType, .carouselWithoutPaging, "templateType")
        XCTAssertEqual(config?.ratio, 100, "ratio")
        XCTAssertEqual(config?.bannerHeight, 120, "bannerHeight")
        XCTAssertEqual(config?.radius, 8, "radius")
        XCTAssertEqual(config?.spacing, 10, "spacing")
        XCTAssertEqual(config?.paddingStart, 10, "paddingStart")
        XCTAssertEqual(config?.paddingEnd, 10, "paddingEnd")
        XCTAssertEqual(config?.paddingTop, 20, "paddingTop")
        XCTAssertEqual(config?.paddingBottom, 20, "paddingBottom")
        XCTAssertNil(config?.autoplaySpeed, "autoplaySpeed")

        let contents = (arg.content as? InAppCarouselModel)?.data
        XCTAssertEqual(contents?[0].linkUrl, "https://example.com", "linkUrl[0]")
        XCTAssertEqual(contents?[1].linkUrl, "", "linkUrl[1]")
        XCTAssertEqual(contents?[2].linkUrl, "karte-tracker-sample://simplepage", "linkUrl[2]")
        XCTAssertEqual(contents?[3].linkUrl, "instagram://app", "linkUrl[3]")
    }

    func testParseSimpleBanner() throws {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "iaf_simple_banner", withExtension: "json"))
        let data = try Data(contentsOf: url)
        guard let arg = VariableParser.parse(for: "dummy", data) else {
            XCTFail("Failed to parse JSON data")
            return
        }

        XCTAssertEqual(arg.version, .v1, "version")
        XCTAssertEqual(arg.componentType, .iafCarousel, "componentType")
        XCTAssertTrue(arg.content is any InAppFrameModel, "content is InAppFrameModel")

        let config = (arg.content as? InAppCarouselModel)?.config
        XCTAssertEqual(config?.templateType, .simpleBanner, "templateType")
        XCTAssertEqual(config?.ratio, 100, "ratio")
        XCTAssertEqual(config?.radius, 8, "radius")
        XCTAssertEqual(config?.paddingStart, 10, "paddingStart")
        XCTAssertEqual(config?.paddingEnd, 10, "paddingEnd")
        XCTAssertEqual(config?.paddingTop, 20, "paddingTop")
        XCTAssertEqual(config?.paddingBottom, 20, "paddingBottom")
        XCTAssertNil(config?.bannerHeight, "bannerHeight")
        XCTAssertNil(config?.spacing, "spacing")
        XCTAssertNil(config?.autoplaySpeed, "autoplaySpeed")
    }
}
