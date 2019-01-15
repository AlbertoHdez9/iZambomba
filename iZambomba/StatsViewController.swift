//
//  StatsViewController.swift
//  iZambomba
//
//  Created by SingularNet on 27/12/18.
//  Copyright © 2018 SingularNet. All rights reserved.
//

import UIKit

class StatsViewController: UIViewController {

    
    @IBOutlet weak var restView: UIView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var tabBar: UITabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavBarAndBackground()

        // Do any additional setup after loading the view.
    }
    
    //MARK: Private methods
    private func setNavBarAndBackground() {
        
        //Nav bar
        navBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.tintColor = .none
        
        tabBar.isTranslucent = true
        tabBar.tintColor = .none
        
        
        let bgView = UIImageView(frame: self.view.bounds)
        bgView.image = UIImage(named: "backgroundImage")
        self.view.addSubview(bgView)
        self.view.sendSubviewToBack(bgView)
        
        restView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
//        let background = UIImage(named: "backgroundImage")
//
//        var imageView : UIImageView!
//        imageView = UIImageView(frame: view.bounds)
//        imageView.contentMode =  .scaleAspectFill
//        imageView.clipsToBounds = true
//        imageView.image = background
//        imageView.center = view.center
//        view.addSubview(imageView)
//        self.view.sendSubviewToBack(imageView)
        
//        let footerView = UIView()
//        footerView.backgroundColor = UIColor.black.withAlphaComponent(0.15)
//        tableView.tableFooterView = footerView
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
