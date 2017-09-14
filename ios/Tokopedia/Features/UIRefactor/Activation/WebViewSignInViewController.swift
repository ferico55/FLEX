//
//  WebViewSignInViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 6/29/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import BlocksKit
import SPTPersistentCache

@objc(WebViewSignInViewController)
class WebViewSignInViewController: UIViewController, UIWebViewDelegate, NJKWebViewProgressDelegate {

    fileprivate let provider: SignInProvider
    
    var onReceiveToken: ((String) -> Void)?

    @IBOutlet var progressView: NJKWebViewProgressView!

    @IBOutlet fileprivate var webView: UIWebView! {
        didSet {
            webView.delegate = progress
        }
    }

    lazy var progress: NJKWebViewProgress! = {
        let progress = NJKWebViewProgress()
        progress.webViewProxyDelegate = self
        progress.progressDelegate = self
        return progress
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("use init(url) instead")
    }
    
    required init(provider: SignInProvider) {
        self.provider = provider
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let request = NSMutableURLRequest()
        request.setValue("Mozilla/5.0 (iPod; U; CPU iPhone OS 4_3_3 like Mac OS X; ja-jp) AppleWebKit/533.17.9 (KHTML, like Gecko) Version/5.0.2 Mobile/8J2 Safari/6533.18.5", forHTTPHeaderField: "User-Agent")
        request.url = URL(string: provider.signInUrl + "?os_type=2")

        webView.loadRequest(request as URLRequest)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setWhite()
    }
    
    func webViewProgress(_ webViewProgress: NJKWebViewProgress, updateProgress progress: Float) {
        progressView.setProgress(progress, animated: true)
    }

    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let path = request.mainDocumentURL!.path
        let url = request.mainDocumentURL! as NSURL
        self.navigationItem.title = "Masuk dengan \(provider.name)"

        if path == "/mappauth/code" {
            URLSession.shared.reset() {}
            
            let code = url.parameters()["code"] as! String
            self.onReceiveToken?(code)
            navigationController?.popViewController(animated: true)
            return false
        }
        
        if path == "/wv/activation-social" {
            URLSession.shared.reset() {}
            
            let message = (url.parameters()["message"] as! String).removingPercentEncoding!
            
            let alertView = UIAlertView.bk_alertView(withTitle: "Perhatian", message: message) as! UIAlertView
            alertView.bk_addButton(withTitle: "OK", handler: {[unowned self] in
                self.navigationController?.popViewController(animated: true)
            })
            
            alertView.show()
            return false
        }
        
        if path.contains("/error") {
            URLSession.shared.reset() {}
            
            let message = (url.parameters()["message"] as! String).removingPercentEncoding!
            
            let alertView = UIAlertView.bk_alertView(withTitle: "Perhatian", message: message) as! UIAlertView
            alertView.bk_addButton(withTitle: "OK", handler: {[unowned self] in
                self.navigationController?.popViewController(animated: true)
                })
            
            alertView.show()
            
            return false
        }

        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
