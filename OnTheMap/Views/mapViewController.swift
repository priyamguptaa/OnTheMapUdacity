//
//  mapViewController.swift
//  OnTheMap
//
//  Created by Priyam Gupta on 13/01/18.
//  Copyright © 2018 Priyam Gupta. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class mapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapOutlet: MKMapView!
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapOutlet.delegate = self
        mapOutlet.addAnnotations(annotations)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async{
        self.map()
        }
    }
    func map(){
        parse.sharedInstance().displayLocation() { ( locations, success, error) in
            if success { 
                for location in locations! {
                    if let lattitude = location.latitude ,
                        let longitude = location.longitude,
                        let firstName = location.firstName,
                        let lastName = location.lastName,
                        let mediaURL = location.mediaURL{
                            let annotation = MKPointAnnotation()
                        let lattDegrees = CLLocationDegrees(lattitude)
                        let longDegrees = CLLocationDegrees(longitude)
                        let coordinate = CLLocationCoordinate2D(latitude: lattDegrees, longitude: longDegrees)
                        annotation.coordinate = coordinate
                        annotation.title = "\(firstName) \(lastName)"
                        if mediaURL.isEmpty {
                            annotation.subtitle = "http://www.udacity.com"
                        }
                        else{
                            annotation.subtitle = mediaURL
                        }
                        self.annotations.append(annotation)
                }
            }
            DispatchQueue.main.async {
                self.mapOutlet.removeAnnotations(self.annotations)
                self.mapOutlet.addAnnotations(self.annotations)
            }
        }
        else {
                self.showAlert(error!)
        }
    }
    }
    func showAlert(_ error: String) {
    
        let controller = UIAlertController(title: "Alert", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ok", style: UIAlertActionStyle.default) { action in self.dismiss(animated: true, completion: nil)
        }
        
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func logout(_ sender: Any) {
        udacity.sharedInstance().endSession{ (success, error) in
            if success {
                self.tabBarController?.dismiss(animated: true, completion: nil)
            } else {
               self.showAlert(error!)
                
            }
        }
    }
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    
    // This delegate method is implemented to respond to taps. It opens the system browser
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle {
            if canVerifyUrl(urlString: toOpen) {
                app.open(URL(string: toOpen!)!, options: [:], completionHandler: nil)
            } else {
                self.showAlert("URL not valid and could not be opened")
            }
        }
    }
    }
    
    func canVerifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url  = NSURL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
}
