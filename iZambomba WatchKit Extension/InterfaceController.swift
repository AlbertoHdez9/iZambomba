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
    @IBOutlet var doneButton: WKInterfaceButton!
    
    var currentZambAmount: Int = 0
    var startedZambSession: Bool = false
    var zamb: Zamb?
    
    var manager = WorkoutManager()
    
    override init() {
        super.init()
        manager.delegate = self
    }

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        startedZambSession = true
        
        //manager.startWorkout(type: 1) //type: 1 -> Watch
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        startedZambSession = false
        //manager.stopWorkout()
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
    
    //MARK: Actions
    @IBAction func doneButtonAction() {
        startedZambSession = false
        //manager.stopWorkout()
        //if currentZambAmount == 0 {
            //popToRootController()
        //}
    }
    
    //MARK: Navigation
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        switch(segueIdentifier) {
            case "addZamb":
                //let amount = currentZambAmount
                let amount = 2500 //for simulation purposes
                let hand = "Right"
                let location = "Indahouse"
                let date = Date()
                let sessionTime = 2
                
                zamb = Zamb(amount: amount, hand: hand, location: location, date: date, sessionTime: sessionTime)
                
                os_log("Adding a new zamb", log: OSLog.default, type: .debug)
                return zamb
            
            default:
                os_log("This shouldn't be printing", log: OSLog.default, type: .debug)
                return nil
        }
    }

}
