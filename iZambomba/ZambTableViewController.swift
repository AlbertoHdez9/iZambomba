//
//  ZambTableViewController.swift
//  iZambomba
//
//  Created by admin on 22/11/2018.
//  Copyright © 2018 singularfactory. All rights reserved.
//

import UIKit
import os.log
import WatchConnectivity

class ZambTableViewController: UITableViewController, WCSessionDelegate {
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive: \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate: \(session)")
    }
    
    
    //MARK: Properties
    
    var zambs = [Zamb]()
    private var session = WCSession.default
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var restView: UIView!
    
    
    @IBOutlet weak var weeklyZambs: UILabel!
    @IBOutlet weak var weekDate: UILabel!
    var aboutAWeekAgo: Date?
    var weeklyZambCount: Int? = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarAndBackground()
        
        //If there are saved zambs, load'em, if not, load sample data
        if let savedZambs = loadZambs() {
            zambs += savedZambs
        } else {
            loadSampleZambs()
        }
        if isSuported() {
            session.delegate = self
            session.activate()
        }
        //Weekly zambs
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        let userCalendar = NSCalendar.current
        if let aWeekAgo = userCalendar.date(byAdding: Calendar.Component.day, value: -7, to: Date()) {
            aboutAWeekAgo = aWeekAgo
            weekDate.text = "since \(formatter.string(from: aWeekAgo))"
            weekDate.textColor = UIColor(red: 255 / 255.0, green: 164 / 255.0, blue: 81 / 255.0, alpha: 1 / 1.0)
        }
        weeklyZambCount = getWeeklyZambs()
        if !zambs.isEmpty || weeklyZambCount != 0 {
            weeklyZambs.text = "\(weeklyZambCount!) ZAMBS!!!"
        } else {
            weeklyZambs.text = "No zambs"
        }
        weeklyZambs.textColor = UIColor(red: 255 / 255.0, green: 164 / 255.0, blue: 81 / 255.0, alpha: 1 / 1.0)
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }
    
    //MARK: Private Methods
    
    private func loadSampleZambs() {
        guard let zamb1 = Zamb(amount: 275, hand: "Other", location: "Home", date: Date(), sessionTime: 345) else {
            fatalError("Unable to instantiate zamb1")
        }
        zambs += [zamb1]
        saveZambs()
    }
    
    private func saveZambs() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: zambs, requiringSecureCoding: false)
            try data.write(to: Zamb.ArchiveURL)
        } catch {
            print("Couldn't write file")
        }
    }
    
    func loadZambs() -> [Zamb]? {
        var savedZambs: [Zamb]? = nil
        do {
            let rawdata = try Data(contentsOf: Zamb.ArchiveURL)
            if let archivedZambs = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawdata) as! [Zamb]? {
                savedZambs = archivedZambs
            }
        } catch {
            print("Couldn't read file.")
        }
        return savedZambs
    }
    
    private func setNavBarAndBackground() {
        
        //Nav bar
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .none
        navigationController?.hidesBarsOnSwipe = true
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundImage")!)
        
        
        //Table view
        //restView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        //restView.heightAnchor.constraint(equalToConstant: 400.0).isActive = true
        //self.tableView.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        //restView.translatesAutoresizingMaskIntoConstraints = false
        //restView.topAnchor.constraint(equalTo: tableContent.topAnchor, constant: 10).isActive = true
        //restView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        
        let bgView = UIImageView(frame: tableView.bounds)
        bgView.image = UIImage(named: "backgroundImage")
        tableView.backgroundView = bgView
        tableView.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        tableView.separatorColor = UIColor.white
        
//        let letsTry = UIView()
//        letsTry.backgroundColor = UIColor.black.withAlphaComponent(0.15)
//        tableView.tableFooterView = letsTry
        
        //THIS DOES NOT WORK, PARA MOSTRAR EL PRIMER SEPARATOR
        //tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        
        //Top view background
        topView.backgroundColor = UIColor.black.withAlphaComponent(0.67)
    }
    
    private func getWeeklyZambs() -> Int{
        var sumatory = 0
        for zamb in zambs {
            if(zamb.date > aboutAWeekAgo!) {
                sumatory += zamb.amount
            }
        }
        return sumatory
    }
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zambs.count
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let result = UIView()
        
        // recreate insets from existing ones in the table view
        let width = tableView.bounds.width
        let sepFrame = CGRect(x: 0, y: -0.5, width: width, height: 0.5)
        
        // create layer with separator, setting color
        let sep = CALayer()
        sep.frame = sepFrame
        sep.backgroundColor = tableView.separatorColor?.cgColor
        result.layer.addSublayer(sep)
        
        result.frame = CGRect(x:0, y:0, width: width, height: 200)
        result.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        result.translatesAutoresizingMaskIntoConstraints = false
//        let inset = CGFloat(zambs.count) * 90.0
//        result.heightAnchor.constraint(equalTo: tableView.heightAnchor, multiplier: 0, constant: inset).isActive = true
        result.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        return result
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ZambTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ZambTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ZambTableViewCell.")
        }
        // Fetches the appropriate meal for the data source layout.
        let zamb = zambs[indexPath.row]
        let zambVC = ZambViewController() //Zamb VC instance to use its methods
        
        //Cell config
        cell.zambsAmountLabel.text = "\(zamb.amount) ZAMBS!!!"
        cell.locationLabel.text = zamb.location
        cell.dateLabel.text = zambVC.convertDateToString(date: zamb.date)
        cell.sessionTimeLabel.text = zambVC.secondsProcessor(inputSeconds: zamb.sessionTime)
        
        
        if(zamb.hand != "No hand") {
            
            //Remove previous label
            cell.validationLabel.removeFromSuperview()
            
            //Create image and add it
            let imageView = UIImageView(image: UIImage(named: "circleCheck"))
            imageView.frame = CGRect(x: 15, y: 15, width: 30, height: 30)
            imageView.contentMode = .scaleAspectFit
            cell.viewForImage.addSubview(imageView)
            
            //Change label colors and location icon
            cell.zambsAmountLabel.textColor = UIColor.white.withAlphaComponent(0.5)
            cell.locationLabel.textColor = UIColor.white.withAlphaComponent(0.3)
            cell.dateLabel.textColor = UIColor.white.withAlphaComponent(0.3)
            cell.sessionTimeLabel.textColor = UIColor.white.withAlphaComponent(0.3)
            cell.locationIcon.image = UIImage(named: "locationIconOp")
        }
        cell.separatorInset = .zero
        cell.selectionStyle = .none

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
            case "showZambDetail":
                guard let zambDetailViewController = segue.destination as? ZambViewController else {
                    fatalError("Unexpected destination: \(segue.destination)")
                }
                    
                guard let selectedZambCell = sender as? ZambTableViewCell else {
                    fatalError("Unexpected sender: \(String(describing: sender))")
                }
                    
                guard let indexPath = tableView.indexPath(for: selectedZambCell) else {
                    fatalError("The selected cell is not being displayed by the table")
                }
                    
                let selectedZamb = zambs[indexPath.row]
                zambDetailViewController.zamb = selectedZamb
            
        case "addZamb":
            os_log("Adding a new zamb", log: OSLog.default, type: .debug)
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    @IBAction func unwindToZambList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ZambViewController, let zamb = sourceViewController.zamb {
            //Checks if a row is selected
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                //Update selected Meal
                zambs[selectedIndexPath.row] = zamb
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            saveZambs()
        }
    }
    
    @IBAction func unwindFromNewZamb(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewZambViewController, let zamb = sourceViewController.zamb {
            
            //Add a new zamb
            let newIndexPath = IndexPath(row: zambs.count, section: 0)
            zambs.append(zamb)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            saveZambs()
        }
    }
    
    //MARK: Watch
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) -> Void {
        if (message["amount"] is Int) {
            let newIndexPath = IndexPath(row: zambs.count, section: 0)
            
            let zamb = Zamb(
                amount: message["amount"] as! Int,
                hand: message["hand"] as? String,
                location: message["location"] as? String,
                date: message["date"] as! Date,
                sessionTime: message["sessionTime"] as! Int)
            
            zambs.append(zamb!)
            weeklyZambCount = weeklyZambCount! + zamb!.amount
            weeklyZambs.text = "\(weeklyZambCount!) ZAMBS!!!"
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
}
