//
//  JSONRequestVerbs.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 1/11/16.
//  Copyright © 2016 Hathway. All rights reserved.
//

public enum JSONRequestHttpVerb: String {
    case GET
    case POST
    case PUT
    case PATCH
    case DELETE
}

// MARK: Instance basic sync/async

extension JSONRequest {

    public func send(method: JSONRequestHttpVerb, url: String, queryParams: JSONObject? = nil,
                     payload: Any? = nil, headers: JSONObject? = nil,
                     complete: @escaping (JSONResult) -> Void) {

        submitAsyncRequest(method: method, url: url, queryParams: queryParams, payload: payload,
                           headers: headers, complete: complete)
    }

    public func send(method: JSONRequestHttpVerb, url: String, queryParams: JSONObject? = nil,
                     payload: Any? = nil, headers: JSONObject? = nil, timeOut: TimeInterval? = nil) -> JSONResult {
        return submitSyncRequest(method: method, url: url, queryParams: queryParams,
                                 payload: payload, headers: headers, timeOut: timeOut)
    }

}

// MARK: Instance HTTP Sync methods

public extension JSONRequest {

    func get(url: String, queryParams: JSONObject? = nil,
             headers: JSONObject? = nil) -> JSONResult {
        return send(method: .GET, url: url, queryParams: queryParams, headers: headers)
    }

    func post(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
              headers: JSONObject? = nil) -> JSONResult {
        return send(method: .POST, url: url, queryParams: queryParams, payload: payload,
                    headers: headers)
    }

    func put(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
             headers: JSONObject? = nil) -> JSONResult {
        return send(method: .PUT, url: url, queryParams: queryParams, payload: payload,
                    headers: headers)
    }

    func patch(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
               headers: JSONObject? = nil) -> JSONResult {
        return send(method: .PATCH, url: url, queryParams: queryParams, payload: payload,
                    headers: headers)
    }

    func delete(url: String, queryParams: JSONObject? = nil,
                headers: JSONObject? = nil) -> JSONResult {
        return send(method: .DELETE, url: url, queryParams: queryParams, headers: headers)
    }

}

// MARK: Instance HTTP Async methods

public extension JSONRequest {

    func get(url: String, queryParams: JSONObject? = nil, headers: JSONObject? = nil,
             complete: @escaping (JSONResult) -> Void) {
        send(method: .GET, url: url, queryParams: queryParams, headers: headers,
             complete: complete)
    }

    func post(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
              headers: JSONObject? = nil, complete: @escaping (JSONResult) -> Void) {
        send(method: .POST, url: url, queryParams: queryParams, payload: payload,
             headers: headers, complete: complete)
    }

    func put(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
             headers: JSONObject? = nil, complete: @escaping (JSONResult) -> Void) {
        send(method: .PUT, url: url, queryParams: queryParams, payload: payload,
             headers: headers, complete: complete)
    }

    func patch(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
               headers: JSONObject? = nil, complete: @escaping (JSONResult) -> Void) {
        send(method: .PATCH, url: url, queryParams: queryParams, payload: payload,
             headers: headers, complete: complete)
    }

    func delete(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                headers: JSONObject? = nil, complete: @escaping (JSONResult) -> Void) {
        send(method: .DELETE, url: url, queryParams: queryParams, headers: headers,
             complete: complete)
    }

}

// MARK: Class HTTP Sync methods

public extension JSONRequest {

    class func get(url: String, queryParams: JSONObject? = nil,
                   headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().get(url: url, queryParams: queryParams, headers: headers)
    }

    class func post(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                    headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().post(url: url, queryParams: queryParams, payload: payload,
                                  headers: headers)
    }

    class func put(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                   headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().put(url: url, queryParams: queryParams, payload: payload,
                                 headers: headers)
    }

    class func patch(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                     headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().patch(url: url, queryParams: queryParams, payload: payload,
                                   headers: headers)
    }

    class func delete(url: String, queryParams: JSONObject? = nil,
                      headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().delete(url: url, queryParams: queryParams, headers: headers)
    }

}

// MARK: Class HTTP Async methods

public extension JSONRequest {

    class func get(url: String, queryParams: JSONObject? = nil, headers: JSONObject? = nil,
                   complete: @escaping (JSONResult) -> Void) {
        JSONRequest().get(url: url, queryParams: queryParams, headers: headers, complete: complete)
    }

    class func post(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                    headers: JSONObject? = nil, complete: @escaping (JSONResult) -> Void) {
        JSONRequest().post(url: url, queryParams: queryParams, payload: payload, headers: headers,
                           complete: complete)
    }

    class func put(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                   headers: JSONObject? = nil, complete: @escaping (JSONResult) -> Void) {
        JSONRequest().put(url: url, queryParams: queryParams, payload: payload, headers: headers,
                          complete: complete)
    }

    class func patch(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                     headers: JSONObject? = nil, complete: @escaping (JSONResult) -> Void) {
        JSONRequest().patch(url: url, queryParams: queryParams, payload: payload, headers: headers,
                            complete: complete)
    }

    class func delete(url: String, queryParams: JSONObject? = nil,
                      headers: JSONObject? = nil, complete: @escaping (JSONResult) -> Void) {
        JSONRequest().delete(url: url, queryParams: queryParams, headers: headers,
                             complete: complete)
    }
}
