//
//  JSONResultTests.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 3/22/16.
//  Copyright © 2016 Hathway. All rights reserved.
//

import XCTest
@testable import JSONRequest

class JSONResultTests: XCTestCase {

    func testDataSuccess() {
        let result = JSONResult.success(data: "hello", response: httpUrlResponse())
        XCTAssertEqual(result.data as? String, "hello")
    }

    func testDataFailure() {
        let result = JSONResult.failure(error: JSONError.unknownError, response: nil, body: nil)
        XCTAssertNil(result.data)
    }

    func testArrayValue() {
        let result = JSONResult.success(data: ["hello"], response: httpUrlResponse())
        XCTAssertEqual(result.arrayValue.first as? String, "hello")
    }

    func testArrayValueEmpty() {
        let result = JSONResult.success(data: "hello", response: httpUrlResponse())
        XCTAssertEqual(result.arrayValue.count, 0)
    }

    func testDictionaryValue() {
        let result = JSONResult.success(data: ["hello": "world"], response: httpUrlResponse())
        XCTAssertEqual(result.dictionaryValue["hello"] as? String, "world")
    }

    func testDictionaryValueEmpty() {
        let result = JSONResult.success(data: "hello", response: httpUrlResponse())
        XCTAssertEqual(result.dictionaryValue.keys.count, 0)
    }

    func testError() {
        let result = JSONResult.failure(error: JSONError.unknownError, response: nil, body: nil)
        XCTAssertTrue(result.error is JSONError)
    }

    func testNoError() {
        let result = JSONResult.success(data: "hello", response: httpUrlResponse())
        XCTAssertNil(result.error)
    }

    func testHttpResponseSuccess() {
        let result = JSONResult.success(data: "hello", response: httpUrlResponse())
        XCTAssertNotNil(result.httpResponse)
    }

    func testHttpResponseFailure() {
        let result = JSONResult.failure(error: JSONError.unknownError, response: httpUrlResponse(),
                                        body: nil)
        XCTAssertNotNil(result.httpResponse)
    }

    fileprivate func httpUrlResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: URL(string: "http://httpbin.org")!,
                                 statusCode: 200, httpVersion: nil, headerFields: nil)!
    }

}
