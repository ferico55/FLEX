//
//  ResolutionWebViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 12/21/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import WebKit
import JLRoutes

@objc class ResolutionWebViewController: UIViewController {
    
    fileprivate var stringUrl : String?
    fileprivate var route = JLRoutes()
    fileprivate var webView : WKWebView = {
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        
        return WKWebView(frame: CGRect.zero, configuration: wkWebConfig)
    }()
    
    fileprivate let progressView : UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .bar)
        progressView.progressTintColor = UIColor(red:0.071, green:0.780, blue:0, alpha:1)
        return progressView
    }()
    
    fileprivate var onRefreshRequested : (()->Void)?
    
    fileprivate init(stringUrl:String) {
        super.init(nibName: nil, bundle: nil)
        self.stringUrl = stringUrl;
    }

    init(resolutionId:String) {
        super.init(nibName: nil, bundle: nil)
        self.stringUrl = self.urlStringDetailWithResolutionId(resolutionId);
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Pusat Resolusi"
        
        let backButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        self.view.addSubview(webView)
        webView.mas_makeConstraints { make in
            make?.edges.equalTo()(self.view)
        }
        
        webView.addSubview(progressView)
        progressView.mas_makeConstraints { make in
            make?.top.right().left().equalTo()(self.view)
            make?.height.equalTo()(2)
        }
        
        route.addRoute("/invoice.pl") { dictionary in
            guard let pdf = dictionary["pdf"] as? String else {return false}
            guard let id = dictionary["id"] as? String else {return false}
            let url = "\(NSString.tokopediaUrl())/invoice.pl?pdf=\(pdf)&id=\(id)"
            NavigateViewController.navigateToInvoice(from: self, withInvoiceURL: url)
            return true
        }
        
        
        route.addRoute("/attachment.pl") { dictionary in
            guard let urlString = dictionary["url"] as? String else {return false}
            let vc = ResolutionWebViewController(resolutionId:urlString)
            self.navigationController?.pushViewController(vc, animated: true)
            return true
        }
        
        route.addRoute(":scheme") { dictionary in
            guard let canGoBack = dictionary["back"] as? String else {return false}
            guard canGoBack == "1" else {return false}
            self.onRefreshRequested?()
            self.navigationController?.popViewController(animated: true)
            return true
        }

        guard stringUrl != nil else { return }
        self.loadWebWiewWithStringUrl(self.stringUrl)
    }
    
    fileprivate func reloadWebView(){
        guard let url = self.stringUrl else { return }
        self.loadWebWiewWithStringUrl(url)
    }
    
    fileprivate func loadWebWiewWithStringUrl(_ stringUrl:String!){

        let request = NSMutableURLRequest(authorizedHeader: URL(string: stringUrl)) as URLRequest
        webView.load(request)
        webView.navigationDelegate = self
        
        webView.bk_addObserver(forKeyPath: "estimatedProgress") { [unowned self] (view: Any?) in
            let webView = view as! WKWebView
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        progressView.isHidden = false
    }
    
    fileprivate func urlStringDetailWithResolutionId(_ resolutionId: String)->String{
        let auth = UserAuthentificationManager()
        let appVersion = UIApplication.getAppVersionString()
        let urlString = auth.webViewUrl(fromUrl: "\(NSString.mobileSiteUrl())/resolution-center.pl?action=detail&wv=2&id=\(resolutionId)&va=\(appVersion)")
        
        return urlString
    }
}

extension ResolutionWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                                                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard !route.routeURL(navigationAction.request.url) else {
            decisionHandler(.cancel)
            return
        }
        
        guard !(navigationAction.request.url!.absoluteString.contains("/resolution-center.pl?action=detail")) else {
            decisionHandler(.allow)
            return
        }
        
        if navigationAction.navigationType == .linkActivated {
            let vc = ResolutionWebViewController(stringUrl: navigationAction.request.url!.absoluteString)
            vc.onRefreshRequested = {
                self.reloadWebView()
            }
            self.navigationController?.pushViewController(vc, animated: true)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
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
    
    fileprivate func hideLoadingIndicators() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        progressView.isHidden = true
    }
}
