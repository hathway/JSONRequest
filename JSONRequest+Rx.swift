//
//  JSONRequest+Rx.swift
//  JSONRequest
//
//  Created by Alex Antonyuk on 1/22/19.
//  Copyright © 2019 Hathway. All rights reserved.
//

import Foundation
import RxSwift

extension JSONRequest {
    public func send(_ method: JSONRequestHttpVerb, url: String, queryParams: JSONObject? = nil, payload: Any? = nil, headers: JSONObject? = nil, timeOut: TimeInterval? = nil) -> Single<JSONResult> {
        return Single.create(subscribe: { single -> Disposable in
            let task = self.send(method, url: url, queryParams: queryParams, payload: payload, headers: headers, timeOut: timeOut, complete: { result in
                single(.success(result))
            })

            return Disposables.create {
                task?.cancel()
            }
        })
    }
}
