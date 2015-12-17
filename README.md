JSONRequest
==================

JSONRequest is a tiny Swift library to do HTTP JSON requests. 

JSONRequest provides a clean and easy-to-use API to submit HTTP requests both **asynchronously** and **synchronously** (see [Why Synchronous? Are you crazy?](http://github.com)).

## Basic Sync Usage

### Basic GET

```
let result = JSONRequest.get("http://httpbin.org/get?hello=world")
if let value = result.data?["args"]??["hello"] as? String {
    print(value) // Outputs "world"
}
```

### Basic POST

```
let postResult = JSONRequest.post("http://httpbin.org/post", payload: ["hello": "world"])
if let value = postResult.data?["json"]??["hello"] as? String {
    print(value) // Outputs "world"
}
```

## Basic Async Usage

### Basic GET

```
JSONRequest.get("http://httpbin.org/get?hello=world") { result in
    if let value = result.data?["args"]??["hello"] as? String {
        print(value) // Outputs "world"
    }
}
```

### Basic POST

```
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

## Advanced Usage

### Handling `.Success` and `.Failure`

### Complex Sync requests

### Complex Async requests

### Custom Headers
All JSONRequest requests automatically include the following default headers:

```
Content-Type: application/json
Accept: application/json
```

Custom headers can be added in addition or to replace the default headers, by passing a `[String: AnyObject]` dictionary as follows:

#### GET with custom headers


#### POST with custom headers


### Accessing the URL Request

The underlining `NSMutableURLRequest` object can be accessed via the `urlRequest` property.

## Why Synchronous? Are you crazy?


### Usage in iOS Apps

### Usage in Command-Line Apps

### Usage in Playgrounds

