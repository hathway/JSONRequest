//
//  JSONRequestPUTTests.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 3/24/16.
//  Copyright © 2016 Hathway. All rights reserved.
//

import XCTest
import JSONRequest

class JSONRequestPUTTests: XCTestCase {

    let goodUrl = "http://httpbin.org/put"
    let badUrl = "httpppp://httpbin.org/put"
    let params: JSONObject = ["hello": "world"]
    let payload: AnyObject = ["hi": "there"]

    func testSimple() {
        let result = JSONRequest.put(goodUrl, queryParams: params, payload: payload)
        switch result {
        case .Success(let data, let response):
            XCTAssertNotNil(data)
            XCTAssertNotNil(data?["args"])
            XCTAssertEqual(data?["args"]??["hello"], "world")
            XCTAssertNotNil(data?["json"])
            XCTAssertEqual(data?["json"]??["hi"], "there")
            XCTAssertEqual(response.statusCode, 200)
        case .Failure:
            XCTFail("Request failed")
        }
    }

    func testDictionaryValue() {
        let result = JSONRequest.put(goodUrl, payload: payload)
        let dict = result.dictionaryValue
        XCTAssertEqual(dict["json"]?["hi"], "there")
    }

    func testArrayValue() {
        let result = JSONRequest.put(goodUrl, payload: payload)
        let array = result.arrayValue
        XCTAssertEqual(array.count, 0)
    }

    func testFailing() {
        let result = JSONRequest.put(badUrl, payload: payload)
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
        JSONRequest.put(goodUrl) { (result) in
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
        JSONRequest.put(badUrl) { (result) in
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
