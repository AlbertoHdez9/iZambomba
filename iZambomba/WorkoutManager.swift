/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 */

import Foundation
/**
 `WorkoutManagerDelegate` exists to inform delegates of swing data changes.
 These updates can be used to populate the user interface.
 */
protocol WorkoutManagerDelegate: class {
    func didUpdateMotion(_ manager: WorkoutManager, zambAmount: Int)
}

class WorkoutManager: MotionManagerDelegate {
    
    // MARK: Properties
    let motionManager = MotionManager()
    
    weak var delegate: WorkoutManagerDelegate?
    var session: Bool = false
    
    // MARK: Initialization
    
    init() {
        motionManager.delegate = self
    }
    
    // MARK: WorkoutManager
    //type: 0 -> iOS
    //      1 -> watchOS
    func startWorkout(type: Int) {
        // If we have already started the workout, then do nothing.
        if (session == true) {
            return
        }
        
        // Start the workout session and device motion updates.
        session = true
        
        motionManager.startUpdates(type: type)
    }
    
    func stopWorkout() {
        // If we have already stopped the workout, then do nothing.
        if (session == false) {
            return
        }
        
        // Stop the device motion updates and workout session.
        motionManager.stopUpdates()
        
        // Clear the workout session.
        session = false
    }
    
    // MARK: MotionManagerDelegate
    
    func didUpdateMotion(_ manager: MotionManager, zambAmount: Int) {
        delegate?.didUpdateMotion(self, zambAmount: zambAmount)
    }
}
