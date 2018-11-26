//
//  JSONRequestDELETETests.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 3/24/16.
//  Copyright © 2016 Hathway. All rights reserved.
//

import XCTest
@testable import JSONRequest
import DVR

class JSONRequestDELETETests: XCTestCase {

    let goodUrl = "http://httpbin.org/delete"
    let badUrl = "httpppp://httpbin.org/delete"
    let params: JSONObject = ["hello": "world"]

    override func setUp() {
        JSONRequest.requireNetworkAccess = false
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSimple() {
        let jsonRequest = JSONRequest(session: DVR.Session(cassetteName: "testFiles/testSimpleDELETE"))
        let result = jsonRequest.delete(url: goodUrl, queryParams: params)
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
        let jsonRequest = JSONRequest(session: DVR.Session(cassetteName: "testFiles/testDictionaryValueDELETE"))
        let result = jsonRequest.delete(url: goodUrl, queryParams: params)
        let dict = result.dictionaryValue
        XCTAssertEqual((dict["args"] as? JSONObject)?["hello"] as? String, "world")
    }

    func testArrayValue() {
        let jsonRequest = JSONRequest(session: DVR.Session(cassetteName: "testFiles/testArrayValueDELETE"))
        let result = jsonRequest.delete(url: goodUrl, queryParams: params)
        let array = result.arrayValue
        XCTAssertEqual(array.count, 0)
    }

    func testFailing() {
        // We don't use DVR on this test because it is designed to fail immediately
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
        let jsonRequest = JSONRequest(session: DVR.Session(cassetteName: "testFiles/testAsyncDELETE"))
        let expectation = self.expectation(description: "async")
        jsonRequest.delete(url: goodUrl) { (result) in
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
        // We don't use DVR on this test because it is designed to fail immediately
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
