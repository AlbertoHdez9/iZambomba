//
//  WKZambListInterfaceController.swift
//  iZambomba WatchKit Extension
//
//  Created by SingularNet on 30/11/18.
//  Copyright © 2018 singularfactory. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class WKZambListInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var amountLabel: WKInterfaceLabel!
    @IBOutlet var dateLabel: WKInterfaceLabel!
    @IBOutlet var locationLabel: WKInterfaceLabel!
    
    var zamb: Zamb?
    private var session = WCSession.default
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        zamb = context as? Zamb
        print("amount: \(zamb!.amount), date : \(convertDateToString(date: zamb!.date)), location: \(String(describing: zamb!.location))      ")
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if isSupported() {
            session.delegate = self
            session.activate()
        }
        updateLabels()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    //MARK: Actions
    @IBAction func syncZamb() {
        sendMessage()
        popToRootController()
    }
    
    @IBAction func sendMessage() {
        if isReachable() {
            session.sendMessage(["zamb" : zamb!], replyHandler: {(response) in
                print("Response: \(response)")
            }, errorHandler: { (error) in
                print("Error: \(error)")
            })
        } else {
            print("Phone is not reachable")
        }
    }
    
    //MARK: Private methods
    private func updateLabels() {
        amountLabel.setText("\(zamb!.amount) ZAMBS!!!")
        dateLabel.setText(convertDateToString(date: zamb!.date))
        locationLabel.setText(zamb!.location)
    }
    
    private func isSupported() -> Bool {
        return WCSession.isSupported()
    }
    
    private func isReachable() -> Bool {
        return session.isReachable
        
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
    
    //MARK: WCSession
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activatioNState: \(activationState) error: \(String(describing: error))")
    }

}
