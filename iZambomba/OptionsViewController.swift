//
//  OptionsViewController.swift
//  iZambomba
//
//  Created by SingularNet on 28/1/19.
//  Copyright © 2019 SingularNet. All rights reserved.
//

import UIKit
import os.log

class OptionsViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var appleIDLabel: UILabel!
    @IBOutlet weak var associatedID: UILabel!
    
    //Buttons
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    @IBOutlet weak var modalView: UIView!
    
    var user: Int = 0
    var userRanking: Bool = false
    var usernameChanged: Bool = false
    var username: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(OptionsViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(OptionsViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        usernameTextField.delegate = self
        associatedID.text = userRanking ? "Yes" : "No"
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
    }
    //MARK: Keyboard show
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    //MARK: Helpers
    private func convertStringToDate(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy H:mm"
        formatter.locale = Locale(identifier: "en_US")
        
        let dateString = formatter.date(from: date)
        return dateString!
    }
    
    private func secondsProcessor(inputSeconds: Int) -> String {
        let secondsInt = ((inputSeconds % 3600) % 60)
        var secondsString: String = "\(secondsInt)"
        if secondsInt < 10 {
            secondsString = "0\((inputSeconds % 3600) % 60)"
        }
        return "\((inputSeconds % 3600) / 60):\(secondsString)"
    }
    
    private func updateAcceptButtonState() {
        // Disable the Save button if the text field is empty.
        let text = usernameTextField.text ?? ""
        acceptButton.isEnabled = !text.isEmpty
    }
    
    private func updateUsername(_ username: String) {
        let url = URL(string: Constants.buildUserUpdate() + "\(user)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let uploadData: [String:String] = [
            "username"  : username
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: uploadData, options: []) else {
            return
        }
        URLSession.shared.uploadTask(with: request, from: data) { (data, response, error) in
            if let error = error {
                print ("updateUsername() error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("Username updated correctly")
            } else {
                print ("Server error in update Username")
                return
            }
            if let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
            }
            }.resume()
    }
    
    private func resetRanking() {
        let url = URL(string: Constants.buildUserUpdate() + "\(user)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let uploadData: [String:Any] = [
            "ranking"  : false
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: uploadData, options: []) else {
            return
        }
        URLSession.shared.uploadTask(with: request, from: data) { (data, response, error) in
            if let error = error {
                print ("updateUserRanking() error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("UserRanking updated correctly")
            } else {
                print ("Server error in update User ranking")
                return
            }
            if let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
            }
            }.resume()
        if let zambRankVC = self.tabBarController?.viewControllers![2] as? RankingViewController {
            zambRankVC.userRanking = false
        }
        
        ZambTableViewController().saveUserRanking(false)
    }
    
    private func presentAlert() {
        let refreshAlert = UIAlertController(title: "Are you sure?", message: "Your username will be changed", preferredStyle: .alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            self.updateUsername(self.username!)
            self.dismiss(animated: true, completion: nil)
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing
        textField.text = ""
        acceptButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        username = textField.text
        updateAcceptButtonState()
        usernameChanged = true
    }
    
    //MARK: Actions
    @IBAction func dismissAction(_ sender: UIButton) {
        usernameChanged = false
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func acceptAction(_ sender: UIButton) {
        if(usernameChanged) {presentAlert()}
        else {
            self.dismiss(animated: true, completion: nil)
        }
        
        //resetRanking()
        usernameChanged = false
    }
    
    
    /*
    //MARK: Navigation
     
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIButton, button === acceptButton else {
            os_log("The accept button was not pressed, aborting", log: OSLog.default, type: .debug)
            return
        }
    }
     */
    
}
