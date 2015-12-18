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

    func testCreateRequest() {
        let jsonRequest = JSONRequest()
        _ = try? jsonRequest.initializeRequest("GET", url: "", queryParams: nil)
        let httpRequest = jsonRequest.request
        XCTAssertNotNil(httpRequest)
        XCTAssertEqual(httpRequest?.HTTPMethod, "GET")
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
        let url = jsonRequest.createURL("http://google.com", queryParams: nil)
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "http://google.com")
    }

    func testCreateURLWithParam() {
        let jsonRequest = JSONRequest()
        let url = jsonRequest.createURL("http://google.com", queryParams: ["q": "JSONRequest"])
        XCTAssertNotNil(url)
        XCTAssertEqual(url?.absoluteString, "http://google.com?q=JSONRequest")
    }

    func testCreateURLWithParams() {
        let jsonRequest = JSONRequest()
        let params: [String: AnyObject] = [
            "a": 1,
            "b": "string",
            "c": 2.2
        ]
        let url = jsonRequest.createURL("http://google.com", queryParams: params)
        XCTAssertNotNil(url)
        XCTAssertNotNil(url?.absoluteString)
        XCTAssert(url?.absoluteString.containsString("a=1") ?? false)
        XCTAssert(url?.absoluteString.containsString("b=string") ?? false)
        XCTAssert(url?.absoluteString.containsString("c=2.2") ?? false)
    }

    func testCreateURLWithUrlParams() {
        let jsonRequest = JSONRequest()
        let url = jsonRequest.createURL("http://google.com?a=1&b=string&c=2.2", queryParams: nil)
        XCTAssertNotNil(url)
        XCTAssertNotNil(url?.absoluteString)
        XCTAssert(url?.absoluteString.containsString("a=1") ?? false)
        XCTAssert(url?.absoluteString.containsString("b=string") ?? false)
        XCTAssert(url?.absoluteString.containsString("c=2.2") ?? false)
    }

    func testCreateURLWithUrlAndQueryParams() {
        let jsonRequest = JSONRequest()
        let params = [
            "a": 1,
            "b": "string",
            "c": 2.2
        ]
        let url = jsonRequest.createURL("http://google.com?a=1", queryParams: params)
        XCTAssertNotNil(url)
        XCTAssertNotNil(url?.absoluteString)
        XCTAssert(url?.absoluteString.containsString("a=1") ?? false)
        XCTAssert(url?.absoluteString.containsString("b=string") ?? false)
        XCTAssert(url?.absoluteString.containsString("c=2.2") ?? false)
        XCTAssertEqual(url?.absoluteString.componentsSeparatedByString("a=1").count, 3)
    }

    func testParseNilResponse() {
        let request = JSONRequest()
        let result = request.parseResponse(nil, response: nil)
        switch result {
        case .Failure(let error, let response):
            XCTAssertEqual(error, JSONError.NonHTTPResponse)
            XCTAssertEqual(response, nil)
        case .Success:
            XCTFail("Should always fail")
        }
    }

    func testParseNilResponseWithData() {
        let request = JSONRequest()
        let result = request.parseResponse(NSData(), response: nil)
        switch result {
        case .Failure(let error, let response):
            XCTAssertEqual(error, JSONError.NonHTTPResponse)
            XCTAssertEqual(response, nil)
        case .Success:
            XCTFail("Should always fail")
        }
    }

    func testSimpleGet() {
        let request = JSONRequest()
        let result = request.get("http://httpbin.org/get",
            params: ["hello": "world"])
        switch result {
        case .Success(let data, let response):
            XCTAssertNotNil(data)
            XCTAssertNotNil(data?["args"])
            XCTAssertEqual(data?["args"]??["hello"], "world")
            XCTAssertEqual(response.statusCode, 200)
        case .Failure:
            XCTFail("Request failed")
        }
    }

    func testFailingGet() {
        let request = JSONRequest()
        let result = request.get("httpppp://httpbin.org/get",
            params: ["hello": "world"])
        switch result {
        case .Success:
            XCTFail("Request should have failed")
        case .Failure(let error, let response):
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            XCTAssertEqual(error, JSONError.RequestFailed)
        }
    }

}
