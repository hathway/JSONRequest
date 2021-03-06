//
//  JSONRequestAuthChallengeHandler.swift
//  JSONRequest
//
//  Created by Yevhenii Hutorov on 04.11.2019.
//  Copyright © 2019 Hathway. All rights reserved.
//

import Foundation

public struct JSONRequestAuthChallengeResult {
    public let disposition: URLSession.AuthChallengeDisposition
    public let credential: URLCredential?

    public init(disposition: URLSession.AuthChallengeDisposition, credential: URLCredential? = nil) {
        self.disposition = disposition
        self.credential = credential
    }
}

public protocol JSONRequestAuthChallengeHandler {
    func handle(_ session: URLSession, challenge: URLAuthenticationChallenge) -> JSONRequestAuthChallengeResult
}

class JSONRequestSessionDelegate: NSObject, URLSessionDelegate {
    var authChallengeHandler: JSONRequestAuthChallengeHandler?
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let result = authChallengeHandler?.handle(session, challenge: challenge)
        let disposition = result?.disposition ?? .performDefaultHandling
        completionHandler(disposition, result?.credential)
    }
}
