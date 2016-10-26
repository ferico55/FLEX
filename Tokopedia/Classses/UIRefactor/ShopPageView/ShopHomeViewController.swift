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
    
    private let webView = WKWebView()
    
    private let router = JLRoutes()
    private let headerHeight: CGFloat = 245
    
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
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "https://s3-ap-southeast-1.amazonaws.com/tokopedia-upload-test/brand-store/ramayana/_apps/top")!))
        
        webView.navigationDelegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.scrollView.contentInset.top = headerHeight
        
        let header = ShopPageHeader(selectedTab: .Home)
        header.onTabSelected = self.onTabSelected
        
        header.view.frame.size.height = headerHeight
        header.view.frame.size.width = self.view.bounds.size.width
        header.view.frame.origin.y = -headerHeight
        
        self.addChildViewController(header)
        webView.scrollView.addSubview(header.view)
        
        header.didMoveToParentViewController(self)
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
