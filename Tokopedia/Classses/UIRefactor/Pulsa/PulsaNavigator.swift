//
//  PulsaNavigator.swift
//  Tokopedia
//
//  Created by Tonito Acen on 8/8/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation

class PulsaNavigator: NSObject {
    var controller: UIViewController!
    var loginDelegate: LoginViewDelegate?
    var pulsaView: PulsaView!
    
    override init() {
        super.init()
        
    }
    
    func navigateToAddressBook(contacts: [APContact]) {
        let controller = AddressBookViewController()
        controller.contacts = contacts
        controller.didTapContact = { [unowned self] contact in
            var phoneNumber = contact
            phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch, range: nil)
            
            //replace 2 first characters if 62 with 0
            if(phoneNumber.characters.count >= 2) {
                let firstTwoCharacter = phoneNumber.substringWithRange(phoneNumber.startIndex.advancedBy(0) ..< phoneNumber.startIndex.advancedBy(2))
                if(firstTwoCharacter == "62") {
                    phoneNumber = phoneNumber.stringByReplacingCharactersInRange(phoneNumber.startIndex ..< phoneNumber.startIndex.advancedBy(2), withString: "0")
                }
            }
            
            self.pulsaView.numberField.text = phoneNumber
            
            if(phoneNumber.characters.count >= 4) {
                let prefix = phoneNumber.substringWithRange(phoneNumber.startIndex.advancedBy(0) ..< phoneNumber.startIndex.advancedBy(4))
                
                self.pulsaView.checkInputtedNumber()
            }
        }
        
        controller.hidesBottomBarWhenPushed = true
        self.controller.navigationController!.pushViewController(controller, animated: true)
    }
    
    func navigateToPulsaProduct(products: [PulsaProduct]) {
        let controller = PulsaProductViewController()
        var activeProducts: [PulsaProduct] = []
        
        products.map { product in
            activeProducts.append(product)
        }
        
        activeProducts.sortInPlace({
            $0.attributes.weight < $1.attributes.weight
        })
        
        controller.products = activeProducts
        controller.didSelectProduct = { [unowned self] product in
            self.pulsaView.selectedProduct = product
            self.pulsaView.hideErrors()
            self.pulsaView.productButton.setTitle(product.attributes.desc, forState: .Normal)
        }
        
        controller.hidesBottomBarWhenPushed = true
        self.controller.navigationController!.pushViewController(controller, animated: true)
    }
    
    func navigateToLoginIfRequired() {
        let navigation = UINavigationController()
        navigation.navigationBar.backgroundColor = UIColor(red: (18.0/255.0), green: (199.0/255.0), blue: (0/255.0), alpha: 1)
        navigation.navigationBar.translucent = false
        navigation.navigationBar.tintColor = UIColor.whiteColor()
        
        let controller = LoginViewController()
        controller.isPresentedViewController = true
        controller.redirectViewController = self.controller
        controller.delegate = self.loginDelegate
        
        navigation.viewControllers = [controller]
        
        self.controller.navigationController!.presentViewController(navigation, animated: true, completion: nil)
    }
    
    func navigateToSuccess(url: NSURL) {
        let controller = WebViewController()
        controller.strURL = url.absoluteString
        
        self.controller.navigationController!.pushViewController(controller, animated: true)
    }
    
    func navigateToWebTicker(url: NSURL) {
        let controller = WebViewController()
        controller.strURL = url.absoluteString
        controller.strTitle = ""
        controller.onTapLinkWithUrl = {[weak self] (url) in
            if url.absoluteString == "https://www.tokopedia.com/" {
                self!.controller.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        self.controller.navigationController?.pushViewController(controller, animated: true)
    }
}
