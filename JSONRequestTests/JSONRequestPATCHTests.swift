//
//  JSONRequestPATCHTests.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 3/24/16.
//  Copyright © 2016 Hathway. All rights reserved.
//

import XCTest
import JSONRequest
import DVR

class JSONRequestPATCHTests: XCTestCase {

    let goodUrl = "http://httpbin.org/patch"
    let badUrl = "httpppp://httpbin.org/patch"
    let params: JSONObject = ["hello": "world"]
    let payload: Any = ["hi": "there"]

    override func tearDown() {
        JSONRequest.urlSession = nil
        super.tearDown()
    }

    func testSimple() {
        JSONRequest.urlSession = DVR.Session(cassetteName: "testFiles/testSimplePATCH")
        let result = JSONRequest.patch(url: goodUrl, queryParams: params, payload: payload)
        switch result {
        case .success(let data, let response):
            XCTAssertNotNil(data)
            let object = data as? JSONObject
            XCTAssertNotNil(object?["args"])
            XCTAssertEqual((object?["args"] as? JSONObject)?["hello"] as? String, "world")
            XCTAssertNotNil(object?["json"])
            XCTAssertEqual((object?["json"] as? JSONObject)?["hi"] as? String, "there")
            XCTAssertEqual(response.statusCode, 200)
        case .failure:
            XCTFail("Request failed")
        }
    }

    func testDictionaryValue() {
        JSONRequest.urlSession = DVR.Session(cassetteName: "testFiles/testDictionaryValuePATCH")
        let result = JSONRequest.patch(url: goodUrl, payload: payload)
        let dict = result.dictionaryValue
        XCTAssertEqual((dict["json"] as? JSONObject)?["hi"] as? String, "there")
    }

    func testArrayValue() {
        JSONRequest.urlSession = DVR.Session(cassetteName: "testFiles/testArrayValuePATCH")
        let result = JSONRequest.patch(url: goodUrl, payload: payload)
        let array = result.arrayValue
        XCTAssertEqual(array.count, 0)
    }

    func testFailing() {
        // We don't use DVR on this test because it is designed to fail immediately
        let result = JSONRequest.patch(url: badUrl, payload: payload)
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
        JSONRequest.urlSession = DVR.Session(cassetteName: "testFiles/testAsyncPATCH")
        let expectation = self.expectation(description: "async")
        JSONRequest.patch(url: goodUrl) { (result) in
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
        JSONRequest.patch(url: badUrl) { (result) in
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
