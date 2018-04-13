//
//  ReferralManager.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 28/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Branch
import Foundation
@objc internal class ReferralManager: NSObject {
    //    MARK:- Public
    internal var referralCode: String? {
        get {
            return UserDefaults.standard.string(forKey: "referralPromoCode")
        }
        set(code) {
            if code != nil {
                UserDefaults.standard.set(code, forKey: "referralPromoCode")
            } else {
                UserDefaults.standard.removeObject(forKey: "referralPromoCode")
            }
            UserDefaults.standard.synchronize()
        }
    }
    //    MARK: - Public
    internal func share(object: Any, from viewController: UIViewController, anchor: UIView?, onCompletion: ((String)->Void)? = nil) {
        guard let referable = object as? Referable else { return }
        if ReferralRemoteConfig.shared.isBranchLinkActive == false {
            if let anchor = anchor {
                self.branchInactiveShare(object: referable, from: viewController, anchor: anchor)
            }
            return
        }
        let linkProperties = self.linkProperties(object: referable)
        let buo = BranchUniversalObject(canonicalIdentifier: referable.utmCampaign)
        buo.title = referable.title.kv_decodeHTMLCharacterEntities()
        var shareText = buo.title
        if referable is ReferralSharing || referable is AppSharing {
            shareText = referable.buoDescription + " Cek : \n"
        } else {
            buo.contentDescription = referable.buoDescription
        }
        if let referalSharing = referable as? ReferralSharing {
            linkProperties.addControlParam("$og_title", withValue: referalSharing.ogTitle)
            linkProperties.addControlParam("$og_description", withValue: referalSharing.ogDescription)
        } else if let rctReferalSharing = referable as? RCTSharingReferable, let ogTitle = rctReferalSharing.ogTitle, let ogDescription = rctReferalSharing.ogDescription, let ogImageUrl = rctReferalSharing.ogImageUrl {
            linkProperties.addControlParam("$og_title", withValue: ogTitle)
            linkProperties.addControlParam("$og_description", withValue: ogDescription)
            linkProperties.addControlParam("$og_image_url", withValue: ogImageUrl)
        }
        buo.showShareSheet(with: linkProperties, andShareText: shareText, from: viewController) { (_: String?, _: Bool) in
        }
    }
    private func branchInactiveShare(object:Referable?, from viewController: UIViewController, anchor: UIView) {
        if let refObject = object, let url = URL(string: refObject.desktopUrl), let controller = UIActivityViewController.shareDialog(withTitle: refObject.title, url: url, anchor: anchor) {
            viewController.present(controller, animated: true, completion: nil)
        }
    }
    //    MARK:- BranchLinkProperties
    private func linkProperties(object:Referable)->BranchLinkProperties {
        let deeplink_path = self.utmQueryWith(campaign: object.utmCampaign, to: object.deeplinkPath)
        let desktop_url = self.utmQueryWith(campaign: object.utmCampaign, to: object.desktopUrl)
        let linkProperties = BranchLinkProperties()
        linkProperties.addControlParam("$desktop_url", withValue: desktop_url)
        linkProperties.addControlParam("$ios_deeplink_path", withValue: deeplink_path)
        linkProperties.addControlParam("$android_deeplink_path", withValue: deeplink_path)
        linkProperties.feature = object.feature
        linkProperties.campaign = "iOS App"
        return linkProperties
    }
    //    MARK: - UTM parameters
    private func utmQueryWith(campaign: String, to url: String) -> String {
        let query = "utm_campaign=" + campaign + "share" + "&utm_source=ios&utm_medium=share"
        let finalUrl = (url.contains("?")) ? (url + "&" + query) : (url + "?" + query)
        return finalUrl
    }
}
