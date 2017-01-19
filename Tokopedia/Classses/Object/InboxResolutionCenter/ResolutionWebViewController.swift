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
    
    private var stringUrl : String?
    private var route = JLRoutes()
    private var webView : WKWebView = {
        
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: WKUserScriptInjectionTime.AtDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController
        
        return WKWebView(frame: CGRectZero, configuration: wkWebConfig)
    }()
    
    private let progressView : UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .Bar)
        progressView.progressTintColor = UIColor(red:0.071, green:0.780, blue:0, alpha:1)
        return progressView
    }()
    
    private var onRefreshRequested : (()->Void)?
    
    private init(stringUrl:String) {
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
        
        let backButton = UIBarButtonItem(title: "", style: .Plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backButton
        
        self.view.addSubview(webView)
        webView.mas_makeConstraints { make in
            make.edges.equalTo()(self.view)
        }
        
        webView.addSubview(progressView)
        progressView.mas_makeConstraints { make in
            make.top.right().left().equalTo()(self.view)
            make.height.equalTo()(2)
        }
        
        route.addRoute("/invoice.pl") { dictionary in
            guard let pdf = dictionary["pdf"] as? String else {return false}
            guard let id = dictionary["id"] as? String else {return false}
            let url = "\(NSString.tokopediaUrl())/invoice.pl?pdf=\(pdf)&id=\(id)"
            NavigateViewController.navigateToInvoiceFromViewController(self, withInvoiceURL: url)
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
            self.navigationController?.popViewControllerAnimated(true)
            return true
        }

        guard stringUrl != nil else { return }
        self.loadWebWiewWithStringUrl(self.stringUrl)
    }
    
    private func reloadWebView(){
        guard let url = self.stringUrl else { return }
        self.loadWebWiewWithStringUrl(url)
    }
    
    private func loadWebWiewWithStringUrl(stringUrl:String!){

        let request = NSMutableURLRequest(authorizedHeader: NSURL(string: stringUrl))
        webView.loadRequest(request)
        webView.navigationDelegate = self
        webView.bk_addObserverForKeyPath("estimatedProgress") { [unowned self] view in
            let webView = view as! WKWebView
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        progressView.hidden = false
    }
    
    private func urlStringDetailWithResolutionId(resolutionId: String)->String{
        let auth = UserAuthentificationManager()
        let appVersion = UIApplication.getAppVersionString()
        let urlString = auth.webViewUrlFromUrl("\(NSString.mobileSiteUrl())/resolution-center.pl?action=detail&wv=2&id=\(resolutionId)&va=\(appVersion)")
        
        return urlString
    }
}

extension ResolutionWebViewController: WKNavigationDelegate {
    func webView(webView: WKWebView,
                 decidePolicyForNavigationAction navigationAction: WKNavigationAction,
                                                 decisionHandler: (WKNavigationActionPolicy) -> Void) {
        
        guard !route.routeURL(navigationAction.request.URL) else {
            decisionHandler(.Cancel)
            return
        }
        
        guard !(navigationAction.request.URL!.absoluteString!.containsString("/resolution-center.pl?action=detail")) else {
            decisionHandler(.Allow)
            return
        }
        
        if navigationAction.navigationType == .LinkActivated {
            let vc = ResolutionWebViewController(stringUrl: navigationAction.request.URL!.absoluteString!)
            vc.onRefreshRequested = {
                self.reloadWebView()
            }
            self.navigationController?.pushViewController(vc, animated: true)
            decisionHandler(.Cancel)
        } else {
            decisionHandler(.Allow)
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
