//
//  locationStruct.swift
//  OnTheMap
//
//  Created by Priyam Gupta on 26/01/18.
//  Copyright © 2018 Priyam Gupta. All rights reserved.
//

import Foundation
import MapKit

struct locationDetails {
    
    let lat : Double
    let long : Double
    var coordinates : CLLocationCoordinate2D{
        return CLLocationCoordinate2DMake(lat, long)
    }
    let mapString : String
}
