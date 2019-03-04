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
    var timerForFrecuencyArray: Timer?
    var timerSeconds: Int = 0
    
    var zamb: Zamb?
    
    var user: Int?

    var frecuencyArray: [Zamb.zambsPerSec] = [Zamb.zambsPerSec]()
    var finalFrecuencyArray: [[String:Int]] = [[String:Int]]()
    
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
        
        startButton.layer.cornerRadius = 5
        startButton.layer.borderColor = UIColor.white.cgColor
        startButton.layer.borderWidth = 1
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
    
    @objc private func buildFrecuencyArray() {
        frecuencyArray.append(
            Zamb.zambsPerSec(zambs: currentZambAmount, seconds: timerSeconds)
        )
    }
    
    private func secondsProcessor(inputSeconds: Int) -> String {
        let secondsInt = ((inputSeconds % 3600) % 60)
        var secondsString: String = "\(secondsInt)"
        if secondsInt < 10 {
            secondsString = "0\((inputSeconds % 3600) % 60)"
        }
        return "\((inputSeconds % 3600) / 60):\(secondsString)"
    }
    
    private func processFrecuencyArray() {
        var intervalFloat = (Float(timerSeconds)/10.0)
        intervalFloat.round()
        var interval = Int(intervalFloat)
        let increment = interval

        for zambPerSec in frecuencyArray.enumerated() {
            if (zambPerSec.element.seconds >= interval) {
                finalFrecuencyArray.append(["zambs": zambPerSec.element.zambs, "seconds" : zambPerSec.element.seconds])
                interval = interval + increment
            }
        }
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
            //Frecuency array trigger
            timerForFrecuencyArray = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(buildFrecuencyArray), userInfo: nil, repeats: true)


            
        } else {
            //Workout manager stop
            manager.stopWorkout()
            startButton.setTitle("Start", for: .normal)
            
            //Timer stops
            timer?.invalidate()
            timer = nil
            
            timerForFrecuencyArray?.invalidate()
            timerForFrecuencyArray = nil
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
        
        processFrecuencyArray()
        
        let amount = currentZambAmount
        //let amount = 200
        let hand = "No hand"
        let location = "No location"
        let date = Date()
        let sessionTime = timerSeconds
        let frecuencyArray = finalFrecuencyArray
        
        zamb = Zamb(id: 0, user: user!, amount: amount, hand: hand, location: location, date: date, sessionTime: sessionTime, frecuencyArray: frecuencyArray)
    }

}

//  MARK:- UIViewControllerRestoration
/*extension NewZambViewController: UIViewControllerRestoration {
    static func viewController(withRestorationIdentifierPath identifierComponents: [String], coder: NSCoder) -> UIViewController? {
        guard let restoredUser = coder.decodeObject(forKey: "user") as? Int else {
            print("decoding User")
            return nil
        }
        guard let restoredCurrentZambAmount = coder.decodeObject(forKey: "currentZambAmount") as? Int else {
            print("decoding current Zamb amount")
            return nil
        }
        guard let restoredStartedZambSession = coder.decodeObject(forKey: "startedZambSession") as? Bool else {
            print("decoding startedZambSession")
            return nil
        }
        guard let restoredTimer = coder.decodeObject(forKey: "timer") as? Timer else {
            print("decoding timer")
            return nil
        }
        guard let restoredTimerForFrecuencyArray = coder.decodeObject(forKey: "timerForFrecuencyArray") as? Timer else {
            print("decoding frecuencyArray")
            return nil
        }
        guard let restoredTimerSeconds = coder.decodeObject(forKey: "timerSeconds") as? Int else {
            print("decoding timerSeconds")
            return nil
        }
        guard let restoredZamb = coder.decodeObject(forKey: "zamb") as? Zamb else {
            print("decoding Zamb")
            return nil
        }
        if let storyboard = coder.decodeObject(forKey: UIApplication.stateRestorationViewControllerStoryboardKey) as? UIStoryboard{
            if let vc = storyboard.instantiateViewController(withIdentifier: "NewZambVC") as? NewZambViewController{
                vc.user = restoredUser
                vc.currentZambAmount = restoredCurrentZambAmount
                vc.zamb = restoredZamb
                vc.startedZambSession = restoredStartedZambSession
                vc.timer = restoredTimer
                vc.timerForFrecuencyArray = restoredTimerForFrecuencyArray
                vc.timerSeconds = restoredTimerSeconds
                return vc;
            }
        }
        return nil;
    }

    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        // preserve user model object.
        coder.encode(self.user, forKey: "user")
        coder.encode(self.currentZambAmount, forKey: "currentZambAmount")
        coder.encode(self.startedZambSession, forKey: "startedZambSession")
        coder.encode(self.timer, forKey: "timer")
        coder.encode(self.timerForFrecuencyArray, forKey: "timerForFrecuencyArray")
        coder.encode(self.timerSeconds, forKey: "timerSeconds")
        coder.encode(self.zamb, forKey: "zamb")
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        if let obj = coder.decodeObject(forKey: "user") as? Int {
            self.user = obj
        }
        if let obj = coder.decodeObject(forKey: "currentZambAmount") as? Int {
            self.currentZambAmount = obj
        }
        if let obj = coder.decodeObject(forKey: "startedZambSession") as? Bool{
            self.startedZambSession = obj
        }
        if let obj = coder.decodeObject(forKey: "timer") as? Timer{
            self.timer = obj
        }
        if let obj = coder.decodeObject(forKey: "timerForFrecuencyArray") as? Timer{
            self.timerForFrecuencyArray = obj
        }
        if let obj = coder.decodeObject(forKey: "timerSeconds") as? Int{
            self.timerSeconds = obj
        }
        if let obj = coder.decodeObject(forKey: "zamb") as? Zamb{
            self.zamb = obj
        }
    
    }
    
    override func applicationFinishedRestoringState() {
        print("HomeDetailVC finished restoring")
//        self.prepareUI()
//        self.tableView.reloadData()
        
    }
}*/
