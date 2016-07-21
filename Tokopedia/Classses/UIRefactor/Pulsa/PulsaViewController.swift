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
        let numberField = UITextField.init()
        numberField.placeholder = category.attributes.client_number.help
        numberField.borderStyle = .RoundedRect
        numberField.rightViewMode = .WhileEditing
        
        numberField.delegate = self
        
        let phoneText = UILabel.init(frame: CGRectMake(10, 44, self.view.frame.width - 10, 44))
        phoneText.text = category.attributes.client_number.text
        
        self.view.addSubview(numberField)
        self.view.addSubview(phoneText)
        
        numberField .mas_makeConstraints{ make in
            make.height.equalTo()(44)
            make.width.equalTo()(self.view)
            make.top.equalTo()(phoneText.mas_bottom)
        }
    }
    
    func didReceiveCategory(category : PulsaCategoryRoot) {
        self.pulsaCategoryControl.removeAllSegments()
        var i = 0;
        for category in category.data {
            self.pulsaCategoryControl.insertSegmentWithTitle(category.attributes.name, atIndex: i, animated: false)
            i += 1
        }
        self.pulsaCategoryControl.hidden = false
        self.pulsaCategoryControl.selectedSegmentIndex = 0
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK - UITextFieldDelegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let inputtedPrefix = textField.text! + string as String
        let characterCount = inputtedPrefix.characters.count - range.length
        
        if(characterCount == 4) {
            let prefix = self.prefixes[inputtedPrefix]
            if(prefix != nil) {
                let prefixImage = UIImageView.init(frame: CGRectMake(0, 0, 100, 50))
                prefixImage.setImageWithURL((NSURL.init(string: prefix!["image"]!)))
                textField.rightView = prefixImage
                
//                self.fetchProductsById(prefix["id"])
            } else {
                textField.rightView = nil
            }
        }
        
        if(characterCount < 4) {
            textField.rightView = nil
        }
        
        return true
    }
    
//    func fetchProductsById(id: String) -> PulsaProductRoot{
//        
//    }
    
    func loadProductFromNetwork() {
        let networkManager = TokopediaNetworkManager()
        networkManager .
            requestWithBaseUrl("https://pulsa-api.tokopedia.com",
                               path: "/v1/product/list",
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
    
    func didReceiveProduct(productRoot: PulsaProductRoot) {
        
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
