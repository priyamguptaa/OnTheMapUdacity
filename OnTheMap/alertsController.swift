//
//  alertsController.swift
//  OnTheMap
//
//  Created by Priyam Gupta on 21/01/18.
//  Copyright © 2018 Priyam Gupta. All rights reserved.
//

import UIKit

class alertsController: UIViewController {
    
    static var shared = alertsController()
    
    func showAlert(_ error: String) {
        
        let controller = UIAlertController()
        controller.title = "Alert"
        controller.message = error
        
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { action in self.dismiss(animated: true, completion: nil)
        }
        
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
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
    

}
