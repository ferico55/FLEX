//
//  AudioCampaignService.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import AudioToolbox.AudioServices
import Foundation
import UIKit
internal class AudioCampaignService: NSObject {
    internal var completionHandler:(()->Void)?
    internal func verifyShake(url: URL?, isAudio: Bool, onCompletion: (()->Void)?) {
        self.completionHandler = onCompletion
        let headers = [
            "content-type" : "multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW",
            "cache-control" : "no-cache"
        ]
        let boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
        var bodyData = Data()
        if let boundaryData = "--\(boundary)\r\n".data(using: .utf8) {
            bodyData.append(boundaryData)
        }
        if isAudio {
            guard let fileUrl = url else {return}
            let disposition = "Content-Disposition:form-data; name=\"tkp_file\"; filename=\"\(fileUrl.lastPathComponent)\";\r\nContent-Transfer-Encoding: \"binary\"\r\n\r\n\r\n"
            if let databytes = disposition.data(using: .utf8) {
                bodyData.append(databytes)
            }
            do {
                let data = try Data(contentsOf: fileUrl)
                bodyData.append(data)
                if let boundaryData = "--\(boundary)\r\n".data(using: .utf8) {
                    bodyData.append(boundaryData)
                }
            } catch {
                debugPrint(error)
            }
        }
        var body2 = "Content-Disposition:form-data; name=\"is_audio\"\r\n\r\n"
        body2 += "\(isAudio)\r\n"
        body2 += "--\(boundary)--\r\n"
        if let databytes = body2.data(using: .utf8) {
            bodyData.append(databytes)
        }
        let urlString = NSString.bookingUrl() + "/trigger/v1/api/campaign/av/verify"
        guard let url = URL(string: urlString) else {return}
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.allHTTPHeaderFields = headers
        request.httpShouldHandleCookies = false
        let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let handler = self.completionHandler {
                DispatchQueue.main.sync {
                    handler()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0, execute: {
                if error != nil {
                    StickyAlertView.showErrorMessage(["Terjadi kesalahan, ulangi beberapa saat lagi"])
                    return
                }
                self.routingAction(data: data)
            })
        }
        dataTask.resume()
    }
    private func routingAction(data: Data?) {
        guard let response = data else {return}
        do {
            guard let dict = try JSONSerialization.jsonObject(with: response, options: JSONSerialization.ReadingOptions.allowFragments) as? [String:Any] else {
                return
            }
            if let error = dict["message_error"] as? [String] {
                StickyAlertView.showErrorMessage(error)
                return
            }
            if let dataDict = dict["data"] as? [String:String] {
                var eventAction = (AnalyticsManager().dataLayer.get("screenName") as? String ?? "") + "- shake device -"
                var eventLabel = ""
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
                if let deeplink = dataDict["tkp_url"], let url = URL(string: deeplink) {
                    if let campaign = dataDict["campaign_id"] {
                        eventLabel += campaign + " - "
                    }
                    var urlString = deeplink
                    if let range = urlString.range(of: "tokopedia://") {
                        urlString.removeSubrange(range)
                    }
                    eventLabel += urlString
                    let topViewController = UIApplication.topViewController(UIApplication.shared.keyWindow?.rootViewController)
                    topViewController?.navigationController?.popToRootViewController(animated: false)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3, execute: {
                        TPRoutes.routeURL(url)
                    })
                    eventAction += "success"
                } else {
                    eventAction += "fail"
                }
                AnalyticsManager.trackEventName("campaignEvent", category: "trigger based campaign", action: eventAction, label: eventLabel)
            }
        } catch {
            debugPrint(error)
        }
    }
}

