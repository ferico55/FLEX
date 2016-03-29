//
//  OnboardingViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc
class IntroViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    lazy var vcs: [UIViewController] = {
        let vc1 = UIViewController()
        
        let vc2 = UIViewController()
        
        let vc3 = UIViewController()
        
        return [vc1, vc2, vc3, UIViewController(), UIViewController()]
    }();
    
    init() {
        super.init(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(white: 0xe7/255.0, alpha: 1)
        self.dataSource = self
        
        setViewControllers([vcs[0]], direction: .Forward, animated: false, completion: nil)
        
        let pageControl = UIPageControl(frame: CGRect(x:50, y:50, width: 100, height: 50))
        pageControl.tintColor = UIColor.redColor()
        pageControl.numberOfPages = vcs.count
        pageControl.currentPageIndicatorTintColor = UIColor.greenColor()
        
        
        self.view.addSubview(pageControl)
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        let index = vcs.indexOf(viewController)! + 1
        return index < vcs.count ? vcs[index]:nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        let index = vcs.indexOf(viewController)! - 1
        return index >= 0 ? vcs[index]:nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
