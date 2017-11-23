//
//  TopAdsService.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/29/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Render
import RestKit
import SPTPersistentCache
import Moya
import RxSwift

@objc(TopAdsFilterType)
enum TopAdsFilterType: Int {
    case standard, recommendationCategory, merlinRecommendation
}

class TopAdsFilter: NSObject {
    var ep: TopAdsEp = .product
    var numberOfProductItems: Int = UIDevice.current.userInterfaceIdiom == .pad ? 4 : 2
    var numberOfShopItems: Int = 1
    var source: TopAdsSource = .directory
    var currentPage: Int = 0
    var departementId: String?
    var hotlistId: String?
    var searchKeyword: String?
    var userFilter: NSDictionary?
    var type: TopAdsFilterType = .standard
    var searchNF: String? // flag parameter used for search not found top Ads
    var userId: String?
    
    override init() {
        super.init()
    }
    
    // used for merlin recommendation in search no result
    convenience init(source: TopAdsSource,
                     ep: TopAdsEp,
                     numberOfProductItems: Int,
                     searchNF: String,
                     searchKeyword: String,
                     type: TopAdsFilterType
        ) {
        self.init()
        self.source = source
        self.ep = ep
        self.numberOfProductItems = numberOfProductItems
        self.searchNF = searchNF
        self.searchKeyword = searchKeyword
        self.type = type
    }
    
    convenience init(source: TopAdsSource,
                     ep: TopAdsEp? = nil,
                     numberOfProductItems: Int? = nil,
                     numberOfShopItems: Int? = nil,
                     page: Int? = nil,
                     departementId: String? = nil,
                     hotlistId: String? = nil,
                     searchKeyword: String? = nil,
                     userFilter: NSDictionary? = nil,
                     type: TopAdsFilterType? = nil) {
        self.init()
        if let theEp = ep {
            self.ep = theEp
        }
        if let num = numberOfProductItems {
            self.numberOfProductItems = num
        }
        if let num = numberOfShopItems {
            self.numberOfShopItems = num
        }
        if let thePage = page {
            self.currentPage = thePage
        }
        if let type = type {
            self.type = type
        }
        self.source = source
        self.departementId = departementId
        self.hotlistId = hotlistId
        self.searchKeyword = searchKeyword
        self.userFilter = userFilter
        
    }
}

@objc enum TopAdsEp: Int {
    case product
    case shop
    case random
    
    func name() -> String {
        switch self {
        case .product: return "product"
        case .shop: return "shop"
        case .random: return ""
        }
    }
}

@objc enum TopAdsSource: Int {
    case directory
    case hotlist
    case search
    case favoriteProduct
    case favoriteShop
    case recommendation
    case recentlyViewed
    case wishlist
    case inboxMessageDetail
    case catalog
    case pageNotFound
    case emptyCart
    case intermediary
    
    func name() -> String {
        switch self {
        case .directory: return "directory"
        case .hotlist: return "hotlist"
        case .search: return "search"
        case .favoriteProduct: return "fav_product"
        case .favoriteShop: return "fav_shop"
        case .recommendation: return "recommendation"
        case .recentlyViewed: return "recently_viewed"
        case .wishlist: return "wishlist"
        case .inboxMessageDetail: return "inbox_message_detail"
        case .catalog: return "catalog"
        case .pageNotFound: return "page_not_found"
        case .emptyCart: return "empty_cart"
        case .intermediary: return "intermediary"
        }
    }
}

class CategoryRecommendationResponse: NSObject {
    var categoryIds = NSArray()
    
    class func mapping() -> RKObjectMapping {
        let mapping = RKObjectMapping(for: self)
        mapping?.addAttributeMappings(from: ["user_categories_id": "categoryIds"])
        
        return mapping!
    }
}

class TopAdsService: NSObject {
    let cacheIdentifier: String = "com.tokopedia.topads-\(UIApplication.getAppVersionStringWithoutDot())"
    let cacheExpirationPeriod = 60 * 15 // 15 minutes
    var cache: SPTPersistentCache!
    
    override init() {
        super.init()
        
        let cachePath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + cacheIdentifier
        
        let cacheOption = SPTPersistentCacheOptions()
        cacheOption.cachePath = cachePath
        cacheOption.cacheIdentifier = cacheIdentifier
        cacheOption.defaultExpirationPeriod = UInt(cacheExpirationPeriod)
        cacheOption.garbageCollectionInterval = 1 * SPTPersistentCacheDefaultGCIntervalSec
        
        self.cache = SPTPersistentCache(options: cacheOption)
    }
    
    func getTopAdsJSON(topAdsFilter: TopAdsFilter, onSuccess: @escaping (_ result: [String: Any]?) -> Void, onFailure: @escaping (_ error: Swift.Error) -> Void) {
            NetworkProvider<TopAdsTarget>()
                .request(.getTopAds(adFilter: topAdsFilter))
                .mapJSON(failsOnEmptyData: false)
                .subscribe(onNext: { json in
                    if let dictionary = json as? [String: Any] {
                        onSuccess(dictionary)
                    }
                    else if let array = json as? [Any] {
                        var dictionary:[String: Any] = [:]
                        for (index, element) in array.enumerated() {
                            dictionary["\(index)"] = element
                        }
                        onSuccess(dictionary)
                    }
                    else {
                        print("Error converting json to dictionary")
                        onSuccess(nil)
                        return
                    }
                }, onError: { error in
                    onFailure(error)
                })
        
    }
    
    func getTopAds(topAdsFilter: TopAdsFilter, onSuccess: @escaping (_ result: [PromoResult]) -> Void, onFailure: @escaping (_ error: Swift.Error) -> Void) {
        if topAdsFilter.type == .recommendationCategory {
            self.getTopAdsFromCategoryRecommendation(topAdsFilter: topAdsFilter, onSuccess: { result in
                onSuccess(result)
            }, onFailure: { error in
                onFailure(error)
            })
        } else if topAdsFilter.type == .standard {
            self.requestTopAds(topAdsFilter: topAdsFilter, onSuccess: { result in
                onSuccess(result)
            }, onFailure: { error in
                onFailure(error)
            })
        } else if topAdsFilter.type == .merlinRecommendation {
            self.requestTopAdsMerlinRecommendation(topAdsFilter: topAdsFilter, onSuccess: { (promoResult) in
                onSuccess(promoResult)
            }, onFailure: { (error) in
                onFailure(error)
            })
        }
    }
    
    private func storeRecommendationCategoryIds(_ ids: [String]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: ids)
        
        self.cache.store(data,
                         forKey: "recommendationCategoryIds",
                         ttl: UInt(cacheExpirationPeriod),
                         locked: false,
                         withCallback: { (_: SPTPersistentCacheResponse) in
                             
                         },
                         on: DispatchQueue.main)
    }
    
    private func loadRecommendationCategoryIds(_ onSuccess: @escaping (_ ids: [String]) -> Void) {
        
        self.cache.loadData(forKey: "recommendationCategoryIds",
                            withCallback: { (response: SPTPersistentCacheResponse) in
                                guard let record = response.record else {
                                    return onSuccess([String]())
                                }
                                
                                let ids = NSKeyedUnarchiver.unarchiveObject(with: record.data) as! [String]
                                return onSuccess(ids)
                            },
                            on: DispatchQueue.main)
    }
    
    private func getTopAdsFromCategoryRecommendation(topAdsFilter: TopAdsFilter, onSuccess: @escaping (_ result: [PromoResult]) -> Void, onFailure: @escaping (_ error: Swift.Error) -> Void) {
        
        self.loadRecommendationCategoryIds { [weak self] ids in
            if ids.count > 0 {
                let randomIndex = Int(arc4random_uniform(UInt32(ids.count)))
                topAdsFilter.departementId = "\(ids[randomIndex])"
                
                self?.requestTopAds(topAdsFilter: topAdsFilter, onSuccess: { result in
                    onSuccess(result)
                }, onFailure: { error in
                    onFailure(error)
                })
                
            } else {
                let networkManager = TokopediaNetworkManager()
                networkManager.isUsingHmac = true
                let path = "/promo/v1/info/user"
                let parameters = ["pub_id": "15"]
                
                networkManager.request(withBaseUrl: NSString.topAdsUrl(),
                                       path: path,
                                       method: .GET,
                                       parameter: parameters,
                                       mapping: CategoryRecommendationResponse.mapping(),
                                       onSuccess: { successResult, _ in
                                           
                                           if let response = successResult.dictionary()[""] as? CategoryRecommendationResponse {
                                               if response.categoryIds.count > 0 {
                                                   var temp = [String]()
                                                   for id in response.categoryIds {
                                                       temp.append("\(id)")
                                                   }
                                                   self?.storeRecommendationCategoryIds(temp)
                                                   let randomIndex = Int(arc4random_uniform(UInt32(response.categoryIds.count)))
                                                   topAdsFilter.departementId = "\(response.categoryIds[randomIndex])"
                                               }
                                           }
                                           
                                           self?.requestTopAds(topAdsFilter: topAdsFilter, onSuccess: { result in
                                               onSuccess(result)
                                           }, onFailure: { error in
                                               onFailure(error)
                                           })
                                           
                }, onFailure: { _ in
                    self?.requestTopAds(topAdsFilter: topAdsFilter, onSuccess: { result in
                        onSuccess(result)
                    }, onFailure: { error in
                        onFailure(error)
                    })
                })
            }
        }
    }
    
    private func requestTopAds(topAdsFilter: TopAdsFilter, onSuccess: @escaping (_ result: [PromoResult]) -> Void, onFailure: @escaping (_ error: Swift.Error) -> Void) {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        let path = "/promo/v1.1/display/ads"
        let parameters = TopAdsService.generateParameters(adFilter: topAdsFilter)
        
        networkManager.request(withBaseUrl: NSString.topAdsUrl(), path: path, method: .GET, parameter: parameters, mapping: PromoResponse.mapping(), onSuccess: { successResult, _ in
            if let response = successResult.dictionary()[""] as? PromoResponse {
                if let data = response.data as? [PromoResult] {
                    onSuccess(data)
                    return
                }
            }
            
            if let response = successResult.dictionary()[""] as? PromoResponse,
                let data = response.data as? [PromoResult] {
                onSuccess(data)
                return
                    
            }
        }) { error in
            onFailure(error)
        }
    }
    
    private func requestTopAdsMerlinRecommendation(topAdsFilter: TopAdsFilter, onSuccess: @escaping (_ result: [PromoResult]) -> Void, onFailure: @escaping (_ error: Swift.Error) -> Void) {
        guard let searchKeyword = topAdsFilter.searchKeyword else { return }
        MerlinProvider()
            .request(.getProductRecommendation(productTitle: searchKeyword))
            .map(to: MerlinRecommendationResponse.self)
            .subscribe(onNext: {[weak self] merlinRecommendationResponse in
                let topAdsNoResultFilter = topAdsFilter
                
                topAdsNoResultFilter.departementId = merlinRecommendationResponse.data.first?.productCategoryPrediction.first?.merlinProductCategories.last?.categoryId
                topAdsNoResultFilter.userId = UserAuthentificationManager().getUserId()
                
                self?.requestTopAds(topAdsFilter: topAdsNoResultFilter, onSuccess: { result in
                    onSuccess(result)
                }, onFailure: { error in
                    onFailure(error)
                })
            }, onError: { error in
                    onFailure(error)
            }).disposed(by: self.rx_disposeBag)
    }
    
    static func sendClickImpression(clickURLString: String) {
        guard let url = URL(string: clickURLString) else {
            return
        }
        
        let request = URLRequest(url: url)
        let queue = OperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler: { _, _, _ in
        })
    }
    
    class func generateParameters(adFilter: TopAdsFilter) -> [String: String] {
        
        let parameters: NSMutableDictionary = ["ep": adFilter.ep.name(),
                                               "item": "\(adFilter.numberOfProductItems),\(adFilter.numberOfShopItems)",
                                               "src": adFilter.source.name(),
                                               "page": adFilter.currentPage,
                                               "device": "ios"]
        
        if let depId = adFilter.departementId {
            parameters["dep_id"] = depId
        }
        
        if let hotId = adFilter.hotlistId {
            parameters["h"] = hotId
        }
        
        if let filter = adFilter.userFilter {
            parameters.addEntries(from: filter as! [AnyHashable: Any])
        }
        
        if let searchKey = adFilter.searchKeyword {
            parameters["q"] = searchKey
        }
        
        if let searchNF = adFilter.searchNF {
            parameters["search_nf"] = searchNF
        }
        
        if let userId = adFilter.userId {
            parameters["user_id"] = userId
        }
        
        var dict = [String: String]()
        for (key, value) in parameters as NSDictionary {
            dict[key as! String] = "\(value)"
        }
        
        return dict
    }
}
