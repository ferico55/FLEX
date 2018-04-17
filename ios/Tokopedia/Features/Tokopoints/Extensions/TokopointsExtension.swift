//
//  TokopointsExtension.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 16/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

extension CrackResultMutation.Data.CrackResult {
    internal var benefitText: NSAttributedString {
        let benefits = NSMutableAttributedString()
        for benefit in self.benefits {
            if let benefitText = benefit?.text {
                if benefits.length > 0 {
                    benefits.append(NSAttributedString(string: "\n"))
                }
                let attr = NSMutableAttributedString(string: benefitText)
                if let benefitColor = benefit?.color, benefitColor.isValidHexColor() {
                    attr.addAttribute(NSForegroundColorAttributeName, value: UIColor.fromHexString(benefitColor), range: NSRange(location: 0, length: benefitText.count))
                }
                if let benefitSize = benefit?.size {
                    var smallFontSize: CGFloat = 24
                    var largeFontSize: CGFloat = 32
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        smallFontSize = 32
                        largeFontSize = 56
                    }
                    if benefitSize == "small" {
                        attr.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: smallFontSize), range: NSRange(location: 0, length: benefitText.count))
                    }
                    else {
                        attr.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: largeFontSize), range: NSRange(location: 0, length: benefitText.count))
                    }
                }
                benefits.append(attr)
            }
        }
        
        return benefits
    }
}

extension CrackResultMutation.Data.CrackResult.ResultStatus {
    internal enum StatusValue: String {
        case ok = "200"
        case requestDenied = "403"
        case isAlreadyCracked = "42501"
        case campaignExpired = "42504"
        case tokenExpired = "42503"
        case unknown
    }
    
    internal var statusValue: StatusValue {
        guard let code = self.code, let status = self.status else {
            return .unknown
        }
        
        switch code {
        case "200":
            return .ok
        case "42501":
            return .isAlreadyCracked
        case "403":
            return status == "REQUEST_DENIED" ? .requestDenied : .unknown
        case "42503":
            return .tokenExpired
        case "42504":
            return .campaignExpired
        default:
            return .unknown
        }
    }
}

extension TokopointsTokenQuery.Data.TokopointsToken {
    internal func hasRequiredProperties() -> Bool {
        guard let homeToken = self.home,
            homeToken.tokensUser?.campaignId != nil,
            homeToken.tokensUser?.tokenUserId != nil,
            let currentUserToken = homeToken.tokensUser,
            let _ = currentUserToken.tokenAsset?.smallImgUrl,
            let _ = currentUserToken.backgroundAsset?.backgroundImgUrl,
            let imageUrls = currentUserToken.tokenAsset?.imageUrls,
            imageUrls.count >= 7,
            let _ = imageUrls[0],
            let _ = imageUrls[4],
            let _ = imageUrls[5],
            let _ = imageUrls[6]
            else {
                return false
        }
        
        return true
    }
}

internal enum RewardButtonType: String {
    case dismiss
    case redirect
    case invisible
    case unknown
}

extension CrackResultMutation.Data.CrackResult.CtaButton {
    internal var buttonType: RewardButtonType {
        if let rewardButtonType = RewardButtonType(rawValue: self.type ?? "") {
            return rewardButtonType
        }
        else {
            return .unknown
        }
    }
}

extension CrackResultMutation.Data.CrackResult.ReturnButton {
    internal var buttonType: RewardButtonType {
        if let rewardButtonType = RewardButtonType(rawValue: self.type ?? "") {
            return rewardButtonType
        }
        else {
            return .unknown
        }
    }
}
