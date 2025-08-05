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

class RequestSpec: QuickSpec {
    override func spec() {
        describe("a request") {
            
            describe("its buildURLRequest") {
                context("when baseURL is valid") {
                    it("builds a URL request with the correct URL") {
                        let baseURL = URL(string: "https://example.com")!
                        let path = "/test/path"
                        let request = RequestMock(baseURL: baseURL, path: path)
                        
                        let urlRequest = try request.buildURLRequest()
                        
                        expect(urlRequest.url?.absoluteString).to(equal("https://example.com/test/path"))
                    }
                    
                    it("uses baseURL directly when path is empty") {
                        let baseURL = URL(string: "https://example.com")!
                        let request = RequestMock(baseURL: baseURL, path: "")
                        
                        let urlRequest = try request.buildURLRequest()
                        
                        expect(urlRequest.url?.absoluteString).to(equal("https://example.com"))
                    }
                    
                    it("sets the HTTP method correctly") {
                        let request = RequestMock(method: .post)
                        
                        let urlRequest = try request.buildURLRequest()
                        
                        expect(urlRequest.httpMethod).to(equal("POST"))
                    }
                    
                    it("sets the Accept header from responseParser") {
                        let request = RequestMock(acceptableMediaType: "application/test")

                        let urlRequest = try request.buildURLRequest()
                        
                        expect(urlRequest.value(forHTTPHeaderField: "Accept")).to(equal("application/test"))
                    }
                    
                    it("sets custom header fields") {
                        let headerFields = ["X-Custom-Header": "CustomValue"]
                        let request = RequestMock(headerFields: headerFields)
                        
                        let urlRequest = try request.buildURLRequest()
                        
                        expect(urlRequest.value(forHTTPHeaderField: "X-Custom-Header")).to(equal("CustomValue"))
                    }
                    
                    context("with body parameters") {
                        it("sets Content-Type header from bodyParameters") {
                            let request = RequestMock(contentType: "application/custom")

                            let urlRequest = try request.buildURLRequest()
                            
                            expect(urlRequest.value(forHTTPHeaderField: "Content-Type")).to(equal("application/custom"))
                        }
                        
                        it("sets httpBody from bodyParameters.build()") {
                            let testData = "test data".data(using: .utf8)!
                            let request = RequestMock(buildBodyResult: testData)

                            let urlRequest = try request.buildURLRequest()
                            
                            expect(urlRequest.httpBody).to(equal(testData))
                        }
                        
                        it("propagates errors from bodyParameters.build()") {
                            let request = RequestMock(shouldThrowFromBuildBody: true)

                            expect { try request.buildURLRequest() }.to(throwError())
                        }
                    }
                }
            }
            
            describe("its parse") {
                let successStatusCode = 200
                let failureStatusCode = 400
                let testData = "test data".data(using: .utf8)!
                
                func createHTTPURLResponse(statusCode: Int) -> HTTPURLResponse {
                    return HTTPURLResponse(
                        url: URL(string: "https://example.com")!,
                        statusCode: statusCode,
                        httpVersion: nil,
                        headerFields: nil
                    )!
                }
                
                context("when status code is successful (200-299)") {
                    it("returns the expected response") {
                        let request = RequestMock()
                        let response = createHTTPURLResponse(statusCode: successStatusCode)
                        
                        let result = try request.parse(data: testData, urlResponse: response)

                        expect(result).to(equal("success response"))
                    }
                    
                    it("propagates errors from dataParser.parse()") {
                        let request = RequestMock(shouldThrowFromParse: true)
                        let response = createHTTPURLResponse(statusCode: successStatusCode)

                        expect { try request.parse(data: testData, urlResponse: response) }.to(throwError())
                    }
                }
                
                context("when status code is not successful") {
                    it("throws NetworkingError.invalidStatusCode") {
                        let request = RequestMock()
                        let response = createHTTPURLResponse(statusCode: failureStatusCode)
                        
                        expect { try request.statusCodeCheck(urlResponse: response) }
                            .to(throwError(NetworkingError.invalidStatusCode(failureStatusCode)))
                    }
                }
            }
            
            
            describe("its default implementation") {
                it("returns empty dictionary for headerFields") {
                    let request = RequestMock()
                    
                    expect(request.headerFields).to(beEmpty())
                }
                
                describe("its default intercept(object:urlResponse:)") {
                    context("when status code is in 200-299 range") {
                        it("returns the object unchanged") {
                            let testObject = "test object"
                            let response = HTTPURLResponse(
                                url: URL(string: "https://example.com")!,
                                statusCode: 200,
                                httpVersion: nil,
                                headerFields: nil
                            )!
                            
                            struct DefaultRequest: Request {
                                typealias Response = String
                                var baseURL: URL { URL(string: "https://example.com")! }
                                var method: HTTPMethod { .get }
                                var path: String { "" }
                                var headerFields: [String : String] { [:] }
                                var contentType: String {
                                    ""
                                }
                                func buildBody() throws -> Data? {
                                    nil
                                }
                                func parse(data: Data, urlResponse: HTTPURLResponse) throws -> String {
                                    return ""
                                }
                            }
                            
                            let request = DefaultRequest()
                            expect(try request.statusCodeCheck(urlResponse: response)).toNot(throwError())

                        }
                    }
                    
                    context("when status code is outside 200-299 range") {
                        it("throws ResponseError.unacceptableStatusCode") {
                            let testObject = "test object"
                            let statusCode = 400
                            let response = HTTPURLResponse(
                                url: URL(string: "https://example.com")!,
                                statusCode: statusCode,
                                httpVersion: nil,
                                headerFields: nil
                            )!
                            
                            struct DefaultRequest: Request {
                                typealias Response = String
                                var baseURL: URL { URL(string: "https://example.com")! }
                                var method: HTTPMethod { .get }
                                var path: String { "" }
                                var headerFields: [String: String] { [:] }
                                var contentType: String { "" }

                                func buildBody() throws -> Data? {
                                    nil
                                }
                                func parse(data: Data, urlResponse: HTTPURLResponse) throws -> String {
                                    return ""
                                }
                            }
                            
                            let request = DefaultRequest()
                            
                            expect { try request.statusCodeCheck(urlResponse: response) }
                                .to(throwError(NetworkingError.invalidStatusCode(statusCode)))
                        }
                    }
                }
            }
        }
    }
}
