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
@testable import KarteUtilities

class MultipartFormDataBodySpec: QuickSpec {
    override class func spec() {
        describe("MultipartFormDataBody") {
            
            let boundary = String(
                format: "%08x%08x",
                UInt32.random(in: 0...UInt32.max),
                UInt32.random(in: 0...UInt32.max)
            )

            describe("initialization") {
                it("generates a random boundary when not provided") {
                    let parts: [MultipartFormDataBody.Part] = []
                    let body = MultipartFormDataBody(parts: parts, boundary: boundary)

                    expect(body.boundary).notTo(beEmpty())
                    expect(body.boundary.count).to(equal(16)) // 8 hex chars + 8 hex chars
                }
                
                it("uses the provided boundary") {
                    let parts: [MultipartFormDataBody.Part] = []
                    let customBoundary = "custom-boundary-123"
                    let body = MultipartFormDataBody(parts: parts, boundary: customBoundary)
                    
                    expect(body.boundary).to(equal(customBoundary))
                }
                
                it("stores the provided parts") {
                    let testData = "test".data(using: .utf8)!
                    let part = MultipartFormDataBody.Part(data: testData, name: "test")
                    let body = MultipartFormDataBody(parts: [part], boundary: boundary)

                    expect(body.parts.count).to(equal(1))
                    expect(body.parts.first?.name).to(equal("test"))
                }
            }
            

            describe("build") {
                it("builds empty data when no parts are provided") {
                    let parts: [MultipartFormDataBody.Part] = []
                    let body = MultipartFormDataBody(parts: parts, boundary: "boundary")
                    
                    let data = try body.asData()
                    let expectedData = "--boundary--\r\n".data(using: .utf8)!
                    
                    expect(data).to(equal(expectedData))
                }
                
                it("builds correct data for a simple part") {
                    let testData = "test-content".data(using: .utf8)!
                    let part = MultipartFormDataBody.Part(data: testData, name: "test-field")
                    let body = MultipartFormDataBody(parts: [part], boundary: "boundary")
                    
                    let data = try body.asData()
                    let expectedString = "--boundary\r\nContent-Disposition: form-data; name=\"test-field\"\r\nContent-Type: text/plain\r\n\r\ntest-content\r\n--boundary--\r\n"
                    let expectedData = expectedString.data(using: .utf8)!

                    expect(data).to(equal(expectedData))
                }
                
                it("builds correct data for a part with mime type and filename") {
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
                    
                    expect(data).to(equal(expectedData))
                }
                
                it("builds correct data for multiple parts") {
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

                    expect(data).to(equal(expectedData))
                }
            }
        }
        
        describe("Part") {
            it("initializes with data and name") {
                let testData = "test".data(using: .utf8)!
                let part = MultipartFormDataBody.Part(data: testData, name: "test")
                
                expect(part.name).to(equal("test"))
                expect(part.mimeType).to(equal(.textPlain))
                expect(part.fileName).to(beNil())
            }
            
            it("initializes with data, name, mimeType, and fileName") {
                let testData = "test".data(using: .utf8)!
                let part = MultipartFormDataBody.Part(
                    data: testData,
                    name: "test",
                    mimeType: .textPlain,
                    fileName: "test.txt"
                )
                
                expect(part.name).to(equal("test"))
                expect(part.mimeType).to(equal(.textPlain))
                expect(part.fileName).to(equal("test.txt"))
            }
        }
        
        describe("integration tests") {
            it("builds and reads multipart form data correctly") {
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
                
                expect(dataString).to(contain("--\(boundary)"))
                expect(dataString).to(contain("name=\"text_field\""))
                expect(dataString).to(contain("text field value"))
                expect(dataString).to(contain("name=\"file_field\""))
                expect(dataString).to(contain("filename=\"test.txt\""))
                expect(dataString).to(contain("Content-Type: text/plain"))
                expect(dataString).to(contain("file content"))
                expect(dataString).to(contain("--\(boundary)--"))
            }
            
            it("validates data entity with regex pattern matching") {
                let boundary = String(
                    format: "%08x%08x",
                    UInt32.random(in: 0...UInt32.max),
                    UInt32.random(in: 0...UInt32.max)
                )
                let value1 = "1".data(using: .utf8)!
                let value2 = "2".data(using: .utf8)!
                let parameters = MultipartFormDataBody(parts: [
                    MultipartFormDataBody.Part(data: value1, name: "foo"),
                    MultipartFormDataBody.Part(data: value2, name: "bar"),
                ], boundary: boundary)

                let data = try parameters.asData()
                let encodedData = String(data: data, encoding: .utf8)!

                let expectedString = "--\(boundary)\r\nContent-Disposition: form-data; name=\"foo\"\r\nContent-Type: text/plain\r\n\r\n1\r\n--\(boundary)\r\nContent-Disposition: form-data; name=\"bar\"\r\nContent-Type: text/plain\r\n\r\n2\r\n--\(boundary)--\r\n"

                expect(encodedData).to(equal(expectedString))
            }
        }
    }
}
