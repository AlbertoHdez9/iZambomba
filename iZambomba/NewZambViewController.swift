//
//  NewZambViewController.swift
//  iZambomba
//
//  Created by SingularNet on 29/11/18.
//  Copyright © 2018 singularfactory. All rights reserved.
//

import UIKit
import os.log

class NewZambViewController: UIViewController , WorkoutManagerDelegate {
    
    
    @IBOutlet weak var zambAmount: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var darkBackground: UIView!
    
    var currentZambAmount: Int = 0
    var startedZambSession: Bool = false
    var timer: Timer?
    var timerSeconds: Int = 0
    var zamb: Zamb?
    
    var manager = WorkoutManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.delegate = self
        
        setNavBarAndBackground()
        // Do any additional setup after loading the view.
    }
    
    //MARK: Private methods
    private func updateZambLabel() {
        if startedZambSession {
            zambAmount.text = "\(self.currentZambAmount) ZAMBS!!!"
        }
    }
    
    private func setNavBarAndBackground() {
        
        let navBarHeight = navigationController!.navigationBar.frame.height
        darkBackground.frame = CGRect(x:0, y: navBarHeight, width: self.view.bounds.width, height: (self.view.bounds.height - (self.view.safeAreaInsets.bottom + navBarHeight)))
        
        //Not working
        view.backgroundColor = UIColor(red: 0 / 255.0, green: 0 / 255.0, blue: 0 / 255.0, alpha: 1 / 1.0)
    }
    
    
    internal func didUpdateMotion(_ manager: WorkoutManager, zambAmount: Int) {
        DispatchQueue.main.async {
            self.currentZambAmount = zambAmount
            self.updateZambLabel()
        }
    }
    
    @objc private func processTimer() {
        timerSeconds += 1
        timerLabel.text = secondsProcessor(inputSeconds: timerSeconds)
    }
    
    private func secondsProcessor(inputSeconds: Int) -> String {
        let secondsInt = ((inputSeconds % 3600) % 60)
        var secondsString: String = "\(secondsInt)"
        if secondsInt < 10 {
            secondsString = "0\((inputSeconds % 3600) % 60)"
        }
        return "\((inputSeconds % 3600) / 60):\(secondsString)"
    }

    
    //MARK: Actions
    @IBAction func changeSessionStatus(_ sender: UIButton) {
        startedZambSession = !startedZambSession
        if (startButton.titleLabel!.text == "Start") {
            startButton.setTitle("Stop", for: .normal)
            
            //Workout manager start
            manager.startWorkout(type: 0) //type: 0 -> iPhone
            
            //Timer start
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(processTimer), userInfo: nil, repeats: true)

            
        } else {
            //Workout manager stop
            manager.stopWorkout()
            startButton.setTitle("Start", for: .normal)
            
            //Timer stops
            timer?.invalidate()
            timer = nil
        }
    }
    
    @IBAction func cancelNewZamb(_ sender: UIBarButtonItem) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
        }
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        //let amount = currentZambAmount
        let amount = 200
        let hand = "No hand"
        let location = "No location"
        let date = Date()
        let sessionTime = timerSeconds
        
        zamb = Zamb(amount: amount, hand: hand, location: location, date: date, sessionTime: sessionTime)
    }
    

}
