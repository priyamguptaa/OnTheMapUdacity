//
//  parse.swift
//  OnTheMap
//
//  Created by Priyam Gupta on 16/01/18.
//  Copyright © 2018 Priyam Gupta. All rights reserved.
//

import UIKit

class parse: NSObject {
    
    class func sharedInstance() -> parse {
        struct Singleton {
            static var sharedInstance = parse()
        }
        return Singleton.sharedInstance
    }
    
    func getLocation(getLocationCompletionHandler: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation/?limit=100&order=-updatedAt")!)
        
        request.addValue(parseConstants.parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(parseConstants.restApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let session = udacity.sharedSession
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                getLocationCompletionHandler(nil, false, "Please Check Your Network Connection")
                return
            }
            
            udacity.sharedInstance().handleErrors(data, response, error as NSError?, completionHandler: getLocationCompletionHandler)
            udacity.sharedInstance().convertDataWithCompletionHandler(data!, completionHandlerForConvertedData: getLocationCompletionHandler)
        }
        task.resume()
    }
    func displayLocation(completionHandler: @escaping (_ result : [student]? , _ success: Bool , _ error: String?) -> Void ) {
        parse.sharedInstance().getLocation{(result, success, error) in
            if success {
                if let data = result!["results"] as AnyObject? {
                    student.Location.removeAll()
                    for result in data as! [AnyObject] {
                        let stud = student(dictionary: result as! [String : AnyObject])
                        student.Location.append(stud)
                    }
                    completionHandler(student.Location, true, nil)
                }
            }
            else{
                completionHandler(nil, false, error)
            }
        }
    }
    
    func postLocation(mapString: String, mediaUrl: String, latitude: Double, longitude: Double, completionHandlerForPostLocation: @escaping (_ result: [String:AnyObject]?, _ success: Bool,  _ error: String?) -> Void) {
        var request = URLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation")!)
        request.httpMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dictionary: [String:Any] = [
            "uniqueKey": udacity.userId!,
            "firstName": udacity.fname!,
            "lastName": udacity.lname!,
            "mapString": mapString,
            "mediaURL": mediaUrl,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        request.httpBody = jsonData
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            guard let _ = data else {
                completionHandlerForPostLocation(nil, false, "Please Check Your Network Connection")
                return
            }
            udacity.sharedInstance().handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPostLocation)
            udacity.sharedInstance().convertDataWithCompletionHandler(data!, completionHandlerForConvertedData: completionHandlerForPostLocation)
        }
        task.resume()
    }
}

