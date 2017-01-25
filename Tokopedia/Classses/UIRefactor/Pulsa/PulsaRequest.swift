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
    var didNotSuccessReceiveCategory: (() -> Void)!
    
    override init() {
        
    }
    
    func requestCategory() {
        self.checkMaintenanceStatus(didReceiveMaintenanceStatus: { (status) in
            if(!status.attributes.is_maintenance) {
                self.cache.loadCategories { (cachedCategory) in
                    if(cachedCategory == nil) {
                        self.requestCategoryFromNetwork()
                    } else {
                        self.didReceiveCategory(cachedCategory!.data)
                    }
                }
            } else {
                self.didNotSuccessReceiveCategory()
            }
        }, onFailure: {
            self.didNotSuccessReceiveCategory()
        })
    }
    
    private func requestCategoryFromNetwork() {
        let networkManager = TokopediaNetworkManager()
        networkManager.isParameterNotEncrypted = true
        networkManager .
            requestWithBaseUrl(NSString.pulsaApiUrl(),
                               path: "/v1.1/category/list",
                               method: .GET,
                               parameter: nil,
                               mapping: PulsaCategoryRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let category = mappingResult.dictionary()[""] as! PulsaCategoryRoot
                                self.didReceiveCategory(category.data)
                                self.cache .storeCategories(category)
                },
                               onFailure: { (errors) -> Void in
                                self.didNotSuccessReceiveCategory()
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
            requestWithBaseUrl(NSString.pulsaApiUrl(),
                               path: "/v1.1/operator/list",
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
        self.cache.loadProducts{ (cachedProduct) in
            if(cachedProduct == nil) {
                self.requestProductFromNetwork(operatorId,  categoryId: categoryId)
            } else {
                let products = self.filterProductBy(cachedProduct!.data, operatorId: operatorId, categoryId: categoryId)
                self.didReceiveProduct(products)
            }
        }
    }
    
    private func requestProductFromNetwork(operatorId: String, categoryId: String) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isParameterNotEncrypted = true
        networkManager .
            requestWithBaseUrl(NSString.pulsaApiUrl(),
                               path: "/v1.1/product/list",
                               method: .GET,
                               parameter: ["device" : "ios"],
                               mapping: PulsaProductRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let productRoot = mappingResult.dictionary()[""] as! PulsaProductRoot
                                self.cache.storeProducts(productRoot)
                                
                                var products = [PulsaProduct]()
                                if(categoryId != "" || operatorId != "") {
                                    products = self.filterProductBy(productRoot.data, operatorId: operatorId, categoryId: categoryId)
                                } else {
                                    products = productRoot.data
                                }
                                
                                self.didReceiveProduct(products)
                                
                },
                               onFailure: { (errors) -> Void in
                                
            });

    }
    
    private func filterProductBy(products: [PulsaProduct], operatorId: String, categoryId: String) -> [PulsaProduct] {
        let filteredProducts = products.filter({ (product) -> Bool in
            categoryId != "" ? product.relationships.relationCategory.data.id == categoryId : true
        }).filter({ (product) -> Bool in
            operatorId != "" ? product.relationships.relationOperator.data.id == operatorId : true
        })
        
        return filteredProducts
    }
    
    private func checkMaintenanceStatus(didReceiveMaintenanceStatus didReceiveMaintenanceStatus: (PulsaStatus -> Void)!, onFailure: (() -> Void)!) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isParameterNotEncrypted = true
        networkManager .
            requestWithBaseUrl(NSString.pulsaApiUrl(),
                               path: "/v1/status",
                               method: .GET,
                               parameter: nil,
                               mapping: PulsaStatusRoot.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let statusRoot = mappingResult.dictionary()[""] as! PulsaStatusRoot
                                didReceiveMaintenanceStatus(statusRoot.data)
                                
                                
                },
                               onFailure: { (errors) -> Void in
                                onFailure()
            });
    }
}
