//
//  RequestManager.swift
//  welkio
//
//  Created by Eneko Alonso on 9/12/14.
//  Copyright (c) 2014 Hathway. All rights reserved.
//

import UIKit

typealias JSONRequestComplete = (AnyObject?, NSURLRequest, NSURLResponse, NSError?) -> Void
private typealias JSONRequestParseComplete = (AnyObject?, NSError?) -> Void

class JSONRequest: NSObject {

    class func get(urlPath:String, params:NSDictionary?, complete:JSONRequestComplete!) {
        let request = self.request(urlPath, params: params)
        let task = NSURLSession.sharedSession().dataTaskWithRequest(request) {(data, response, error) in
            if error == nil {
                self.parse(data) { (JSON, error) in
                    complete(JSON, request, response, error)
                }
            } else {
                complete(nil, request, response, error)
            }
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
            if error == nil {
                self.parse(data) { (JSON, error) in
                    complete(JSON, request, response, error)
                }
            } else {
                complete(nil, request, response, error)
            }
        }
        task.resume()
    }
    
    private class func request(url:String, params:NSDictionary?) -> NSMutableURLRequest {
        let URL =  NSURL(string:url + queryStringWithDictionary(params))
        let request = NSMutableURLRequest(URL: URL)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }

    private class func queryStringWithDictionary(dict:NSDictionary?) -> String {
        let params = dict == nil ? [] : dict!.allKeys.map { (key) -> String in
            let name = (key as String).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            let value = (dict![key as String]! as String).stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            return "\(name)=\(value)"
        }
        return params.count == 0 ? "" : ("?" + "&".join(params))
    }
    
    private class func parse(data:NSData, complete:JSONRequestParseComplete!) {
        // println(NSString(data: data, encoding: NSUTF8StringEncoding))
        var error: NSError?
        let JSON: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)
        complete(JSON, error)
    }
    
}
