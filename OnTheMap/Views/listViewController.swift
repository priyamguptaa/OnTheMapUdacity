//
//  listViewController.swift
//  OnTheMap
//
//  Created by Priyam Gupta on 16/01/18.
//  Copyright © 2018 Priyam Gupta. All rights reserved.
//

import UIKit

class listViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var listView: UITableView!
    @IBAction func logout(_ sender: Any) {
        udacity.sharedInstance().endSession{ (success, error) in
            if success {
                self.tabBarController?.dismiss(animated: true, completion: nil)
            } else {
                self.showAlert(error!)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.list()
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
    
    func list() {
        parse.sharedInstance().displayLocation{ (locations, success, error) in
            if success {
                DispatchQueue.main.async {
                    self.listView.reloadData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return student.Location.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath : IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "listCell")!
        let students = student.Location[indexPath.row]
        let studentName: String
        if "\(students.firstName!)" == nil{
             studentName = "\(students.lastName!)"
        }
        else if "\(students.lastName!)" == nil{
             studentName = "\(students.firstName!)"
        }
        else{
            studentName = "\(students.firstName!) \(students.lastName!)"
        }
        let range = studentName.rangeOfCharacter(from: NSCharacterSet.letters)
        if range != nil {
            if students.firstName != nil && students.lastName != nil {
                cell.textLabel?.text = studentName
                
            }
            else {
                //fullName.text = "Anonymous"
            cell.textLabel?.text = "Anonymous"
            }
        }
        else {
           cell.textLabel?.text = "Anonymous"
            //fullName.text = "Anonymous"
        }
        if let mediaUrl = students.mediaURL {
            cell.detailTextLabel?.text = mediaUrl
           // location.text = mediaUrl
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        let mediaUrl = student.Location[indexPath.row].mediaURL
        if let toOpen = mediaUrl {
            if canVerifyUrl(urlString: toOpen) {
                app.open(URL(string: toOpen)!, options: [:], completionHandler: nil)
            } else {
                showAlert("The URL was not valid and could not be opened")
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
}
