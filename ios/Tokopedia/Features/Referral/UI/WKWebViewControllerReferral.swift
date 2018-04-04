//
//  WKWebViewControllerReferral.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 06/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import WebKit
internal class WKWebViewControllerReferral: WKWebViewController {
    override internal func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        if let isReferral = webView.url?.absoluteString.hasPrefix("tokopedia://referral"), isReferral == true {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
