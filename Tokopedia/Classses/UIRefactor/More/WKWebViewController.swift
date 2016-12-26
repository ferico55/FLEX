//
//  WKWebViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import WebKit

class WKWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, NoResultDelegate {

    private var urlString: String
    private var shouldAuthorizeRequest: Bool
    private var webView: WKWebView!
    private var refreshControl: UIRefreshControl!
    private var urlRequest: NSURLRequest!
    private var progressView: UIProgressView!
    private var noInternetView: NoResultReusableView!
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.UIDelegate = self
        view = webView
        initProgressView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(WKWebViewController.refreshWebView), forControlEvents: UIControlEvents.ValueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.navigationDelegate = self
        
        initNoInternetView()
        loadWebView()
    }
    
    init(urlString: String, shouldAuthorizeRequest: Bool) {
        self.urlString = urlString
        self.shouldAuthorizeRequest = shouldAuthorizeRequest
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func loadWebView() {
        let myURL = NSURL(string: urlString)
        webView.loadRequest(requestForURL(myURL!))
        
        webView.bk_addObserverForKeyPath("estimatedProgress") { [unowned self] view in
            let webView = view as! WKWebView
            
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    private func requestForURL(url: NSURL) -> NSMutableURLRequest {
        var request: NSMutableURLRequest
        if shouldAuthorizeRequest {
            request = NSMutableURLRequest(authorizedHeader: url)
        } else {
            request = NSMutableURLRequest()
            request.setValue("Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5", forHTTPHeaderField: "User-Agent")
            request.URL = url
        }
        
        return request
    }
    
    private func initNoInternetView() {
        noInternetView = NoResultReusableView(frame: UIScreen.mainScreen().bounds)
        noInternetView.delegate = self
        noInternetView.generateAllElements("icon_no_data_grey.png", title: "Whoops!\nTidak ada koneksi Internet", desc: "Harap coba lagi", btnTitle: "Coba Kembali")
    }
    
    private func initProgressView() {
        progressView = UIProgressView(progressViewStyle: .Bar)
        progressView.frame.size.width = self.view.bounds.size.width
        webView.addSubview(progressView);
        progressView.mas_makeConstraints { make in
            make.top.right().left().equalTo()(self.view)
            make.height.equalTo()(2)
        }
    }
    
    @objc private func refreshWebView() {
        initProgressView()
        progressView.hidden = false
        webView.loadRequest(requestForURL(NSURL(string: urlString)!))
        
        webView.bk_addObserverForKeyPath("estimatedProgress") { [unowned self] view in
            let webView = view as! WKWebView
            
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    //MARK: WKNavigation Delegate
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        hideLoadingIndicators()
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        if !noInternetView.isDescendantOfView(webView) && error.code == -1009 {
            webView.addSubview(noInternetView)
        }
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "about:blank")!))
        hideLoadingIndicators()
    }
    
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        hideLoadingIndicators()
    }
    
    private func hideLoadingIndicators() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        progressView.hidden = true
        refreshControl.endRefreshing()
    }
    
    //MARK: No Result Delegate
    func buttonDidTapped(sender: AnyObject!) {
        if noInternetView.isDescendantOfView(webView) {
            noInternetView.removeFromSuperview()
        }
        refreshWebView()
    }


}
