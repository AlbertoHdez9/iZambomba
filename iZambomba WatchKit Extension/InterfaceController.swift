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
    
    //Frecuency Array
    var frecuencyArray: [Zamb.zambsPerSec] = [Zamb.zambsPerSec]()
    var finalFrecuencyArray: [[String:Int]] = [[String:Int]]()
    
    //Timer
    var timer: Timer?
    var timerSeconds: Int = 0
    var timerForFrecuencyArray: Timer?
    
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
        WKExtension.shared().isAutorotating = true
        
        //Timer
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(processTimer), userInfo: nil, repeats: true)
        
        //Frecuency array trigger
        timerForFrecuencyArray = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(buildFrecuencyArray), userInfo: nil, repeats: true)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        startedZambSession = false
        
        manager.stopWorkout()
        WKExtension.shared().isAutorotating = false
        
        //Timer
        timer?.invalidate()
        timer = nil
        
        timerForFrecuencyArray?.invalidate()
        timerForFrecuencyArray = nil
        
    }
    
    //MARK: Private methods
    private func updateZambLabel() {
        if startedZambSession {
            zambAmount.setText("\(self.currentZambAmount) ZAMBS!")
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
    
    @objc private func buildFrecuencyArray() {
        frecuencyArray.append(
            Zamb.zambsPerSec(zambs: currentZambAmount, seconds: timerSeconds)
        )
    }
    
    private func secondsProcessor(inputSeconds: Int) -> String {
        let secondsInt = ((inputSeconds % 3600) % 60)
        var secondsString: String = "\(secondsInt)"
        if secondsInt < 10 {
            secondsString = "0\((inputSeconds % 3600) % 60)"
        }
        return "\((inputSeconds % 3600) / 60):\(secondsString)"
    }
    
    private func processFrecuencyArray() {
        var intervalFloat = (Float(timerSeconds)/10.0)
        intervalFloat.round()
        var interval = Int(intervalFloat)
        let increment = interval
        
        for zambPerSec in frecuencyArray.enumerated() {
            if (zambPerSec.element.seconds >= interval) {
                finalFrecuencyArray.append(["zambs": zambPerSec.element.zambs, "seconds" : zambPerSec.element.seconds])
                interval = interval + increment
            }
        }
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
                processFrecuencyArray()
                let frecuencyArray = finalFrecuencyArray

                if let zamb = Zamb(id: 0, user: 1, amount: amount, hand: hand, location: location, date: date, sessionTime: sessionTime, frecuencyArray: frecuencyArray) {
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
