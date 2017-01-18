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
    var onFilterSelected: ([NSObject: AnyObject] -> Void)?
    var onTabSelected: ((ShopPageTab) -> Void)?
    var onProductSelected: ((String) -> Void)?
    var data: [NSObject: AnyObject]?
    var shopPageHeader: ShopPageHeader!
    var showHomeTab: Bool = false
    
    let url: String
    
    private let webView = WKWebView(frame: CGRectZero, configuration: {
        let config: WKWebViewConfiguration = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        return config
    }())
    
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
        
        router.addRoute("/shop/:shopDomain") { [unowned self] dictionary in
            self.onFilterSelected?([
                "query": dictionary["keyword"] ?? "",
                "order_by": dictionary["sort"] ?? "",
                "page": dictionary["page"] as? Int ?? 1
            ])
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
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: self.url)!))
        
        webView.navigationDelegate = self
        
        webView.bk_addObserverForKeyPath("estimatedProgress") { [unowned self] view in
            let webView = view as! WKWebView
            
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        progressView.frame.size.width = self.view.bounds.size.width
        webView.scrollView.addSubview(progressView);
    }
    
    deinit {
        webView.bk_removeAllBlockObservers()
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
        } else if let targetFrame = navigationAction.targetFrame where !targetFrame.mainFrame {
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
