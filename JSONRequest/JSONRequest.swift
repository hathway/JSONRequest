//
//  RequestManager.swift
//  welkio
//
//  Created by Eneko Alonso on 9/12/14.
//  Copyright (c) 2014 Hathway. All rights reserved.
//

import UIKit

typealias JSONRequestComplete = (AnyObject?, NSURLResponse, NSError?) -> Void

class JSONRequest: NSObject {

    class func get(urlPath:String, params:NSDictionary?, complete:JSONRequestComplete!) {
        let request = self.request(urlPath, params: params)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            self.parse(data, response: response, error: error, complete: complete)
        }
        task.resume()
    }
    
    class func post(urlPath:String, payload:NSDictionary?, complete:JSONRequestComplete!) {
        let request = self.request(urlPath, params: nil)
        request.HTTPMethod = "POST"
        
        if payload != nil {
            var err: NSError?
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(payload!, options: nil, error: &err)
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
//            println(NSString(data: data, encoding: NSUTF8StringEncoding))
            self.parse(data, response: response, error: error, complete: complete)
        }
        task.resume()
    }
    
    private class func request(url:String, params:NSDictionary?) -> NSMutableURLRequest {
        let parts = params == nil ? [] : params!.allKeys.map { (key) -> String in
            return "\(key as String)=\(params![key as String]!)"
        }
        let query = parts.count == 0 ? "" : ("&" + "&".join(parts))
        let URL =  NSURL(string:url + query.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        let request = NSMutableURLRequest(URL: URL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private class func parse(data:NSData, response:NSURLResponse, error:NSError?, complete:JSONRequestComplete!) {
        if (error == nil) {
            var err: NSError?
            let JSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &err)
            complete(JSON?, response, err)
        } else {
            complete(nil, response, error)
        }
    }
    
}
