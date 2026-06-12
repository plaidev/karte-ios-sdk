import XCTest
@testable import KarteUtilities

class SessionSpec: XCTestCase {

    override func tearDown() {
        HTTPStubProtocol.removeAllStubs()
        super.tearDown()
    }

    // MARK: - static send method

    func testStaticSendDelegatesToSharedInstanceAndReturnsTask() {
        _ = HTTPStubProtocol.addStub(matcher: http(.get, uri: "https://example.com/test"), builder: jsonData("test response".data(using: .utf8)!))

        let exp = expectation(description: "handler called")
        let task = Session.send(RequestMock()) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3.0)
        XCTAssertNotNil(task, "should return a task")
    }

    // MARK: - instance send method (request building succeeds)

    func testInstanceSendCreatesAndReturnsDataTask() {
        _ = HTTPStubProtocol.addStub(matcher: http(.get, uri: "https://example.com"), builder: jsonData(Data()))

        let exp = expectation(description: "handler called")
        let task = Session.send(RequestMock()) { _ in
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3.0)
        XCTAssertNotNil(task, "should return a task")
    }

    func testNetworkRequestSuccessCallsHandlerWithSuccess() {
        let request = RequestMock(baseURL: URL(string: "https://example.com")!, path: "/test", parseResult: "mocked response")
        _ = HTTPStubProtocol.addStub(matcher: http(.get, uri: "https://example.com/test"), builder: jsonData("test response".data(using: .utf8)!))

        let exp = expectation(description: "handler called")
        var result: Result<String, NetworkingError>?
        _ = Session.send(request) { res in
            result = res
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3.0)

        switch result {
        case .success(let response):
            XCTAssertEqual(response, "mocked response", "should return mocked response")
        case .failure(let error):
            XCTFail("Expected success but got error: \(error)")
        case .none:
            XCTFail("Expected result but got nil")
        }
    }

    func testNetworkRequestFailureCallsHandlerWithInvalidStatusCode() {
        let request = RequestMock(baseURL: URL(string: "https://example.com")!, path: "/test-fail")
        _ = HTTPStubProtocol.addStub(matcher: http(.get, uri: "https://example.com/test-fail"), builder: http(500))

        let exp = expectation(description: "handler called")
        var result: Result<String, NetworkingError>?
        _ = Session.send(request) { res in
            result = res
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3.0)

        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            if case .responseError(let responseError as NetworkingError) = error {
                if case .invalidStatusCode(let statusCode) = responseError {
                    XCTAssertEqual(statusCode, 500, "should return 500 status code")
                } else {
                    XCTFail("Expected invalidStatusCode but got \(error)")
                }
            } else {
                XCTFail("Expected invalidStatusCode but got \(error)")
            }
        case .none:
            XCTFail("Expected result but got nil")
        }
    }

    func testResponseParsingFailureCallsHandlerWithResponseError() {
        let request = RequestMock(baseURL: URL(string: "https://example.com")!, path: "/test-parse", shouldThrowFromParse: true)
        _ = HTTPStubProtocol.addStub(matcher: http(.get, uri: "https://example.com/test-parse"), builder: jsonData("valid response".data(using: .utf8)!))

        let exp = expectation(description: "handler called")
        var result: Result<String, NetworkingError>?
        _ = Session.send(request) { res in
            result = res
            exp.fulfill()
        }

        wait(for: [exp], timeout: 3.0)

        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            let underlyingError = NSError(domain: "RequestMockError", code: -1, userInfo: nil)
            if case .responseError(let storedError) = error {
                XCTAssertEqual(storedError as NSError, underlyingError, "should contain the underlying parse error")
            } else {
                XCTFail("Expected responseError but got \(error)")
            }
        case .none:
            XCTFail("Expected result but got nil")
        }
    }

    // MARK: - instance send method (request building fails)

    func testRequestBuildingFailureCallsHandlerWithErrorAndReturnsNil() {
        let request = RequestMock(shouldThrowFromBuildBody: true)

        let exp = expectation(description: "handler called")
        var result: Result<String, NetworkingError>?
        let task = Session.send(request) { res in
            result = res
            exp.fulfill()
        }

        XCTAssertNil(task, "should return nil when request building fails")

        wait(for: [exp], timeout: 1.0)

        switch result {
        case .success:
            XCTFail("Expected failure but got success")
        case .failure(let error):
            let underlyingError = NSError(domain: "MockBodyError", code: -1, userInfo: nil)
            if case .requestBuildFailed(let storedError) = error {
                XCTAssertEqual(storedError as NSError, underlyingError, "should contain the underlying build error")
            } else {
                XCTFail("Expected requestBuildFailed case but got \(error)")
            }
        case .none:
            XCTFail("Expected result but got nil")
        }
    }
}
