//
//  PromoViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import WebKit

class PromoView: WKWebView, WKNavigationDelegate, WKUIDelegate, RetryViewDelegate {
    
    var homeTabViewController: HomeTabViewController?
    private var firstTimeLoad = true
    private let promoURL = "https://m.tokopedia.com/promo?flag_app=1"
    private var refreshControl: UIRefreshControl!
    private var activityIndicator: UIActivityIndicatorView!
    private var retryButton: UIButton!
    private var urlRequest: NSURLRequest{
        return NSURLRequest(URL: NSURL(string: promoURL)!)
    }
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
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
        self.refreshControl.beginRefreshing()
    }
    
    func webView(webView: WKWebView, didCommitNavigation navigation: WKNavigation!) {
        self.refreshControl.endRefreshing()
        activityIndicator.stopAnimating()
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if let query = navigationAction.request.URL!.query {
            if query.containsString("newpage=1"){
                let webViewController = WebViewController()
                webViewController.strURL = navigationAction.request.URL?.absoluteString
                webViewController.onTapLinkWithUrl = { [unowned self] url in
                    if url.absoluteString == "https://www.tokopedia.com/" {
                        self.homeTabViewController?.navigationController?.popViewControllerAnimated(true)
                    }
                }
                homeTabViewController?.navigationController?.pushViewController(webViewController, animated: true)
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
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        let retryCollectionReusableView = RetryCollectionReusableView()
        retryCollectionReusableView.delegate = self
        self.addSubview(retryCollectionReusableView)
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        refreshControl.endRefreshing()
        let urlRequest = NSURLRequest(URL: NSURL(string: "about:blank")!)
        webView.loadRequest(urlRequest)
        let retryCollectionReusableView = RetryCollectionReusableView()
        retryCollectionReusableView.delegate = self
        retryButton.hidden = false
    }
    
    // MARK: Refresh Control
    
    func generateRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PromoView.refreshPromo), forControlEvents: .ValueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    func generateRetryButton(){
        retryButton = (NSBundle.mainBundle().loadNibNamed("RetryCollectionReusableView", owner: nil, options: nil)![0] as! RetryCollectionReusableView).retryButton
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
        activityIndicator.center.x = self.bounds.midX
        activityIndicator.frame.origin.y = 15
        activityIndicator.startAnimating()
        self.addSubview(activityIndicator)

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
