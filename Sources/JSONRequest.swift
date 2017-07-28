//
//  JSONRequest.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 9/12/14.
//  Copyright (c) 2014 Hathway. All rights reserved.
//

import Foundation
import SystemConfiguration

public typealias JSONObject = Dictionary<String, Any>

public enum JSONError: Error {
    case invalidURL
    case payloadSerialization

    case noInternetConnection
    case requestFailed(error: Error)

    case nonHTTPResponse
    case responseDeserialization

    case unknownError
}

public enum JSONResult {
    case success(data: Any?, response: HTTPURLResponse)
    case failure(error: JSONError, response: HTTPURLResponse?, body: String?)
}

public extension JSONResult {

    public var data: Any? {
        switch self {
        case .success(let data, _):
            return data
        case .failure:
            return nil
        }
    }

    public var arrayValue: [Any] {
        return data as? [Any] ?? []
    }

    public var dictionaryValue: [String: Any] {
        return data as? [String: Any] ?? [:]
    }

    public var httpResponse: HTTPURLResponse? {
        switch self {
        case .success(_, let response):
            return response
        case .failure(_, let response, _):
            return response
        }
    }

    public var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error, _, _):
            return error
        }
    }

}

open class JSONRequest {

    fileprivate(set) var request: NSMutableURLRequest?

    open static var log: ((String) -> Void)?
    open static var userAgent: String?
    open static var requestTimeout = 5.0
    open static var resourceTimeout = 10.0
    open static var requestCachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy

    /* Used for dependency injection of outside URLSessions (keep nil to use default) */
    open static var urlSession: URLSession?

    open var httpRequest: NSMutableURLRequest? {
        return request
    }

    /* Set to false during testing to avoid test failures due to lack of internet access */
    internal static var requireNetworkAccess = true

    public init() {
        request = NSMutableURLRequest()
    }

    // MARK: Non-public business logic (testable but not public outside the module)

    func submitAsyncRequest(method: JSONRequestHttpVerb, url: String,
                            queryParams: JSONObject? = nil, payload: Any? = nil,
                            headers: JSONObject? = nil, complete: @escaping (JSONResult) -> Void) {
        if (isConnectedToNetwork() == false) && (JSONRequest.requireNetworkAccess) {
            let error = JSONError.noInternetConnection
            complete(.failure(error: error, response: nil, body: nil))
            return
        }

        updateRequest(method: method, url: url, queryParams: queryParams)
        updateRequest(headers: headers)
        updateRequest(payload: payload)

        let start = Date()
        let session = JSONRequest.urlSession ?? networkSession()
        let task = session.dataTask(with: request! as URLRequest) { (data, response, error) in
            let elapsed = -start.timeIntervalSinceNow
            self.traceResponse(elapsed: elapsed, responseData: data,
                               httpResponse: response as? HTTPURLResponse,
                               error: error as NSError?)
            if let error = error {
                let result = JSONResult.failure(error: JSONError.requestFailed(error: error),
                                                response: response as? HTTPURLResponse,
                                                body: self.body(fromData: data))
                complete(result)
                return
            }
            let result = self.parse(data: data, response: response)
            complete(result)
        }
        trace(task: task)
        task.resume()
    }

    func networkSession() -> URLSession {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = JSONRequest.requestCachePolicy
        config.timeoutIntervalForRequest = JSONRequest.requestTimeout
        config.timeoutIntervalForResource = JSONRequest.resourceTimeout
        if let userAgent = JSONRequest.userAgent {
            config.httpAdditionalHeaders = ["User-Agent": userAgent]
        }
        return URLSession(configuration: config)
    }

    func submitSyncRequest(method: JSONRequestHttpVerb, url: String,
                           queryParams: JSONObject? = nil,
                           payload: Any? = nil,
                           headers: JSONObject? = nil) -> JSONResult {

        let semaphore = DispatchSemaphore(value: 0)
        var requestResult: JSONResult = JSONResult.failure(error: JSONError.unknownError,
                                                           response: nil, body: nil)
        submitAsyncRequest(method: method, url: url, queryParams: queryParams,
                           payload: payload, headers: headers) { result in
                            requestResult = result
                            semaphore.signal()
        }
        // Wait for the request to complete
        while semaphore.wait(timeout: DispatchTime.now()) == .timedOut {
            let intervalDate = Date(timeIntervalSinceNow: 0.01) // 10 milliseconds
            RunLoop.current.run(mode: RunLoopMode.defaultRunLoopMode, before: intervalDate)
        }
        return requestResult
    }

    func updateRequest(method: JSONRequestHttpVerb, url: String,
                       queryParams: JSONObject? = nil) {
        request?.url = createURL(urlString: url, queryParams: queryParams)
        request?.httpMethod = method.rawValue
    }

    func updateRequest(headers: JSONObject?) {
        request?.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request?.setValue("application/json", forHTTPHeaderField: "Accept")
        if let headers = headers {
            for (headerName, headerValue) in headers {
                request?.setValue(String(describing: headerValue), forHTTPHeaderField: headerName)
            }
        }
    }

    func updateRequest(payload: Any?) {
        guard let payload = payload else {
            return
        }
        request?.httpBody = objectToJSON(object: payload)
    }

    open func createURL(urlString: String, queryParams: JSONObject?) -> URL? {
        var components = URLComponents(string: urlString)
        if queryParams != nil {
            if components?.queryItems == nil {
                components?.queryItems = []
            }
            for (key, value) in queryParams! {
                let item = URLQueryItem(name: key, value: String(describing: value))
                components?.queryItems?.append(item)
            }
        }
        return components?.url
    }

    func parse(data: Data?, response: URLResponse?) -> JSONResult {
        guard let httpResponse = response as? HTTPURLResponse else {
            return JSONResult.failure(error: JSONError.nonHTTPResponse, response: nil, body: nil)
        }
        guard let data = data, data.count > 0 else {
            return JSONResult.success(data: nil, response: httpResponse)
        }
        guard let json = JSONToObject(data: data) else {
            return JSONResult.failure(error: JSONError.responseDeserialization,
                                      response: httpResponse,
                                      body: dataToUTFString(data: data))
        }
        return JSONResult.success(data: json, response: httpResponse)
    }

    func body(fromData data: Data?) -> String? {
        guard let data = data else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }

    open func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        guard let reachability = defaultRouteReachability else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        SCNetworkReachabilityGetFlags(reachability, &flags)
        if flags.isEmpty {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return isReachable && !needsConnection
    }

    fileprivate func trace(task: URLSessionDataTask) {
        guard let log = JSONRequest.log else {
            return
        }

        log(">>>>>>>>>> JSON Request >>>>>>>>>>")
        if let method = task.currentRequest?.httpMethod {
            log("HTTP Method: \(method)")
        }
        if let url = task.currentRequest?.url?.absoluteString {
            log("Url: \(url)")
        }
        if let headers = task.currentRequest?.allHTTPHeaderFields {
            log("Headers: \(objectToJSONString(object: headers as Any, pretty: true))")
        }
        if let payload = task.currentRequest?.httpBody,
            let body = String(data: payload, encoding: String.Encoding.utf8) {
            log("Payload: \(body)")
        }
    }

    fileprivate func traceResponse(elapsed: TimeInterval, responseData: Data?,
                                   httpResponse: HTTPURLResponse?, error: NSError?) {
        guard let log = JSONRequest.log else {
            return
        }

        log("<<<<<<<<<< JSON Response <<<<<<<<<<")
        log("Time Elapsed: \(elapsed)")
        if let url = request?.url {
            log("Url: \(url.absoluteString)")
        }
        if let statusCode = httpResponse?.statusCode {
            log("Status Code: \(statusCode)")
        }
        if let headers = httpResponse?.allHeaderFields {
            log("Headers: \(objectToJSONString(object: headers as Any, pretty: true))")
        }
        if let data = responseData, let body = JSONToObject(data: data) {
            log("Body: \(objectToJSONString(object: body, pretty: true))")
        }
        if let errorString = error?.localizedDescription {
            log("Error: \(errorString)")
        }
    }

    fileprivate func JSONToObject(data: Data) -> Any? {
        return try? JSONSerialization.jsonObject(with: data, options: [.allowFragments])
    }

    fileprivate func objectToJSON(object: Any, pretty: Bool = false) -> Data? {
        if JSONSerialization.isValidJSONObject(object) {
            let options = pretty ? JSONSerialization.WritingOptions.prettyPrinted : []
            return try? JSONSerialization.data(withJSONObject: object, options: options)
        }
        return nil
    }

    fileprivate func objectToJSONString(object: Any, pretty: Bool) -> String {
        if let data = objectToJSON(object: object, pretty: pretty) {
            return dataToUTFString(data: data)
        }
        return ""
    }

    fileprivate func dataToUTFString(data: Data) -> String {
        return String(data: data, encoding: String.Encoding.utf8) ?? ""
    }

}
