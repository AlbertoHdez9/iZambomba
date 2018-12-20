//
//  InterfaceController.swift
//  iZambomba WatchKit Extension
//
//  Created by admin on 22/11/2018.
//  Copyright © 2018 singularfactory. All rights reserved.
//

import WatchKit
import Foundation
import os.log


class InterfaceController: WKInterfaceController, WorkoutManagerDelegate {
    
    @IBOutlet var zambAmount: WKInterfaceLabel!
    @IBOutlet weak var timerLabel: WKInterfaceLabel!
    
    @IBOutlet var doneButton: WKInterfaceButton!
    
    //Zamb session config
    var currentZambAmount: Int = 0
    var startedZambSession: Bool = false
    
    //Zambs for controller and context
    var zambs = [Zamb]()
    
    //Timer
    var timer: Timer?
    var timerSeconds: Int = 0
    
    var manager = WorkoutManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
        
        if let contextZambs = context as? [Zamb] {
            print(contextZambs.count)
        
            // Configure interface objects here.
            zambs = contextZambs
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        startedZambSession = true
        
        manager.startWorkout(type: 1) //type: 1 -> Watch
        
        //Timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(processTimer), userInfo: nil, repeats: true)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        startedZambSession = false
        manager.stopWorkout()
        
        //Timer
        timer?.invalidate()
        timer = nil
    }
    
    //MARK: Private methods
    private func updateZambLabel() {
        if startedZambSession {
            zambAmount.setText("\(self.currentZambAmount) ZAMBS!!!")
        }
    }
    
    func didUpdateMotion(_ manager: WorkoutManager, zambAmount: Int) {
        DispatchQueue.main.async {
            self.currentZambAmount = zambAmount
            self.updateZambLabel()
        }
    }
    
    @objc private func processTimer() {
        timerSeconds += 1
        timerLabel.setText(secondsProcessor(inputSeconds: timerSeconds))
    }
    
    private func secondsProcessor(inputSeconds: Int) -> String {
        let secondsInt = ((inputSeconds % 3600) % 60)
        var secondsString: String = "\(secondsInt)"
        if secondsInt < 10 {
            secondsString = "0\((inputSeconds % 3600) % 60)"
        }
        return "\((inputSeconds % 3600) / 60):\(secondsString)"
    }
    
    //MARK: Actions
    @IBAction func doneButtonAction() {
        startedZambSession = false
        manager.stopWorkout()
        if currentZambAmount == 0 {
            popToRootController()
        }
    }
    
    //MARK: Navigation
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        switch(segueIdentifier) {
            case "addZamb":
                let amount = 2500 //for simulation purposes
                //let amount = currentZambAmount
                let hand = "No hand"
                let location = "No location"
                let date = Date()
                let sessionTime = timerSeconds
                
                if let zamb = Zamb(amount: amount, hand: hand, location: location, date: date, sessionTime: sessionTime) {
                    zambs += [zamb]
                }
                
                os_log("Adding a new zamb", log: OSLog.default, type: .debug)
                return zambs
            
            default:
                os_log("This shouldn't be printing", log: OSLog.default, type: .debug)
                return nil
        }
    }

}
