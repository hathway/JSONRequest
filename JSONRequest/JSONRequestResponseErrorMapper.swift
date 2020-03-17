//
//  JSONRequestResponseErrorMapper.swift
//  JSONRequest
//
//  Created by Yevhenii Hutorov on 17.03.2020.
//  Copyright © 2020 Hathway. All rights reserved.
//

import Foundation

public protocol JSONRequestResponseErrorMapper {
    typealias TransformedErrorBlock = (Error) -> Void
    func handle(_ error: Error, response: HTTPURLResponse?, completion: @escaping TransformedErrorBlock)
}
