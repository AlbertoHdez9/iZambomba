//
//  RankingViewController.swift
//  iZambomba
//
//  Created by SingularNet on 18/1/19.
//  Copyright © 2019 SingularNet. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController {

    @IBOutlet weak var timeSpan: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    
    let cellId = "rankingCell"
    let dispatchGroup = DispatchGroup()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let loadingView = UIView()
    
    var zambs = [Zamb]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarAndBackground()
        setLoadingScreen()
        loadRankingZambs("d")
    }
    
    //MARK: Private methods
    private func loadRankingZambs(_ span: String)  {
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
                    sleep(1)
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
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.tintColor = .none
        
        //Background
        let bgView = UIImageView(frame: self.view.bounds)
        bgView.image = UIImage(named: "backgroundImage")
        self.view.addSubview(bgView)
        self.view.sendSubviewToBack(bgView)
    }
    
    private func loadEmptyListView() {
        tableView.isHidden = true
        loadingView.isHidden = true
        
        let emptyView = UIView()
        let topInset = self.view.safeAreaInsets.top + self.navBar.bounds.height + 35
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
        
        let topInset = self.view.safeAreaInsets.top + self.navBar.bounds.height + 35
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
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
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
        if timeSpan.selectedSegmentIndex == 0 {
            zambs.removeAll()
            loadRankingZambs("d")
        } else if timeSpan.selectedSegmentIndex == 1 {
            zambs.removeAll()
            loadRankingZambs("w")
        } else {
            zambs.removeAll()
            loadRankingZambs("m")
        }
    }
    
    //MARK: Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return zambs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as UITableViewCell
        
        // Fetches the appropriate zamb for the data source layout.
        let zamb = zambs[indexPath.row]
        cell.textLabel?.text = "\(zamb.user)             \(zamb.amount) ZAMBS"
        cell.textLabel?.textColor = .white
        cell.textLabel?.font = UIFont(name: "Lato-Bold", size: 16.0)
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You selected cell \(indexPath.row)!")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
