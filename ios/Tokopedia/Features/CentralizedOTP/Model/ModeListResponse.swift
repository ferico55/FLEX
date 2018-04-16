//
//  ModeListResponse.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 29/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
import UIKit

public class ModeListResponse: NSObject {
    public let isSuccess: Bool
    public let modeList: [ModeListDetail]

    public init(isSuccess: Bool, modeList: [ModeListDetail]) {
        self.isSuccess = isSuccess
        self.modeList = modeList
    }

    convenience public init(json: JSON) {
        var modeListDetails = [ModeListDetail]()
        let isSuccess = json["data"]["is_success"].boolValue
        for value in json["data"]["mode_list"].arrayValue {
            let list = ModeListDetail(json: value)
            modeListDetails.append(list)
        }
        self.init(isSuccess: isSuccess, modeList: modeListDetails)
    }
}

public class ModeListDetail: NSObject {
    public let modeCode: Int
    public let modeText: String
    public let otpListText: String
    public let afterOtpListText: String
    public let afterOtpListHtml: String
    public let otpListImgUrl: URL?

    public init(modeCode: Int, modeText: String, otpListText: String, afterOtpListText: String, afterOtpListHtml: String, otpListImgUrl: String) {
        self.modeCode = modeCode
        self.modeText = modeText
        self.otpListText = otpListText
        self.afterOtpListText = afterOtpListText
        self.afterOtpListHtml = afterOtpListHtml
        self.otpListImgUrl = URL(string: otpListImgUrl)
    }

    public convenience init(json: JSON) {
        let modeCode = json["mode_code"].intValue
        let modeText = json["mode_text"].stringValue
        let otpListText = json["otp_list_text"].stringValue
        let afterOtpListText = json["after_otp_list_text"].stringValue
        let afterOtpListHtml = json["after_otp_list_text_html"].stringValue
        let otpListImgUrl = json["otp_list_img_url"].stringValue

        self.init(modeCode: modeCode, modeText: modeText, otpListText: otpListText, afterOtpListText: afterOtpListText, afterOtpListHtml: afterOtpListHtml, otpListImgUrl: otpListImgUrl)
    }
}

