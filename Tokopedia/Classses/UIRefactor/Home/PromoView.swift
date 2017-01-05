//
//  PromoViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import WebKit

class PromoView: WKWebView, WKNavigationDelegate, WKUIDelegate {
    private static let PROMO_URL = "https://m.tokopedia.com/promo?flag_app=1"
    private var refreshControl: UIRefreshControl!
    private var activityIndicator: UIActivityIndicatorView!
    private var retryButton: UIButton!
    private var urlRequest: NSURLRequest{
        return NSURLRequest(URL: NSURL(string: PromoView.PROMO_URL)!)
    }
    
    var didTapPromoDetail: ((webViewController: WebViewController) -> Void)?
    var onTapLinkWithUrl: ((url: NSURL) -> Void)?
    
    init() {
        super.init(frame: CGRectZero, configuration: WKWebViewConfiguration())
        generateRefreshControl()
        generateRetryButton()
        self.UIDelegate = self
        self.navigationDelegate = self
        refreshPromo()
        generateActivityIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: WK Web View Delegate
    
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        refreshControl.beginRefreshing()
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        refreshControl.endRefreshing()
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let query = navigationAction.request.URL!.query {
            if query.containsString("newpage=1"){
                let webViewController = WebViewController()
                webViewController.strURL = navigationAction.request.URL?.absoluteString
                webViewController.onTapLinkWithUrl = { [unowned self] url in
                    self.onTapLinkWithUrl?(url: url)
                }
                didTapPromoDetail?(webViewController: webViewController)
                decisionHandler(.Cancel)
                return
            }
            else {
                decisionHandler(.Allow)
            }
        } else {
            decisionHandler(.Allow)
        }
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        refreshControl.endRefreshing()
        let urlRequest = NSURLRequest(URL: NSURL(string: "about:blank")!)
        webView.loadRequest(urlRequest)
        retryButton.hidden = false
    }
    
    // MARK: Refresh Control
    
    func generateRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PromoView.refreshPromo), forControlEvents: .ValueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    func generateRetryButton(){
        retryButton = LoadingView().buttonRetry
        switch UIDevice.currentDevice().systemVersion.compare("9.0.0", options: NSStringCompareOptions.NumericSearch) {
        // jika di bawah iOS 9.0.0, karena untuk di bawah iOS 9 jika tombol di klik akan menghasilkan crash
        case .OrderedAscending:
            retryButton = UIButton(type: .Custom)
            retryButton.setTitle("Coba Kembali.", forState: .Normal)
            retryButton.titleLabel?.font = UIFont.mediumSystemFontOfSize(15.0)
            retryButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            retryButton.backgroundColor = UIColor.init(red: 189.0/255.0, green: 189.0/255.0, blue: 189.0/255.0, alpha: 1.0)
        default:
            break
        }
        
        retryButton.addTarget(self, action: #selector(PromoView.pressRetryButton), forControlEvents: .TouchUpInside)
        retryButton.hidden = true
        retryButton.layer.cornerRadius = 3
        self.addSubview(retryButton)
        retryButton.mas_makeConstraints { (make) in
            make.left.equalTo()(self).with().offset()(25)
            make.right.equalTo()(self).with().offset()(-25)
            make.top.equalTo()(self).with().offset()(5)
            make.height.equalTo()(40)
        }
    }
    
    func generateActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        activityIndicator.mas_makeConstraints { (make) in
            make.centerX.mas_equalTo()(self)
            make.top.mas_equalTo()(15)
        }
        activityIndicator.startAnimating()
    }
    
    //MARK: Common Method
    
    func refreshPromo(){
        retryButton.hidden = true
        self.loadRequest(urlRequest)
    }
    
    func pressRetryButton() {
        activityIndicator.startAnimating()
        refreshPromo()
    }
    
}
