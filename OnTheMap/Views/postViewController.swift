//
//  postViewController.swift
//  OnTheMap
//
//  Created by Priyam Gupta on 21/01/18.
//  Copyright © 2018 Priyam Gupta. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class postViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTextField.delegate = self
        websiteTextField.delegate = self
        locationView.isHidden = false
        mapView.isHidden = true
        websiteView.isHidden = true
        activitySpinner.isHidden = true
    }
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        if locationTextField.isFirstResponder{
            self.view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
        else if websiteTextField.isFirstResponder{
            self.view.frame.origin.y = -getKeyboardHeight(notification: notification)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        if locationTextField.isFirstResponder{
            self.view.frame.origin.y = 0
        }
        else if websiteTextField.isFirstResponder{
            self.view.frame.origin.y = 0
        }
    }
    
    func keyBoardNotificationsOn(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func keyBoardNotificationsOff(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyBoardNotificationsOn()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyBoardNotificationsOff()
    }
    
    //locationView
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    
    var postLat : CLLocationDegrees? = nil
    var postLong : CLLocationDegrees? = nil
    
    @IBAction func searchLocation(_ sender: Any) {
        activitySpinner.isHidden = false
        activitySpinner.hidesWhenStopped = true
        activitySpinner.activityIndicatorViewStyle = .gray
        activitySpinner.startAnimating()
        if let activitySpinner = activitySpinner{
            self.view.addSubview(activitySpinner)
        }
        let geocode = CLGeocoder()
        
        guard let location = locationTextField.text else {
            showAlert("Enter a location")
            return
        }
        
        geocode.geocodeAddressString(location){ (landmarks, error) in 
            if ( error == nil){
                self.locationView.isHidden = true
                self.mapView.isHidden = false
                self.websiteView.isHidden = true
                let landmark = landmarks?.first
                if let landmark = landmark{
                    
                    let coordinateSpanMake = MKCoordinateSpanMake(1.0, 1.0)
                    let landmarkCoordinate = landmark.location?.coordinate
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = landmarkCoordinate!
                    
                    self.postLat = (landmarkCoordinate?.latitude)!
                    self.postLong = (landmarkCoordinate?.longitude)!
                    
                    let coordinateRegion = MKCoordinateRegion(center: landmarkCoordinate!, span: coordinateSpanMake)
                    DispatchQueue.main.async {
                        self.mapKitView.removeAnnotation(annotation)
                        self.mapKitView.addAnnotation(annotation)
                        self.mapKitView.setRegion(coordinateRegion, animated: true)
                        self.activitySpinner.isHidden = true
                    }
                }
                else{
                    self.showAlert("No match found!")
                    self.activitySpinner.isHidden = true
                }
            }
            else{
                self.showAlert("Enter a valid location")
                self.activitySpinner.isHidden = true
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
    //mapView
    @IBOutlet weak var mapView: UIView!
    @IBOutlet weak var mapKitView: MKMapView!
    
    @IBAction func placePin(_ sender: Any) {
        self.locationView.isHidden = true
        self.mapView.isHidden = true
        self.websiteView.isHidden = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    } 
    //websiteView
    @IBOutlet weak var websiteView: UIView!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var websiteTextField: UITextField!
    
    @IBAction func submitWebsite(_ sender: Any) {
        if websiteTextField.text == nil {
           showAlert("Enter a website please!")
        }
        parse.sharedInstance().postLocation(mapString: locationTextField.text!, mediaUrl: websiteTextField.text!, latitude: postLat!, longitude: postLong!){(result, success, error)
            in
            if error == nil {
                let finalResult = result
                self.dismiss(animated: true, completion: nil)
            }
            else{
                DispatchQueue.main.async {
                    self.showAlert("Poor internet connection")
                    self.activitySpinner.isHidden=true
                }
                return
            }
        }
    }

    @IBAction func cancelTask(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func doneTask(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    
}
