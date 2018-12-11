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

    override func viewDidLoad() {
        super.viewDidLoad()


        //If there are saved zambs, load'em, if not, load sample data
        if let savedZambs = loadZambs() {
            zambs += savedZambs
            print(zambs.count)
        } else {
            loadSampleZambs()
        }
        if isSuported() {
            session.delegate = self
            session.activate()
        }
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    //MARK: Private Methods
    
    private func loadSampleZambs() {
        guard let zamb1 = Zamb(amount: 275, hand: "Other", location: "Home", date: Date(), sessionTime: 345) else {
            fatalError("Unable to instantiate zamb1")
        }

        guard let zamb2 = Zamb(amount: 350, hand: "Left", location: "Office", date: Date(), sessionTime: 445) else {
            fatalError("Unable to instantiate zamb2")
        }

        guard let zamb3 = Zamb(amount: 250, hand: "Right", location: "Space", date: Date(), sessionTime: 245) else {
            fatalError("Unable to instantiate zamb3")
        }
        zambs += [zamb1, zamb2, zamb3]
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
    
    private func loadZambs() -> [Zamb]? {
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
    
    func isSuported() -> Bool {
        return WCSession.isSupported()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zambs.count
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
        print("hola")
        if (message["amount"] is Int) {
            let amount = message["amount"] as? Int
//            replyHandler(["version" : "\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") ?? "No version")"])
//            let newIndexPath = IndexPath(row: zambs.count, section: 0)
//            zambs.append(message["zamb"] as! Zamb)
//            tableView.insertRows(at: [newIndexPath], with: .automatic)
            print("pasa socio \(amount)")
        }
    }
    

}
