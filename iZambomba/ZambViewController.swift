//
//  ViewController.swift
//  iZambomba
//
//  Created by admin on 22/11/2018.
//  Copyright © 2018 singularfactory. All rights reserved.
//

import UIKit
import os.log

class ZambViewController: UIViewController, UITextFieldDelegate {

    //MARK: Properties
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var sessionTimeLabel: UILabel!
    
        //Buttons
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    var zamb: Zamb?
    var locationChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(ZambViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ZambViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        locationTextField.delegate = self
        
        //Set up views if editing an existing ZAMB
        if let zamb = zamb {
            amountLabel.text = "\(zamb.amount) ZAMBS!"
            //botones de los switches = zamb.hand
            dateLabel.text = convertDateToString(date: zamb.date)
            locationLabel.text = zamb.location
            sessionTimeLabel.text = secondsProcessor(inputSeconds: zamb.sessionTime)
        }
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
    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    func secondsProcessor(inputSeconds: Int) -> String {
        let secondsInt = ((inputSeconds % 3600) % 60)
        var secondsString: String = "\(secondsInt)"
        if secondsInt < 10 {
            secondsString = "0\((inputSeconds % 3600) % 60)"
        }
        return "\((inputSeconds % 3600) / 60):\(secondsString)"
    }
    
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Disable the Save button while editing
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        locationLabel.text = textField.text
        locationChanged = true
    }
    
    //MARK: Actions
    @IBAction func dismissAction(_ sender: UIButton) {
        locationChanged = false
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: Navigation
    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let button = sender as? UIButton, button === acceptButton else {
            os_log("The accept button was not pressed, aborting", log: OSLog.default, type: .debug)
            return
        }
        
        let amount = zamb!.amount
        let hand = zamb!.hand
        let location = locationChanged ? locationTextField.text : zamb!.location
        let date = zamb!.date
        let sessionTime = zamb!.sessionTime
        
        zamb = Zamb(amount: amount, hand: hand, location: location, date: date, sessionTime: sessionTime)
        
        locationChanged = false
    }
}

