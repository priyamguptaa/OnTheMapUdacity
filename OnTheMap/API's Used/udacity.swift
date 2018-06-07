//
//  udacity.swift
//  OnTheMap
//
//  Created by Priyam Gupta on 13/01/18.
//  Copyright © 2018 Priyam Gupta. All rights reserved.
//

import UIKit

class udacity: NSObject {
    
    class func sharedInstance() -> udacity {
        struct Singleton {
            static var sharedInstance = udacity()
        }
        return Singleton.sharedInstance
    }
    
    // shared session
    static var sharedSession = URLSession.shared
    
    // authentication state
    static var sessionId: String? = nil
    static var userId: String? = nil

    static var fname: String? = nil
    static var lname: String? = nil
    
    func authenticateUser(username: String, password: String, completionHandlerForAuth: @escaping (_ success: Bool, _ error: String?) -> Void) {
        
        let _ = createSession(udacityConstants.sessionUrl , username: username, password: password) { (result, success, error) in
            
            guard let _ = result else {
                completionHandlerForAuth(false, "Please Check Your Network Connection")
                return
            }
            guard let session = result?["session"],
                let sessionId = session["id"] as? String,
                let user = result?["account"],
                let userId = user["key"] as? String else {
                print("Error")
                completionHandlerForAuth(false, "Enter the Correct Credentials.")
                return
            }
            udacity.sessionId = sessionId
            udacity.userId = userId
            
            let _ = self.userData(completionHandlerForUserData: { (result, success, error) in
                guard let user = result?["user"] else {
                    print("Error")
                    return
                }
                
                guard let firstName = user["first_name"] as? String, let lastName = user["last_name"] as? String else {
                    print("Error")
                    return
                }
                udacity.fname = firstName as String?
                udacity.lname = lastName as String?
            }
            )
            
            completionHandlerForAuth(true, nil)
        }
    }
    func handleErrors(_ data: Data?, _ response: URLResponse?, _ error: NSError?, completionHandler: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        
        guard (error == nil) else {
            completionHandler(nil, false, "Please Check Your Network Connection")
            return
        }
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            completionHandler(nil, false, "Enter the Correct Credentials.")
            return
        }
        guard let _ = data else {
            completionHandler(nil, false, "No Data Found.")
            return
        }
    }
    
    func createSession(_ url_path: String, username: String, password: String, completionHandlerForPOST: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) -> URLSessionDataTask {
        
        let request = NSMutableURLRequest(url: URL(string: url_path)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dictionary: [String: Any] = [
            "udacity": [
                "username": username,
                "password": password
            ]
        ]
        
        let jsonData = try! JSONSerialization.data(withJSONObject: dictionary, options: .prettyPrinted)
        request.httpBody = jsonData
        
        let task = udacity.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                self.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForPOST)
                return
            }
            
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForPOST)
            
        }
        task.resume()
        
        return task
    }
    
    func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertedData: (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
        let parsedResult: AnyObject!
        
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject!
        } catch {
            completionHandlerForConvertedData(nil, false, "There was an error parsing the JSON")
            return
        }
        completionHandlerForConvertedData(parsedResult as? [String:AnyObject], true, nil)
    }
    func endSession(completionHandlerForDeleteSession: @escaping (_ success: Bool, _ error: String?) -> Void) {
        let _ = removeSession { (result, success, error) in
            if success {
                completionHandlerForDeleteSession(true, nil)
            } else {
                completionHandlerForDeleteSession(false, error)
            }
        }
    }
    
    func removeSession(completionHandlerForDELETE: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) -> URLSessionDataTask {
        
        
        let request = NSMutableURLRequest(url: URL(string:  udacityConstants.sessionUrl)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let task = udacity.sharedSession.dataTask(with: request as URLRequest) { data, response, error in
            
            guard let _ = data else {
                self.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForDELETE)
                return
            }
           self.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForDELETE)
            
            let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
            self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForDELETE)
        }
        task.resume()
        return task
    }
    
    func userData(completionHandlerForUserData: @escaping (_ result: [String:AnyObject]?, _ success: Bool, _ error: String?) -> Void) {
    
    let request = NSMutableURLRequest(url: URL(string: "\(udacityConstants.userIdUrl)\(udacity.userId!)")!)
    let task = udacity.sharedSession.dataTask(with: request as URLRequest) { data, response, error in

        guard let _ = data else {
            completionHandlerForUserData(nil, false, "Please Check Your Network Connection")
            return
        }
        self.handleErrors(data, response, error as NSError?, completionHandler: completionHandlerForUserData)
        let newData = data?.subdata(in: Range(uncheckedBounds: (5, data!.count)))
        self.convertDataWithCompletionHandler(newData!, completionHandlerForConvertedData: completionHandlerForUserData)
    }
    task.resume()
}
}
