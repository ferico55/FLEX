//
//  PulsaViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation

@objc(PulsaViewController)

class PulsaViewController: UIViewController, LoginViewDelegate {
    var prefixes = Dictionary<String, Dictionary<String, String>>()

    var pulsaView = PulsaView!()
    var requestManager = PulsaRequest!()

    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestManager = PulsaRequest()
        requestManager.requestCategory()
        requestManager.didReceiveCategory = { [unowned self] categories in
            self.didReceiveCategory(categories)
        }
    }
    func didReceiveCategory(categories: [PulsaCategory]) {
        var activeCategories: [PulsaCategory] = []
        categories.enumerate().forEach { id, category in
            if(category.attributes.status == 1) {
                activeCategories.append(category)
            }
        }
        
        var sortedCategories = activeCategories
        sortedCategories.sortInPlace({
            $0.attributes.weight < $1.attributes.weight
        })
        
        self.pulsaView = PulsaView(categories: sortedCategories)
        self.pulsaView .attachToView(self.view2)
        self.pulsaView.didAskedForLogin = {
            let navigation = UINavigationController()
            navigation.navigationBar.backgroundColor = UIColor(red: (18.0/255.0), green: (199.0/255.0), blue: (0/255.0), alpha: 1)
            navigation.navigationBar.translucent = false
            navigation.navigationBar.tintColor = UIColor.whiteColor()
            
            let controller = LoginViewController()
            controller.isPresentedViewController = true
            controller.redirectViewController = self
            controller.delegate = self
            
            navigation.viewControllers = [controller]
            
            self.navigationController?.presentViewController(navigation, animated: true, completion: nil)
        }
        
        self.pulsaView.didSuccessPressBuy = { url in
            let controller = WebViewController()
            controller.strURL = url.absoluteString
            
            self.navigationController!.pushViewController(controller, animated: true)
        }
        
        self.requestManager.requestOperator()
        self.requestManager.didReceiveOperator = { operators in
            var sortedOperators = operators
            
            sortedOperators.sortInPlace({
                $0.attributes.weight < $1.attributes.weight
            })
            
            self.didReceiveOperator(sortedOperators)
        }
    }
    
    func didReceiveOperator(operators: [PulsaOperator]) {
        //mapping operator by prefix
        // {0812 : {"image" : "simpati.png", "id" : "1"}}
        for op in operators {
            for var prefix in op.attributes.prefix {
                var prefixDictionary = Dictionary<String, String>()
                prefixDictionary["image"] = op.attributes.image
                prefixDictionary["id"] = op.id
                
                //BOLT only had 3 chars prefix
                if(prefix.characters.count == 3) {
                    let range = 0...9
                    range.enumerate().forEach { index, element in
                        prefixes[prefix.stringByAppendingString(String(element))] = prefixDictionary
                    }
                } else {
                    prefixes[prefix] = prefixDictionary
                }
            }
        }
        
        if(prefixes.count > 0) {
            self.pulsaView.prefixes = self.prefixes    
        }
        
        self.pulsaView.addActionNumberField();
        self.pulsaView.didPrefixEntered = { [unowned self] operatorId, categoryId in
//            let debounced = Debouncer(delay: 1.0) {
                self.pulsaView.selectedOperator = self.findOperatorById(operatorId, operators: operators)
                
                self.requestManager.requestProduct(operatorId, categoryId: categoryId)
                self.requestManager.didReceiveProduct = { products in
                    self.didReceiveProduct(products)
                }
//            }
//            debounced.call()
        }
        
        self.pulsaView.didTapAddressbook = { [unowned self] contacts in
            let controller = AddressBookViewController()
            controller.contacts = contacts
            controller.didTapContact = { [unowned self] phoneNumber in
                var phoneNumber = phoneNumber
                phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch, range: nil)
                
                self.pulsaView.numberField.text = phoneNumber
                
                if(phoneNumber.characters.count >= 4) {
                    let prefix = phoneNumber.substringWithRange(Range<String.Index>(start: phoneNumber.startIndex.advancedBy(0), end: phoneNumber.startIndex.advancedBy(4)))
                    
                    self.pulsaView.setRightViewNumberField(prefix)
                }
            }
            
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    func didReceiveProduct(products: [PulsaProduct]) {
        if(products.count > 0) {
            self.pulsaView.showBuyButton(products)
            self.pulsaView.didTapProduct = { [unowned self] products in
                let controller = PulsaProductViewController()
                var activeProducts: [PulsaProduct] = []
                
                products.map { product in
//                    if(product.attributes.status == 1) {
                        activeProducts.append(product)
//                    }
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
                
                self.navigationController!.pushViewController(controller, animated: true)
            }
        }
    }
    
    func findOperatorById(id: String, operators: [PulsaOperator]) -> PulsaOperator{
        var foundOperator = PulsaOperator()
        operators.enumerate().forEach { index, op in
            if(op.id == id) {
                foundOperator = operators[index]
            }
        }
        
        return foundOperator
    }
    
    func redirectViewController(viewController: AnyObject!) {
        
    }
    
}
