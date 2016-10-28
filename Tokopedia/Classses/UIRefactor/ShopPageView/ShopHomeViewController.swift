//
//  ShopHomeViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 10/19/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Masonry
import WebKit
import JLRoutes

class ShopHomeViewController: UIViewController {

    var onEtalaseSelected: ((String, String) -> Void)?
    var onTabSelected: ((ShopPageTab) -> Void)?
    var data: [NSObject: AnyObject]?
    var shopPageHeader: ShopPageHeader?
    var showHomeTab: Bool = false
    
    private let webView = WKWebView()
    
    private let router = JLRoutes()
    
    private var fakeTab: ShopTabView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        router.addRoute("/shop/:shopDomain/etalase/:etalaseId") { [unowned self] dictionary in
            let shopDomain = dictionary["shopDomain"] as! String
            let etalaseId = dictionary["etalaseId"] as! String
            
            self.onEtalaseSelected?(shopDomain, etalaseId)
            return true
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(webView)
        
        webView.mas_makeConstraints { make in
            make.edges.equalTo()(self.view)
        }
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "file:///Users/se/Desktop/ramayana.htm")!))
        
        webView.navigationDelegate = self
        
        fakeTab = ShopTabView(tab: .Home)
        self.view.addSubview(fakeTab)
        
        fakeTab.mas_makeConstraints { make in
            make.top.right().left().equalTo()(self.view)
            make.height.equalTo()(40)
        }
        
        fakeTab.showHomeTab = self.showHomeTab
        fakeTab.onTabSelected = self.onTabSelected
        fakeTab.hidden = true
        
        fakeTab.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        fakeTab.layer.shadowColor = UIColor.blackColor().CGColor
        fakeTab.layer.shadowRadius = 1
        fakeTab.layer.shadowOpacity = 3
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let header = ShopPageHeader(selectedTab: .Home)
        header.onTabSelected = self.onTabSelected
        header.data = data
        header.showHomeTab = self.showHomeTab
        
        
        header.view.frame = CGRect(x: 0,
                                   y: -header.view.frame.height,
                                   width: self.view.bounds.width,
                                   height: header.view.frame.height)
        
        header.view.layoutIfNeeded()
        
        self.shopPageHeader = header
        
        webView.scrollView.contentInset.top = header.view.frame.size.height
        
        self.addChildViewController(header)
        webView.scrollView.addSubview(header.view)
        header.didMoveToParentViewController(self)
        
        webView.scrollView.bk_addObserverForKeyPath("contentOffset") { [unowned self] view in
            let scrollView = view as! UIScrollView
            
            self.fakeTab.hidden = !(scrollView.contentOffset.y > -self.fakeTab.frame.height)
            self.notifyScrolling()
        }
    }

    private func notifyScrolling() {
        let userInfo = ["y_position": webView.scrollView.contentOffset.y]
        
        NSNotificationCenter.defaultCenter().postNotificationName("updateProductHeaderPosition", object: self, userInfo: userInfo)
        NSNotificationCenter.defaultCenter().postNotificationName("updateTalkHeaderPosition", object: self, userInfo: userInfo)
        NSNotificationCenter.defaultCenter().postNotificationName("updateNotesHeaderPosition", object: self, userInfo: userInfo)
        NSNotificationCenter.defaultCenter().postNotificationName("updateReviewHeaderPosition", object: self, userInfo: userInfo)
    }
}

extension ShopHomeViewController: WKNavigationDelegate {
    func webView(webView: WKWebView,
                 decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                 decisionHandler: (WKNavigationActionPolicy) -> Void) {        
        if router.routeURL(navigationAction.request.URL!) {
            decisionHandler(.Cancel)
        }
        else {
            decisionHandler(.Allow)
        }
    }
}
