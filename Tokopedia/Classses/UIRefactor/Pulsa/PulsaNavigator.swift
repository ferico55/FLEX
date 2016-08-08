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
            var phoneNumber = (contact.phones?.first?.number)!
            phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch, range: nil)
            
            self.pulsaView.numberField.text = phoneNumber
            
            if(phoneNumber.characters.count >= 4) {
                let prefix = phoneNumber.substringWithRange(Range<String.Index>(start: phoneNumber.startIndex.advancedBy(0), end: phoneNumber.startIndex.advancedBy(4)))
                
                self.pulsaView.setRightViewNumberField(prefix)
            }
        }
        
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
        controller.strTitle = "Mengarahkan..."
        controller.onTapLinkWithUrl = {[weak self] (url) in
            if url.absoluteString == "https://www.tokopedia.com/" {
                self!.controller.navigationController?.popViewControllerAnimated(true)
            }
        }
        
        self.controller.navigationController?.pushViewController(controller, animated: true)
    }
}
