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
        
        if let zamb = context as? Zamb {
            print("amount: \(zamb.amount), date : \(convertDateToString(date: zamb.date)), location: \(String(describing: zamb.location)), hand: \(String(describing: zamb.hand)), sessionTime: \(zamb.sessionTime)")
            
            // Configure interface objects here.
            
            //self.amountLabel.setText("\(zamb.amount) ZAMBS!!!")
            //self.dateLabel.setText(convertDateToString(date: zamb.date))
            //locationLabel.setText(zamb.location)
            self.zamb = zamb
        }
    
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        updateLabels()
        if isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        popToRootController()
    }
    
    //MARK: Actions
    @IBAction func syncZamb() {
        sendMessage()
        popToRootController()
    }
    
    func sendMessage() {
        if isReachable() {
            if let zamb = zamb {
                
                let message: [String : Any] = [
                    "amount"        : zamb.amount,
                    "hand"          : zamb.hand ?? "",
                    "location"      : zamb.location ?? "",
                    "date"          : zamb.date,
                    "sessionTime"   : zamb.sessionTime ]
                
                session.sendMessage(message, replyHandler: nil, errorHandler: nil)
                print("Message sent")
            } else {
                print("Zamb incomplete, message could not be sent")
            }
        } else {
            print("Phone is not reachable")
        }
    }
    
    //MARK: Private methods
    private func updateLabels() {
        if let zamb = zamb {
            amountLabel.setText("\(zamb.amount) ZAMBS!!!")
            dateLabel.setText(convertDateToString(date: zamb.date))
            locationLabel.setText(zamb.location)
        }
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
