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
        static let frecuencyArray = "frecuencyArray"
    }
    
    //Initialization
    init?(user: Int, amount: Int, hand: String?, location: String?, date: Date, sessionTime: Int, frecuencyArray: [[String:Int]]) {
        guard amount != 0 else {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy H:mm"

        self.user = user
        self.amount = amount
        self.hand = hand ?? "No hand"
        self.location = location ?? "No location"
        self.date = formatter.string(from: date)
        self.sessionTime = sessionTime
        self.frecuency = Float(amount/(sessionTime == 0 ? 1 : sessionTime))
        self.frecuencyArray = frecuencyArray
    }
    
    //MARK: NSCoding
//    func encode(with aCoder: NSCoder) {
//        aCoder.encode(amount, forKey: PropertyKey.amount)
//        aCoder.encode(hand, forKey: PropertyKey.hand)
//        aCoder.encode(location, forKey: PropertyKey.location)
//            //Date to string
//            let formatter = DateFormatter()
//            formatter.dateFormat = "d MMM yy, hh:mm a"
//            formatter.locale = Locale(identifier: "en_US")
//            let dateString = formatter.string(from: date)
//        aCoder.encode(dateString, forKey: PropertyKey.date)
//        aCoder.encode(sessionTime, forKey: PropertyKey.sessionTime)
//
//        var processedArray =  [[String:Int]]()
//        for zambPerSec in frecuencyArray.enumerated() {
//            processedArray.append(zambPerSec.element.toDictionary())
//        }
//        aCoder.encode(processedArray, forKey: PropertyKey.frecuencyArray)
//    }
    
//    required convenience init?(coder aDecoder: NSCoder) {
//        //The name is required. If we cannot decode a name String. the init should fail
//        let amount = aDecoder.decodeInteger(forKey: PropertyKey.amount)
//        let hand = aDecoder.decodeObject(forKey: PropertyKey.hand) as? String ?? "No hand"
//        let location = aDecoder.decodeObject(forKey: PropertyKey.location) as? String ?? "No location"
//
//        let dateString = aDecoder.decodeObject(forKey: PropertyKey.date) as? String
//        let formatter = DateFormatter()
//        formatter.dateFormat = "d MMM yy, hh:mm a"
//        formatter.locale = Locale(identifier: "en_US")
//
//        let date = formatter.date(from: dateString!)
//        let sessionTime = aDecoder.decodeInteger(forKey: PropertyKey.sessionTime)
//
//        var frecuencyArray = [zambsPerSec]()
//        if let decodedFrecuencyArray = aDecoder.decodeObject(forKey: PropertyKey.frecuencyArray) as? [[String:Int]] {
//            for zambPerSec in decodedFrecuencyArray.enumerated() {
//                frecuencyArray.append(zambsPerSec(zambs: zambPerSec.element["zambs"]!, seconds: zambPerSec.element["seconds"]!))
//            }
//        }
//
//        //Must call designated initializer
//        self.init(amount: amount, hand: hand, location: location, date: date!, sessionTime: sessionTime, frecuencyArray: frecuencyArray)
//    }
}
