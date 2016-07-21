//
//  PulsaViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/4/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation

@objc
class PulsaViewController: UIViewController, UITextFieldDelegate {
    var cache: PulsaCache = PulsaCache()
    var prefixes = Dictionary<String, Dictionary<String, String>>()
    var stackView = StackView!()

    @IBOutlet weak var pulsaCategoryControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pulsaCategoryControl.hidden = true
        self.pulsaCategoryControl .addTarget(self, action: #selector(didSelectSegmentControl), forControlEvents: .ValueChanged)
        
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
    

    func didSelectSegmentControl(sender : UISegmentedControl) {
        self.cache.loadCategories { (cachedCategory) in
            if(cachedCategory != nil) {
                let category = cachedCategory?.data[sender.selectedSegmentIndex]
                let shouldShowNumberField = category?.attributes.client_number.is_shown
                if((shouldShowNumberField) != nil) {
                    self.buildNumberField(category!)
                }
            }
        }
    }
    
    func buildNumberField(category: PulsaCategory) {
        if(stackView != nil) {
            self.stackView.removeFromSuperview()
        }
        
        let stackViewFrame = CGRectMake(view.frame.origin.x, 44, view.frame.size.width, view.frame.size.height)
        stackView = StackView.init(axis: .vertical, spacing: 4)
        stackView.frame = stackViewFrame
        stackView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        self.view .addSubview(stackView)
        
        let helloView = PulsaLayout(category: category, prefixes: self.prefixes, callback: { (prefix) -> Void in
            self.loadProductFromNetwork()
            
        }).arrangement().makeViews()
        
        self.stackView .addArrangedSubviews([helloView])
    }
    
    func didReceiveCategory(category : PulsaCategoryRoot) {
        self.pulsaCategoryControl.removeAllSegments()
        var i = 0;
        for category in category.data {
            self.pulsaCategoryControl.insertSegmentWithTitle(category.attributes.name, atIndex: i, animated: false)
            i += 1
        }
        
        self.buildNumberField(category.data[0])
        self.pulsaCategoryControl.hidden = false
        self.pulsaCategoryControl.selectedSegmentIndex = 0

    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
//    func fetchProductsById(id: String) -> PulsaProductRoot{
//        
//    }
    
    func loadProductFromNetwork() {
        let networkManager = TokopediaNetworkManager()
        networkManager .
            requestWithBaseUrl("http://private-c3816-digitalcategory.apiary-mock.com",
                               path: "/products",
                               method: .GET,
                               parameter: nil,
                               mapping: PulsaProductRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let productRoot = mappingResult.dictionary()[""] as! PulsaProductRoot
                                self.didReceiveProduct(productRoot)
                                
                },
                               onFailure: { (errors) -> Void in
                                
            });
    }
    
    func didReceiveProduct(productRoot: PulsaProductRoot) {
        let chooseProductButton = UIButton(frame: CGRectMake(0, 0, self.view.frame.size.width - 10, 44))
        chooseProductButton.backgroundColor = UIColor.darkGrayColor()
        chooseProductButton.setTitle("Pilih Nominal", forState: .Normal)
        chooseProductButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        let buyButton = UIButton(frame: CGRectMake(0, 0, self.view.frame.size.width - 10, 44))
        buyButton.backgroundColor = UIColor.orangeColor()
        buyButton.setTitle("Beli", forState: .Normal)
        buyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        let stackButton = StackView.init(axis: .horizontal, spacing: 10, distribution: .fillEqualSize, contentInsets: UIEdgeInsetsMake(10, 10, 10, 10))
        stackButton.addArrangedSubviews([chooseProductButton, buyButton])
        
        stackView.addArrangedSubviews([stackButton])
        
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
    }
    

}
