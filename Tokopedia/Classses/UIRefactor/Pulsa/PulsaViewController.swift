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

class PulsaViewController: UIViewController, UITextFieldDelegate {
    var cache: PulsaCache = PulsaCache()
    var prefixes = Dictionary<String, Dictionary<String, String>>()

    var pulsaView = PulsaView!()
    var requestManager = PulsaRequest!()

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var container: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        requestManager = PulsaRequest()
        requestManager.requestCategory()
        requestManager.didReceiveCategory = { [unowned self] categories in
            self.pulsaView = PulsaView(categories: categories)
            self.pulsaView .attachToView(self.view2)
            
            self.requestManager.requestOperator()
            self.requestManager.didReceiveOperator = { operators in
                self.didReceiveOperator(operators)
            }
        }
    }
    
    func didReceiveOperator(operators: [PulsaOperator]) {
        for op in operators {
            for prefix in op.attributes.prefix {
                var prefixDictionary = Dictionary<String, String>()
                prefixDictionary["image"] = op.attributes.image
                prefixDictionary["id"] = op.id
                
                prefixes[prefix] = prefixDictionary
            }
        }
        
        if(prefixes.count > 0) {
            self.pulsaView.prefixes = self.prefixes    
        }
        
        self.pulsaView.didOperatorReceived();
        self.pulsaView.didPrefixEntered = { [unowned self] operatorId in
            self.pulsaView.selectedOperator = self.findOperatorById(operatorId, operators: operators)
            self.requestManager.requestProduct(operatorId)
            self.requestManager.didReceiveProduct = { products in
                self.pulsaView.showBuyButton(products)
            }
        }
        
        self.pulsaView.didTapAddressbook = { [unowned self] contacts in
            let controller = AddressBookViewController()
            controller.contacts = contacts
            controller.didTapContact = { [unowned self] contact in
                var phoneNumber = (contact.phones?.first?.number)!
                phoneNumber = phoneNumber.stringByReplacingOccurrencesOfString("[^0-9]", withString: "", options: .RegularExpressionSearch, range: nil)
                
                self.pulsaView.numberField.text = phoneNumber
            }
            
            self.navigationController!.pushViewController(controller, animated: true)
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
}
