import XCPlayground
import Foundation
import JSONRequest

// Allow network requests to complete
XCPSetExecutionShouldContinueIndefinitely()

println("hello")

JSONRequest.get("http://httpbin.org/get", params: ["hello": "world"]) { (JSON, response, error) -> Void in
    // JSON is an NSArray, NSDictionary or nil if an error happened
    println(JSON)
    println(response)
    println(error)
}
