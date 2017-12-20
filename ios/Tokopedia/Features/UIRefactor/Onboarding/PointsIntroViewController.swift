//
//  PointsIntroViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/24/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import EAIntroView

class PointsIntroViewController: UIViewController {

    @IBOutlet var page1: UIView!
    @IBOutlet var page2: UIView!
    @IBOutlet var page3: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnSkip: UIButton!
    
    private var introView: EAIntroView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        introView = EAIntroView(frame: UIScreen.main.bounds, andPages: [
            {
                let page = EAIntroPage(customView: page1)
                return page as Any
            }(),
            {
                let page = EAIntroPage(customView: page2)
                page?.onPageDidAppear = {[unowned self] in
                    self.showMainControls(show: true)
                }
                return page as Any
            }(),
            {
                let page = EAIntroPage(customView: page3)
                page?.onPageDidAppear = {[unowned self] in
                    self.showMainControls(show: false)
                }
                return page as Any
            }()
        ])
        
        introView?.swipeToExit = false
        introView?.show(in: containerView)
        introView?.skipButton = nil
        
        UserDefaults.standard.set(true, forKey: "has_shown_points_onboarding")
        UserDefaults.standard.synchronize()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showMainControls(show: Bool) {
        UIView.animate(withDuration: 0.2) { 
            self.btnNext.isHidden = !show
            self.btnSkip.isHidden = !show
        }
    }
    
    // tap actions
    @IBAction func btnNextTapped(_ sender: Any) {
        let currentPageIndex = introView?.currentPageIndex ?? 0
        if (currentPageIndex < 2) {
            introView?.setCurrentPageIndex(currentPageIndex + 1, animated: true)
            if (currentPageIndex + 1 == 2) {
                showMainControls(show: false)
            }
        }
    }
    @IBAction func btnSkipTapped(_ sender: Any) {
        self.dismiss(animated: true) {
            
        }
    }
    @IBAction func btnSeePointsTapped(_ sender: Any) {
        self.dismiss(animated: true) { 
            
        }
    }

}
