//
//  JSONRequestGETTests.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 1/11/16.
//  Copyright © 2016 Hathway. All rights reserved.
//

import XCTest
@testable import JSONRequest
import DVR

class JSONRequestGETTests: XCTestCase {

    let goodUrl = "http://httpbin.org/get"
    let badUrl = "httpppp://httpbin.org/get"
    let params: JSONObject = ["hello": "world"]

    override func setUp() {
        JSONRequest.requireNetworkAccess = false
        super.setUp()
    }

    override func tearDown() {
        JSONRequest.urlSession = nil
        super.tearDown()
    }

    func testSimple() {
        JSONRequest.urlSession = DVR.Session(cassetteName: "testFiles/testSimpleGET")
        let result = JSONRequest.get(url: goodUrl, queryParams: params)
        switch result {
        case .success(let data, let response):
            XCTAssertNotNil(data)
            let object = data as? JSONObject
            XCTAssertNotNil(object?["args"])
            XCTAssertEqual((object?["args"] as? JSONObject)?["hello"] as? String, "world")
            XCTAssertEqual(response.statusCode, 200)
        case .failure(let error):
            XCTFail("Request failed with \(error)")
        }
    }

    func testDictionaryValue() {
        JSONRequest.urlSession = DVR.Session(cassetteName: "testFiles/testDictionaryValueGET")
        let result = JSONRequest.get(url: goodUrl, queryParams: params)
        let dict = result.dictionaryValue
        XCTAssertEqual((dict["args"] as? JSONObject)?["hello"] as? String, "world")
    }

    func testArrayValue() {
        JSONRequest.urlSession = DVR.Session(cassetteName: "testFiles/testArrayValueGET")
        let result = JSONRequest.get(url: goodUrl, queryParams: params)
        let array = result.arrayValue
        XCTAssertEqual(array.count, 0)
    }

    func testFailing() {
        // We don't use DVR on this test because it is designed to fail immediately
        let result = JSONRequest.get(url: badUrl, queryParams: params)
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
        JSONRequest.urlSession = DVR.Session(cassetteName: "testFiles/testAsyncGET")
        let expectation = self.expectation(description: "async")
        JSONRequest.get(url: goodUrl) { (result) in
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
        JSONRequest.get(url: badUrl) { (result) in
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
