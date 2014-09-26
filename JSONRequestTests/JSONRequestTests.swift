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
        JSONRequest.get("http://httpbin.org/get", params: ["hello": "world"]) { (JSON, response, error) -> Void in
            // JSON is an NSArray, NSDictionary or nil if an error happened
            println(JSON)
            println(response)
            println(error)
            XCTAssert(JSON != nil, "We got JSON")
            let data = JSON! as NSDictionary
            let args = data["args"]! as NSDictionary
            XCTAssert(args["hello"]! as String == "world", "We got Hello World")
        }
    }
    
}
