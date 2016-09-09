//
//  PulsaRequest.swift
//  Tokopedia
//
//  Created by Tonito Acen on 7/30/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class PulsaRequest: NSObject {
    var cache: PulsaCache = PulsaCache()
    
    var didReceiveCategory: (([PulsaCategory]) -> Void)!
    var didReceiveOperator: (([PulsaOperator]) -> Void)!
    var didReceiveProduct: ([PulsaProduct] -> Void)!
    
    override init() {
        
    }
    
    func requestCategory() {
        self.checkMaintenanceStatus { (status) in
            if(!status.attributes.is_maintenance) {
                self.cache.loadCategories { (cachedCategory) in
                    if(cachedCategory == nil) {
                        self.requestCategoryFromNetwork()
                    } else {
                        self.didReceiveCategory(cachedCategory!.data)
                    }
                }
            }
        }
        
    }
    
    private func requestCategoryFromNetwork() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isParameterNotEncrypted = true
        networkManager .
            requestWithBaseUrl(NSString.pulsaUrl(),
                               path: "/v1/category/list",
                               method: .GET,
                               parameter: ["device" : "ios"],
                               mapping: PulsaCategoryRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let category = mappingResult.dictionary()[""] as! PulsaCategoryRoot
                                self.didReceiveCategory(category.data)
                                self.cache .storeCategories(category)
                },
                               onFailure: { (errors) -> Void in
                                
            });
    }
    
    func requestOperator() {
        self.cache.loadOperators{ (cachedOperator) in
            if(cachedOperator == nil) {
                self.requestOperatorFromNetwork()
            } else {
                self.didReceiveOperator(cachedOperator!.data)
            }
        }
        
    }
    
    private func requestOperatorFromNetwork() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isParameterNotEncrypted = true
        networkManager .
            requestWithBaseUrl(NSString.pulsaUrl(),
                               path: "/v1/operator/list",
                               method: .GET,
                               parameter: ["device" : "ios"],
                               mapping: PulsaOperatorRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let operatorRoot = mappingResult.dictionary()[""] as! PulsaOperatorRoot
                                self.cache.storeOperators(operatorRoot)
                                self.didReceiveOperator(operatorRoot.data)
                },
                               onFailure: { (errors) -> Void in
                                
            });
    }
    
    func requestProduct(operatorId: String, categoryId: String) {
        self.requestProductFromNetwork(operatorId, categoryId: categoryId)
    }
    
    private func requestProductFromNetwork(operatorId: String, categoryId: String) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isParameterNotEncrypted = true
        networkManager .
            requestWithBaseUrl(NSString.pulsaUrl(),
                               path: "/v1/product/list",
                               method: .GET,
                               parameter: ["operator_id" : operatorId, "category_id" : categoryId, "device" : "ios"],
                               mapping: PulsaProductRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let productRoot = mappingResult.dictionary()[""] as! PulsaProductRoot
                                self.didReceiveProduct(productRoot.data)
                                
                },
                               onFailure: { (errors) -> Void in
                                
            });

    }
    
    private func checkMaintenanceStatus(didReceiveMaintenanceStatus: (PulsaStatus -> Void)!) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isParameterNotEncrypted = true
        networkManager .
            requestWithBaseUrl(NSString.pulsaUrl(),
                               path: "/v1/status",
                               method: .GET,
                               parameter: nil,
                               mapping: PulsaStatusRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let statusRoot = mappingResult.dictionary()[""] as! PulsaStatusRoot
                                didReceiveMaintenanceStatus(statusRoot.data)
                                
                                
                },
                               onFailure: { (errors) -> Void in
                                
            });
    }
}
