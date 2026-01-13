import Quick
import Nimble
@testable import KarteUtilities

class HTTPMethodSpec: QuickSpec {
    override class func spec() {
        describe("HTTPMethod") {
            describe("raw values") {
                it("has correct raw value for GET") {
                    expect(HTTPMethod.get.rawValue).to(equal("GET"))
                }
                
                it("has correct raw value for POST") {
                    expect(HTTPMethod.post.rawValue).to(equal("POST"))
                }
            }
            
            describe("initialization from raw value") {
                it("creates GET from string") {
                    let method = HTTPMethod(rawValue: "GET")
                    expect(method).to(equal(.get))
                }
                
                it("creates POST from string") {
                    let method = HTTPMethod(rawValue: "POST")
                    expect(method).to(equal(.post))
                }
                
                it("returns nil for invalid string") {
                    let method = HTTPMethod(rawValue: "INVALID")
                    expect(method).to(beNil())
                }
                
                it("is case sensitive") {
                    let method = HTTPMethod(rawValue: "get")
                    expect(method).to(beNil())
                }
            }
        }
    }
}
