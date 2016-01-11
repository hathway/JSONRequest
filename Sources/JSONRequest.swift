//
//  JSONRequest.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 9/12/14.
//  Copyright (c) 2014 Hathway. All rights reserved.
//

import Foundation

public typealias JSONObject = Dictionary<String, AnyObject?>

public enum JSONError: ErrorType {
    case InvalidURL
    case PayloadSerialization

    case RequestFailed
    case NonHTTPResponse
    case ResponseDeserialization
    case UnknownError
}

public enum JSONResult {
    case Success(data: AnyObject?, response: NSHTTPURLResponse)
    case Failure(error: JSONError, response: NSHTTPURLResponse?, body: String?)
}

public extension JSONResult {

    public var data: AnyObject? {
        switch self {
        case .Success(let data, _):
            return data
        case .Failure:
            return nil
        }
    }

    public var arrayValue: [AnyObject] {
        return data as? [AnyObject] ?? []
    }

    public var dictionaryValue: [String: AnyObject] {
        return data as? [String: AnyObject] ?? [:]
    }

    public var httpResponse: NSHTTPURLResponse? {
        switch self {
        case .Success(_, let response):
            return response
        case .Failure(_, let response, _):
            return response
        }
    }

    public var error: ErrorType? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error, _, _):
            return error
        }
    }

}

public enum JSONRequestHttpVerb: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

public class JSONRequest {

    private(set) var request: NSMutableURLRequest?

    public var httpRequest: NSMutableURLRequest? {
        return request
    }

    public init() {
        request = NSMutableURLRequest()
    }

    // MARK: Non-public business logic (testable but not public outside the module)

    func submitAsyncRequest(method: JSONRequestHttpVerb, url: String,
        queryParams: JSONObject? = nil, payload: AnyObject? = nil, headers: JSONObject? = nil,
        complete: (result: JSONResult) -> Void) {
            updateRequestUrl(method, url: url, queryParams: queryParams)
            updateRequestHeaders(headers)

            do {
                try updateRequestPayload(payload)
            } catch {
                complete(result: JSONResult.Failure(error: JSONError.PayloadSerialization,
                    response: nil, body: nil))
                return
            }

            let task = NSURLSession.sharedSession().dataTaskWithRequest(request!) {
                (data, response, error) in
                if error != nil {
                    let body = data == nil
                        ? nil
                        : String(data: data!, encoding: NSUTF8StringEncoding)
                    complete(result: JSONResult.Failure(error: JSONError.RequestFailed,
                        response: response as? NSHTTPURLResponse,
                        body: body))
                    return
                }
                let result = self.parseResponse(data, response: response)
                complete(result: result)
            }
            task.resume()
    }

    func submitSyncRequest(method: JSONRequestHttpVerb, url: String, queryParams: JSONObject? = nil,
        payload: AnyObject? = nil, headers: JSONObject? = nil) -> JSONResult {
            let semaphore = dispatch_semaphore_create(0)
            var requestResult: JSONResult = JSONResult.Failure(error: JSONError.RequestFailed,
                response: nil, body: nil)
            submitAsyncRequest(method, url: url, queryParams: queryParams, payload: payload,
                headers: headers) { result in
                    requestResult = result
                    dispatch_semaphore_signal(semaphore)
            }
            // Wait for the request to complete
            while dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW) != 0 {
                let intervalDate = NSDate(timeIntervalSinceNow: 10)
                NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: intervalDate)
            }
            return requestResult
    }

    func updateRequestUrl(method: JSONRequestHttpVerb, url: String,
        queryParams: JSONObject? = nil) {
            request?.URL = createURL(url, queryParams: queryParams)
            request?.HTTPMethod = method.rawValue
    }

    func updateRequestHeaders(headers: JSONObject?) {
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.setValue("application/json", forHTTPHeaderField: "Accept")
        if headers != nil {
            for (headerName, headerValue) in headers! {
                request?.setValue(String(headerValue), forHTTPHeaderField: headerName)
            }
        }
    }

    func updateRequestPayload(payload: AnyObject?) throws {
        if payload != nil {
            request?.HTTPBody = try NSJSONSerialization.dataWithJSONObject(payload!, options: [])
        }
    }

    func createURL(urlString: String, queryParams: JSONObject?) -> NSURL? {
        let components = NSURLComponents(string: urlString)
        if queryParams != nil {
            if components?.queryItems == nil {
                components?.queryItems = []
            }
            for (key, value) in queryParams! {
                if let unwrapped = value {
                    let encoded = String(unwrapped)
                        .stringByAddingPercentEncodingWithAllowedCharacters(
                            .URLHostAllowedCharacterSet())
                    let item = NSURLQueryItem(name: key, value: encoded)
                    components?.queryItems?.append(item)
                } else {
                    let item = NSURLQueryItem(name: key, value: nil)
                    components?.queryItems?.append(item)
                }
            }
        }
        return components?.URL
    }

    func parseResponse(data: NSData?, response: NSURLResponse?) -> JSONResult {
        guard let httpResponse = response as? NSHTTPURLResponse else {
            return JSONResult.Failure(error: JSONError.NonHTTPResponse, response: nil, body: nil)
        }
        guard data != nil && data!.length > 0 else {
            return JSONResult.Success(data: nil, response: httpResponse)
        }
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data!,
            options: [.AllowFragments]) else {
                return JSONResult.Failure(error: JSONError.ResponseDeserialization,
                    response: httpResponse,
                    body: String(data: data!, encoding: NSUTF8StringEncoding))
        }
        return JSONResult.Success(data: json, response: httpResponse)
    }

}


// MARK: Instance HTTP Sync methods

public extension JSONRequest {

    public func get(url: String, params: JSONObject? = nil,
        headers: JSONObject? = nil) -> JSONResult {
            return submitSyncRequest(.GET, url: url, queryParams: params, headers: headers)
    }

    public func post(url: String, params: JSONObject? = nil, payload: AnyObject? = nil,
        headers: JSONObject? = nil) -> JSONResult {
            return submitSyncRequest(.POST, url: url, payload: payload, headers: headers)
    }

    public func put(url: String, params: JSONObject? = nil, payload: AnyObject? = nil,
        headers: JSONObject? = nil) -> JSONResult {
            return submitSyncRequest(.PUT, url: url, payload: payload, headers: headers)
    }

}


// MARK: Instance HTTP Async methods

public extension JSONRequest {

    public func get(url: String, params: JSONObject? = nil, headers: JSONObject? = nil,
        complete: (result: JSONResult) -> Void) {
            submitAsyncRequest(.GET, url: url, queryParams: params, headers: headers,
                complete: complete)
    }

    public func post(url: String, params: JSONObject? = nil, payload: AnyObject? = nil,
        headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
            submitAsyncRequest(.POST, url: url, payload: payload, headers: headers,
                complete: complete)
    }

    public func put(url: String, params: JSONObject? = nil, payload: AnyObject? = nil,
        headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
            submitAsyncRequest(.PUT, url: url, payload: payload, headers: headers,
                complete: complete)
    }

}


// MARK: Class HTTP Sync methods

public extension JSONRequest {

    public class func get(url: String, params: JSONObject? = nil,
        headers: JSONObject? = nil) -> JSONResult {
            return JSONRequest().get(url, params: params, headers: headers)
    }

    public class func post(url: String, params: JSONObject? = nil, payload: AnyObject? = nil,
        headers: JSONObject? = nil) -> JSONResult {
            return JSONRequest().post(url, params: params, payload: payload, headers: headers)
    }

    public class func put(url: String, params: JSONObject? = nil, payload: AnyObject? = nil,
        headers: JSONObject? = nil) -> JSONResult {
            return JSONRequest().put(url, params: params, payload: payload, headers: headers)
    }

}


// MARK: Class HTTP Async methods

public extension JSONRequest {

    public class func get(url: String, params: JSONObject? = nil, headers: JSONObject? = nil,
        complete: (result: JSONResult) -> Void) {
            JSONRequest().get(url, params: params, headers: headers,
                complete: complete)
    }

    public class func post(url: String, params: JSONObject? = nil, payload: AnyObject? = nil,
        headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
            JSONRequest().post(url, params: params, payload: payload, headers: headers,
                complete: complete)
    }

    public class func put(url: String, params: JSONObject? = nil, payload: AnyObject? = nil,
        headers: JSONObject? = nil, complete: (result: JSONResult) -> Void) {
            JSONRequest().put(url, params: params, payload: payload, headers: headers,
                complete: complete)
    }

}
