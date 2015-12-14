//
//  RequestManager.swift
//  welkio
//
//  Created by Eneko Alonso on 9/12/14.
//  Copyright (c) 2014 Hathway. All rights reserved.
//

import UIKit


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
    case Failure(error: JSONError, response: NSHTTPURLResponse?)
}

public class JSONRequest {

    private(set) var request: NSMutableURLRequest?

    public func get(url: String, params: JSONObject? = nil,
        headers: JSONObject? = nil) throws -> JSONResult {
        return try submitSyncRequest("GET", url: url, queryParams: params, headers: headers)
    }

    public func post(url: String, payload: AnyObject? = nil,
        headers: JSONObject? = nil) throws -> JSONResult {
        return try submitSyncRequest("POST", url: url, payload: payload, headers: headers)
    }

    func submitAsyncRequest(method: String, url: String, queryParams: JSONObject? = nil,
        payload: AnyObject? = nil, headers: JSONObject? = nil,
        complete: (result: JSONResult) -> Void) {
        do {
            try initializeRequest(method, url: url, queryParams: queryParams)
            updateRequestHeaders(headers)
            try updateRequestPayload(payload)
        } catch {
            complete(result: JSONResult.Failure(error: JSONError.InvalidURL, response: nil))
            return
        }

        let task = NSURLSession.sharedSession().dataTaskWithRequest(request!) {
            (data, response, error) in
            //            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            if error != nil {
                complete(result: JSONResult.Failure(error: JSONError.RequestFailed,
                    response: response as? NSHTTPURLResponse))
                return
            }
            let result = self.parseResponse(data, response: response)
            complete(result: result)
        }
        task.resume()
    }

    func submitSyncRequest(method: String, url: String, queryParams: JSONObject? = nil,
        payload: AnyObject? = nil, headers: JSONObject? = nil) throws -> JSONResult {
        try initializeRequest(method, url: url, queryParams: queryParams)
        updateRequestHeaders(headers)
        try updateRequestPayload(payload)

        var response: NSURLResponse?
        let data = try NSURLConnection.sendSynchronousRequest(request!,
            returningResponse: &response)
        return parseResponse(data, response: response)
    }

    func initializeRequest(method: String, url: String, queryParams: JSONObject? = nil) throws {
        guard let url = createURL(url, queryParams: queryParams) else {
            throw JSONError.InvalidURL
        }
        request = NSMutableURLRequest(URL: url)
        request?.HTTPMethod = method
    }

    func updateRequestHeaders(headers: JSONObject?) {
        request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.addValue("application/json", forHTTPHeaderField: "Accept")
        if headers != nil {
            for (headerName, headerValue) in headers! {
                request?.addValue(String(headerValue), forHTTPHeaderField: headerName)
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
            return JSONResult.Failure(error: JSONError.NonHTTPResponse, response: nil)
        }
        guard data != nil else {
            return JSONResult.Success(data: nil, response: httpResponse)
        }
        guard let json = try? NSJSONSerialization.JSONObjectWithData(data!, options: []) else {
            return JSONResult.Failure(error: JSONError.ResponseDeserialization,
                response: httpResponse)
        }
        return JSONResult.Success(data: json, response: httpResponse)
    }
    
}
