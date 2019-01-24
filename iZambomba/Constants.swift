//
//  Constants.swift
//  iZambomba
//
//  Created by SingularNet on 17/1/19.
//  Copyright © 2019 SingularNet. All rights reserved.
//

import Foundation

struct Constants {
    static let BASEURL = "https://izambomba.singularfactory.com"
    
    struct User {
        static let create = "/user"
        static let update = "/user/"
    }
    
    struct Zamb {
        static let create = "/zamb"
        static let update = "/zamb/update"
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
    
    static func buildGetStats() -> String {
        return BASEURL + Zamb.getStats
    }
    
    static func buildGetRanking() -> String {
        return BASEURL + Zamb.getRanking
    }
}
