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

    let router: JLRoutes = {
        let router = JLRoutes()
        router.addRoute("/shop/:shopDomain/etalase/:etalaseId") { dictionary in
            print("link result = \(dictionary)")
            return true
        }
        return router
    }()
    
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
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "http://ecs7.tokopedia.net/brand-store/ramayana/_apps/top.html")!))
        
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
