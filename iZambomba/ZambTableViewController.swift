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
    var user: Int = 0
    var userRanking: Bool = false
    var zambs = [Zamb]()
    let dispatchGroup = DispatchGroup()
    private var session = WCSession.default
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let loadingView = UIView()
    let emptyView = UIView()
    
    @IBOutlet weak var topView: UIView!
    
    @IBOutlet weak var weeklyZambs: UILabel!
    @IBOutlet weak var weekDate: UILabel!
    var aboutAWeekAgo: Date?
    var weeklyZambCount: Int? = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        //Load user ID
        if let userID = loadUser() {
            user = userID
        }
        if let ranking = loadUserRanking() {
            userRanking = ranking
        }
        setNavBarAndBackground()
        setLoadingScreen()
        
        //Load zambs if there are, if not load empty view
        loadZambs()
        
        //Watch Connectivity
        if isSuported() {
            session.delegate = self
            session.activate()
        }
        //Weekly zambs
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy H:mm"
        let userCalendar = NSCalendar.current
        if let aWeekAgo = userCalendar.date(byAdding: Calendar.Component.day, value: -7, to: Date()) {
            aboutAWeekAgo = aWeekAgo
            weekDate.text = "since \(formatter.string(from: aWeekAgo))"
            weekDate.textColor = UIColor(red: 255 / 255.0, green: 164 / 255.0, blue: 81 / 255.0, alpha: 1 / 1.0)
        }
        updateWeeklyZambs()
        
        RankingProduct.store.requestProducts{ [weak self] success, products in
            guard let self = self else { return }
            if success {
                print("pepino")
            }
        }
        
        print("isPaired?: \(session.isPaired), isWatchAppInstalled?: \(session.isWatchAppInstalled)")
    }
    
    //MARK: Private Methods
    
    private func updateWeeklyZambs() {
        weeklyZambCount = getWeeklyZambs()
        if !zambs.isEmpty || weeklyZambCount != 0 {
            weeklyZambs.text = "\(weeklyZambCount!) ZAMBS!!!"
        } else {
            weeklyZambs.text = "No zambs"
        }
        weeklyZambs.textColor = UIColor(red: 255 / 255.0, green: 164 / 255.0, blue: 81 / 255.0, alpha: 1 / 1.0)
    }
    
    private func loadEmptyListView() {
        //Primero eliminamos la vista anterior del superview, para luego recuperarla cuando se añada un zamb
        topView.isHidden = true
        loadingView.isHidden = true
        
        let bottomInset = (self.tabBarController?.tabBar.bounds.height)! + self.view.safeAreaInsets.bottom
        emptyView.frame = CGRect(x:0, y: 0, width: self.view.bounds.width, height: tableView.bounds.height - bottomInset)
        emptyView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        //Creamos las labels y mierdas para la nueva vista
        let startNOW = UILabel(frame: CGRect(x: 0, y: emptyView.bounds.height/4, width: self.view.bounds.width, height: 90))
        startNOW.text = "Start NOW!"
        startNOW.font = UIFont(name: "Lato-Bold", size: 31)
        startNOW.textAlignment = .center
        startNOW.textColor = .white
        
        let description = UILabel(frame: CGRect(x: 0, y: self.view.bounds.height/4, width: self.view.bounds.width, height: 180))
        description.text = "Millions of people are waiting\n for your first ZAMB!"
        description.numberOfLines = 2
        description.font = UIFont(name: "Lato-Light", size: 20)
        description.textAlignment = .center
        description.textColor = .white
        
        //Añadimos a la vista
        emptyView.addSubview(description)
        emptyView.addSubview(startNOW)
        emptyView.isUserInteractionEnabled = false
        self.view.addSubview(emptyView)
    }
    
    private func setLoadingScreen() {
        //Loader
        topView.isHidden = true
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.isHidden = false
        
        loadingView.frame = CGRect(x:0, y: 0, width: self.view.bounds.width, height: tableView.bounds.height)
        loadingView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        //Creamos las labels y mierdas para la nueva vista
        let description = UILabel(frame: CGRect(x: 0, y: self.view.bounds.height/3, width: self.view.bounds.width, height: 90))
        description.text = "Loading list items"
        description.font = UIFont(name: "Lato-Light", size: 20)
        description.textAlignment = .center
        description.textColor = .white
        
        //Añadimos a la vista
        loadingView.addSubview(activityIndicator)
        loadingView.addSubview(description)
        self.view.addSubview(loadingView)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    public func getUser() {
        let url = URL(string: Constants.buildUserCreate())
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print ("getUser() error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                    print("User got correctly")

            } else {
                    print ("server error")
                    return
            }
            if let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
                self.transformUserReceivedIntoUserSaved(data)
            }
        }.resume()
        
    }
    
    private func saveUser(_ user: Int) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: user, requiringSecureCoding: false)
            try data.write(to: FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("user"))
        } catch {
            print("Couldn't write file: " + error.localizedDescription)
        }
    }
    
    func saveUserRanking(_ ranking: Bool) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: ranking, requiringSecureCoding: false)
            try data.write(to: FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("userRanking"))
        } catch {
            print("Couldn't write file: " + error.localizedDescription)
        }
    }
    
    func loadUser() -> Int? {
        var savedUser: Int = 0
        do {
            let rawdata = try Data(contentsOf: FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("user"))
            if let archivedUser = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawdata) as? Int {
                savedUser = archivedUser
            }
        } catch {
            print("Couldn't read file: " + error.localizedDescription)
        }
        return savedUser
    }
    
    func loadUserRanking() -> Bool? {
        var savedUserRanking: Bool = false
        do {
            let rawdata = try Data(contentsOf: FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("userRanking"))
            if let archivedUserRanking = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawdata) as? Bool {
                savedUserRanking = archivedUserRanking
            }
        } catch {
            print("Couldn't read file: " + error.localizedDescription)
        }
        return savedUserRanking
    }
    
    private func transformUserReceivedIntoUserSaved(_ data: Data) {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
            if let jsonArray = jsonResponse as? [String: Any] {
                if let id = jsonArray["id"] as? Int {
                    saveUser(id)
                }
                if let ranking = jsonArray["ranking"] as? Bool {
                    saveUserRanking(ranking)
                }
            } else {
                print(jsonResponse)
                return
            }
        } catch {
            print(error)
        }
    }
    
    private func saveZambs(_ zamb: Zamb) {
        let url = URL(string: Constants.buildZambCreate())
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        guard let uploadData = try? JSONEncoder().encode(zamb) else {
            return
        }
        URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            if let error = error {
                print ("postZamb() error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("Zamb posted correctly")
            } else {
                print ("Server error in post Zamb")
                return
            }
            if let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
            }
            }.resume()
    }
    
    private func loadZambs()  {
        let url = URL(string: Constants.buildGetStats() + "\(user)/w")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        dispatchGroup.enter()
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print ("getZambs() error: \(error)")
                    return
                }
                if let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    print("Zambs got correctly")
                } else if let response = response as? HTTPURLResponse {
                    print ("Server error \(response.statusCode)")
                    return
                }
                if let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                    DispatchQueue.main.async {
                        self.processZambReceived(data)
                        self.dispatchGroup.leave()
                    }
                    
                }
                }.resume()
        
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            self.activityIndicator.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.activityIndicator.isHidden = true
            
            if self.zambs.isEmpty {
                self.loadEmptyListView()
            } else {
                self.emptyView.isHidden = true
                self.loadingView.isHidden = true
                self.tableView.reloadData()
                self.updateBottomView()
                
            }
        })
    }
    
    private func processZambReceived(_ data: Data) {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                return
            }
            for zamb in jsonArray {
                zambs.append(Zamb(
                    id: zamb["id"] as! Int,
                    user: zamb["user"] as! Int,
                    amount: zamb["amount"] as! Int,
                    hand: zamb["hand"] as? String,
                    location: zamb["location"] as? String,
                    date: convertStringToDate(date: zamb["date"] as! String),
                    sessionTime: zamb["sessionTime"] as! Int,
                    frecuencyArray: zamb["frecuencyArray"] as! [[String:Int]])!)
            }
        } catch {
            print(error)
        }
    }
    
    private func setNavBarAndBackground() {
        
        //Nav bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.tintColor = .none
        
        let bgView = UIImageView(frame: tableView.bounds)
        bgView.image = UIImage(named: "backgroundImage")
        tableView.backgroundView = bgView
        tableView.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        tableView.separatorColor = UIColor.white
        
        if (zambs.count != 0) {
            updateBottomView()

        } else {
            tableView.tableFooterView = UIView()
        }
        //Top view background
        topView.backgroundColor = UIColor.black.withAlphaComponent(0.67)
    }
    
    private func updateBottomView() {
        //Contenido de la tabla + nº de filas por su altura
        var height = topView.bounds.height + CGFloat(90*zambs.count)
        
        //Si el contenido es mayor que lo que cabe en la pantalla, no ponemos footer
        if self.view.bounds.height - height < 0 {
            height = 0
            tableView.isScrollEnabled = true;
        } else {
            height = tableView.bounds.height - height + 10
            tableView.isScrollEnabled = false;
        }
        let compare = height + 80.0 + CGFloat(90*zambs.count)
        if (compare < (self.view.bounds.height + self.view.safeAreaInsets.bottom + self.view.safeAreaInsets.top)) {
            height = height + ((self.view.bounds.height + self.view.safeAreaInsets.bottom + self.view.safeAreaInsets.top) - compare)
        }
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: height))
        footerView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        tableView.tableFooterView = footerView
    }
    
    private func convertStringToDate(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy H:mm"
        formatter.locale = Locale(identifier: "en_US")
        
        let dateString = formatter.date(from: date)
        return dateString!
    }
    
    private func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy H:mm"
        formatter.locale = Locale(identifier: "en_US")
        
        let dateString = formatter.string(from: date)
        return dateString
    }
    
    private func secondsProcessor(inputSeconds: Int) -> String {
        let secondsInt = ((inputSeconds % 3600) % 60)
        var secondsString: String = "\(secondsInt)"
        if secondsInt < 10 {
            secondsString = "0\((inputSeconds % 3600) % 60)"
        }
        return "\((inputSeconds % 3600) / 60):\(secondsString)"
    }
    
    private func getWeeklyZambs() -> Int{
        var sumatory = 0
        for zamb in zambs {
            if(convertStringToDate(date: zamb.date) > aboutAWeekAgo!) {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "ZambTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ZambTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ZambTableViewCell.")
        }
        // Fetches the appropriate zamb for the data source layout.
        let zamb = zambs[indexPath.row]
        
        //Cell config
        cell.zambsAmountLabel.text = "\(zamb.amount) ZAMBS!!!"
        cell.locationLabel.text = zamb.location
        cell.dateLabel.text = zamb.date
        cell.sessionTimeLabel.text = secondsProcessor(inputSeconds: zamb.sessionTime)
        
        if (zambs.count > 0) {
            topView.isHidden = false
        }
        
        if zambs.count - 1 == indexPath.row {
            let separator = UIView(frame: CGRect(x:0, y:83, width: self.view.bounds.width, height: 0.5))
            separator.backgroundColor = .white
            cell.contentView.addSubview(separator)
        }
        
        if(zamb.hand == "No hand" && zamb.location == "No location") {
            
            //Change label colors and location icon
            cell.zambsAmountLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            cell.locationLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            cell.dateLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            cell.sessionTimeLabel.textColor = UIColor.white.withAlphaComponent(0.6)
            
        }
        
        if(zamb.hand != "No hand" && zamb.location != "No location") {
            
            //Remove previous label
            if (cell.validationLabel != nil) {
                cell.validationLabel.removeFromSuperview()
            }
            
            //Create image and add it
            let imageView = UIImageView(image: UIImage(named: "circleCheck"))
            imageView.frame = CGRect(x: 15, y: 15, width: 30, height: 30)
            imageView.contentMode = .scaleAspectFit
            cell.viewForImage.addSubview(imageView)
            
            cell.locationIcon.image = UIImage(named: "locationIcon")
        }
        
        cell.separatorInset = .zero
        cell.selectionStyle = .none
        
        updateWeeklyZambs()

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
                zambDetailViewController.user = user
            
        case "addZamb":
            guard let newZambViewController = segue.destination as? NewZambViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            newZambViewController.user = user
            os_log("Adding a new zamb", log: OSLog.default, type: .debug)
            
        case "options":
            guard let optionsViewController = segue.destination as? OptionsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            optionsViewController.user = user
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
            updateBottomView()
        }
    }
    
    @IBAction func unwindFromNewZamb(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewZambViewController, let zamb = sourceViewController.zamb {
            
            emptyView.isHidden = true
            //Add a new zamb
            let newIndexPath = IndexPath(row: zambs.count, section: 0)
            zambs.append(zamb)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            updateBottomView()
            saveZambs(zamb)
        }
    }
    
    //MARK: Watch
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) -> Void {
        if (message["amount"] is Int) {
            let newIndexPath = IndexPath(row: zambs.count, section: 0)
            
            if let zamb = Zamb(
                id: 0,
                user: user,
                amount: message["amount"] as! Int,
                hand: message["hand"] as? String,
                location: message["location"] as? String,
                date: message["date"] as! Date,
                sessionTime: message["sessionTime"] as! Int,
                frecuencyArray: message["frecuencyArray"] as! [[String : Int]]
                ) {
                zambs.append(zamb)
                weeklyZambCount = weeklyZambCount! + zamb.amount
                weeklyZambs.text = "\(weeklyZambCount!) ZAMBS!!!"
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                saveZambs(zamb)
                updateBottomView()
            }
            
            
            
        }
    }
}
