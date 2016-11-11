//
//  PromoViewController.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 11/10/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PromoView: UIWebView, UIWebViewDelegate {
    
    var homeTabViewController: HomeTabViewController?
    private var firstTimeLoad = true
    private let promoURL = "https://m.tokopedia.com/promo?flag_app=1"
    private var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    override init(frame: CGRect) {
        super.init(frame: frame)
        let urlRequest = NSURLRequest(URL: NSURL(string: promoURL)!)
        self.loadRequest(urlRequest)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        activityIndicatorView.center.x = self.bounds.midX
        print("aiV frame: \(activityIndicatorView.frame)" )
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        self.addSubview(activityIndicatorView)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        activityIndicatorView.stopAnimating()
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    
        if (request.URL!.absoluteString!.containsString("blog")) {
            let webViewController = WebViewController()
            webViewController.strURL = request.URL?.absoluteString
            webViewController.onTapLinkWithUrl = { [unowned self] url in
                if url.absoluteString == "https://www.tokopedia.com/" {
                    self.homeTabViewController?.navigationController?.popViewControllerAnimated(true)
                }
            }
            homeTabViewController?.navigationController?.pushViewController(webViewController, animated: true)
            return false
        } else {
            return true
        }
    }
}
