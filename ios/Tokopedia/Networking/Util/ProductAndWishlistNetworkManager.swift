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
internal class ProductAndWishlistNetworkManager: NSObject {
    internal static let productPerPage = 12
    
    internal func requestSearchWith(params:[String:Any], andPath path:String, withCompletionHandler completionHandler: @escaping(SearchProductWrapper) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        var outerResult:SearchProductWrapper?
        AceProvider()
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
            })
    }
    
    internal func requestIntermediaryCategory(forCategoryID:String,
                                              trackerObject:ProductTracker,
                                              withCompletionHandler completionHandler: @escaping(CategoryIntermediaryResult) -> Void,
                                              andErrorHandler errorHandler: @escaping(Error) -> Void) {
        var outerResult:CategoryIntermediaryResult?
        NetworkProvider<HadesTarget>()
            .request(.getCategoryIntermediary(forCategoryID: forCategoryID))
            .map(to: CategoryIntermediaryResult.self)
            .flatMap { searchResult -> Observable<CategoryIntermediaryResult> in
                outerResult = searchResult
                var productIds:[String] = []
                
                if let curatedSections = searchResult.curatedProduct?.sections {
                    let attribution = trackerObject.trackerAttribution
                    for (sectionIndex, section) in curatedSections.enumerated() {
                        var productArray: [[String: Any]] = []
                        for (productIndex, product) in section.products.enumerated() {
                            if productIndex < 4 {
                                let strippedPrice = product.price.replacingOccurrences( of:"[^0-9]", with: "", options: .regularExpression)
                                productArray.append([
                                    "id": "\(product.id)",
                                    "name": "\(product.name)",
                                    "price": "\(strippedPrice)",
                                    "brand": "none/other",
                                    "category": "none/other",
                                    "variant": "none/other",
                                    "position": "\(productIndex+1)",
                                    "list": "/intermediary/\(searchResult.name) - product \(sectionIndex+1) - \(section.title)",
                                    "dimension37": "\(attribution)"
                                    ])
                            }
                        }
                        
                        let trackerDict: [String : Any] = [
                            "event": "productView",
                            "eventCategory" : "intermediary page",
                            "eventAction" : "product curation impression",
                            "eventLabel" : "",
                            "ecommerce": [
                                "currencyCode": "IDR",
                                "impressions": productArray
                            ]
                        ]
                        
                        AnalyticsManager.trackData(trackerDict)
                    }
                }
                
                if let children = searchResult.children, children.count > 0 {
                    let promoNumber = searchResult.isIntermediary ? 2 : 1
                    let eventCategory = searchResult.isIntermediary ? "intermediary page" : "category page"
                    
                    let promotionArray: [[String: Any]] = children.enumerated().map({ (index, child) in
                        let name = searchResult.isIntermediary ?
                            "/intermediary/\(searchResult.name) - promo \(promoNumber) - subcategory"
                            : "/category/\(searchResult.name) - promo \(promoNumber)"
                        
                        return [
                            "id": "\(child.id)",
                            "name": "\(name)",
                            "position": "\(index+1)",
                            "creative": "\(child.name)",
                            "creative_url": "\(child.thumbnailImage ?? "")",
                        ]
                    })
                    
                    let trackerDict: [String : Any] = [
                        "event": "promoView",
                        "eventCategory" : "\(eventCategory)",
                        "eventAction" : "subcategory impression",
                        "eventLabel" : "",
                        "ecommerce": [
                            "promoView": [
                                "promotions": promotionArray
                            ]
                        ]
                    ]
                    
                    AnalyticsManager.trackData(trackerDict)
                }
                
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
    
    internal func checkWishlistStatusFor(products:[[SearchProduct]], withCompletionHandler completionHandler: @escaping([[SearchProduct]]) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        
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
    
    internal func checkWishlistStatusFor(fuzzyProduct:[[FuzzySearchProduct]], withCompletionHandler completionHandler: @escaping([[FuzzySearchProduct]]) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        
        let productIds:[String] = fuzzyProduct.reduce([]) { allIds, productList in
            return allIds + productList.map { $0.productId }
        }
        
        NetworkProvider<MojitoTarget>()
            .request(.getProductWishStatus(productIds: productIds))
            .map(to: ProductWishlistCheckResult.self)
            .subscribe(onNext: { checkResult in
                checkResult.ids.forEach { id in
                    fuzzyProduct.forEach { products in
                        let product = products.first { $0.productId == id }
                        product?.isOnWishlist = true
                    }
                }
                completionHandler(fuzzyProduct)
            },
                       onError: { [] error in
                        errorHandler(error)
            }
            ).disposed(by: self.rx_disposeBag)
    }
    
    internal func checkWishlistStatusFor(intermediaryCategorySection:[CategoryIntermediaryCuratedProductSection], withCompletionHandler completionHandler: @escaping([Any]) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        let productIds:[String] = intermediaryCategorySection.reduce([]) { allIds, section in
            return allIds + section.products.map { $0.id }
        }
        
        NetworkProvider<MojitoTarget>()
            .request(.getProductWishStatus(productIds: productIds))
            .map(to: ProductWishlistCheckResult.self)
            .subscribe(onNext: { checkResult in
                for id in checkResult.ids {
                    for section in intermediaryCategorySection {
                        for product in section.products {
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
    
    internal func requestProductShop(shopID:String,
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
            "per_page": ProductAndWishlistNetworkManager.productPerPage,
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
                            let product = searchResult.list.first { $0.product_id == info.productID }
                            product?.original_price = info.originalPrice
                            product?.percentage_amount = info.percentageAmount
                            product?.end_date = info.endDate
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
    
    internal func requestFeaturedProduct(shopID: String,
                                         withCompletionHandler completionHandler: @escaping([FeaturedProduct]) -> Void,
                                         andErrorHandler errorHandler: @escaping(Error) -> Void) {
        NetworkProvider<GoldMerchantTarget>()
            .request(.getFeaturedProduct(withShopID: shopID))
            .map(to: [FeaturedProduct.self], fromKey: "data")
            .subscribe(onNext: { result in
                completionHandler(result)
            }, onError: { [] error in
                errorHandler(error)
            })
            .disposed(by: self.rx_disposeBag)
    }
    
    internal func requestFuzzySearchWith(params:[String:Any], andPath path:String, withCompletionHandler completionHandler: @escaping(FuzzySearchWrapper) -> Void, andErrorHandler errorHandler: @escaping(Error) -> Void) {
        var outerResult:FuzzySearchWrapper?
        AceProvider()
            .request(.fuzzySearch(params: params, path: path))
            .map(to: FuzzySearchWrapper.self)
            .flatMap { searchResult -> Observable<FuzzySearchWrapper> in
                outerResult = searchResult
                var productIds:[String] = []
                if let products = searchResult.data.products {
                    let ids:[String] = products.map { $0.productId }
                    productIds.append(contentsOf: ids)
                }
                
                let userManager = UserAuthentificationManager()
                if !userManager.isLogin {
                    return Observable<FuzzySearchWrapper>.just(searchResult)
                }
                
                return NetworkProvider<MojitoTarget>()
                    .request(.getProductWishStatus(productIds: productIds))
                    .map(to: ProductWishlistCheckResult.self)
                    .map { checkResult in
                        if let products = searchResult.data.products {
                            zip(checkResult.ids, products).forEach({
                                if $0 == $1.productId {
                                    $1.isOnWishlist = true
                                }
                            })
                        }
                        return searchResult
                }
            }
            .subscribe(onNext: { result in
                completionHandler(result)
            }, onError: { [] error in
                guard let searchResult = outerResult else { errorHandler(error); return }
                completionHandler(searchResult)
            }).disposed(by: self.rx_disposeBag)
    }
}
