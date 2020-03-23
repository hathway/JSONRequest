//
//  JSONRequest.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 9/12/14.
//  Copyright (c) 2014 Hathway. All rights reserved.
//

import SystemConfiguration

public typealias JSONObject = [String: Any]
public typealias APITripTimeObject = (path: String, tripTime: TimeInterval)

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

public protocol JSONCancellableRequest {
    func cancel()
}

extension URLSessionDataTask: JSONCancellableRequest {}

public extension JSONResult {

    var data: Any? {
        switch self {
        case .success(let data, _):
            return data
        case .failure:
            return nil
        }
    }

    var arrayValue: [Any] {
        return data as? [Any] ?? []
    }

    var dictionaryValue: [String: Any] {
        return data as? [String: Any] ?? [:]
    }

    var httpResponse: HTTPURLResponse? {
        switch self {
        case .success(_, let response):
            return response
        case .failure(_, let response, _):
            return response
        }
    }

    var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let error, _, _):
            return error
        }
    }

}

// swiftlint:disable type_body_length file_length
open class JSONRequest {
    public static var log: ((String) -> Void)?
    public static var userAgent: String? {
        didSet {
            if let value = userAgent {
                sessionConfig.httpAdditionalHeaders = ["User-Agent": value]
            } else {
                sessionConfig.httpAdditionalHeaders?.removeValue(forKey: "User-Agent")
            }
            updateSessionConfig()
        }
    }
    public static var requestTimeout = 30.0 {
        didSet { updateSessionConfig() }
    }
    public static var resourceTimeout = 30.0 {
        didSet { updateSessionConfig() }
    }
    public static var requestCachePolicy: NSURLRequest.CachePolicy = .useProtocolCachePolicy {
        didSet { updateSessionConfig() }
    }
    public static var isURLCacheEnabled: Bool = true {
        didSet { updateSessionConfig() }
    }

    /// These headers are added to each request.
    /// - Note: this property is thread unsafe
    public static var additionalHeaders: JSONObject = [:]

    /// Set this property if the app needs handle raw HTTP responses
    public static var rawResponsesHandler: JSONRequestRawResponseHandler?

    public static let serviceTripTimeNotification = Notification.Name("JSON_REQUEST_TRIP_TIME_NOTIFICATION")
    public static let mainThreadSyncRequestWarningNotification = Notification.Name("JSON_REQUEST_MAIN_THREAD_SYNC_REQUEST_WARNING_NOTIFICATION")

    public static var errorCallback: (Error) -> Void = { _ in }

    /* Used for dependency injection of outside URLSessions (keep nil to use default) */
    private var urlSession: URLSession?

    private static let sessionDelegateQueue: OperationQueue = {
        let operationQueue = OperationQueue()
        operationQueue.qualityOfService = .userInitiated
        operationQueue.maxConcurrentOperationCount = 1
        operationQueue.name = "JSONRequest::session_delegate"
        return operationQueue
    }()
    private static let urlSessionDelegate = JSONRequestSessionDelegate()
    public static var authChallengeHandler: JSONRequestAuthChallengeHandler? {
        get { return urlSessionDelegate.authChallengeHandler }
        set { urlSessionDelegate.authChallengeHandler = newValue }
    }

    /* Set to false during testing to avoid test failures due to lack of internet access */
    internal static var requireNetworkAccess = true

    /* Delegate that allows additional configurations to be made to the URLSessionConfiguration used for the JSONRequest instance.
        This delegate will be called *after* JSONRequest configures the instance for its needs. Keep in mind making
        significant changes to the URLSessionConfiguration object could cause undefined behavior that JSONRequest cannot control.
    */
    public static var sessionConfigurationDelegate: ((URLSessionConfiguration) -> Void)?

    /* Omit the session parameter to use the default URLSession */
    public init(session: URLSession? = nil) {
        urlSession = session
    }

    private static var _sessionConfig: URLSessionConfiguration?
    private static var sessionConfig: URLSessionConfiguration {
        guard _sessionConfig == nil else { return _sessionConfig! }
        _sessionConfig = URLSessionConfiguration.default
        // FYI, from Apple's documentation: NSURLSession won't attempt to cache a file larger than 5% of the cache size
        // https://goo.gl/CpVNqZ
        return _sessionConfig!
    }

    public static var maxEstimatedResponseMegabytes: Int = 5 {
        didSet { updateSessionConfig() }
    }

    private static var urlSession: URLSession! = nil

    /// Create URL session with JSONRequest configuration
    /// - Parameter forcedTimeout: Forced timeout
    public static func createNetworkSession(forcedTimeout: TimeInterval? = nil) -> URLSession {
        let config = JSONRequest.sessionConfig
        if let timeout = forcedTimeout {
            config.timeoutIntervalForRequest = timeout
            config.timeoutIntervalForResource = timeout
        }
        return URLSession(configuration: config,
                          delegate: JSONRequest.urlSessionDelegate,
                          delegateQueue: Self.sessionDelegateQueue)
    }

    private static func updateSessionConfig() {
        sessionConfig.requestCachePolicy = requestCachePolicy
        sessionConfig.timeoutIntervalForResource = resourceTimeout
        sessionConfig.timeoutIntervalForRequest = requestTimeout
        let capacity: Int = (maxEstimatedResponseMegabytes * 20) * 1024 * 1024 // max response should be less than 5% of cache size
        let urlCache: URLCache? = isURLCacheEnabled ? URLCache(memoryCapacity: capacity, diskCapacity: capacity, diskPath: nil) : nil
        sessionConfig.urlCache = urlCache
        JSONRequest.sessionConfigurationDelegate?(sessionConfig)
        urlSession = URLSession(configuration: JSONRequest.sessionConfig,
                                delegate: JSONRequest.urlSessionDelegate,
                                delegateQueue: sessionDelegateQueue)
    }

    // MARK: Non-public business logic (testable but not public outside the module)

    /// Method for sending asynchronous requests
    ///
    /// - Parameters:
    ///   - method: HTTP Method (GET|POST|PUT|PATCH|DELETE)
    ///   - url: Destination URL
    ///   - queryParams: Query parameters
    ///   - payload: Body parameters. If payload is Array or Dictionary it's tried to be converted to JSON. If payload is Data it stays as it
    ///   - headers: Headers
    ///   - timeOut: Request timeout
    ///   - complete: Completion handler which accepts Result value
    /// - Returns: Active request which can be cancelled
    @discardableResult
    func send(_ method: JSONRequestHttpVerb, url: String, queryParams: JSONObject? = nil, payload: Any? = nil, headers: JSONObject? = nil, timeOut: TimeInterval? = nil, complete: @escaping (JSONResult) -> Void) -> JSONCancellableRequest? {
        if (isConnectedToNetwork() == false) && (JSONRequest.requireNetworkAccess) {
            let error = JSONError.noInternetConnection
            complete(.failure(error: error, response: nil, body: nil))
            return nil
        }
        var request = URLRequest(url: URL(string: url)!, cachePolicy: JSONRequest.requestCachePolicy, timeoutInterval: timeOut ?? JSONRequest.requestTimeout)
        updateRequest(&request, method: method, url: url, queryParams: queryParams)
        updateRequest(&request, headers: headers)
        updateRequest(&request, payload: payload)

        let session = (timeOut == urlSession?.configuration.timeoutIntervalForRequest ? (urlSession ?? networkSession()) : networkSession(forcedTimeout: timeOut))
        let start = Date()

        let cachedResponse: CachedURLResponse? = session.configuration.urlCache?.cachedResponse(for: request)
        if cachedResponse == nil {
            removeCachingHeaders(&request)
        }

        let task = session.dataTask(with: request) { (data, response, error) in
            let elapsed = -start.timeIntervalSinceNow
            self.traceResponse(elapsed: elapsed, responseData: data,
                               httpResponse: response as? HTTPURLResponse,
                               error: error as NSError?)
            JSONRequest.rawResponsesHandler?.handle(data, response: response as? HTTPURLResponse, error: error)
            if let error = error {
                let result = JSONResult.failure(error: JSONError.requestFailed(error: error), response: response as? HTTPURLResponse, body: self.body(fromData: data))
                JSONRequest.errorCallback(error)
                complete(result)
                return
            } else if let httpResponse = (response as? HTTPURLResponse), httpResponse.statusCode == 304, let cachedResponseObj = cachedResponse {
                /*  For some rediculous reason, there are cases where the cache contains a response for the HTTP request (as verified
                 by the conditional check above), but that cached response isn't passed transparently to us as a 200OK response, and is
                 instead a 304, which throws the consumer out of wack since there's no guarantee they have cached the data themselves.

                 So, if we got a 304, AND we have a cached response object, let's parse & process that instead here. Yay for caching >:-(
                 */
                print("Unexpected 304 returned when a cached value exists. Parsing & returning cached response")
                self.traceResponse(elapsed: elapsed, responseData: cachedResponseObj.data,
                                   httpResponse: cachedResponseObj.response as? HTTPURLResponse,
                                   error: error as NSError?)
                let result = self.parse(data: cachedResponseObj.data, response: cachedResponseObj.response)
                if let error = result.error {
                    JSONRequest.errorCallback(error)
                }
                complete(result)
            } else {
                let result = self.parse(data: data, response: response)
                if let error = result.error {
                    JSONRequest.errorCallback(error)
                }
                complete(result)
            }
        }
        trace(task: task)
        task.resume()
        return task
    }

    func networkSession(forcedTimeout: TimeInterval? = nil) -> URLSession {
        let session = JSONRequest.createNetworkSession(forcedTimeout: forcedTimeout)
        if forcedTimeout == nil {
            // if there isn't a custom timeout, set the member variable with this new session we've created for future use.
            urlSession = session
        }
        return session
    }

    func submitSyncRequest(method: JSONRequestHttpVerb, url: String,
                           queryParams: JSONObject? = nil,
                           payload: Any? = nil,
                           headers: JSONObject? = nil,
                           timeOut: TimeInterval? = nil) -> JSONResult {
        if Thread.isMainThread {
            NotificationCenter.default.post(name: JSONRequest.mainThreadSyncRequestWarningNotification, object: url)
        }
        var requestResult: JSONResult = JSONResult.failure(error: JSONError.unknownError,
                                                           response: nil, body: nil)

        let semaphore = DispatchSemaphore(value: 0)
        send(method, url: url, queryParams: queryParams,
                           payload: payload, headers: headers, timeOut: timeOut) { result in
                            requestResult = result
                            semaphore.signal()
        }
        // Wait for the request to complete
        semaphore.wait()    // Timeout will be handled by the HTTP layer
        return requestResult
    }

    func updateRequest(_ request: inout URLRequest,
                       method: JSONRequestHttpVerb, url: String,
                       queryParams: JSONObject? = nil) {
        request.url = createURL(urlString: url, queryParams: queryParams)
        request.httpMethod = method.rawValue
    }

    func updateRequest(_ request: inout URLRequest, headers: JSONObject?) {
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        for (headerName, headerValue) in JSONRequest.additionalHeaders {
            request.setValue(String(describing: headerValue), forHTTPHeaderField: headerName)
        }

        if let headers = headers {
            for (headerName, headerValue) in headers {
                request.setValue(String(describing: headerValue), forHTTPHeaderField: headerName)
            }
        }
    }

    func removeCachingHeaders(_ request: inout URLRequest) {
        request.setValue(nil, forHTTPHeaderField: "If-None-Match")
        request.setValue(nil, forHTTPHeaderField: "If-Modified-Since")
    }

    func updateRequest(_ request: inout URLRequest, payload: Any?) {
        guard let payload = payload else {
            return
        }

        if let jsonData = objectToJSON(object: payload) {
            request.httpBody = jsonData
        } else if let data = payload as? Data {
            request.httpBody = data
        }
    }

    open func createURL(urlString: String, queryParams: JSONObject?) -> URL? {
        guard let baseURL = URL(string: urlString) else {
            return nil
        }
        guard let queryParams = queryParams else {
            return baseURL
        }

        return url(baseURL, appendingPercentEncodingOf: queryParams)
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
        if let path = task.currentRequest?.url?.path {
            log("PATH: \(path)")
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
        if let url = httpResponse?.url {
            log("Url: \(url.absoluteString)")
            log("PATH: \(url.path)")
            let apiTripObject = APITripTimeObject(path: url.path, tripTime: elapsed)
            NotificationCenter.default.post(name: JSONRequest.serviceTripTimeNotification, object: apiTripObject)
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
