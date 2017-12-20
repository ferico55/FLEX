//
//  PopUpNotif.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import SwiftyJSON

final class PopUpNotification : NSObject {
    let title: String
    let text: String
    let imageUrl: String
    let buttonText: String
    let buttonUrl: String
    let appLink: String
    
    init(title: String, text: String, imageUrl: String, buttonText: String, buttonUrl: String, appLink: String) {
        self.title = title
        self.text = text
        self.imageUrl = imageUrl
        self.buttonText = buttonText
        self.buttonUrl = buttonUrl
        self.appLink = appLink
    }
}

extension PopUpNotification : JSONAbleType {
    static func fromJSON(_ source: [String: Any]) -> PopUpNotification {
        let json = JSON(source)
        
        let title = json["title"].stringValue
        let text = json["text"].stringValue
        let imageUrl = json["image_url"].stringValue
        let buttonText = json["button_text"].stringValue
        let buttonUrl = json["button_url"].stringValue
        let appLink = json["app_link"].stringValue
        
        return PopUpNotification(title: title, text: text, imageUrl: imageUrl, buttonText: buttonText, buttonUrl: buttonUrl, appLink: appLink)
    }
}
