//
//  Redirection.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 03/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import Unbox

@objc(SearchRedirection)
final class SearchRedirection : NSObject, Unboxable {
    var redirectUrl:String?
    var departmentId:String?
    
    convenience required init(unboxer:Unboxer) throws {
        self.init()
        redirectUrl = try? unboxer.unbox(keyPath: "redirect_url")
        departmentId = try? unboxer.unbox(keyPath: "department_id")
    }
}
