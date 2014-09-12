//
//  RequestManager.swift
//  welkio
//
//  Created by Eneko Alonso on 9/12/14.
//  Copyright (c) 2014 Hathway. All rights reserved.
//

import UIKit

typealias JSONRequestComplete = (AnyObject) -> Void
typealias JSONRequestFailure = (String, NSError) -> Void

class JSONRequestManager: NSObject {

    class func get(urlPath:String, params:NSDictionary?, complete:JSONRequestComplete!, failure:JSONRequestFailure!) {
        let request = self.request(urlPath, params: params)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            self.parse(data, response: response, error: error, complete: complete, failure: failure)
        }
        task.resume()
    }
    
    class func post(urlPath:String, payload:NSDictionary?, complete:JSONRequestComplete!, failure:JSONRequestFailure!) {
        let request = self.request(urlPath, params: nil)
        request.HTTPMethod = "POST"
        
        if payload != nil {
            var err: NSError?
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(payload!, options: nil, error: &err)
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            self.parse(data, response: response, error: error, complete: complete, failure: failure)
        }
        task.resume()
    }
    
    private class func request(url:String, params:NSDictionary?) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string:url))
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private class func parse(data:NSData, response:NSURLResponse, error:NSError?, complete:JSONRequestComplete!, failure:JSONRequestFailure!) {
        if (error == nil) {
            var err: NSError?
            let JSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err)
            if (err == nil) {
                complete(JSON!)
            } else {
                failure(NSString(data: data, encoding: NSUTF8StringEncoding), err!)
            }
        } else {
            failure(NSString(data: data, encoding: NSUTF8StringEncoding), error!)
        }
    }
    
}
