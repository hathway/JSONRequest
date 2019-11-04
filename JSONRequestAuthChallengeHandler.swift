//
//  JSONRequestAuthChallengeHandler.swift
//  JSONRequest
//
//  Created by Yevhenii Hutorov on 04.11.2019.
//  Copyright © 2019 Hathway. All rights reserved.
//

import Foundation

public protocol JSONRequestAuthChallengeHandler {
    func handle(_ session: URLSession, challenge: URLAuthenticationChallenge) -> URLSession.AuthChallengeDisposition
}

class JSONRequestSessionDelegate: NSObject, URLSessionDelegate {
    var authChallengeHandler: JSONRequestAuthChallengeHandler?
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        let disposition = authChallengeHandler?.handle(session, challenge: challenge) ?? .performDefaultHandling
        completionHandler(disposition, nil)
    }
}
