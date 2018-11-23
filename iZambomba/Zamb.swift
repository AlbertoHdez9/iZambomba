//
//  Zamb.swift
//  iZambomba
//
//  Created by admin on 22/11/2018.
//  Copyright © 2018 singularfactory. All rights reserved.
//
import UIKit
import os.log

class Zamb: NSObject/*, NSCoding */{
    
    //MARK: Properties
    var amount: Int
    var hand: String?
    var location: String?
    var date: Date
    
    //MARK: Archiving paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("zambs")
    
    //MARK: Types
    struct PropertyKey {
        static let amount = "amount"
        static let hand = "hand"
        static let location = "location"
        static let date = "date"
    }
    
    //Initialization
    init?(amount: Int, hand: String?, location: String?, date: Date) {
        guard amount != 0 else {
            return nil
        }
        /*guard date > Date() else {
            return nil
        }*/
        self.amount = amount
        self.hand = hand
        self.location = location
        self.date = date
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(amount, forKey: PropertyKey.amount)
        aCoder.encode(hand, forKey: PropertyKey.hand)
        aCoder.encode(location, forKey: PropertyKey.location)
        aCoder.encode(date, forKey: PropertyKey.date)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        //The name is required. If we cannot decode a name String. the init should fail
        guard let amount = aDecoder.decodeObject(forKey: PropertyKey.amount) as? Int else {
            os_log("Unable to decode the amount for the selected Zamb.", log: OSLog.default, type: .debug)
            return nil
        }
        let hand = aDecoder.decodeObject(forKey: PropertyKey.hand) as? String
        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as? String
        let date = aDecoder.decodeObject(forKey: PropertyKey.date) as! Date
        
        
        
        //TODO - check if this shit works (the as! shit)
        
        //Must call designated initializer
        self.init(amount: amount, hand: hand, location: location, date: date)
    }
}
