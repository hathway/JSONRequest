//
//  JSONRequestTests.swift
//  JSONRequestTests
//
//  Created by Eneko Alonso on 9/26/14.
//  Copyright (c) 2014 Hathway. All rights reserved.
//

import XCTest
@testable import JSONRequest

class JSONRequestTests: XCTestCase {

    func testHTTPRequest() {
        let jsonRequest = JSONRequest()
        jsonRequest.updateRequestUrl(.GET, url: "")
        XCTAssertNotNil(jsonRequest.request)
        XCTAssertEqual(jsonRequest.request?.HTTPMethod, "GET")
    }

    func testCreateBadURL() {
        let jsonRequest = JSONRequest()
        let url = jsonRequest.createURL("bad url", queryParams: nil)
        XCTAssertNil(url)
    }

    func testCreateEmptyURL() {
        let jsonRequest = JSONRequest()
        let url = jsonRequest.createURL("", queryParams: nil)
        XCTAssertNotNil(url)
        XCTAssertEqual(url, NSURL(string: ""))
    }

    func testCreateURL() {
        let jsonRequest = JSONRequest()
        let url = jsonRequest.createURL("http://httpbin.org", queryParams: nil)
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "http://httpbin.org")
    }

    func testCreateURLWithParam() {
        let jsonRequest = JSONRequest()
        let url = jsonRequest.createURL("http://httpbin.org", queryParams: ["q": "JSONRequest"])
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "http://httpbin.org?q=JSONRequest")
    }

    func testCreateURLWithParams() {
        let jsonRequest = JSONRequest()
        let params: [String: AnyObject] = [
            "aaaa": 1,
            "bbbb": "string",
            "cccc": 2.2
        ]
        let url = jsonRequest.createURL("http://httpbin.org", queryParams: params)
        XCTAssertNotNil(url)
        XCTAssertNotNil(url?.absoluteString)
        XCTAssert(url?.absoluteString.containsString("aaaa=1") ?? false)
        XCTAssert(url?.absoluteString.containsString("bbbb=string") ?? false)
        XCTAssert(url?.absoluteString.containsString("cccc=2.2") ?? false)
    }

    func testCreateURLWithNilParams() {
        let jsonRequest = JSONRequest()
        let params: JSONObject = [
            "aaaa": 1,
            "bbbb": "string",
            "cccc": nil
        ]
        let url = jsonRequest.createURL("http://httpbin.org", queryParams: params)
        XCTAssertNotNil(url)
        XCTAssertNotNil(url?.absoluteString)
        XCTAssertEqual(url?.absoluteString.containsString("aaaa=1"), true)
        XCTAssertEqual(url?.absoluteString.containsString("bbbb=string"), true)
        XCTAssertEqual(url?.absoluteString.containsString("cccc"), true)
    }

    func testCreateURLWithUrlParams() {
        let jsonRequest = JSONRequest()
        let url = jsonRequest.createURL("http://httpbin.org?aaaa=1&bbbb=string&cccc=2.2",
                                        queryParams: nil)
        XCTAssertNotNil(url)
        XCTAssertNotNil(url?.absoluteString)
        XCTAssert(url?.absoluteString.containsString("aaaa=1") ?? false)
        XCTAssert(url?.absoluteString.containsString("bbbb=string") ?? false)
        XCTAssert(url?.absoluteString.containsString("cccc=2.2") ?? false)
    }

    func testCreateURLWithUrlAndQueryParams() {
        let jsonRequest = JSONRequest()
        let params = [
            "aaaa": 1,
            "bbbb": "string",
            "cccc": 2.2
        ]
        let url = jsonRequest.createURL("http://httpbin.org?aaaa=1", queryParams: params)
        XCTAssertNotNil(url)
        XCTAssertNotNil(url?.absoluteString)
        XCTAssert(url?.absoluteString.containsString("aaaa=1") ?? false)
        XCTAssertEqual(url?.absoluteString.componentsSeparatedByString("aaaa=1").count, 3)
        XCTAssert(url?.absoluteString.containsString("bbbb=string") ?? false)
        XCTAssert(url?.absoluteString.containsString("cccc=2.2") ?? false)
    }

    func testParseNilResponse() {
        let request = JSONRequest()
        let result = request.parseResponse(nil, response: nil)
        switch result {
        case .Failure(let error, let response, let body):
            XCTAssertEqual(error, JSONError.NonHTTPResponse)
            XCTAssertNil(response)
            XCTAssertNil(body)
        case .Success:
            XCTFail("Should always fail")
        }
    }

    func testParseNilResponseWithData() {
        let request = JSONRequest()
        let result = request.parseResponse(NSData(), response: nil)
        switch result {
        case .Failure(let error, let response, let body):
            XCTAssertEqual(error, JSONError.NonHTTPResponse)
            XCTAssertNil(response)
            XCTAssertNil(body)
        case .Success:
            XCTFail("Should always fail")
        }
    }

    func testParseResponseWithNilData() {
        let request = JSONRequest()
        let response = NSHTTPURLResponse(URL: NSURL(string: "http://httpbin.org")!,
                                         statusCode: 200,
                                         HTTPVersion: nil, headerFields: nil)
        let result = request.parseResponse(nil, response: response)
        switch result {
        case .Failure:
            XCTFail("Should not fail")
        case .Success:
            XCTAssert(true)
        }
    }

    func testParseResponseWithInvalidJSON() {
        let request = JSONRequest()
        let response = NSHTTPURLResponse(URL: NSURL(string: "http://httpbin.org")!,
                                         statusCode: 200,
                                         HTTPVersion: nil, headerFields: nil)
        let result = request.parseResponse(binaryData(), response: response)
        switch result {
        case .Success:
            XCTFail("Should have failed")
        case .Failure(let error, _, _):
            XCTAssertEqual(error, JSONError.ResponseDeserialization)
        }
    }

    func testHttpRequestGetter() {
        let request = JSONRequest()
        XCTAssertNotNil(request.httpRequest)
    }

    func testPayload() {
        let payload = ["Hello": "world"]
        let request = JSONRequest()
        request.updateRequestPayload(payload)
        XCTAssertNotNil(request.httpRequest?.HTTPBody)
    }

    func testInvalidPayload() {
        let payload = binaryData()
        let request = JSONRequest()
        request.updateRequestPayload(payload)
        XCTAssertNil(request.httpRequest?.HTTPBody)
    }

    func testBodyStringFromData() {
        let data = "Hello world".dataUsingEncoding(NSUTF8StringEncoding)
        XCTAssertEqual(JSONRequest().bodyStringFromData(data), "Hello world")
    }

    func testUpdateRequestHeaders() {
        let headers: JSONObject = ["User-Agent": "XCTest"]
        let request = JSONRequest()
        request.updateRequestHeaders(headers)
        XCTAssertEqual(request.httpRequest?.allHTTPHeaderFields?["User-Agent"], "XCTest")
    }

    private func binaryData() -> NSData {
        var int = 42
        return NSData(bytes: &int, length: 32)
    }

}
