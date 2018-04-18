//
//  ProductTracker.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 06/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RestKit
import UIKit

internal class ProductTracker: NSObject {
    internal var trackerAttribution: String = "none/other"
    internal var trackerListName: String = "none/other"
    
    internal override init() {}
    
    convenience internal init(trackerAttribution: String?) {
        self.init(trackerAttribution: trackerAttribution, trackerListName: nil)
    }
    
    internal init(trackerAttribution: String?, trackerListName: String?) {
        self.trackerAttribution = trackerAttribution ?? "none/others"
        self.trackerListName = trackerListName ?? "none/other"
    }
    
    internal func addTrackerList(listName: String?) -> ProductTracker {
        return ProductTracker(trackerAttribution: self.trackerAttribution, trackerListName: listName)
    }
    
    internal static func mapping() -> RKObjectMapping {
        let mapping : RKObjectMapping = RKObjectMapping(for: self)
        mapping.addAttributeMappings(from:[
            "attribution" : "trackerAttribution",
            "tracker_list_name" : "trackerListName"
            ])
        return mapping
    }
}
