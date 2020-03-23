//
//  JSONRequestRawResponseHandler.swift
//  JSONRequest
//
//  Created by Yevhenii Hutorov on 17.03.2020.
//  Copyright © 2020 Hathway. All rights reserved.
//

import Foundation

public protocol JSONRequestRawResponseHandler {
    func handle(_ data: Data?, response: HTTPURLResponse?, error: Error?)
}
