//
//  NewZambViewController.swift
//  iZambomba
//
//  Created by SingularNet on 29/11/18.
//  Copyright © 2018 singularfactory. All rights reserved.
//

import UIKit
import os.log

class NewZambViewController: UIViewController , WorkoutManagerDelegate {
    
    
    @IBOutlet weak var zambAmount: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var currentZambAmount: Int = 0
    var startedZambSession: Bool = false
    var timer: Timer?
    var timerSeconds: Int = 0
    var zamb: Zamb?
    
    var manager = WorkoutManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: Private methods
    private func updateZambLabel() {
        if startedZambSession {
            zambAmount.text = "\(self.currentZambAmount) ZAMBS!!!"
        }
    }
    
    
    internal func didUpdateMotion(_ manager: WorkoutManager, zambAmount: Int) {
        DispatchQueue.main.async {
            self.currentZambAmount = zambAmount
            self.updateZambLabel()
        }
    }
    
    @objc private func processTimer() {
        timerSeconds += 1
        timerLabel.text = "\(timerSeconds) seconds"
    }
    
    private func secondsProcessor(inputSeconds: Int) -> String {
        let processedTime: String
        if (inputSeconds / 3600) > 0 {
            processedTime = "\(inputSeconds / 3600)"
        }
        if ((inputSeconds % 3600) / 60) > 0 {
            
        }
        let minutes: Int = (inputSeconds % 3600) / 60
        let seconds: Int = (inputSeconds % 3600) % 60
        
        return ""
    }

    
    //MARK: Actions
    @IBAction func changeSessionStatus(_ sender: UIButton) {
        startedZambSession = !startedZambSession
        if (startButton.titleLabel!.text == "Start") {
            startButton.setTitle("Stop", for: .normal)
            
            manager.startWorkout(type: 0) //type: 0 -> iPhone
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(processTimer), userInfo: nil, repeats: true)

            
        } else {
            manager.stopWorkout()
            startButton.setTitle("Start", for: .normal)
            timer?.invalidate()
            timer = nil
        }
    }
    
    @IBAction func cancelNewZamb(_ sender: UIBarButtonItem) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let amount = currentZambAmount
        let hand = "Right"
        let location = "Choso"
        let date = Date()
        
        zamb = Zamb(amount: amount, hand: hand, location: location, date: date)
    }
    

}
