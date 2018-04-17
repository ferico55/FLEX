//
//  AudioCampaignService.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import AudioToolbox.AudioServices
import Foundation
import Moya
import UIKit
internal class AudioCampaignService: NSObject {
    internal var completionHandler:(()->Void)?
    private static var visitedScreen = ""
    internal func verifyShake(url: URL?, isAudio: Bool, onCompletion: (()->Void)?) {
        self.completionHandler = onCompletion
        let target = ShakeTarget.verifyShake(url: url, isAudio: isAudio)
        let endpointClosure = { (target: ShakeTarget) -> Endpoint<ShakeTarget> in
            let defaultEndpoint = NetworkProvider.defaultEndpointCreator(for: target)
            guard  UserAuthentificationManager().isLogin else {
                return defaultEndpoint
            }
            let userInformation = UserAuthentificationManager().getUserLoginData()
            guard let type = userInformation?["oAuthToken.tokenType"] as? String else {
                return defaultEndpoint
            }
            guard let token = userInformation?["oAuthToken.accessToken"] as? String else {
                return defaultEndpoint
            }
            let headers = [
                "Authorization": "\(type) \(token)",
            ]
            return defaultEndpoint.adding(newHTTPHeaderFields: headers)
        }
        let provider = NetworkProvider<ShakeTarget>(endpointClosure: endpointClosure)
        let _ = provider
            .request(target) { (result) in
                self.completionHandler?()
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0, execute: {
                    switch result {
                    case let .success(response):
                        self.routingAction(response: response)
                    case let .failure(error):
                        self.routingAction(response: error.response)
                    }
                })
        }
    }
    private func routingAction(response: Moya.Response?) {
        guard let response = response else {
            StickyAlertView.showErrorMessage(["Terjadi kesalahan, ulangi beberapa saat lagi"])
            return
        }
        guard let dict = try? JSONSerialization.jsonObject(with: response.data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
            return
        }
        guard let dataDict = dict?["data"] as? [String:Any] else {return}
        let status = response.statusCode
        let errorMessage = "Maaf, campaign tidak terbuka"
        if status != 200 {
            let error = (status == 0) ? "Maaf, sedang tidak ada campaign" : dataDict["message_error"] ?? errorMessage
            StickyAlertView.showErrorMessage([error])
            if status == 401 {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "navigateToPageInTabBar"), object: "4")
            }
        } else {
            let message = dataDict["message"] ?? "Berhasil shake shake"
            StickyAlertView.showSuccessMessage([message])
        }
        var analytics:[String:String] = [:]
        analytics["current"] = AnalyticsManager().dataLayer.get("screenName") as? String
        if let deeplink = dataDict["tkp_url"] as? String, let url = URL(string: deeplink) {
            if let vibrate = dataDict["vibrate"] as? Int, vibrate == 1 {
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            }
            analytics["campaign_id"] = dataDict["campaign_id"] as? String
            let topViewController = UIApplication.topViewController()
            if let isModal = topViewController?.isModal(), isModal == true, topViewController?.navigationController == nil {
                topViewController?.dismiss(animated: false, completion: nil)
            } else if AudioCampaignService.visitedScreen == analytics["current"] {
                topViewController?.navigationController?.popViewController(animated: false)
            }
            if UIApplication.shared.keyWindow?.rootViewController == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue:"hideNotificationView"), object: nil)
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0, execute: {
                if let scheme = url.scheme, ["tokopedia","http","https"].contains(scheme)  {
                    TPRoutes.routeURL(url, onDeeplinkNotFound: { (url) in
                        StickyAlertView.showErrorMessage([errorMessage])
                    })
                } else {
                    StickyAlertView.showErrorMessage([errorMessage])
                }
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3.0, execute: {
                    analytics["deeplink"] = deeplink
                    self.sendAnalytics(param: analytics)
                })
            })
            analytics["status"] = "success"
        } else {
            analytics["status"] = "fail"
        }
    }
    private func sendAnalytics(param:[String:String]) {
        var eventAction = ""
        var eventLabel = ""
        if let currentScreen = param["current"] {
            eventAction += currentScreen
        }
        eventAction += " - shake device - "
        eventAction += param["status"] ?? ""
        if let campaignId = param["campaign_id"] {
            eventLabel += campaignId + " - "
        }
        var urlString = param["deeplink"] ?? ""
        if let range = urlString.range(of: "tokopedia://") {
            urlString.removeSubrange(range)
        }
        let visited = AnalyticsManager().dataLayer.get("screenName") as? String ?? urlString
        eventLabel += visited
        AudioCampaignService.visitedScreen = visited
        AnalyticsManager.trackEventName("campaignEvent", category: "trigger based campaign", action: eventAction, label: eventLabel)
    }
}

