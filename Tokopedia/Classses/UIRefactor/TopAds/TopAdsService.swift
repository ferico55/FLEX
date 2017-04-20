//
//  TopAdsService.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/29/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Render

struct TopAdsFilter {
    let ep: String = "product" //sementara hanya support product
    let numberOfItems: Int
    let source: TopAdsSource
    let page: Int?
    let departementId: String?
    let hotlistId: String?
    let searchKeyword: String?
    let userFilter: NSDictionary?
    
    init (numberOfItems: Int, source: TopAdsSource, page: Int? = nil, departementId: String? = nil, hotlistId: String? = nil, searchKeyword: String? = nil, userFilter: NSDictionary? = nil) {
        self.numberOfItems = numberOfItems
        self.source = source
        self.page = page
        self.departementId = departementId
        self.hotlistId = hotlistId
        self.searchKeyword = searchKeyword
        self.userFilter = userFilter
    }
}

enum TopAdsSource: String {
    case directory = "directory"
    case hotlist = "hotlist"
    case favoriteProduct = "fav_product"
    case favoriteShop = "fav_shop"
    case recommendation = "recommendation"
    case recentlyViewed = "recently_viewed"
    case wishlist = "wishlist"
    case inboxMessageDetail = "inbox_message_detail"
    case catalog = "catalog"
    case pageNotFound = "page_not_found"
    case emptyCart = "empty_cart"
    case intermediary = "intermediary"
}

class TopAdsService: NSObject {
    func getTopAds(topAdsFilter:TopAdsFilter, onSucces:@escaping (_ result:[PromoResult])->Void, onFailure:@escaping (_ error:Error)->Void){
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        let path = "/promo/v1.1/display/ads"
        let parameters = generateParameters(adFilter: topAdsFilter)
        
        networkManager.request(withBaseUrl: NSString.topAdsUrl(), path: path, method: .GET, parameter: parameters, mapping: PromoResponse.mapping(), onSuccess: { (successResult, operation) in
            let response = successResult.dictionary()[""] as! PromoResponse
            onSucces(response.data as! [PromoResult])
        }) { (error) in
            onFailure(error)
        }
    }
    
//    func getTopAdsNodeType(viewToBeRenderedAt:UIView, topAdsFilter:TopAdsFilter, onSucces:@escaping (_ nodeType:NodeType)->Void, onFailure:@escaping (_ error:Error)->Void){
//        getTopAds(topAdsFilter: topAdsFilter, onSucces: { (results) in
//            let topAdsComponentView = TopAdsComponentView()
//            let topAdsState = TopAdsState(topAds: results)
//            onSucces(topAdsComponentView.construct(state: topAdsState, size: viewToBeRenderedAt.frame.size))
//        }) { (error) in
//            onFailure(error)
//        }
//    }
    
    static func sendClickImpression(clickURLString:String){
        let url = URL(string:clickURLString)
        let request = URLRequest(url:url!)
        let queue = OperationQueue()
        NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ response, data, error in
        })
    }
    
    private func generateParameters(adFilter:TopAdsFilter) -> [String:String] {
        let parameters: NSMutableDictionary = ["ep":adFilter.ep,
                                               "item":adFilter.numberOfItems,
                                               "src":adFilter.source.rawValue,
                                               "device":"ios"]
        
        if let page = adFilter.page {
            parameters["page"] = page
        }
        
        if let depId = adFilter.departementId {
            parameters["dep_id"] = depId
        }
        
        if let hotId = adFilter.hotlistId {
            parameters["h"] = hotId
        }
        
        if let searchKey = adFilter.searchKeyword {
            parameters["q"] = searchKey
        }
        
        if let filter = adFilter.userFilter {
            parameters.addEntries(from: filter as! [AnyHashable : Any])
        }
    
        
        var dict = [String:String]()
        for (key,value) in (parameters as NSDictionary) {
            dict[key as! String] = "\(value)"
        }
        
        return dict
    }
}
