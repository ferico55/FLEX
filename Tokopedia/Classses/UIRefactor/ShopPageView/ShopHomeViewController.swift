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
    var onProductSelected: ((String) -> Void)?
    var data: [NSObject: AnyObject]?
    var shopPageHeader: ShopPageHeader!
    var showHomeTab: Bool = false
    
    let url: String
    
    private let webView = WKWebView()
    
    private let router = JLRoutes()
    
    private var fakeTab: ShopTabView!
    private let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .Bar)
        progressView.progressTintColor = UIColor(red:0.071, green:0.780, blue:0, alpha:1)
        return progressView
    }()
    
    init(url: String) {
        self.url = url
        
        super.init(nibName: nil, bundle: nil)
        
        router.addRoute("/shop/:shopDomain/etalase/:etalaseId") { [unowned self] dictionary in
            let shopDomain = dictionary["shopDomain"] as! String
            let etalaseId = dictionary["etalaseId"] as! String
            
            self.onEtalaseSelected?(shopDomain, etalaseId)
            return true
        }
        
        router.addRoute("/shop/:shopDomain/product/:productId") { [unowned self] dictionary in
            let productId = dictionary["productId"] as! String
            
            self.onProductSelected?(productId)
            return true
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopHomeViewController.updateHeaderPosition), name: "updateHeaderPosition", object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func updateHeaderPosition(notification: NSNotification) {
        if notification.object! !== self {
            let userInfo = notification.userInfo! 
            let yPos: Double = userInfo["y_position"] as! Double
            
            webView.scrollView.contentOffset = CGPoint(x: 0, y: yPos)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(webView)
        
        webView.mas_makeConstraints { make in
            make.edges.equalTo()(self.view)
        }
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: self.url)!))
        
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
        
        let header = ShopPageHeader(selectedTab: .Home)
        header.onTabSelected = self.onTabSelected
        header.data = data
        header.showHomeTab = self.showHomeTab
        
        
        header.view.frame = CGRect(x: 0,
                                   y: -header.view.frame.height,
                                   width: self.view.bounds.width,
                                   height: header.view.frame.height)
        
        self.shopPageHeader = header
        
        webView.scrollView.delegate = self
        webView.scrollView.contentInset.top = header.view.frame.size.height
        
        self.addChildViewController(header)
        webView.scrollView.addSubview(header.view)
        header.didMoveToParentViewController(self)
        
        webView.bk_addObserverForKeyPath("estimatedProgress") { [unowned self] view in
            let webView = view as! WKWebView
            
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //TODO: fix header layout. height is hardcoded to prevent the header from setting its own height
        self.shopPageHeader.view.frame.size = CGSize(width: self.view.bounds.width, height: 245)
        self.shopPageHeader.view.layoutIfNeeded()
        
        progressView.frame.size.width = self.view.bounds.size.width
        webView.scrollView.addSubview(progressView);
    }

    private func notifyScrolling() {
        let userInfo = ["y_position": webView.scrollView.contentOffset.y]
        
        NSNotificationCenter.defaultCenter().postNotificationName("updateHeaderPosition", object: self, userInfo: userInfo)
    }
    
    deinit {
        // prevent the view controller from being retained after deallocated
        // this code is never needed at app version 1.92. somehow
        // at 1.93 with XCode 8.1, with iOS 9 and below, if we don't remove the delegate
        // this view controller will still receive messages even after deallocated, which causes crash
        webView.scrollView.delegate = nil
        
        webView.bk_removeAllBlockObservers()
        webView.scrollView.bk_removeAllBlockObservers()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

extension ShopHomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.fakeTab.hidden = !(scrollView.contentOffset.y > -self.fakeTab.frame.height)
        self.notifyScrolling()
    }
}

extension ShopHomeViewController: WKNavigationDelegate {
    func webView(webView: WKWebView,
                 decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                 decisionHandler: (WKNavigationActionPolicy) -> Void) {        
        if router.routeURL(navigationAction.request.URL!) {
            decisionHandler(.Cancel)
        } else if navigationAction.request.URL!.absoluteString! == self.url {
            decisionHandler(.Allow)
        } else {
            let webViewController = WebViewController()
            let url = UserAuthentificationManager().webViewUrlFromUrl(navigationAction.request.URL!.absoluteString!)
            
            webViewController.strURL = url
            self.navigationController!.pushViewController(webViewController, animated: true)
            
            decisionHandler(.Cancel);
        }
    }
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        hideLoadingIndicators()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        hideLoadingIndicators()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        hideLoadingIndicators()
    }
    
    private func hideLoadingIndicators() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        progressView.hidden = true
    }
}
