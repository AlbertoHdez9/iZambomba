//
//  Zamb.swift
//  iZambomba
//
//  Created by admin on 22/11/2018.
//  Copyright © 2018 singularfactory. All rights reserved.
//
import UIKit
import os.log

class Zamb: NSObject, NSCoding {
    
    //MARK: Properties
    var amount: Int
    var hand: String?
    var location: String?
    var date: Date
    var sessionTime: Int
    var frecuency: Float
    
    //MARK: Archiving paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("zambs")
    
    //MARK: Types
    struct PropertyKey {
        static let amount = "amount"
        static let hand = "hand"
        static let location = "location"
        static let date = "date"
        static let sessionTime = "sessionTime"
    }
    
    //Initialization
    init?(amount: Int, hand: String?, location: String?, date: Date, sessionTime: Int) {
        guard amount != 0 else {
            return nil
        }
        /*guard date > Date() else {
            return nil
        }*/
        self.amount = amount
        self.hand = hand ?? nil
        self.location = location ?? nil
        self.date = date
        self.sessionTime = sessionTime
        self.frecuency = Float(amount/sessionTime)
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(amount, forKey: PropertyKey.amount)
        aCoder.encode(hand, forKey: PropertyKey.hand)
        aCoder.encode(location, forKey: PropertyKey.location)
            //Date to string
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM dd, yyyy HH:mm a"
            formatter.locale = Locale(identifier: "en_US")
            let dateString = formatter.string(from: date)
        aCoder.encode(dateString, forKey: PropertyKey.date)
        aCoder.encode(sessionTime, forKey: PropertyKey.sessionTime)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        //The name is required. If we cannot decode a name String. the init should fail
        let amount = aDecoder.decodeInteger(forKey: PropertyKey.amount)
        let hand = aDecoder.decodeObject(forKey: PropertyKey.hand) as? String ?? "No hand"
        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as? String ?? "No location"
        
        let dateString = aDecoder.decodeObject(forKey: PropertyKey.date) as? String
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy HH:mm a"
        formatter.locale = Locale(identifier: "en_US")

        let date = formatter.date(from: dateString!)
        let sessionTime = aDecoder.decodeInteger(forKey: PropertyKey.sessionTime)
        
        //TODO - check if this shit works (the as! shit)
        
        //Must call designated initializer
        self.init(amount: amount, hand: hand, location: location, date: date!, sessionTime: sessionTime)
    }
}
