//
//  PageViewController.swift
//  iZambomba
//
//  Created by SingularNet on 27/12/18.
//  Copyright © 2018 SingularNet. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    lazy var orderedViewControllers: [UIViewController] = {
        return [self.newPageVC(viewController: "FirstPageVC"),
                self.newPageVC(viewController: "SecondPageVC"),
                self.newPageVC(viewController: "ThirdPageVC")]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataSource = self
        
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }

        // Do any additional setup after loading the view.
    }
    
    func newPageVC(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex =  orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex =  orderedViewControllers.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard orderedViewControllers.count != nextIndex else {
            return nil
        }
        
        guard orderedViewControllers.count > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
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
