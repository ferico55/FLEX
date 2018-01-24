//
//  RCTPulsaView.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 09/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import React
import JLPermissions

class RCTPulsaView: PulsaView {
    
    private var pulsaNavigator: PulsaNavigator!
    public var onLoadingFinished: RCTBubblingEventBlock?
    
    public func requestCategory() {
        self.pulsaNavigator = PulsaNavigator()
        self.pulsaNavigator.pulsaView = self
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
        let topMostViewController = rootViewController?.topMostViewController()
        self.pulsaNavigator.controller = topMostViewController
        self.navigator = self.pulsaNavigator
        
        self.onConsraintChanged = { [weak self] in
            guard let `self` = self else { return }
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
        
        let requestManager = PulsaRequest()
        requestManager.didReceiveCategory = { [weak self] categories in
            guard let `self` = self else { return }
            
            if let callback = self.onLoadingFinished {
                callback(nil)
            }
            self.setCategories(categories: categories)
            
            self.didAskedForLogin = { [unowned self] in
                self.pulsaNavigator.navigateToLoginIfRequired()
            }
            
            self.didTapProduct = { [unowned self] products in
                self.pulsaNavigator.navigateToPulsaProduct(products, selectedOperator: self.selectedOperator)
            }
            
            self.didTapOperator = { [unowned self] operators in
                self.pulsaNavigator.navigateToPulsaOperator(operators)
            }
            
            self.didTapSeeAll = { [unowned self] in
                self.pulsaNavigator.navigateToDigitalCategories()
            }
            
            self.didSuccessPressBuy = { [unowned self] url in
                self.pulsaNavigator.navigateToWKWebView(url)
            }
            
            self.didTapAddressbook = { [unowned self] in
                AnalyticsManager.trackEventName("clickPulsa", category: GA_EVENT_CATEGORY_PULSA, action: GA_EVENT_ACTION_CLICK, label: "Click Phonebook Icon")
                self.pulsaNavigator.navigateToAddressBook()
            }
            
            self.didShowAlertPermission = {
                let alert = UIAlertController(title: "", message: "Aplikasi Tokopedia tidak dapat mengakses kontak kamu. Aktifkan terlebih dahulu di menu : Settings -> Privacy -> Contacts", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Aktifkan", style: .default, handler: { action in
                    switch action.style {
                    case .default:
                        JLContactsPermission.sharedInstance().displayAppSystemSettings()
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                    }
                }))
                let rootViewController = UIApplication.shared.keyWindow?.rootViewController
                let topMostViewController = rootViewController?.topMostViewController()
                topMostViewController?.present(alert, animated: true, completion: nil)
            }
        }
        requestManager.didNotSuccessReceiveCategory = {
        }
        
        requestManager.requestCategory()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in self.subviews {
            view.reactSetFrame(self.bounds)
        }
    }
}
