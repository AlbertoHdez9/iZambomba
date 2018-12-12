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
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    var zambs = [Zamb]()
    
    //TODO - el array zambs se reinicia con cada instancia de la lista, asi que habria que cambiar la declaracion al rootController, de ese modo pasamos el array por contexto al resto de controllers que van rellenando el mismo, y aqui lo recuperamos y pasamos al rowController
    
    private var session = WCSession.default
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        if let zamb = context as? Zamb {
            print("amount: \(zamb.amount), date : \(convertDateToString(date: zamb.date)), location: \(String(describing: zamb.location)), hand: \(String(describing: zamb.hand)), sessionTime: \(zamb.sessionTime)")
            
            // Configure interface objects here.
            zambs += [zamb]
            loadTableCells()
            
        }
    
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if isSupported() {
            session.delegate = self
            session.activate()
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    override func willDisappear() {
        //popToRootController()
    }
    
    func loadTableCells() {
        print(zambs.count)
        tableView.setNumberOfRows(zambs.count, withRowType: "WKZambRowController")
        
        for (index, zamb) in zambs.enumerated() {
            if let zambListRowController = tableView.rowController(at: index) as? WKZambRowController {
                zambListRowController.amountLabel.setText("\(zamb.amount) ZAMBS!!!")
                zambListRowController.dateLabel.setText(convertDateToString(date: zamb.date))
                zambListRowController.locationLabel.setText(zamb.location)
            }
        }
    }
    
    //MARK: Actions
    @IBAction func syncZamb() {
        sendMessage()
        popToRootController()
    }
    
    func sendMessage() {
        if isReachable() {
            for zamb in zambs {
                let message: [String : Any] = [
                    "amount"        : zamb.amount,
                    "hand"          : zamb.hand ?? "",
                    "location"      : zamb.location ?? "",
                    "date"          : zamb.date,
                    "sessionTime"   : zamb.sessionTime ]
                
                session.sendMessage(message, replyHandler: nil, errorHandler: nil)
                print("Message sent")
            }
        } else {
            print("Phone is not reachable")
        }
    }
    
    //MARK: Private methods
  
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
