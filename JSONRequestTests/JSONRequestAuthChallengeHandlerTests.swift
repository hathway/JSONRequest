//
//  JSONRequestAuthChallengeHandlerTests.swift
//  JSONRequestTests
//
//  Created by Yevhenii Hutorov on 11.11.2019.
//  Copyright © 2019 Hathway. All rights reserved.
//

import XCTest
import JSONRequest

class JSONRequestAuthChallengeHandlerTests: XCTestCase {
    func testHandlerInjection() {
        XCTAssertNil(JSONRequest.authChallengeHandler)

        let sslPinningHandler = JSONRequestSSLPinningHandler()
        XCTAssertTrue(sslPinningHandler.cerificatePublicKeys.isEmpty)

        sslPinningHandler.cerificatePublicKeys["google.com"] = "xjcjKKKLll-dd45mMM-3"
        XCTAssertEqual(sslPinningHandler.cerificatePublicKeys.count, 1)

        JSONRequest.authChallengeHandler = sslPinningHandler
        XCTAssertNotNil(JSONRequest.authChallengeHandler)
    }
}
