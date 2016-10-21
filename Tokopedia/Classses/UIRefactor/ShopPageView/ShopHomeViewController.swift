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
    
    private let router = JLRoutes()
    
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
        
        let header = ShopPageHeader(selectedTab: .Home)
        self.addChildViewController(header)
        self.view.addSubview(header.view)
        header.didMoveToParentViewController(self)
        
        header.view.mas_makeConstraints { make in
            make.top.equalTo()(self.view.mas_top)
            make.left.equalTo()(self.view.mas_left)
            make.right.equalTo()(self.view.mas_right)
            make.height.equalTo()(245)
        }

        let webView = WKWebView()
        
        self.view.addSubview(webView)
        
        webView.mas_makeConstraints { make in
            make.left.equalTo()(self.view.mas_left)
            make.right.equalTo()(self.view.mas_right)
            make.bottom.equalTo()(self.view.mas_bottom)

            make.top.equalTo()(self.view.mas_top).offset()(245)
        }
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "file:///Users/se/Desktop/ramayana.htm")!))
        
        webView.navigationDelegate = self
        
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
