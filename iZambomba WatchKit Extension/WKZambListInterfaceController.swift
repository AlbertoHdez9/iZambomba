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
import os.log

class WKZambListInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var tableView: WKInterfaceTable!
    
    var zambs = [Zamb]()
    var isGonnaSync: Bool = false
    
    //TODO - el array zambs se reinicia con cada instancia de la lista, asi que habria que cambiar la declaracion al rootController, de ese modo pasamos el array por contexto al resto de controllers que van rellenando el mismo, y aqui lo recuperamos y pasamos al rowController
    
    private var session = WCSession.default
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        if let contextZambs = context as? [Zamb] {
            print(contextZambs.count)
            
            // Configure interface objects here.
            zambs = contextZambs
            print("amount: \(zambs[0].amount), hand: \(String(describing: zambs[0].hand)), location: \(String(describing: zambs[0].location)), date: \(zambs[0].date), sessionTime: \(zambs[0].sessionTime)")
        }
        
        loadTableCells()
        loadBackgroundAndTableView()
    
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
    
//    override func didAppear() {
//        // Hack to make the digital time overlay disappear
//        
//        let views = NSClassFromString("UIApplication")?.shared().keyWindow?.rootViewController?.viewControllers()?.first?.view().subviews()
//        
//        for view: NSObject? in views as? [NSObject?] ?? [] {
//            if (view is NSClassFromString("SPFullScreenView")) {
//                view?.timeLabel()?.layer().opacity = 0
//            }
//        }
//    }
    
    override func willDisappear() {
        if (!isGonnaSync) {
            WKInterfaceController.reloadRootControllers(withNames: ["First Interface Controller"], contexts: [zambs])
        } else {
            zambs = []
        }
    }
    
    private func loadTableCells() {
        print(zambs.count)
        tableView.setNumberOfRows(zambs.count, withRowType: "WKZambRowController")
        
        for (index, zamb) in zambs.enumerated() {
            if let zambListRowController = tableView.rowController(at: index) as? WKZambRowController {
                zambListRowController.amountLabel.setText("\(zamb.amount)\nZAMBS!")
                zambListRowController.dateLabel.setText(convertDateToString(date: zamb.date))
                zambListRowController.locationLabel.setText(zamb.location)
            }
        }
    }
    
    private func loadBackgroundAndTableView() {
        
        
    }
    
    //MARK: Actions
    @IBAction func syncZamb() {
        isGonnaSync = true
        print("State: \(session.activationState) isReachable: \(session.isReachable)")
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
        formatter.dateFormat = "d MMM yy, hh:mm a"
        formatter.locale = Locale(identifier: "en_US")
        let dateString = formatter.string(from: date)
        
        return dateString.replacingOccurrences(of: ",", with: "\n")
    }
    
    //MARK: Navigation
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        switch(segueIdentifier) {
        case "syncZambs":
            os_log("This shouldn't be printing", log: OSLog.default, type: .debug)
            return nil
            
            
        default:
            
            os_log("Passing non-synchronized zamb list to root", log: OSLog.default, type: .debug)
            return zambs
        }
    }
    
    //MARK: WCSession
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activatioNState: \(activationState) error: \(String(describing: error))")
    }

}
