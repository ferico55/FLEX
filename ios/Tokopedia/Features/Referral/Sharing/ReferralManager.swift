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
//    MARK:- Public
    func share(object:Any, from viewController: UIViewController, anchor: UIView?) {
        guard let referable = object as? Referable else { return }
        if let anchor = anchor {
            BranchInactiveSharing().share(object: referable, from: viewController, anchor: anchor)
        }
        return
        let linkProperties = self.linkProperties(object: referable)
        let buo = BranchUniversalObject(canonicalIdentifier: referable.utm_campaign)
        buo.title = referable.title
        buo.contentDescription = referable.buoDescription
        buo.showShareSheet(with: linkProperties, andShareText: referable.title, from: viewController) { (activityType: String?, completed: Bool) in
        }
    }
    //    MARK:- BranchLinkProperties
    private func linkProperties(object:Referable)->BranchLinkProperties {
        let deeplink_path = self.utmQueryWith(campaign: object.utm_campaign, to: object.deeplinkPath)
        let desktop_url = self.utmQueryWith(campaign: object.utm_campaign, to: object.desktopUrl)
        let linkProperties = BranchLinkProperties()
        linkProperties.addControlParam("$desktop_url", withValue: desktop_url)
        linkProperties.addControlParam("$ios_deeplink_path", withValue: deeplink_path)
        linkProperties.addControlParam("$android_deeplink_path", withValue: deeplink_path)
        linkProperties.addControlParam("$uri_redirect_mode", withValue: "2")
        linkProperties.feature = object.feature
        linkProperties.campaign = "iOS App"
        return linkProperties
    }
    //    MARK:- UTM parameters
    private func utmQueryWith(campaign :String, to url:String)->String {
        let query = "utm_campaign=" + campaign + "share" + "&utm_source=ios&utm_medium=share"
        let finalUrl = (url.contains("?")) ? (url + "&" + query) : (url + "?" + query)
        return finalUrl
    }
}
