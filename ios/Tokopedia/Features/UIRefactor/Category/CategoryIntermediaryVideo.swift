//
//  CategoryIntermediaryVideo.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 5/18/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Unbox

final class CategoryIntermediaryVideo: NSObject, Unboxable {
    
    var title: String?
    var videoDescription: String?
    var videoUrl: String?
    
    convenience init(unboxer:Unboxer) throws {
        self.init()
        if let title: String = try? unboxer.unbox(keyPath: "title") {
            self.title = title
        } else {
            self.title = nil
        }
        
        if let videoDescription: String = try? unboxer.unbox(keyPath: "description") {
            self.videoDescription = videoDescription
        } else {
            self.videoDescription = nil
        }
        
        if let videoUrl: String = try? unboxer.unbox(keyPath: "video_url") {
            self.videoUrl = videoUrl
        } else {
            self.videoUrl = nil
        }
    }
    
}
