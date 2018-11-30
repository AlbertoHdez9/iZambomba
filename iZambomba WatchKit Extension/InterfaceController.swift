//
//  InterfaceController.swift
//  iZambomba WatchKit Extension
//
//  Created by admin on 22/11/2018.
//  Copyright © 2018 singularfactory. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, WorkoutManagerDelegate {
    
    @IBOutlet var zambAmount: WKInterfaceLabel!
    @IBOutlet var doneButton: WKInterfaceButton!
    
    var currentZambAmount: Int = 0
    var startedZambSession: Bool = false
    var zamb: Zamb?
    
    var manager = WorkoutManager()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        manager.delegate = self
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        startedZambSession = true
        
        manager.startWorkout()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
        manager.stopWorkout()
    }
    
    

}
