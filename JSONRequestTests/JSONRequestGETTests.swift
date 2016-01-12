//
//  JSONRequestGETTests.swift
//  JSONRequest
//
//  Created by Eneko Alonso on 1/11/16.
//  Copyright © 2016 Hathway. All rights reserved.
//

import XCTest
@testable import JSONRequest

class JSONRequestGETTests: XCTestCase {

    let goodUrl = "http://httpbin.org/get"
    let badUrl = "httpppp://httpbin.org/get"
    let params: JSONObject = ["hello": "world"]

    func testSimpleGet() {
        let request = JSONRequest()
        let result = request.get(goodUrl, queryParams: params)
        switch result {
        case .Success(let data, let response):
            print(data)
            XCTAssertNotNil(data)
            XCTAssertNotNil(data?["args"])
            XCTAssertEqual(data?["args"]??["hello"], "world")
            XCTAssertEqual(response.statusCode, 200)
        case .Failure:
            XCTFail("Request failed")
        }
    }

    func testDictionaryValue() {
        let result = JSONRequest.get(goodUrl, queryParams: params)
        let dict = result.dictionaryValue
        XCTAssertEqual(dict["args"]?["hello"], "world")
    }

    func testArrayValue() {
        let result = JSONRequest.get(goodUrl, queryParams: params)
        let array = result.arrayValue
        XCTAssertEqual(array.count, 0)
    }

    func testFailingGet() {
        let request = JSONRequest()
        let result = request.get(badUrl, queryParams: params)
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

}
