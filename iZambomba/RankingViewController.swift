//
//  RankingViewController.swift
//  iZambomba
//
//  Created by SingularNet on 18/1/19.
//  Copyright © 2019 SingularNet. All rights reserved.
//

import UIKit
import os.log
import StoreKit

class RankingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var timeSpan: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    //let cellId = "RankingTableViewCell"
    let dispatchGroup = DispatchGroup()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let loadingView = UIView()
    let paymentSetupView = UIView()
    let emptyView = UIView()
    
    struct userZamb {
        let user: String
        let zambs: String
    }
    var zambs = [userZamb]()
    var user: Int = 0
    var userRanking: Bool = false
    var viewHasLoaded: Bool = false
    var product: [SKProduct] = []
    
    var span: String = "d"
    var previousSpan: String = "d"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Get user from table VC
        let zambTableNC = self.tabBarController?.viewControllers![0] as! UINavigationController
        let zambTableVC = zambTableNC.topViewController as! ZambTableViewController
        userRanking = zambTableVC.userRanking
        user = zambTableVC.user
        product = zambTableVC.product
        
        NotificationCenter.default.addObserver(self, selector: #selector(RankingViewController.changeVisibleViewAndUpdateRanking), name: .IAPHelperPurchaseNotification, object: nil)
        setNavBarAndBackground()
        if !userRanking {
            setPaymentSetupScreen()
        }
        viewHasLoaded = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if !userRanking {
            paymentSetupView.isHidden = false
        } else {
            if previousSpan != span || viewHasLoaded {
                paymentSetupView.isHidden = true
                setLoadingScreen()
                loadRankingZambs(span)
            }
        }
    }
    
    //MARK: Private methods
    private func loadRankingZambs(_ span: String)  {
        zambs.removeAll()
        let url = URL(string: Constants.buildGetRanking() + span)
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"

        dispatchGroup.enter()
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print ("getRanking() error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("Ranking received correctly")
            } else {
                print ("Server error in ranking")
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
                self.tableView.isHidden = false
                self.loadingView.isHidden = true
                self.emptyView.isHidden = true
                self.tableView.reloadData()
            }
        })
    }
    
    private func processZambReceived(_ data: Data) {
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with: data, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                return
            }
            for tuple in jsonArray {
                var username: String = ""
                var amount: Int = 0
                if let user = tuple["user"] as? [String: Any] {
                    username = user["username"] as! String
                }
                if let zamb = tuple["zamb"] as? [String: Any] {
                    amount = zamb["amount"] as! Int
                }
                zambs.append(userZamb(user: username, zambs: "\(amount) ZAMBS!"))
            }
        } catch {
            print(error)
        }
    }
    
    private func spanToInt(_ span: String) -> Int {
        let table = [
            "d": 0,
            "w": 1,
            "m": 2
        ]
        return table[span]!
    }
    
    private func setNavBarAndBackground() {
        
        //Nav bar
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.tintColor = .none
        
        //Background
        let bgView = UIImageView(frame: self.view.bounds)
        bgView.image = UIImage(named: "backgroundImage")
        self.view.addSubview(bgView)
        self.view.sendSubviewToBack(bgView)
        
        let bgaView = UIImageView(frame: tableView.bounds)
        bgaView.image = UIImage(named: "backgroundImage")
        tableView.backgroundView = bgaView
        tableView.backgroundView?.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        tableView.separatorColor = UIColor.white
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 70
    }
    
    private func loadEmptyListView() {
        tableView.isHidden = true
        loadingView.isHidden = true
        
        let topInset = (UIApplication.shared.keyWindow?.safeAreaInsets.top)! + self.navBar.bounds.height + 35
        emptyView.frame = CGRect(x:0, y: topInset, width: self.view.bounds.width, height: tableView.bounds.height)
        emptyView.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        
        //Creamos las labels y mierdas para la nueva vista
        let startNOW = UILabel(frame: CGRect(x: 0, y: emptyView.bounds.height/4, width: self.view.bounds.width, height: 90))
        startNOW.text = "Wow!"
        startNOW.font = UIFont(name: "Lato-Bold", size: 31)
        startNOW.textAlignment = .center
        startNOW.textColor = .white
        
        let description = UILabel(frame: CGRect(x: 0, y: self.view.bounds.height/4, width: self.view.bounds.width, height: 180))
        description.text = "It seems there are no records\nfor this time span"
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
        tableView.isHidden = true
        
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.isHidden = false
        
        let topInset = (UIApplication.shared.keyWindow?.safeAreaInsets.top)! + self.navBar.bounds.height + 35
        loadingView.frame = CGRect(x:0, y: topInset, width: self.view.bounds.width, height: tableView.bounds.height)
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
        loadingView.isHidden = false
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    private func setPaymentSetupScreen() {
        //Loader
        tableView.isHidden = true
        loadingView.isHidden = true
        
        //let topInset = self.view.safeAreaInsets.top + self.navBar.bounds.height + 35
        paymentSetupView.frame = CGRect(x:0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        //Creamos las labels y mierdas para la nueva vista
        let startNOW = UILabel(frame: CGRect(x: 0, y: self.view.bounds.height/3, width: self.view.bounds.width, height: 120))
        startNOW.text = "Would you like to\nbe here?"
        startNOW.numberOfLines = 2
        startNOW.font = UIFont(name: "Lato-Bold", size: 31)
        startNOW.textAlignment = .center
        startNOW.textColor = .black
        
        let description = UILabel(frame: CGRect(x: 0, y: self.view.bounds.height/2, width: self.view.bounds.width, height: 180))
        description.text = "Keeping this dream is everyone's\nbusiness. Join our cause and challenge\n your friends!"
        description.numberOfLines = 3
        description.font = UIFont(name: "Lato-Light", size: 20)
        description.textAlignment = .center
        description.textColor = .black
        
        let backgroundImage = UIImageView(frame: self.view.bounds)
        backgroundImage.image = UIImage(named: "whiteGradient")
        paymentSetupView.addSubview(backgroundImage)
        paymentSetupView.sendSubviewToBack(backgroundImage)
        
        let paymentButton = UIButton(frame: CGRect(origin: CGPoint(x: self.view.bounds.width*(0.5/6), y: self.view.bounds.height*(6/8)), size: CGSize(width: self.view.bounds.width*(5/6), height: 60.0)))
        paymentButton.setBackgroundImage(UIImage(named: "buttonPrimary"), for: .normal)
        paymentButton.setTitle("Participate with 1$", for: .normal)
        paymentButton.titleLabel?.font = UIFont(name: "Lato-Black", size: 22)
        paymentButton.addTarget(self, action: #selector(paymentHandler), for: .touchUpInside)
        
        //Añadimos a la vista
        paymentSetupView.addSubview(description)
        paymentSetupView.addSubview(startNOW)
        paymentSetupView.addSubview(paymentButton)
        
        self.view.addSubview(paymentSetupView)
    }
    
    @objc private func paymentHandler() {
        if IAPHelper.canMakePayments() {
            //userRanking = true
            RankingProduct.store.buyProduct(product[0])
        } else {
            print("payment chungo")
        }
        
    }
    
    @objc private func changeVisibleViewAndUpdateRanking() {
        paymentSetupView.isHidden = true
        loadingView.isHidden = false
        loadRankingZambs(span)
        let url = URL(string: Constants.buildUserUpdate() + "\(user)")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        
        let uploadData: [String:Any] = [
            "ranking"  : true
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: uploadData, options: []) else {
            return
        }
        URLSession.shared.uploadTask(with: request, from: data) { (data, response, error) in
            if let error = error {
                print ("updateUserRanking() error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse,
                response.statusCode == 200 {
                print("UserRanking updated correctly")
            } else {
                print ("Server error in update User ranking")
                return
            }
            if let data = data,
                let dataString = String(data: data, encoding: .utf8) {
                print ("got data: \(dataString)")
            }
            }.resume()
        userRanking = true
        ZambTableViewController().saveUserRanking(userRanking)
    }
    
    private func convertStringToDate(date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy H:mm"
        formatter.locale = Locale(identifier: "en_US")
        
        let dateString = formatter.date(from: date)
        return dateString!
    }
    
    //MARK: Actions
    @IBAction func timeSpanHandler(_ sender: Any) {
        if spanToInt(span) != timeSpan.selectedSegmentIndex {
            self.tableView.isHidden = true
            self.loadingView.isHidden = true
            self.emptyView.isHidden = true
            setLoadingScreen()
            previousSpan = span
            if timeSpan.selectedSegmentIndex == 0 {
                span = "d"
            } else if timeSpan.selectedSegmentIndex == 1 {
                span = "w"
            } else {
                span = "m"
            }
            loadRankingZambs(span)
        }
    }
    
    //MARK: Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zambs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellId = "RankingTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? RankingTableViewCell else {
            fatalError("The dequeued cell is not an instance of RankingTableViewCell.")
        }
        
        // Fetches the appropriate zamb for the data source layout.
        let zamb = zambs[indexPath.row]
        cell.usernameLabel.text = zamb.user
        cell.zambsLabel.text = zamb.zambs
        cell.index.text = "\(indexPath.row + 1)"
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell \(indexPath.row)!")
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "options":
            guard let optionsViewController = segue.destination as? OptionsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            optionsViewController.user = user
            optionsViewController.userRanking = userRanking
            os_log("Sending user", log: OSLog.default, type: .debug)
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
 
    
    

}
