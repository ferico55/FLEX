//
//  WKWebViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 12/14/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import WebKit
import Popover

class WKWebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, NoResultDelegate {

    fileprivate var strTitle: String = ""
    fileprivate var urlString: String = ""
    fileprivate var shouldAuthorizeRequest: Bool = true
    fileprivate var webView: WKWebView!
    fileprivate var refreshControl: UIRefreshControl!
    fileprivate var urlRequest: URLRequest!
    fileprivate var progressView: UIProgressView!
    fileprivate var noInternetView: NoResultReusableView!
    
    fileprivate var popover     : WebviewPopover!
    fileprivate var zoomEnabled : Bool = true
    
    //intercept when user click on action here
    var didReceiveNavigationAction:((WKNavigationAction) -> Void)?
    var didTapBack:(() -> Void)?
    
    override func loadView() {
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = wkUController
        
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        
        if !self.zoomEnabled {
            webView.scrollView.delegate = self
        }
        
        view = webView
        initProgressView()
        
        popover = WebviewPopover(viewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(WKWebViewController.refreshWebView), for: UIControlEvents.valueChanged)
        webView.scrollView.addSubview(refreshControl)
        webView.navigationDelegate = self

        let emptyLeftButton = UIBarButtonItem(image: UIImage(named: "icon_arrow_white"), style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem = emptyLeftButton
        navigationItem.hidesBackButton = true

        initNoInternetView()
        loadWebView()
        
        //popover
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.make(controller: self, selector: #selector(WKWebViewController.tapPopover))
        
        // set title
        self.navigationItem.title = strTitle
    }
    
    func didTapBackButton() {
        if webView.canGoBack {
           webView.goBack()
           self.didTapBack?()
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    convenience init(urlString: String) {
        let authenticationManager = UserAuthentificationManager()
        
        let shouldAuthorizeRequest = authenticationManager.isLogin
        
        self.init(urlString: authenticationManager.webViewUrl(fromUrl: urlString), shouldAuthorizeRequest: shouldAuthorizeRequest)
    }
    
    convenience init(urlString: String, zoomEnabled: Bool) {
        let authenticationManager = UserAuthentificationManager()
        
        let shouldAuthorizeRequest = authenticationManager.isLogin
        
        self.init(urlString: authenticationManager.webViewUrl(fromUrl: urlString), shouldAuthorizeRequest: shouldAuthorizeRequest)
        self.zoomEnabled = zoomEnabled
    }
    
    convenience init(urlString: String, title: String) {
        let authenticationManager = UserAuthentificationManager()
        
        let shouldAuthorizeRequest = authenticationManager.isLogin
        
        self.init(urlString: authenticationManager.webViewUrl(fromUrl: urlString), shouldAuthorizeRequest: shouldAuthorizeRequest, title: title)
    }
    
    init(urlString: String, shouldAuthorizeRequest: Bool) {
        self.urlString = urlString
        self.shouldAuthorizeRequest = shouldAuthorizeRequest
        super.init(nibName: nil, bundle: nil)
    }
    
    init(urlString: String, shouldAuthorizeRequest: Bool, title: String) {
        self.urlString = urlString
        self.shouldAuthorizeRequest = shouldAuthorizeRequest
        self.strTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    fileprivate func loadWebView() {
        guard let myURL = URL(string: urlString) else { return }
        
        webView.load(requestForURL(myURL))
        
        webView.bk_addObserver(forKeyPath: "estimatedProgress") { [unowned self] (view: Any?) in
            let webView = view as! WKWebView

            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    fileprivate func requestForURL(_ url: URL) -> URLRequest {
        var request: NSMutableURLRequest
        if shouldAuthorizeRequest {
            request = NSMutableURLRequest(authorizedHeader: url)
        } else {
            request = NSMutableURLRequest()
            request.setValue("Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5", forHTTPHeaderField: "User-Agent")
            request.url = url
        }
        
        return request as URLRequest
    }
    
    fileprivate func initNoInternetView() {
        noInternetView = NoResultReusableView(frame: UIScreen.main.bounds)
        noInternetView.delegate = self
        noInternetView.generateAllElements("icon_no_data_grey.png", title: "Whoops!\nTidak ada koneksi Internet", desc: "Harap coba lagi", btnTitle: "Coba Kembali")
    }
    
    fileprivate func initProgressView() {
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.frame.size.width = self.view.bounds.size.width
        webView.addSubview(progressView);
        progressView.mas_makeConstraints { make in
            make?.top.right().left().equalTo()(self.view)
            make?.height.equalTo()(2)
        }
    }
    
    @objc fileprivate func refreshWebView() {
        initProgressView()
        progressView.isHidden = false
        guard let myURL = URL(string: urlString) else { return }
        
        webView.load(requestForURL(myURL))
        
        webView.bk_addObserver(forKeyPath: "estimatedProgress") { [unowned self] (view: Any?) in
            let webView = view as! WKWebView
            
            self.progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    //MARK: WKNavigation Delegate
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if(webView.canGoBack) {
            self.didReceiveNavigationAction?(navigationAction)
        }
        
        //hit _blank url
        if(navigationAction.targetFrame == nil) {
            webView.load(navigationAction.request)
        }
        
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        hideLoadingIndicators()
                
        let title = webView.title
        if let title = title, !title.isEmpty && strTitle.isEmpty {
            self.navigationItem.title = title
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if !noInternetView.isDescendant(of: webView) && (error as NSError).code == -1009 {
            webView.addSubview(noInternetView)
        }
        webView.load(URLRequest(url: URL(string: "about:blank")!))
        hideLoadingIndicators()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideLoadingIndicators()
    }
    
    fileprivate func hideLoadingIndicators() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        progressView.isHidden = true
        refreshControl.endRefreshing()
    }
        
    //MARK: No Result Delegate
    func buttonDidTapped(_ sender: Any!) {
        if noInternetView.isDescendant(of: webView) {
            noInternetView.removeFromSuperview()
        }
        refreshWebView()
    }
    
    //MARK: pop over
    func tapPopover() {
        if let navigationFrame = self.navigationController?.navigationBar.frame {
            self.popover.tapShow(coordinate: CGPoint(x: self.view.frame.size.width-26, y: navigationFrame.origin.y + 40))
        } else {
            self.popover.tapShow(coordinate: CGPoint(x: self.view.frame.size.width-26, y: 50))
        }
    }
}

// disable scrolling by overriding webview's scrollview's delegate zoom callback
extension WKWebViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}
