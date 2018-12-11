/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 This class manages the CoreMotion interactions and
 provides a delegate to indicate changes in data.
 */

import Foundation
import CoreMotion
import os.log

/**
 `MotionManagerDelegate` exists to inform delegates of motion changes.
 These contexts can be used to enable application specific behavior.
 */
protocol MotionManagerDelegate: class {
    func didUpdateMotion(_ manager: MotionManager, zambAmount: Int)
}

class MotionManager {
    // MARK: Properties
    
    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    
    // MARK: Application Specific Constants
    
    // The app is using 50hz data and the buffer is going to hold 1s worth of data.
    let sampleInterval = 1.0 / 50
    
    weak var delegate: MotionManagerDelegate?
    
    var zambAmount = 0
    var countOnePhone = false
    var countOneWatch = false
    
    var recentDetection = false
    
    // MARK: Initialization
    
    init() {
        // Serial queue for sample handling and calculations.
        queue.maxConcurrentOperationCount = 1
        queue.name = "MotionManagerQueue"
    }
    
    // MARK: Motion Manager
    func startUpdates(type: Int) {
        if !motionManager.isDeviceMotionAvailable {
            print("Device Motion is not available.")
            return
        }
        
        os_log("Start Updates");
        
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startDeviceMotionUpdates(to: queue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!, type: type)
            }
        }
    }
    
    func stopUpdates() {
        if motionManager.isDeviceMotionAvailable {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    // MARK: Motion Processing
    //type: 0 -> iPhone
    //      1 -> iWatch
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion, type: Int) {
        if type == 0 {
            if deviceMotion.userAcceleration.x < -2 {
                countOnePhone = true
            } else if countOnePhone && deviceMotion.userAcceleration.x > 2 {
                countOnePhone = false
                zambAmount += 1
                updateZambAmountDelegate()
            }
        } else if type == 1 {
            if deviceMotion.userAcceleration.y < -1 {
                countOneWatch = true
            } else if countOneWatch && deviceMotion.userAcceleration.y > 1 {
                countOneWatch = false
                zambAmount += 1
                updateZambAmountDelegate()
            }
        }
        
    }
    
    // MARK: Data and Delegate Management
    
    func updateZambAmountDelegate() {
        delegate?.didUpdateMotion(self, zambAmount: zambAmount)
    }
}
