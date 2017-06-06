//
//  Product+WishlistNetworkManager.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift

@objc(ProductAndWishlistNetworkManager)
class ProductAndWishlistNetworkManager: NSObject {
    
    //TODO ganti nama method ini
    func requestSearchWith(params:[String:Any], andPath path:String, forUserID userID:String, withCompletionHandler completionHandler: @escaping(SearchProductWrapper) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        var outerResult:SearchProductWrapper?
        NetworkProvider<AceTarget>()
            .request(.searchProductWith(params: params, path: path))
            .map(to: SearchProductWrapper.self)
            .flatMap { searchResult -> Observable<SearchProductWrapper> in
                outerResult = searchResult
                var productIds:[String] = []
                for product in searchResult.data.products {
                    productIds.append(String(product.product_id))
                }
                if let catalogs = searchResult.data.catalogs {
                    for product in catalogs {
                        productIds.append(String(product.product_id))
                    }
                }
                
                return NetworkProvider<MojitoTarget>()
                    .request(.getProductWishStatus(userId: userID, productIds: productIds))
                    .map(to: ProductWishlistCheckResult.self)
                    .map { checkResult in
                        guard let ids = checkResult.ids else { return searchResult }
                        for id in ids {
                            for product in searchResult.data.products {
                                if String(product.product_id) == id {
                                    product.isOnWishlist = true
                                    break
                                }
                            }
                            if let catalogs = searchResult.data.catalogs {
                                for product in catalogs {
                                    if String(product.product_id) == id {
                                        product.isOnWishlist = true
                                        break
                                    }
                                }
                            }
                        }
                        return searchResult
                    }
            }
            .subscribe(onNext: { result in
                    completionHandler(result)
                }, onError: { [] error in
                    guard let searchResult = outerResult else { errorHandler(error); return }
                    completionHandler(searchResult)
            })
    }
    
    func requestIntermediaryCategory(forCategoryID:String, withUserID userID:String, withCompletionHandler completionHandler: @escaping(CategoryIntermediaryResponse) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        var outerResult:CategoryIntermediaryResponse?
        NetworkProvider<HadesTarget>()
            .request(.getCategoryIntermediary(forCategoryID: forCategoryID))
            .map(to: CategoryIntermediaryResponse.self)
            .flatMap { searchResult -> Observable<CategoryIntermediaryResponse> in
                outerResult = searchResult
                var productIds:[String] = []
                
                //guard let curatedProduct = searchResult.result.curatedProduct else { return Observable<CategoryIntermediaryCuratedProduct>(searchResult) }
                if let curatedProduct = searchResult.result.curatedProduct {
                    for section in curatedProduct.sections {
                        guard let products = section.products else { continue }
                        for product in products {
                            productIds.append(String(product.id))
                        }
                    }
                }
                else {
                    return Observable<CategoryIntermediaryResponse>.just(searchResult)
                }
                
                return NetworkProvider<MojitoTarget>()
                    .request(.getProductWishStatus(userId: userID, productIds: productIds))
                    .map(to: ProductWishlistCheckResult.self)
                    .map { checkResult in
                        guard let ids = checkResult.ids else { return searchResult }
                        for id in ids {
                            guard let curatedProduct = searchResult.result.curatedProduct else { continue }
                            for section in curatedProduct.sections {
                                guard let products = section.products else { continue }
                                for product in products {
                                    if String(product.id) == id {
                                        product.isOnWishlist = true
                                        break
                                    }
                                }
                            }
                        }
                        return searchResult
                    }
            }
            .subscribe(onNext: { result in
                completionHandler(result)
            }, onError: { [] error in
                guard let searchResult = outerResult else { errorHandler(error); return }
                completionHandler(searchResult)
            })
    }
    
    func checkWishlistStatusFor(products:[Any], forUserID userID:String, withCompletionHandler completionHandler: @escaping([Any]) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        var productIds:[String] = []
        
        for products in products {
            guard let products = products as? [SearchProduct] else { continue }
            for product in products {
                productIds.append(String(product.product_id))
            }
        }
        
        NetworkProvider<MojitoTarget>()
            .request(.getProductWishStatus(userId: userID, productIds: productIds))
            .map(to: ProductWishlistCheckResult.self)
            .subscribe(onNext: { checkResult in
                    guard let ids = checkResult.ids else { return}
                    for id in ids {
                        for products in products {
                            guard let products = products as? [SearchProduct] else { continue }
                            for product in products {
                                if String(product.product_id) == id {
                                    product.isOnWishlist = true
                                    break
                                }
                            }
                        }
                    }
                    completionHandler(products)
               },
               onError: { [] error in
                        errorHandler(error)
                }
        ).disposed(by: self.rx_disposeBag)
    }
    
    func checkWishlistStatusFor(intermediaryCategorySection:[CategoryIntermediaryCuratedProductSection], forUserID userID:String, withCompletionHandler completionHandler: @escaping([Any]) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        var productIds:[String] = []
        
        for section in intermediaryCategorySection {
            guard let products = section.products else { continue }
            for product in products {
                productIds.append(String(product.id))
            }
        }
        
        NetworkProvider<MojitoTarget>()
            .request(.getProductWishStatus(userId: userID, productIds: productIds))
            .map(to: ProductWishlistCheckResult.self)
            .subscribe(onNext: { checkResult in
                guard let ids = checkResult.ids else { return}
                for id in ids {
                    for section in intermediaryCategorySection {
                        guard let products = section.products else { continue }
                        for product in products {
                            if String(product.id) == id {
                                product.isOnWishlist = true
                                break
                            }

                        }
                    }
                }
                completionHandler(intermediaryCategorySection)
            },
                       onError: { [] error in
                        errorHandler(error)
            }
            ).disposed(by: self.rx_disposeBag)
    }
    
    func getProductFeedForPage(page:Int, withCompletionHandler complretionHandler:@escaping([Any]) -> Void, andErrorHandler errorHandler: @escaping(NSError) -> Void) {
        
    }
    
    //unused
    func setWishlistWith(productId:String, forUser userId:String, withCompletionHandler completionHandler: @escaping() -> Void, andErrorHandler errorHandler: @escaping() -> Void) {
        errorHandler()
        MojitoProvider()
            .request(.setWishlistFor(productId: productId, userId: userId))
            .subscribe(onNext: { _ in
                completionHandler()
            },
           onError: { _ in
                errorHandler()
            }
        ).disposed(by: self.rx_disposeBag)
    }
    
    //unused
    func unsetWishlistWith(productId:String, forUser userId:String, withCompletionHandler completionHandler: @escaping() -> Void, andErrorHandler errorHandler: @escaping() -> Void) {
        MojitoProvider()
            .request(.unsetWishlistFor(productId: productId, userId: userId))
            .subscribe(onNext: { _ in
                completionHandler()
            },
                       onError: { _ in
                        errorHandler()
            }
            ).disposed(by: self.rx_disposeBag)
    }
}
