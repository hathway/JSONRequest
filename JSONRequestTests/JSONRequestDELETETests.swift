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
        let result = JSONRequest.delete(url: goodUrl, queryParams: params)
        switch result {
        case .success(let data, let response):
            XCTAssertNotNil(data)
            let object = data as? JSONObject
            XCTAssertNotNil(object?["args"])
            XCTAssertEqual((object?["args"] as? JSONObject)?["hello"] as? String, "world")
            XCTAssertEqual(response.statusCode, 200)
        case .failure:
            XCTFail("Request failed")
        }
    }

    func testDictionaryValue() {
        let result = JSONRequest.delete(url: goodUrl, queryParams: params)
        let dict = result.dictionaryValue
        XCTAssertEqual((dict["args"] as? JSONObject)?["hello"] as? String, "world")
    }

    func testArrayValue() {
        let result = JSONRequest.delete(url: goodUrl, queryParams: params)
        let array = result.arrayValue
        XCTAssertEqual(array.count, 0)
    }

    func testFailing() {
        let result = JSONRequest.delete(url: badUrl, queryParams: params)
        switch result {
        case .success:
            XCTFail("Request should have failed")
        case .failure(let error, let response, let body):
            XCTAssertNotNil(error)
            XCTAssertNil(response)
            XCTAssertNil(body)
//            XCTAssertEqual(error, JSONError.requestFailed)
        }
    }

    func testAsync() {
        let expectation = self.expectation(description: "async")
        JSONRequest.delete(url: goodUrl) { (result) in
            XCTAssertNil(result.error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 15) { error in
            if error != nil {
                XCTFail()
            }
        }
    }

    func testAsyncFail() {
        let expectation = self.expectation(description: "async")
        JSONRequest.delete(url: badUrl) { (result) in
            XCTAssertNotNil(result.error)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 15) { error in
            if error != nil {
                XCTFail()
            }
        }
    }

}
