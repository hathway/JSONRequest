JSONRequest
==================

JSONRequest is a tiny Swift library to do HTTP JSON requests. 

![](https://img.shields.io/cocoapods/v/JSONRequest.svg)
![](http://img.shields.io/badge/iOS-8.4%2B-blue.svg)
![](http://img.shields.io/badge/Swift-3.0-orange.svg)

JSONRequest provides a clean and easy-to-use API to submit HTTP requests both **asynchronously** and **synchronously** (see [Why Synchronous? Are you crazy?](#why-synchronous-are-you-crazy)).

## Synchronous Usage

### Synchronous GET

```swift
let result = JSONRequest.get("http://httpbin.org/get?hello=world")
if let value = result.data?["args"]??["hello"] as? String {
    print(value) // Outputs "world"
}
```

### Synchronous POST

```swift
let postResult = JSONRequest.post("http://httpbin.org/post", payload: ["hello": "world"])
if let value = postResult.data?["json"]??["hello"] as? String {
    print(value) // Outputs "world"
}
```

## Asynchronous Usage

### Asynchronous GET

```swift
JSONRequest.get("http://httpbin.org/get?hello=world") { result in
    if let value = result.data?["args"]??["hello"] as? String {
        print(value) // Outputs "world"
    }
}
```

### Asynchronous POST

```swift
JSONRequest.post("http://httpbin.org/post", payload: ["hello": "world"]) { result in
    if let value = result.data?["json"]??["hello"] as? String {
        print(value) // Outputs "world"
    }
}
```

## Sending Data to the Server

### Query Parameters
URL parameters can be passed as a `[String: AnyObject]` dictionary and are automatically URL-encoded 
and appended to the URL string. All requests allow for query parameters, independently of the HTTP 
method used. Values of the query parameter dictionary will be converted to `String` before being 
URL-encoded.

### JSON Payload

Response is automatically parsed (valid JSON response is expected) and returned as AnyObject (valid 
JSON values include `Array`, `Dictionary`, `Int`, `Double`, `String` and `nil`)


### Custom Headers
All JSONRequest requests automatically include the following default headers:

```
Content-Type: application/json
Accept: application/json
```

The underlining `NSMutableURLRequest` object can be accessed via the `urlRequest` property.

## Testing

### DVR
JSONRequest uses [DVR](https://github.com/venmo/DVR) for testing. DVR records the HTTP interactions of the tests and replays them during future runthroughs.

#### Usage
Each test target should contain a setup function that should look like this:
```swift
override func setUp() {
    JSONRequest.requireNetworkAccess = false
    // anything else that needs to be setup
    super.setUp()
}
```
Setting the ```requireNetworkAccess``` variable disables errors due to lack of internet, allowing tests to pass wherever you might need to test.

**It should be noted that internet access is REQUIRED the first time a test is run so that DVR can record the responses given.**

After you have your target setup you can test easily by creating your own instance of JSONRequest and pointing it to the stored response file.

```swift
func testMyAmazingChange() {
    let jsonRequest = JSONRequest(session: DVR.Session(cassetteName: "testFiles/testMyAmazingChange"))
    // all network calls and asserts using jsonRequest
}
```
The first time the test is run DVR will record the requests and responses made, storing both in the file indicated.
When the test has finished DVR will abort testing and print out the location of the saved file which you will need to add to xcode.

## Why Synchronous? Are you crazy?

### Usage in iOS Apps

### Usage in Command-Line Apps

### Usage in Playgrounds

