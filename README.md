JSONRequestManager
==================

##Usage


### GET some JSON
```
JSONRequestManager.get("http://httpbin.org/get", params: nil, complete: { (JSON) -> Void in
  // JSON is an NSArray or NSDictionary
  print(JSON)
}) { (body, error) -> Void in
  // Handle error
}
```


### POST some JSON
```
let payload = ["somekey": "somevalue", "anotherkey": "another value"]
JSONRequestManager.post("http://httpbin.org/post", payload: payload, complete: { (JSON) -> Void in
  // JSON is an NSArray or NSDictionary
  print JSON
}) { (body, error) -> Void in
  // Handle error
}
```

