//
//  JSONRequestVerbs.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 1/11/16.
//  Copyright © 2016 Hathway. All rights reserved.
//


public enum JSONRequestHttpVerb: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

// MARK: Instance basic sync/async

public extension JSONRequest {

    public func send(method: JSONRequestHttpVerb, url: String, queryParams: JSONObject? = nil,
                     payload: AnyObject? = nil, headers: JSONObject? = nil) -> JSONResult {

        return submitSyncRequest(method, url: url, queryParams: queryParams,
                                 payload: payload, headers: headers)
    }

    public func send(method: JSONRequestHttpVerb, url: String, queryParams: JSONObject? = nil,
                     payload: AnyObject? = nil, headers: JSONObject? = nil,
                     complete: (result: JSONResult) -> Void) {

        submitAsyncRequest(method, url: url, queryParams: queryParams, payload: payload,
                           headers: headers, complete: complete)
    }

}

// MARK: Instance HTTP Sync methods

public extension JSONRequest {

    public func get(url: String, queryParams: JSONObject? = nil,
                    headers: JSONObject? = nil) -> JSONResult {
        return submitSyncRequest(.GET, url: url, queryParams: queryParams, headers: headers)
    }

    public func post(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                     headers: JSONObject? = nil) -> JSONResult {
        return submitSyncRequest(.POST, url: url, queryParams: queryParams, payload: payload,
                                 headers: headers)
    }

    public func put(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                    headers: JSONObject? = nil) -> JSONResult {
        return submitSyncRequest(.PUT, url: url, queryParams: queryParams, payload: payload,
                                 headers: headers)
    }

    public func patch(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                      headers: JSONObject? = nil) -> JSONResult {
        return submitSyncRequest(.PATCH, url: url, queryParams: queryParams, payload: payload,
                                 headers: headers)
    }

    public func delete(url: String, queryParams: JSONObject? = nil,
                       headers: JSONObject? = nil) -> JSONResult {
        return submitSyncRequest(.DELETE, url: url, queryParams: queryParams, headers: headers)
    }

}


// MARK: Instance HTTP Async methods

public extension JSONRequest {

    public func get(url: String, queryParams: JSONObject? = nil, headers: JSONObject? = nil,
                    complete: (result: JSONResult) -> Void) {
        submitAsyncRequest(.GET, url: url, queryParams: queryParams, headers: headers,
                           complete: complete)
    }

    public func post(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                     headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
        submitAsyncRequest(.POST, url: url, queryParams: queryParams, payload: payload,
                           headers: headers, complete: complete)
    }

    public func put(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                    headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
        submitAsyncRequest(.PUT, url: url, queryParams: queryParams, payload: payload,
                           headers: headers, complete: complete)
    }

    public func patch(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                      headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
        submitAsyncRequest(.PATCH, url: url, queryParams: queryParams, payload: payload,
                           headers: headers, complete: complete)
    }

    public func delete(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                       headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
        submitAsyncRequest(.DELETE, url: url, queryParams: queryParams, headers: headers,
                           complete: complete)
    }

}


// MARK: Class HTTP Sync methods

public extension JSONRequest {

    public class func get(url: String, queryParams: JSONObject? = nil,
                          headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().get(url, queryParams: queryParams, headers: headers)
    }

    public class func post(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                           headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().post(url, queryParams: queryParams, payload: payload,
                                  headers: headers)
    }

    public class func put(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                          headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().put(url, queryParams: queryParams, payload: payload,
                                 headers: headers)
    }

    public class func patch(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                            headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().patch(url, queryParams: queryParams, payload: payload,
                                   headers: headers)
    }

    public class func delete(url: String, queryParams: JSONObject? = nil,
                             headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().delete(url, queryParams: queryParams, headers: headers)
    }

}


// MARK: Class HTTP Async methods

public extension JSONRequest {

    public class func get(url: String, queryParams: JSONObject? = nil, headers: JSONObject? = nil,
                          complete: (result: JSONResult) -> Void) {
        JSONRequest().get(url, queryParams: queryParams, headers: headers, complete: complete)
    }

    public class func post(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                           headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
        JSONRequest().post(url, queryParams: queryParams, payload: payload, headers: headers,
                           complete: complete)
    }

    public class func put(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                          headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
        JSONRequest().put(url, queryParams: queryParams, payload: payload, headers: headers,
                          complete: complete)
    }

    public class func patch(url: String, queryParams: JSONObject? = nil, payload: AnyObject? = nil,
                            headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
        JSONRequest().patch(url, queryParams: queryParams, payload: payload, headers: headers,
                            complete: complete)
    }

    public class func delete(url: String, queryParams: JSONObject? = nil,
                             headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
        JSONRequest().delete(url, queryParams: queryParams, headers: headers, complete: complete)
    }

}
