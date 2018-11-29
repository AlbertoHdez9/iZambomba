/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class manages the HealthKit interactions and provides a delegate
 to indicate changes in data.
 */

import Foundation
import HealthKit

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
    let healthStore = HKHealthStore()
    
    weak var delegate: WorkoutManagerDelegate?
    var session: Bool = false
    
    // MARK: Initialization
    
    init() {
        motionManager.delegate = self
    }
    
    // MARK: WorkoutManager
    
    func startWorkout() {
        // If we have already started the workout, then do nothing.
        if (session == true) {
            return
        }
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .tennis
        workoutConfiguration.locationType = .outdoor
        
        
        // Start the workout session and device motion updates.
        session = true
        motionManager.startUpdates()
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
