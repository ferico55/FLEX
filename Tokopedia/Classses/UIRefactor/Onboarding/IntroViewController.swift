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
    @IBOutlet private var presentationContainer: UIView!
    @IBOutlet private var page1View: UIView!
    
    var introView: EAIntroView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let page1 = EAIntroPage(customView: page1View)
        setupPage1()
        
        let page2 = EAIntroPage()
        page2.title = "page 2"
        page2.desc = "page2 desc"
        
        let page3 = EAIntroPage()
        page3.title = "page 3"
        page3.desc = "page 3 desc"
        
        introView = EAIntroView(frame: UIScreen.mainScreen().bounds, andPages: [page1, page2, page3])

        introView.showInView(presentationContainer)
    }
    
    private func setupPage1() {
        
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
