//
//  Product+WishlistNetworkManager.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 5/15/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import NSObject_Rx

@objc(ProductAndWishlistNetworkManager)
class ProductAndWishlistNetworkManager: NSObject {
    static let PRODUCT_PER_PAGE = 12
    
    func requestSearchWith(params:[String:Any], andPath path:String, withCompletionHandler completionHandler: @escaping(SearchProductWrapper) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        var outerResult:SearchProductWrapper?
        NetworkProvider<AceTarget>()
            .request(.searchProductWith(params: params, path: path))
            .map(to: SearchProductWrapper.self)
            .flatMap { searchResult -> Observable<SearchProductWrapper> in
                outerResult = searchResult
                var productIds:[String] = []
                if let products = searchResult.data.products {
                    let ids:[String] = products.map { $0.product_id }
                    productIds.append(contentsOf: ids)
                }
                
                if let catalogs = searchResult.data.catalogs {
                    let catalogIds = catalogs.map { $0.product_id }
                    productIds.append(contentsOf: catalogIds)
                }
                
                let userManager = UserAuthentificationManager()
                if !userManager.isLogin {
                    return Observable<SearchProductWrapper>.just(searchResult)
                }
                
                return NetworkProvider<MojitoTarget>()
                    .request(.getProductWishStatus(productIds: productIds))
                    .map(to: ProductWishlistCheckResult.self)
                    .map { checkResult in
                        let _ = checkResult.ids.map {
                            let id = $0
                            if let products = searchResult.data.products {
                                let product = products.first { $0.product_id == id }
                                product?.isOnWishlist = true
                            }
                            if let catalogs = searchResult.data.catalogs {
                                let product = catalogs.first { $0.product_id == id }
                                product?.isOnWishlist = true
                            }
                        }
                        return searchResult
                }
            }.subscribe(onNext: { result in
                completionHandler(result)
            }, onError: { [] error in
                //ini masih ga bisa kalau search 'kaos'
                guard let searchResult = outerResult else { errorHandler(error); return }
                completionHandler(searchResult)
            }).disposed(by: self.rx_disposeBag)
    }
    
    func requestIntermediaryCategory(forCategoryID:String, withCompletionHandler completionHandler: @escaping(CategoryIntermediaryResult) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        var outerResult:CategoryIntermediaryResult?
        NetworkProvider<HadesTarget>()
            .request(.getCategoryIntermediary(forCategoryID: forCategoryID))
            .map(to: CategoryIntermediaryResult.self)
            .flatMap { searchResult -> Observable<CategoryIntermediaryResult> in
                outerResult = searchResult
                var productIds:[String] = []
                
                let userManager = UserAuthentificationManager()
                if !userManager.isLogin {
                    return Observable<CategoryIntermediaryResult>.just(searchResult)
                }
                
                if let curatedProduct = searchResult.curatedProduct {
                    guard let sections = curatedProduct.sections else { return Observable<CategoryIntermediaryResult>.just(searchResult) }
                    productIds = sections.reduce([]) { allIds, section in
                        return allIds + section.products.map { $0.id }
                    }
                }
                else {
                    return Observable<CategoryIntermediaryResult>.just(searchResult)
                }
                
                return NetworkProvider<MojitoTarget>()
                    .request(.getProductWishStatus(productIds: productIds))
                    .map(to: ProductWishlistCheckResult.self)
                    .map { checkResult in
                        let _ = checkResult.ids.map { id in
                            if let curatedProduct = searchResult.curatedProduct {
                                if let sections = curatedProduct.sections {
                                    let _ = sections.map { section in
                                        let product = section.products.first { $0.id == id }
                                        product?.isOnWishlist = true
                                    }
                                }
                            }
                        }
                        return searchResult
                }
            }.subscribe(onNext: { result in
                completionHandler(result)
            }, onError: { [] error in
                guard let searchResult = outerResult else { errorHandler(error); return }
                completionHandler(searchResult)
            }).disposed(by: self.rx_disposeBag)
    }
    
    func checkWishlistStatusFor(products:[[SearchProduct]], withCompletionHandler completionHandler: @escaping([[SearchProduct]]) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        
//        var productIds:[String] = []
        let productIds:[String] = products.reduce([]) { allIds, productList in
            return allIds + productList.map { $0.product_id }
        }
        
        NetworkProvider<MojitoTarget>()
            .request(.getProductWishStatus(productIds: productIds))
            .map(to: ProductWishlistCheckResult.self)
            .subscribe(onNext: { checkResult in
                let _ = checkResult.ids.map { id in
                    let _ = products.map { products in
                        let product = products.first { $0.product_id  == id }
                        product?.isOnWishlist = true
                    }
                }
                completionHandler(products)
            },
                       onError: { [] error in
                        errorHandler(error)
            }
            ).disposed(by: self.rx_disposeBag)
    }
    
    func checkWishlistStatusFor(intermediaryCategorySection:[CategoryIntermediaryCuratedProductSection], withCompletionHandler completionHandler: @escaping([Any]) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        let productIds:[String] = intermediaryCategorySection.reduce([]) { allIds, section in
            return allIds + section.products.map { $0.id }
        }
        
        NetworkProvider<MojitoTarget>()
            .request(.getProductWishStatus(productIds: productIds))
            .map(to: ProductWishlistCheckResult.self)
            .subscribe(onNext: { checkResult in
                for id in checkResult.ids {
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
    
    func requestProductShop(shopID:String,
                            etalaseID:String,
                            keyword:String,
                            page:Int,
                            orderBy:ListOption,
                            shopDomain:String,
                            isAce: Bool,
                            withCompletionHandler completionHandler: @escaping(ShopProductPageResult) -> Void,
                            andErrorHandler errorHandler: @escaping(Error) -> Void) {
        var outerResult:ShopProductPageResult?
        let params = [
            "shop_id": shopID,
            "etalase_id":etalaseID,
            "keyword": keyword,
            "page": page,
            "per_page": ProductAndWishlistNetworkManager.PRODUCT_PER_PAGE,
            orderBy.key: orderBy.value ?? "",
            "shop_domain":shopDomain
            ] as [String : Any]
        
        NetworkProvider<V4Target>()
            .request(.getProductsForShop(parameters: params, isAce: isAce))
            .map(to: ShopProductPageResult.self)
            .flatMap({ searchResult -> Observable<ShopProductPageResult> in
                outerResult = searchResult
                let productIds = searchResult.list.map { $0.product_id }
                let query = productIds.joined(separator: ",")
                
                return NetworkProvider<MojitoTarget>()
                    .request(.getProductCampaignInfo(withProductIds: query))
                    .map(to: ShopProductPageCampaignInfoResponse.self)
                    .map { result in
                        for info in result.data {
                            let product = searchResult.list.first { $0.product_id == info.product_id }
                            product?.original_price = info.original_price
                            product?.percentage_amount = info.percentage_amount
                            product?.end_date = info.end_date
                        }
                        return searchResult
                }
            })
            .subscribe(onNext: { result in
                completionHandler(result)
            }, onError: { [] error in
                guard let searchResult = outerResult else { errorHandler(error); return }
                completionHandler(searchResult)
            })
            .disposed(by: self.rx_disposeBag)
    }
    
    func requestFeaturedProduct(shopID: String,
                                withCompletionHandler completionHandler: @escaping([FeaturedProduct]) -> Void,
                                andErrorHandler errorHandler: @escaping(Error) -> Void) {
        NetworkProvider<GoldMerchantTarget>()
            .request(.getFeaturedProduct(withShopID: shopID))
            .map(to: [FeaturedProduct.self], fromKey: "data")
            .subscribe(onNext: { result in
                completionHandler(result)
            }, onError: { [] error in
                errorHandler(error);
            })
            .disposed(by: self.rx_disposeBag)
    }
}
