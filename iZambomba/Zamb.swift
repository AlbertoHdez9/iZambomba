//
//  Zamb.swift
//  iZambomba
//
//  Created by admin on 22/11/2018.
//  Copyright © 2018 singularfactory. All rights reserved.
//
import UIKit
import os.log

struct Zamb : Codable {
    
    //MARK: Properties
    let id: Int
    let user: Int
    let amount: Int
    let hand: String?
    let location: String?
    let date: String
    let sessionTime: Int
    let frecuency: Float
    struct zambsPerSec: Codable {
        let zambs: Int
        let seconds: Int
        
        func toDictionary()->[String:Int]{
            var dict = [String:Int]()
            dict["zambs"] = self.zambs
            dict["seconds"] = self.seconds
            return dict
        }
    }
    let frecuencyArray: [[String:Int]]
    
    //Initialization
    init?(id: Int, user: Int, amount: Int, hand: String?, location: String?, date: Date, sessionTime: Int, frecuencyArray: [[String:Int]]) {
        guard amount != 0 else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy H:mm"
        
        self.id = id
        self.user = user
        self.amount = amount
        self.hand = hand ?? "No hand"
        self.location = location ?? "No location"
        self.date = formatter.string(from: date)
        self.sessionTime = sessionTime
        self.frecuency = Float(amount/(sessionTime == 0 ? 1 : sessionTime))
        self.frecuencyArray = frecuencyArray
    }
}
