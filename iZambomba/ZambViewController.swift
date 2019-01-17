//
//  ViewController.swift
//  iZambomba
//
//  Created by admin on 22/11/2018.
//  Copyright © 2018 singularfactory. All rights reserved.
//

import UIKit
import os.log
import Charts

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
    
    //Switches
    @IBOutlet weak var rightHandSwitch: UISwitch!
    @IBOutlet weak var leftHandSwitch: UISwitch!
    @IBOutlet weak var otherHandSwitch: UISwitch!
    
    @IBOutlet weak var modalView: UIView!
    @IBOutlet weak var chartView: LineChartView!
    
    var user: Int?
    var zamb: Zamb?
    var locationChanged = false
    var selectedHand: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(ZambViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ZambViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        locationTextField.delegate = self
        view.backgroundColor = .clear
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        //Set up views if editing an existing ZAMB
        if let zamb = zamb {
            amountLabel.text = "\(zamb.amount) ZAMBS!"
            //botones de los switches = zamb.hand
            handleSwitches(hand: zamb.hand!)
            dateLabel.text = zamb.date
            locationLabel.text = zamb.location
            locationTextField.text = zamb.location
            sessionTimeLabel.text = secondsProcessor(inputSeconds: zamb.sessionTime)
        }
        displayChart()
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
    
    func secondsProcessor(inputSeconds: Int) -> String {
        let secondsInt = ((inputSeconds % 3600) % 60)
        var secondsString: String = "\(secondsInt)"
        if secondsInt < 10 {
            secondsString = "0\((inputSeconds % 3600) % 60)"
        }
        return "\((inputSeconds % 3600) / 60):\(secondsString)"
    }
    
    private func updateAcceptButtonState() {
        // Disable the Save button if the text field is empty.
        let text = locationLabel.text ?? ""
        acceptButton.isEnabled = !text.isEmpty
    }
    
    private func displayChart() {
        
        var previousZamb: Double = 0
        
        let values = zamb?.frecuencyArray.map { (zambPerSec) -> ChartDataEntry in
            let chartDataEntry = ChartDataEntry(x: Double(zambPerSec["seconds"]!), y: Double(zambPerSec["zambs"]!) - previousZamb)
            previousZamb = Double(zambPerSec["zambs"]!)
            return chartDataEntry
        }

        let set = LineChartDataSet(values: values, label: "")
        set.setColor(.white)
        set.setCircleColor(.white)
        set.lineWidth = 2.0
        set.circleRadius = 1.0
        let data = LineChartData(dataSet: set)
        
        //View
        chartView.backgroundColor = .darkGray
        chartView.data = data
        chartView.leftAxis.drawLabelsEnabled = false
        chartView.rightAxis.drawLabelsEnabled = false
        chartView.xAxis.drawLabelsEnabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.leftAxis.drawGridLinesEnabled = false
        chartView.xAxis.drawAxisLineEnabled = false
        chartView.leftAxis.drawAxisLineEnabled = false
        chartView.rightAxis.drawAxisLineEnabled = false
        
        chartView.chartDescription?.enabled = false
        chartView.legend.enabled = false
        
        //Separators
        let topSeparator = UIView(frame: CGRect(x: 0, y: 0, width: chartView.bounds.width, height: 1))
        topSeparator.backgroundColor = .white
        chartView.addSubview(topSeparator)
    }
    
    //MARK: Switches control
    
    private func handleSwitches(hand: String) {
        selectedHand = hand
        switch hand {
        case "Right":
            rightHandSwitch.isOn = true
            leftHandSwitch.isOn = false
            otherHandSwitch.isOn = false
        case "Left":
            rightHandSwitch.isOn = false
            leftHandSwitch.isOn = true
            otherHandSwitch.isOn = false
        case "Other":
            rightHandSwitch.isOn = false
            leftHandSwitch.isOn = false
            otherHandSwitch.isOn = true
        default:
            rightHandSwitch.isOn = false
            leftHandSwitch.isOn = false
            otherHandSwitch.isOn = false
            print("This shouldn't be printing, location: handleSwitches")
        }
    }
    
    @IBAction func rightHandSwitchTouch(_ sender: UISwitch) {
        if selectedHand == "Right" {
            selectedHand = "No hand"
            rightHandSwitch.setOn(false, animated: true)
        } else {
            rightHandSwitch.setOn(true, animated: true)
            selectedHand = "Right"
            leftHandSwitch.setOn(false, animated: true)
            otherHandSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func leftHandSwitchTouch(_ sender: UISwitch) {
        if selectedHand == "Left" {
            selectedHand = "No hand"
            leftHandSwitch.setOn(false, animated: true)
        } else {
            rightHandSwitch.setOn(false, animated: true)
            selectedHand = "Left"
            leftHandSwitch.setOn(true, animated: true)
            otherHandSwitch.setOn(false, animated: true)
        }
    }
    
    @IBAction func otherHandSwitchTouch(_ sender: UISwitch) {
        if selectedHand == "Other" {
            selectedHand = "No hand"
            otherHandSwitch.setOn(false, animated: true)
        } else {
            rightHandSwitch.setOn(false, animated: true)
            leftHandSwitch.setOn(false, animated: true)
            otherHandSwitch.setOn(true, animated: true)
            selectedHand = "Other"
        }
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
        locationLabel.text = textField.text
        updateAcceptButtonState()
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
        let location = locationChanged ? locationTextField.text : zamb!.location
        let date = convertStringToDate(date: zamb!.date)
        let sessionTime = zamb!.sessionTime
        let frecuencyArray = zamb!.frecuencyArray
        
        zamb = Zamb(user: user!, amount: amount, hand: selectedHand, location: location!, date: date, sessionTime: sessionTime, frecuencyArray: frecuencyArray)
        
        locationChanged = false
    }
}

