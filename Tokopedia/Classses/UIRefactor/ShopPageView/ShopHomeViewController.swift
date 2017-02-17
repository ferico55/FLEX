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
    var onFilterSelected: ((ShopProductFilter) -> Void)?
    var onTabSelected: ((ShopPageTab) -> Void)?
    var onProductSelected: ((String) -> Void)?
    var data: [NSObject: AnyObject]?
    var shopPageHeader: ShopPageHeader!
    var showHomeTab: Bool = false
    
    let url: String
    
    fileprivate let webView = WKWebView(frame: .zero, configuration: {
        let config: WKWebViewConfiguration = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        return config
    }())
    
    fileprivate let router = JLRoutes()
    
    fileprivate var fakeTab: ShopTabView!
    fileprivate let progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = UIColor(red:0.071, green:0.780, blue:0, alpha:1)
        return progressView
    }()
    
    init(url: String) {
        self.url = url
        
        super.init(nibName: nil, bundle: nil)
        
        router.addRoute("/shop/:shopDomain/etalase/:etalaseId") { [unowned self] dictionary in
            self.onFilterSelected?(ShopProductFilter.fromUrlQuery(dictionary))
            return true
        }
        
        router.addRoute("/shop/:shopDomain/product/:productId") { [unowned self] dictionary in
            let productId = dictionary["productId"] as! String
            
            self.onProductSelected?(productId)
            return true
        }
        
        router.addRoute("/shop/:shopDomain") { [unowned self] dictionary in
            self.onFilterSelected?(ShopProductFilter.fromUrlQuery(dictionary))
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
            make?.edges.equalTo()(self.view)
        }
        
        webView.navigationDelegate = self
        
        webView.load(NSURLRequest(url: NSURL(string: self.url)! as URL) as URLRequest)
        
        webView.bk_addObserver(forKeyPath: "estimatedProgress") { [unowned self] (view: Any?) in
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
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if router.routeURL(navigationAction.request.url!) {
            decisionHandler(.cancel)
        } else if navigationAction.request.url!.absoluteString == self.url {
            decisionHandler(.allow)
        } else if let targetFrame = navigationAction.targetFrame, !targetFrame.isMainFrame {
            decisionHandler(.allow)
        } else {
            let webViewController = WebViewController()
            let url = UserAuthentificationManager().webViewUrl(fromUrl: navigationAction.request.url!.absoluteString)
            
            webViewController.strURL = url
            self.navigationController!.pushViewController(webViewController, animated: true)
            
            decisionHandler(.cancel);
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoadingIndicators()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        hideLoadingIndicators()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideLoadingIndicators()
    }
    
    private func hideLoadingIndicators() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        progressView.isHidden = true
    }
}
