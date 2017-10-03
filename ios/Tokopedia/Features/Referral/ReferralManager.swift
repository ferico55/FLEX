//
//  ReferralManager.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 28/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Branch
@objc class ReferralManager: NSObject {    
    func getShortUrlFor(product: ProductUnbox)->String? {
        let utmQuery = self.utmQueryWith(campaign: "product share")
        var subpath = "product/" + product.id
        subpath += utmQuery
        let dektopUrl = product.url + utmQuery
        return self.shortUrl(subPath:subpath, identifer: "product", desktopUrl: dektopUrl)
    }
    func getShortUrlFor(productDetail: ProductDetail)->String? {
        let utmQuery = self.utmQueryWith(campaign: "product share")
        var subpath = "product/" + productDetail.product_id
        subpath += utmQuery
        let dektopUrl = productDetail.product_url + utmQuery
        return self.shortUrl(subPath:subpath, identifer: "product", desktopUrl: dektopUrl)
    }
    func getShortUrlFor(shopState: FeedCardShopState)->String? {
        let utmQuery = self.utmQueryWith(campaign: "feed share")
        let urlString = shopState.shareURL + utmQuery
        let url = URL(string: shopState.shareURL)
        var subpath = "feedcommunicationdetail/" + (url?.lastPathComponent)!
        subpath += utmQuery
       return self.shortUrl(subPath:subpath, identifer: "feed", desktopUrl: urlString)
    }
    func getShortUrlFor(shopState: FeedDetailShopState)->String? {
        let utmQuery = self.utmQueryWith(campaign: "feed share")
        let urlString = shopState.shareURL + utmQuery
        let url = URL(string: shopState.shareURL)
        var subpath = "feedcommunicationdetail/" + (url?.lastPathComponent ?? "")
        subpath += utmQuery
        return self.shortUrl(subPath:subpath, identifer: "feed", desktopUrl: urlString)
    }
    func getShortUrlFor(hotListBannerResult: HotlistBannerResult)->String? {
        let utmQuery = self.utmQueryWith(campaign: "hotlist share")
        let title = (hotListBannerResult.info.alias_key ?? "")
        let desktopUrl = NSString.tokopediaUrl() + "/hot/" + title + utmQuery
        var subpath = "hot/" + title
        subpath += utmQuery
        return self.shortUrl(subPath:subpath, identifer: "hotlist",desktopUrl: desktopUrl)
    }
    func getShortUrlFor(hotListData: [String:String])->String? {
        let utmQuery = self.utmQueryWith(campaign: "hotlist share")
        let title = hotListData["title"]?.replacingOccurrences(of: " ", with: "-").lowercased()
        let desktopUrl = (hotListData["url"] ?? NSString.tokopediaUrl()) + utmQuery
        var subpath = "hot/" + (title ?? "")
        subpath += utmQuery
        return self.shortUrl(subPath:subpath, identifer: "hotlist",desktopUrl: desktopUrl)
    }
    func getShortUrlFor(search: SearchProductWrapper)->String? {
        let utmQuery = self.utmQueryWith(campaign: "search result share")
        let desktopUrl = (search.data.shareUrl ?? NSString.tokopediaUrl()) + utmQuery
        var subpath = "search?" + ((URL(string:desktopUrl)?.query) ?? "")
        subpath += utmQuery
        return self.shortUrl(subPath:subpath, identifer: "search",desktopUrl: desktopUrl)
    }
    func getShortUrlFor(catalog: CatalogInfo)->String? {
        let utmQuery = self.utmQueryWith(campaign: "catalog share")
        let desktopUrl = catalog.catalog_url + utmQuery
        var subpath = "catalog/" + catalog.catalog_id + "/" + catalog.catalog_key
        subpath += utmQuery
        return self.shortUrl(subPath:subpath, identifer: "catalog",desktopUrl: desktopUrl)
    }
    func getShortUrlFor(shopInfo: ShopInfo)->String? {
        let utmQuery = self.utmQueryWith(campaign: "shop share")
        var subpath = "shop/" + shopInfo.shop_id
        subpath += utmQuery
        let desktopUrl = shopInfo.shop_url + utmQuery
        return self.shortUrl(subPath:subpath, identifer: "shop", desktopUrl: desktopUrl)
    }
    func getShortUrlFor(productReview: DetailReputationReview)->String? {
        let utmQuery = self.utmQueryWith(campaign: "product review share")
        let desktopUrl = NSString.tokopediaUrl() + "/" + productReview.product_uri + utmQuery
        var subpath = "product/" + productReview.product_id + "/review"
        subpath += utmQuery
        return self.shortUrl(subPath:subpath, identifer: "review",desktopUrl: desktopUrl)
    }
//    MARK:- App Share
    func getShortUrlForHome()->String? {
        let utmQuery = self.utmQueryWith(campaign: "app share")
        let desktopUrl = "https://itunes.apple.com/id/app/tokopedia/id1001394201" + utmQuery
        var subpath = "home"
        subpath += utmQuery
        let branchUniversalObject = BranchUniversalObject(canonicalIdentifier: "home")
        branchUniversalObject.title = "Tokopedia, Satu Aplikasi untuk Semua Kebutuhan"
        branchUniversalObject.contentDescription = "Mudahnya beli produk idaman, pulsa, token listrik, tiket liburan, hingga bayar berbagai tagihan, semua dimulai dari aplikasi Tokopedia. Kamu juga bisa mulai & kembangkan bisnis di sini. Yuk, download sekarang!"
        let linkProperties = BranchLinkProperties()
        linkProperties.addControlParam("$desktop_url", withValue: desktopUrl)
        linkProperties.addControlParam("$ios_deeplink_path", withValue: subpath)
        linkProperties.addControlParam("$android_deeplink_path", withValue: subpath)
        linkProperties.addControlParam("$uri_redirect_mode", withValue: "2")
        let textURL = branchUniversalObject.getShortUrl(with: linkProperties)
        return textURL
    }

//    MARK:- Short URL with sub path
    private func shortUrl(subPath :String, identifer :String, desktopUrl :String)->String? {
        if ReferralRemoteConfig.shared.isBranchLinkActive == false {
            return desktopUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        }
        let branchUniversalObject = BranchUniversalObject(canonicalIdentifier: identifer)
        let linkProperties = BranchLinkProperties()
        linkProperties.addControlParam("$desktop_url", withValue: desktopUrl)
        linkProperties.addControlParam("$ios_deeplink_path", withValue: subPath)
        linkProperties.addControlParam("$android_deeplink_path", withValue: subPath)
        linkProperties.addControlParam("$uri_redirect_mode", withValue: "2")
        let textURL = branchUniversalObject.getShortUrl(with: linkProperties)
        return textURL
    }
//    MARK:- UTM parameters
    private func utmQueryWith(campaign :String)->String {
        let query = "?utm_campaign=" + campaign + self.utmQueryCommonParameters
        return query
    }
    private var utmQueryCommonParameters :String {
        return "&utm_source=ios&utm_medium=share"
    }
}
