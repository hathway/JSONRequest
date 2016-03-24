//
//  JSONRequestDELETETests.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 3/24/16.
//  Copyright © 2016 Hathway. All rights reserved.
//

import XCTest
import JSONRequest

class JSONRequestDELETETests: XCTestCase {

    let goodUrl = "http://httpbin.org/delete"
    let badUrl = "httpppp://httpbin.org/delete"
    let params: JSONObject = ["hello": "world"]

    func testSimple() {
        let result = JSONRequest.delete(goodUrl, queryParams: params)
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

    func testDictionaryValue() {
        let result = JSONRequest.delete(goodUrl, queryParams: params)
        let dict = result.dictionaryValue
        XCTAssertEqual(dict["args"]?["hello"], "world")
    }

    func testArrayValue() {
        let result = JSONRequest.delete(goodUrl, queryParams: params)
        let array = result.arrayValue
        XCTAssertEqual(array.count, 0)
    }

    func testFailing() {
        let result = JSONRequest.delete(badUrl, queryParams: params)
        switch result {
        case .Success:
            XCTFail("Request should have failed")
        case .Failure(let error, let response, let body):
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            XCTAssertNil(body)
            XCTAssertEqual(error, JSONError.RequestFailed)
        }
    }

    func testAsync() {
        let expectation = expectationWithDescription("async")
        JSONRequest.delete(goodUrl) { (result) in
            XCTAssertNil(result.error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(15) { error in
            if error != nil {
                XCTFail()
            }
        }
    }

    func testAsyncFail() {
        let expectation = expectationWithDescription("async")
        JSONRequest.delete(badUrl) { (result) in
            XCTAssertNotNil(result.error)
            expectation.fulfill()
        }
        waitForExpectationsWithTimeout(15) { error in
            if error != nil {
                XCTFail()
            }
        }
    }

}
