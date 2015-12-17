import XCPlayground
import JSONRequest

/**
    Synchronous API
*/

let result = JSONRequest.get("http://httpbin.org/get?hello=world")
if let value = result.data?["args"]??["hello"] as? String {
    print(value) // Outputs "world"
}



//let request = JSONRequest()
//
//// async
//request.get("http://httpbin.org/get", params: ["hello": "world async"]) { result in
//    print(result.data?["args"]??["hello"])
//}
//
//// sync
//let result = try? request.get("http://httpbin.org/get", params: ["hello": "world sync"])
//print(result?.data?["args"]??["hello"])





// Wait for async calls to complete
XCPlaygroundPage.currentPage.needsIndefiniteExecution = true
