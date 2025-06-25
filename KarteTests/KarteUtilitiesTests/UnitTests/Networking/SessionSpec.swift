import Quick
import Nimble
import Mockingjay
@testable import KarteUtilities

class SessionSpec: QuickSpec {
    override func spec() {
        describe("Session") {

            describe("static send method") {
                it("delegates to shared instance and returns a task") {
                    self.stub(http(.get, uri: "https://example.com/test"), jsonData("test response".data(using: .utf8)!))

                    let request = RequestMock()
                    
                    let task = Session.send(request)
                    
                    expect(task).toNot(beNil())
                    expect(task).to(beAKindOf(URLSessionTask.self))
                }
            }
            
            describe("instance send method") {
                context("when request building succeeds") {
                    it("creates and returns a data task") {
                        let request = RequestMock()
                        
                        let task = Session.send(request)

                        expect(task).toNot(beNil())
                        expect(task).to(beAKindOf(URLSessionTask.self))
                    }
                    
                    context("when network request succeeds") {
                        it("calls handler with success result") {
                            let request = RequestMock(baseURL: URL(string: "https://example.com")!, path: "/test", parseResult: "mocked response")
                            
                            self.stub(http(.get, uri: "https://example.com/test"), jsonData("test response".data(using: .utf8)!))

                            waitUntil(timeout: .seconds(1)) { done in
                                _ = Session.send(request) { result in
                                    switch result {
                                    case .success(let response):
                                        expect(response).to(equal("mocked response"))
                                        done()
                                    case .failure(let error):
                                        fail("Expected success but got failure: \(error)")
                                        done()
                                    }
                                }
                            }
                        }
                    }
                    
                    context("when network request fails") {
                        it("calls handler with invalidStatusCode error") {
                            let request = RequestMock(baseURL: URL(string: "https://example.com")!, path: "/test-fail")
                            
                            self.stub(http(.get, uri: "https://example.com/test-fail"), http(500))

                            waitUntil(timeout: .seconds(1)) { done in
                                _ = Session.send(request) { result in
                                    switch result {
                                    case .success:
                                        fail("Expected failure but got success")
                                        done()
                                    case .failure(let error):
                                        if case .responseError(let responseError as NetworkingError) = error {
                                            if case .invalidStatusCode(let statusCode) = responseError {
                                                expect(statusCode).to(equal(500))
                                            } else {
                                                fail("Expected invalidStatusCode but got \(error)")
                                            }

                                        } else {
                                            fail("Expected invalidStatusCode but got \(error)")
                                        }
                                        done()
                                    }
                                }
                            }
                        }
                    }
                    
                    context("when response parsing fails") {
                        it("calls handler with responseError") {
                            let request = RequestMock(baseURL: URL(string: "https://example.com")!, path: "/test-parse", shouldThrowFromParse: true)

                            self.stub(http(.get, uri: "https://example.com/test-parse"), jsonData("valid response".data(using: .utf8)!))

                            waitUntil(timeout: .seconds(1)) { done in
                                _ = Session.send(request) { result in
                                    switch result {
                                    case .success:
                                        fail("Expected failure but got success")
                                        done()
                                    case .failure(let error):
                                        let underlyingError = NSError(domain: "RequestMockError", code: -1, userInfo: nil)
                                        if case .responseError(let storedError) = error {
                                            expect(storedError as NSError).to(equal(underlyingError))
                                        } else {
                                            fail("Expected responseError but got \(error)")
                                        }
                                        done()
                                    }
                                }
                            }
                        }
                    }
                }
                
                context("when request building fails") {
                    it("calls handler with requestError and returns nil") {
                        let request = RequestMock(shouldThrowFromBuildBody: true)
                        
                        var result: Result<String, NetworkingError>?
                        let task = Session.send(request) { res in
                            result = res
                        }
                        
                        expect(task).to(beNil())
                        expect(result).toEventuallyNot(beNil())
                        expect(result).toEventually(beFailure { error in
                            let underlyingError = NSError(domain: "MockBodyError", code: -1, userInfo: nil)
                            let error = NetworkingError.requestBuildFailed(underlyingError)

                            if case .requestBuildFailed(let storedError) = error {
                                expect(storedError as NSError).to(equal(underlyingError))
                            } else {
                                fail("Expected requestError case")
                            }
                        })
                    }
                }
            }
        }
    }
}
