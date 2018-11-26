//
//  JSONRequestPUTTests.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 3/24/16.
//  Copyright © 2016 Hathway. All rights reserved.
//

import XCTest
@testable import JSONRequest
import DVR

class JSONRequestPUTTests: XCTestCase {

    let goodUrl = "http://httpbin.org/put"
    let badUrl = "httpppp://httpbin.org/put"
    let params: JSONObject = ["hello": "world"]
    let payload: Any = ["hi": "there"]

    override func setUp() {
        JSONRequest.requireNetworkAccess = false
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testSimple() {
//        let jsonRequest = JSONRequest(session: DVR.Session(cassetteName: "testFiles/testSimplePUT"))
//        let result = jsonRequest.put(url: goodUrl, queryParams: params, payload: payload)
//        switch result {
//        case .success(let data, let response):
//            XCTAssertNotNil(data)
//            let object = data as? JSONObject
//            XCTAssertNotNil(object?["args"])
//            XCTAssertEqual((object?["args"] as? JSONObject)?["hello"] as? String, "world")
//            XCTAssertNotNil(object?["json"])
//            XCTAssertEqual((object?["json"] as? JSONObject)?["hi"] as? String, "there")
//            XCTAssertEqual(response.statusCode, 200)
//        case .failure:
//            XCTFail("Request failed")
//        }
    }

    func testDictionaryValue() {
//        let jsonRequest = JSONRequest(session: DVR.Session(cassetteName: "testFiles/testDictionaryValuePUT"))
//        let result = jsonRequest.put(url: goodUrl, payload: payload)
//        let dict = result.dictionaryValue
//        XCTAssertEqual((dict["json"] as? JSONObject)?["hi"] as? String, "there")
    }

    func testArrayValue() {
//        let jsonRequest = JSONRequest(session: DVR.Session(cassetteName: "testFiles/testArrayValuePUT"))
//        let result = jsonRequest.put(url: goodUrl, payload: payload)
//        let array = result.arrayValue
//        XCTAssertEqual(array.count, 0)
    }

    func testFailing() {
        // We don't use DVR on this test because it is designed to fail immediately
        let result = JSONRequest.put(url: badUrl, payload: payload)
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
//        let jsonRequest = JSONRequest(session: DVR.Session(cassetteName: "testFiles/testAsyncPUT"))
//        let expectation = self.expectation(description: "async")
//        jsonRequest.put(url: goodUrl) { (result) in
//            XCTAssertNil(result.error)
//            expectation.fulfill()
//        }
//        waitForExpectations(timeout: 15) { error in
//            if error != nil {
//                XCTFail()
//            }
//        }
    }

    func testAsyncFail() {
        // We don't use DVR on this test because it is designed to fail immediately
        let expectation = self.expectation(description: "async")
        JSONRequest.put(url: badUrl) { (result) in
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
