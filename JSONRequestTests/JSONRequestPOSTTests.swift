//
//  JSONRequestPOSTTests.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 3/24/16.
//  Copyright © 2016 Hathway. All rights reserved.
//

import XCTest
import JSONRequest

class JSONRequestPOSTTests: XCTestCase {

    let goodUrl = "http://httpbin.org/post"
    let badUrl = "httpppp://httpbin.org/post"
    let params: JSONObject = ["hello": "world"]
    let payload: AnyObject = ["hi": "there"]

    func testSimple() {
        let result = JSONRequest.post(goodUrl, queryParams: params, payload: payload)
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
        let result = JSONRequest.post(goodUrl, payload: payload)
        let dict = result.dictionaryValue
        XCTAssertEqual(dict["json"]?["hi"], "there")
    }

    func testArrayValue() {
        let result = JSONRequest.post(goodUrl, payload: payload)
        let array = result.arrayValue
        XCTAssertEqual(array.count, 0)
    }

    func testFailing() {
        let result = JSONRequest.post(badUrl, payload: payload)
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
        JSONRequest.post(goodUrl) { (result) in
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
        JSONRequest.post(badUrl) { (result) in
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
