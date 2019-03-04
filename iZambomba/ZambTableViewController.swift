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
import KeychainAccess
import StoreKit

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
    var connectionError = false
    var zambs = [Zamb]()
    var product: [SKProduct] = []
    
    let dispatchGroup = DispatchGroup()
    private var session = WCSession.default
    
    var activityIndicator: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView()
        aiv.color = .black
        aiv.style = .whiteLarge
        return aiv
    }()
    let loadingView = UIView()
    let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    let errorMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Apologies, there's a problem with internet connection. Please try again later..."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont(name: "Lato-Light", size: 20)
        label.textColor = .white
    
        return label
    }()
    let errorMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        view.isHidden = true
        return view
    }()

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
        setErrorMessageScreen()
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
                self.product = products!
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
    
    private func setErrorMessageScreen() {
        let bottomInset = (self.tabBarController?.tabBar.bounds.height)! + self.view.safeAreaInsets.bottom
        errorMessageView.frame = CGRect(x:0, y: 0, width: self.view.bounds.width, height: tableView.bounds.height - bottomInset)
        errorMessageLabel.frame = CGRect(x: 0, y: self.view.bounds.height/3, width: self.view.bounds.width, height: 90)
        errorMessageView.addSubview(errorMessageLabel)
        self.view.addSubview(errorMessageView)

    }
    
    private func loadEmptyListView() {
        //Primero eliminamos la vista anterior del superview, para luego recuperarla cuando se añada un zamb
        topView.isHidden = true
        loadingView.isHidden = true
        errorMessageView.isHidden = true
        
        let bottomInset = (self.tabBarController?.tabBar.bounds.height)! + self.view.safeAreaInsets.bottom
        emptyView.frame = CGRect(x:0, y: 0, width: self.view.bounds.width, height: tableView.bounds.height - bottomInset)
        
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
        // replace the keychain service name as you like
        let keychain = Keychain(service: Constants.keychainUserService)
        
        // use the in-app product item identifier as key, and set its value to indicate user has purchased it
        do {
            try keychain.set("\(user)", key: "user")
        } catch let error {
            print("setting keychain to purchased failed")
            print(error)
        }

    }
    
    func saveUserRanking(_ ranking: Bool) {
        // replace the keychain service name as you like
        let keychain = Keychain(service: Constants.keychainRankingService)
        
        // use the in-app product item identifier as key, and set its value to indicate user has purchased it
        do {
            try keychain.set("\(ranking)", key: "userRanking")
        } catch let error {
            print("Setting keychain to ranking failed")
            print(error)
        }
    }
    
    func loadUser() -> Int? {
//        return savedUser
        var savedUser: Int = 0
        let keychain = Keychain(service: Constants.keychainUserService)
        
        // if there is value correspond to the user key in the keychain
        if let recoveredUser = try? keychain.get("user"){
            // there is an user saved in keychain, so we must return it
            if recoveredUser != nil {
                savedUser = Int(recoveredUser ?? "pollas")!
            }
        } else {
            // the user has not been found, do nothing
            print("No user found")
        }
        return savedUser
    }
    
    func loadUserRanking() -> Bool? {
        var savedUserRanking: Bool = false
        let keychain = Keychain(service: Constants.keychainRankingService)
        
        // if there is value correspond to the ranking key in the keychain
        if let recoveredUserRanking = try? keychain.get("userRanking"){
            // there is an ranking value saved in keychain, so we must return it
            savedUserRanking = Bool(recoveredUserRanking!)!
        } else {
            // the user has not been found, do nothing
            print("No user found")
        }
        return savedUserRanking
        //RankingProduct.store.restorePurchases()
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
        let url = URL(string: Constants.buildGetZambs() + "\(user)")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        
        dispatchGroup.enter()
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print ("getZambs() error: \(error)")
                    DispatchQueue.main.async {
                        self.connectionError = true
                        self.dispatchGroup.leave()
                    }
                    return
                }
                if let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    print("Zambs got correctly")
                } else if let response = response as? HTTPURLResponse {
                    print ("Server error \(response.statusCode)")
                    DispatchQueue.main.async {
                        self.connectionError = true
                        self.dispatchGroup.leave()
                    }
                    return
                }
                if let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                    DispatchQueue.main.async {
                        self.processZambReceived(data)
                        self.connectionError = false
                        self.dispatchGroup.leave()
                    }
                    
                }
                }.resume()
        
        dispatchGroup.notify(queue: DispatchQueue.main, execute: {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            
            if self.zambs.isEmpty {
                if self.connectionError {
                    self.loadingView.isHidden = true
                    self.errorMessageView.isHidden = false
                } else {
                    self.loadEmptyListView()
                }
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
        
        //TableView
        let bgView = UIImageView(frame: tableView.bounds)
        bgView.image = UIImage(named: "backgroundImage")
        tableView.backgroundView = bgView
        tableView.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        tableView.separatorColor = UIColor.white
        
        //Nav bar
        self.navigationController?.navigationBar.setBackgroundImage(bgView.image, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .none
        
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
        cell.zambsAmountLabel.text = "\(zamb.amount) ZAMBS!!"
        cell.locationLabel.text = zamb.location
        cell.dateLabel.text = zamb.date
        cell.sessionTimeLabel.text = secondsProcessor(inputSeconds: zamb.sessionTime)
        
        if (zambs.count > 0) {
            topView.isHidden = false
        }
        
//        if zambs.count - 1 == indexPath.row {
//            let separator = UIView(frame: CGRect(x:0, y:83, width: self.view.bounds.width, height: 0.5))
//            separator.backgroundColor = .white
//            cell.contentView.addSubview(separator)
//        }
        
        //No validado
        if(zamb.hand == "No hand" && zamb.location == "No location") {

            //Add label
            cell.validationLabel.isHidden = false

            
            //Remove image
            cell.viewForImage.isHidden = true

            //Change label colors and location icon
            cell.zambsAmountLabel.textColor = UIColor.white.withAlphaComponent(0.5)
            cell.locationLabel.textColor = UIColor.white.withAlphaComponent(0.5)
            cell.dateLabel.textColor = UIColor.white.withAlphaComponent(0.5)
            cell.sessionTimeLabel.textColor = UIColor.white.withAlphaComponent(0.5)
            
            cell.locationIcon.image = UIImage(named: "locationIconOp")

        }
        
        //Validado
        if(zamb.hand != "No hand" && zamb.location != "No location") {
            
            //Remove previous label
            if (cell.validationLabel != nil) {
                cell.validationLabel.isHidden = true
            }
            
            //Create image and add it
            let imageView = UIImageView(image: UIImage(named: "circleCheck"))
            imageView.frame = CGRect(x: 15, y: 15, width: 30, height: 30)
            imageView.contentMode = .scaleAspectFit
            cell.viewForImage.addSubview(imageView)
            cell.viewForImage.isHidden = false
            
            //Change label colors
            cell.zambsAmountLabel.textColor = UIColor.white
            cell.locationLabel.textColor = UIColor.white
            cell.dateLabel.textColor = UIColor.white
            cell.sessionTimeLabel.textColor = UIColor.white
            
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
            os_log("Sending user", log: OSLog.default, type: .debug)
            
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
            //let newIndexPath = IndexPath(row: zambs.count, section: 0)
            zambs.insert(zamb, at: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            tableView.endUpdates()
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
            //let newIndexPath = IndexPath(row: zambs.count, section: 0)
            
            if let zamb = Zamb(
                id: 0,
                user: user,
                amount: message["amount"] as! Int,
                hand: message["hand"] as? String,
                location: message["location"] as? String,
                date: convertStringToDate(date: message["date"] as! String),
                sessionTime: message["sessionTime"] as! Int,
                frecuencyArray: message["frecuencyArray"] as! [[String : Int]]
                ) {
                zambs.insert(zamb, at: 0)
                weeklyZambCount = weeklyZambCount! + zamb.amount
                weeklyZambs.text = "\(weeklyZambCount!) ZAMBS!!!"
                tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                saveZambs(zamb)
                tableView.reloadData()
                updateBottomView()
            }
            
            
            
        }
    }
}
