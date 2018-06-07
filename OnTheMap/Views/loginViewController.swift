//
//  loginViewController.swift
//  OnTheMap
//
//  Created by Priyam Gupta on 12/01/18.
//  Copyright © 2018 Priyam Gupta. All rights reserved.
//

import UIKit

class loginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var acitivityIndicator: UIActivityIndicatorView!
    
    @IBAction func signUpToUdacity(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.udacity.com/account/auth#!/signup")!, options: [:], completionHandler: nil)
    }
    
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordTextField.isSecureTextEntry = true
    }
    
    func setUIenabled(enabled: Bool){
        emailTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        loginButton.isEnabled = enabled
    }
    
    func showAlert(_ error: String) {
        
        let controller = UIAlertController(title: "Alert", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { action in self.dismiss(animated: true, completion: nil)
        }
 
        controller.addAction(okAction)
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func loginToUdacity(){
        if ((emailTextField.text == "") || (passwordTextField.text == "")){
            showAlert("Enter both the credentials")
        }
            
        else{
            setUIenabled(enabled: false)
            udacity.sharedInstance().authenticateUser(username: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.login()
                    self.setUIenabled(enabled: true)
                }
            }
            else{
                self.showAlert(error!)
                self.setUIenabled(enabled: true)
                }
            }
        }
    }
    func login(){
        emailTextField.text = nil; passwordTextField.text = nil
        if let mapAndTableController = storyboard?.instantiateViewController(withIdentifier: "tabBarController") {
            present(mapAndTableController, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
        return true
    }
    
    
}
