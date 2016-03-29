//
//  OnboardingViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 3/24/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc
class IntroViewController: UIViewController {
    @IBOutlet var presentationContainer: UIView!
    var introView: EAIntroView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let page1 = EAIntroPage()
        page1.title = "page 1"
        page1.desc = "page 1 desc"
        
        let page2 = EAIntroPage()
        page2.title = "page 2"
        page2.desc = "page2 desc"
        
        let page3 = EAIntroPage()
        page3.title = "page 3"
        page3.desc = "page 3 desc"
        
        introView = EAIntroView(frame: UIScreen.mainScreen().bounds, andPages: [page1, page2, page3])

        introView.showInView(presentationContainer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // for some reason the introView's frame is distorted
        introView.frame = self.view.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
