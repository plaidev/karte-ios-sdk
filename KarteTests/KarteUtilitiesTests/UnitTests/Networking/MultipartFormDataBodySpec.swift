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
@testable import KarteUtilities

class MultipartFormDataBodySpec: XCTestCase {

    func testInitialization() {
        let boundary = "1a2b3c4d5e6f7a8b"

        let emptyParts: [MultipartFormDataBody.Part] = []
        let body = MultipartFormDataBody(parts: emptyParts, boundary: boundary)
        XCTAssertFalse(body.boundary.isEmpty, "boundary should not be empty")
        XCTAssertEqual(body.boundary.count, 16, "boundary should be 16 characters")

        let customBoundary = "custom-boundary-123"
        let bodyWithCustom = MultipartFormDataBody(parts: emptyParts, boundary: customBoundary)
        XCTAssertEqual(bodyWithCustom.boundary, customBoundary, "should use the provided boundary")

        let testData = "test".data(using: .utf8)!
        let part = MultipartFormDataBody.Part(data: testData, name: "test")
        let bodyWithParts = MultipartFormDataBody(parts: [part], boundary: boundary)
        XCTAssertEqual(bodyWithParts.parts.count, 1, "should store one part")
        XCTAssertEqual(bodyWithParts.parts.first?.name, "test", "part name should be 'test'")
    }

    func testBuildEmptyParts() throws {
        let parts: [MultipartFormDataBody.Part] = []
        let body = MultipartFormDataBody(parts: parts, boundary: "boundary")

        let data = try body.asData()
        let expectedData = "--boundary--\r\n".data(using: .utf8)!

        XCTAssertEqual(data, expectedData, "empty parts should produce closing boundary only")
    }

    func testBuildSimplePart() throws {
        let testData = "test-content".data(using: .utf8)!
        let part = MultipartFormDataBody.Part(data: testData, name: "test-field")
        let body = MultipartFormDataBody(parts: [part], boundary: "boundary")

        let data = try body.asData()
        let expectedString = "--boundary\r\nContent-Disposition: form-data; name=\"test-field\"\r\nContent-Type: text/plain\r\n\r\ntest-content\r\n--boundary--\r\n"
        let expectedData = expectedString.data(using: .utf8)!

        XCTAssertEqual(data, expectedData, "should build correct data for a simple part")
    }

    func testBuildPartWithMimeTypeAndFilename() throws {
        let testData = "file-content".data(using: .utf8)!
        let part = MultipartFormDataBody.Part(
            data: testData,
            name: "file",
            mimeType: .textPlain,
            fileName: "test.txt"
        )
        let body = MultipartFormDataBody(parts: [part], boundary: "boundary")

        let data = try body.asData()
        let expectedString = "--boundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"test.txt\"\r\nContent-Type: text/plain\r\n\r\nfile-content\r\n--boundary--\r\n"
        let expectedData = expectedString.data(using: .utf8)!

        XCTAssertEqual(data, expectedData, "should build correct data with mime type and filename")
    }

    func testBuildMultipleParts() throws {
        let textData = "text-content".data(using: .utf8)!
        let textPart = MultipartFormDataBody.Part(data: textData, name: "text-field")

        let fileData = "file-content".data(using: .utf8)!
        let filePart = MultipartFormDataBody.Part(
            data: fileData,
            name: "file",
            mimeType: .textPlain,
            fileName: "test.txt"
        )

        let body = MultipartFormDataBody(parts: [textPart, filePart], boundary: "boundary")

        let data = try body.asData()
        let expectedString = "--boundary\r\nContent-Disposition: form-data; name=\"text-field\"\r\nContent-Type: text/plain\r\n\r\ntext-content\r\n--boundary\r\nContent-Disposition: form-data; name=\"file\"; filename=\"test.txt\"\r\nContent-Type: text/plain\r\n\r\nfile-content\r\n--boundary--\r\n"
        let expectedData = expectedString.data(using: .utf8)!

        XCTAssertEqual(data, expectedData, "should build correct data for multiple parts")
    }

    func testPartInitialization() {
        let testData = "test".data(using: .utf8)!

        let simplePart = MultipartFormDataBody.Part(data: testData, name: "test")
        XCTAssertEqual(simplePart.name, "test", "name should be 'test'")
        XCTAssertEqual(simplePart.mimeType, .textPlain, "default mimeType should be textPlain")
        XCTAssertNil(simplePart.fileName, "fileName should be nil by default")

        let fullPart = MultipartFormDataBody.Part(
            data: testData,
            name: "test",
            mimeType: .textPlain,
            fileName: "test.txt"
        )
        XCTAssertEqual(fullPart.name, "test", "name should be 'test'")
        XCTAssertEqual(fullPart.mimeType, .textPlain, "mimeType should be textPlain")
        XCTAssertEqual(fullPart.fileName, "test.txt", "fileName should be 'test.txt'")
    }

    func testIntegrationBuildAndRead() throws {
        let textData = "text field value".data(using: .utf8)!
        let textPart = MultipartFormDataBody.Part(data: textData, name: "text_field")

        let fileData = "file content".data(using: .utf8)!
        let filePart = MultipartFormDataBody.Part(
            data: fileData,
            name: "file_field",
            mimeType: .textPlain,
            fileName: "test.txt"
        )

        let boundary = "test-boundary"
        let body = MultipartFormDataBody(parts: [textPart, filePart], boundary: boundary)

        let data = try body.asData()
        let dataString = String(data: data, encoding: .utf8)!

        XCTAssertTrue(dataString.contains("--\(boundary)"), "should contain boundary")
        XCTAssertTrue(dataString.contains("name=\"text_field\""), "should contain text field name")
        XCTAssertTrue(dataString.contains("text field value"), "should contain text field value")
        XCTAssertTrue(dataString.contains("name=\"file_field\""), "should contain file field name")
        XCTAssertTrue(dataString.contains("filename=\"test.txt\""), "should contain filename")
        XCTAssertTrue(dataString.contains("Content-Type: text/plain"), "should contain content type")
        XCTAssertTrue(dataString.contains("file content"), "should contain file content")
        XCTAssertTrue(dataString.contains("--\(boundary)--"), "should contain closing boundary")
    }

    func testIntegrationValidateDataEntity() throws {
        let boundary = "a1b2c3d4e5f6a7b8"
        let value1 = "1".data(using: .utf8)!
        let value2 = "2".data(using: .utf8)!
        let parameters = MultipartFormDataBody(parts: [
            MultipartFormDataBody.Part(data: value1, name: "foo"),
            MultipartFormDataBody.Part(data: value2, name: "bar"),
        ], boundary: boundary)

        let data = try parameters.asData()
        let encodedData = String(data: data, encoding: .utf8)!

        let expectedString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\nContent-Type: text/plain\r\n\r\n1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"bar\"\r\nContent-Type: text/plain\r\n\r\n2\r\n--\(boundary)--\r\n"

        XCTAssertEqual(encodedData, expectedString, "should produce correctly formatted multipart data")
    }
}
