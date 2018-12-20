//
//  firstInterfaceController.swift
//  iZambomba WatchKit Extension
//
//  Created by SingularNet on 20/12/18.
//  Copyright © 2018 singularfactory. All rights reserved.
//

import Foundation
import WatchKit
import os.log

class FirstInterfaceController: WKInterfaceController {
    
    var zambs = [Zamb]()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        // Configure interface objects here.

        //Check whether is the first time we call this controller or not
        if let contextZambs = context as? [Zamb] {
            
            // Configure interface objects here.
            zambs = contextZambs
        } else {
            print ("Primera aparición o fallo en rootController")
        }
    }

    //MARK: Navigation
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        switch(segueIdentifier) {
        case "newZamb":
            return zambs
            
        default:
            os_log("This shouldn't be printing", log: OSLog.default, type: .debug)
            return nil
        }
    }
    
}
