//
//  ReplayConversationPostData.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/1/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReplayConversationPostData: NSObject {
    
    var editSolution : String = ""
    var flagReceived : String = ""
    var photos       : String = ""
    var refundAmount : String = ""
    var replyMessage : String = ""
    var resolutionID : String = ""
    var solution     : String = ""
    var troubleType  : String = ""
    var userID       : String = ""
    var generatedHost : GeneratedHost = GeneratedHost()
    var selectedAssets : [DKAsset] = []
    var selectedSolution : EditSolution = EditSolution()
    var uploadedImages : [ImageResult] = []
    var postKey : String = ""
    var fileUploaded : String = ""
    var actionBy       : String = "1"
    var category_trouble_id : String = ""
    var selectedProducts    : [ResolutionCenterCreatePOSTProduct] = []

}
