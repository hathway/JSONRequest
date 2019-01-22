//
//  JSONRequestTests+Rx.swift
//  JSONRequestTests
//
//  Created by Alex Antonyuk on 1/22/19.
//  Copyright © 2019 Hathway. All rights reserved.
//

import XCTest
@testable import JSONRequest
import DVR
import RxTest
import RxBlocking

class JSONRequestTests_Rx: XCTestCase {
    let goodUrl = "http://httpbin.org/delete"
    let badUrl = "httpppp://httpbin.org/delete"
    let params: JSONObject = ["hello": "world"]

    func testGET() {
        let jsonRequest = JSONRequest(session: DVR.Session(cassetteName: "testFiles/testSimpleGET"))
        let result = try! jsonRequest.send(.GET, url: goodUrl, queryParams: params).toBlocking().toArray().first!
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
}
