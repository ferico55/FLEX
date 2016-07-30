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

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    @IBOutlet weak var container: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.cache.loadCategories { (cachedCategory) in
            if(cachedCategory == nil) {
                self.loadCategoryFromNetwork()
            } else {
                self.didReceiveCategory(cachedCategory!)
            }
        }
        
        self.loadOperatorFromNetwork()
        
    }
    
    func loadCategoryFromNetwork() {
        let networkManager = TokopediaNetworkManager()
        networkManager .
            requestWithBaseUrl("https://pulsa-api.tokopedia.com",
                               path: "/v1/category/list",
                               method: .GET,
                               parameter: nil,
                               mapping: PulsaCategoryRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let category = mappingResult.dictionary()[""] as! PulsaCategoryRoot
                                self.cache .storeCategories(category)
                                self .didReceiveCategory(category)
                },
                               onFailure: { (errors) -> Void in
                                
            });
    }
    
    func didReceiveCategory(category : PulsaCategoryRoot) {
        self.pulsaView = PulsaView(categories: category.data)
        self.pulsaView .attachToView(self.view2)
    }
    
    func loadProductFromNetwork(operatorId: String) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isParameterNotEncrypted = true
        networkManager .
            requestWithBaseUrl("https://pulsa-api.tokopedia.com",
                               path: "/v1/product/list",
                               method: .GET,
                               parameter: ["operator_id" : operatorId],
                               mapping: PulsaProductRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let productRoot = mappingResult.dictionary()[""] as! PulsaProductRoot
                                self.didReceiveProduct(productRoot)
                                
                },
                               onFailure: { (errors) -> Void in
                                
            });
    }
    
    func didReceiveProduct(productRoot: PulsaProductRoot) {
        self.pulsaView.showBuyButton(productRoot.data)
    }
    
    
    func loadOperatorFromNetwork() {
        let networkManager = TokopediaNetworkManager()
        networkManager .
            requestWithBaseUrl("https://pulsa-api.tokopedia.com",
                               path: "/v1/operator/list",
                               method: .GET,
                               parameter: nil,
                               mapping: PulsaOperatorRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let operatorRoot = mappingResult.dictionary()[""] as! PulsaOperatorRoot
                                self.didReceiveOperator(operatorRoot)
                                
                },
                               onFailure: { (errors) -> Void in
                                
            });
    }
    
    func didReceiveOperator(operatorRoot: PulsaOperatorRoot) {
        for op in operatorRoot.data {
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
        
        self.pulsaView.onPrefixEntered = { (operatorId) -> Void in
            self.pulsaView.selectedOperator = self.findOperatorById(operatorId, operators: operatorRoot.data)
            self.loadProductFromNetwork(operatorId)
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
