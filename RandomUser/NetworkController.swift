//
//  NetworkController.swift
//  RandomUser
//
//  Created by AJ Bronson on 8/17/16.
//  Copyright © 2016 PrecisionCodes. All rights reserved.
//

import Foundation

class NetworkController {
    
    enum HTTPMethod: String {
        case Get = "GET"
        case Post = "POST"
        case Put = "PUT"
        case Patch = "PATCH"
        case Delete = "DELETE"
    }

    static func performURLRequest(url: NSURL, method: HTTPMethod, urlParams: [String: String]? = nil, body: NSData? = nil, completion: ((data: NSData?, error: NSError?) -> Void)?) {
        let request = NSMutableURLRequest(URL: url)
        request.HTTPBody = body
        request.HTTPMethod = method.rawValue

        let session = NSURLSession.sharedSession()
        let dataTask = session.dataTaskWithRequest(request) { (data, response, error) in
            if let completion = completion {
                completion(data: data, error: error)
            }
        }
        dataTask.resume()
    }
}