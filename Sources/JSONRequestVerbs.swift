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
    func send(method: JSONRequestHttpVerb, url: String, queryParams: JSONObject? = nil, payload: Any? = nil, headers: JSONObject? = nil, timeOut: TimeInterval? = nil) -> JSONResult {
        return submitSyncRequest(method: method, url: url, queryParams: queryParams,
                                 payload: payload, headers: headers, timeOut: timeOut)
    }

}

// MARK: Instance HTTP Sync methods
public extension JSONRequest {

    func get(url: String, queryParams: JSONObject? = nil, headers: JSONObject? = nil) -> JSONResult {
        return send(method: .GET, url: url, queryParams: queryParams, headers: headers)
    }

    func post(url: String, queryParams: JSONObject? = nil, payload: Any? = nil, headers: JSONObject? = nil) -> JSONResult {
        return send(method: .POST, url: url, queryParams: queryParams, payload: payload,
                    headers: headers)
    }

    func put(url: String, queryParams: JSONObject? = nil, payload: Any? = nil, headers: JSONObject? = nil) -> JSONResult {
        return send(method: .PUT, url: url, queryParams: queryParams, payload: payload,
                    headers: headers)
    }

    func patch(url: String, queryParams: JSONObject? = nil, payload: Any? = nil, headers: JSONObject? = nil) -> JSONResult {
        return send(method: .PATCH, url: url, queryParams: queryParams, payload: payload,
                    headers: headers)
    }

    func delete(url: String, queryParams: JSONObject? = nil, headers: JSONObject? = nil) -> JSONResult {
        return send(method: .DELETE, url: url, queryParams: queryParams, headers: headers)
    }

}
