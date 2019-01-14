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
                     payload: Any? = nil, headers: JSONObject? = nil, timeOut: TimeInterval? = nil) -> JSONResult {
        return submitSyncRequest(method: method, url: url, queryParams: queryParams,
                                 payload: payload, headers: headers, timeOut: timeOut)
    }

}

// MARK: Instance HTTP Sync methods
public extension JSONRequest {

    public func get(url: String, queryParams: JSONObject? = nil,
                    headers: JSONObject? = nil) -> JSONResult {
        return send(method: .GET, url: url, queryParams: queryParams, headers: headers)
    }

    public func post(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                     headers: JSONObject? = nil) -> JSONResult {
        return send(method: .POST, url: url, queryParams: queryParams, payload: payload,
                    headers: headers)
    }

    public func put(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                    headers: JSONObject? = nil) -> JSONResult {
        return send(method: .PUT, url: url, queryParams: queryParams, payload: payload,
                    headers: headers)
    }

    public func patch(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                      headers: JSONObject? = nil) -> JSONResult {
        return send(method: .PATCH, url: url, queryParams: queryParams, payload: payload,
                    headers: headers)
    }

    public func delete(url: String, queryParams: JSONObject? = nil,
                       headers: JSONObject? = nil) -> JSONResult {
        return send(method: .DELETE, url: url, queryParams: queryParams, headers: headers)
    }

}

// MARK: Class HTTP Sync methods

public extension JSONRequest {

    public class func get(url: String, queryParams: JSONObject? = nil,
                          headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().get(url: url, queryParams: queryParams, headers: headers)
    }

    public class func post(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                           headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().post(url: url, queryParams: queryParams, payload: payload,
                                  headers: headers)
    }

    public class func put(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                          headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().put(url: url, queryParams: queryParams, payload: payload,
                                 headers: headers)
    }

    public class func patch(url: String, queryParams: JSONObject? = nil, payload: Any? = nil,
                            headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().patch(url: url, queryParams: queryParams, payload: payload,
                                   headers: headers)
    }

    public class func delete(url: String, queryParams: JSONObject? = nil,
                             headers: JSONObject? = nil) -> JSONResult {
        return JSONRequest().delete(url: url, queryParams: queryParams, headers: headers)
    }

}
