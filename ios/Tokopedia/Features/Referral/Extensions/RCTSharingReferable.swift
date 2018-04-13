//
//  RCTSharingReferable.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 23/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
internal class RCTSharingReferable: NSObject, Referable {
    internal var desktopUrl: String = ""
    internal var deeplinkPath: String = ""
    internal var feature: String = ""
    internal var title: String = ""
    internal var buoDescription: String = ""
    internal var utmCampaign: String = ""
    
    internal var ogTitle: String?
    internal var ogDescription: String?
    internal var ogImageUrl: String?
}
