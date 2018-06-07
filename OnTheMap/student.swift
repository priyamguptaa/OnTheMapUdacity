//
//  student.swift
//  OnTheMap
//
//  Created by Priyam Gupta on 12/01/18.
//  Copyright © 2018 Priyam Gupta. All rights reserved.
//

import Foundation

struct student {
    
    class studentStruct: NSObject{
        
        static let sharedData = studentStruct()
        var studentInfo = [student]()
    }
    
    static var Location = [student]()
    var objectId: String? = ""
    var uniqueKey: String? = ""
    var firstName: String? = ""
    var lastName: String? = ""
    var mapString: String? = ""
    var mediaURL: String? = ""
    var latitude : Double?
    var longitude : Double?
    
    var studentName: String{
        return "\(firstName) \(lastName)"
    }
    
    init (dictionary: [String : AnyObject]) {
        
        self.objectId = dictionary["objectId"] as? String
        self.uniqueKey = (dictionary["uniqueKey"] as? String)
        self.firstName = (dictionary["firstName"] as? String)
        self.lastName = (dictionary["lastName"] as? String)
        self.mapString = (dictionary["mapString"] as? String)
        self.mediaURL = (dictionary["mediaURL"] as? String)
        self.latitude = (dictionary["latitude"] as? Double)
        self.longitude = (dictionary["longitude"] as? Double)
        
    }
}

