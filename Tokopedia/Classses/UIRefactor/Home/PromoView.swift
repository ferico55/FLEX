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
    fileprivate static let PROMO_URL = "https://m.tokopedia.com/promo?flag_app=1"
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var activityIndicator: UIActivityIndicatorView!
    fileprivate var retryButton: UIButton!
    fileprivate var urlRequest: URLRequest{
        return URLRequest(url: URL(string: PromoView.PROMO_URL)!)
    }
    
    var didTapPromoDetail: ((_ webViewController: WebViewController) -> Void)?
    var onTapLinkWithUrl: ((_ url: URL) -> Void)?
    
    init() {
        super.init(frame: CGRect.zero, configuration: WKWebViewConfiguration())
        generateRefreshControl()
        generateRetryButton()
        self.uiDelegate = self
        self.navigationDelegate = self
        refreshPromo()
        generateActivityIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: WK Web View Delegate
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        refreshControl.beginRefreshing()
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        refreshControl.endRefreshing()
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let query = navigationAction.request.url!.query {
            if query.contains("newpage=1"){
                let webViewController = WebViewController()
                webViewController.strURL = navigationAction.request.url?.absoluteString
                webViewController.onTapLinkWithUrl = { [unowned self] url in
                    self.onTapLinkWithUrl?(url!)
                }
                didTapPromoDetail?(webViewController)
                decisionHandler(.cancel)
                return
            }
            else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        refreshControl.endRefreshing()
        let urlRequest = URLRequest(url: URL(string: "about:blank")!)
        webView.load(urlRequest)
        retryButton.isHidden = false
    }
    
    // MARK: Refresh Control
    
    func generateRefreshControl(){
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(PromoView.refreshPromo), for: .valueChanged)
        self.scrollView.addSubview(refreshControl)
    }
    
    func generateRetryButton(){
        retryButton = LoadingView().buttonRetry
        switch UIDevice.current.systemVersion.compare("9.0.0", options: NSString.CompareOptions.numeric) {
        // jika di bawah iOS 9.0.0, karena untuk di bawah iOS 9 jika tombol di klik akan menghasilkan crash
        case .orderedAscending:
            retryButton = UIButton(type: .custom)
            retryButton.setTitle("Coba Kembali.", for: UIControlState())
            retryButton.titleLabel?.font = UIFont.mediumSystemFont(ofSize: 15.0)
            retryButton.setTitleColor(UIColor.white, for: UIControlState())
            retryButton.backgroundColor = UIColor(red: 189.0/255.0, green: 189.0/255.0, blue: 189.0/255.0, alpha: 1.0)
        default:
            break
        }
        
        retryButton.addTarget(self, action: #selector(PromoView.pressRetryButton), for: .touchUpInside)
        retryButton.isHidden = true
        retryButton.layer.cornerRadius = 3
        self.addSubview(retryButton)
        retryButton.mas_makeConstraints { make in
            make?.left.equalTo()(self)?.with().offset()(25)
            make?.right.equalTo()(self)?.with().offset()(-25)
            make?.top.equalTo()(self)?.with().offset()(5)
            make?.height.equalTo()(40)
        }
    }
    
    func generateActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        activityIndicator.mas_makeConstraints { (make) in
            make?.centerX.mas_equalTo()(self)
            make?.top.mas_equalTo()(15)
        }
        activityIndicator.startAnimating()
    }
    
    //MARK: Common Method
    
    func refreshPromo(){
        retryButton.isHidden = true
        self.load(urlRequest)
    }
    
    func pressRetryButton() {
        activityIndicator.startAnimating()
        refreshPromo()
    }
    
}
