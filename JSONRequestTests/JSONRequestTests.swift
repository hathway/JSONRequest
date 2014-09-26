//
//  JSONRequestTests.swift
//  JSONRequestTests
//
//  Created by Eneko Alonso on 9/26/14.
//  Copyright (c) 2014 Hathway. All rights reserved.
//

import UIKit
import XCTest

class JSONRequestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testSimpleGet() {
        let URL = "http://httpbin.org/get"
        let expectation = expectationWithDescription("\(URL)")

        JSONRequest.get(URL, params: ["hello": "world"]) { (JSON, request, response, error) -> Void in
            expectation.fulfill()
            println(JSON)
            println(request)
            println(response)
            println(error)
            XCTAssert(JSON != nil, "We got JSON")
            let data = JSON! as NSDictionary
            let args = data["args"]! as NSDictionary
            XCTAssert(args["hello"]! as String == "world", "We got Hello World")
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }

    func testComplexGet() {
        let URL = "http://httpbin.org/get"
        let expectation = expectationWithDescription("\(URL)")
        
        let params = [
            "multi-word key": "this is a long value",
            "empty-value": ""
        ]
        
        JSONRequest.get(URL, params: params) { (JSON, request, response, error) -> Void in
            expectation.fulfill()
            println(JSON)
            println(request)
            println(response)
            println(error)
            XCTAssert(JSON != nil, "We got JSON")
            let data = JSON! as NSDictionary
            let args = data["args"]! as NSDictionary
            XCTAssert(args["multi-word key"]! as String == "this is a long value", "Multi-word")
        }
        
        waitForExpectationsWithTimeout(10) { (error) in
            XCTAssertNil(error, "\(error)")
        }
    }

    
}
