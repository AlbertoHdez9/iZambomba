//
//  Constants.swift
//  iZambomba
//
//  Created by SingularNet on 17/1/19.
//  Copyright © 2019 SingularNet. All rights reserved.
//

import Foundation

struct Constants {
    static let BASEURL = "https://app.izambomba.com"
    static let keychainUserService = "com.singularfactory.izambomba.userService"
    static let keychainRankingService = "com.singularfactory.izambomba.rankingService"
    
    struct User {
        static let create = "/user"
        static let update = "/user/"
    }
    
    struct Zamb {
        static let create = "/zamb"
        static let update = "/zamb/update"
        static let getZambs = "/getZambs/"
        static let getStats = "/getStats/"
        static let getRanking = "/getRanking/"
    }
    
    static func buildUserCreate() -> String {
        return BASEURL + User.create
    }
    
    static func buildUserUpdate() -> String {
        return BASEURL + User.update
    }
    
    static func buildZambCreate() -> String {
        return BASEURL + Zamb.create
    }
    
    static func buildZambUpdate() -> String {
        return BASEURL + Zamb.update
    }
    
    static func buildGetZambs() -> String {
        return BASEURL + Zamb.getZambs
    }
    
    static func buildGetStats() -> String {
        return BASEURL + Zamb.getStats
    }
    
    static func buildGetRanking() -> String {
        return BASEURL + Zamb.getRanking
    }
    
    static func buildDays() -> [String] {
        var weekDays: [String] = ["","","","","","","", ""]
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        let userCalendar = NSCalendar.current
        var dayCounter = 7
        for index in 0...7 {
            if let someDayAgo = userCalendar.date(byAdding: Calendar.Component.day, value: -dayCounter, to: Date()) {
                dayCounter = dayCounter - 1
                weekDays.insert(formatter.string(from: someDayAgo), at: index)
            }
        }
        return weekDays
    }
    
    static func buildMonthDays(_ days: Int) -> [String] {
        var monthDays = [String]()
        monthDays.append("")
        for index in 1...days {
            monthDays.append("\(index)")
        }
        return monthDays
    }
    
    static let months = ["", "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov", "Dec"]
}
