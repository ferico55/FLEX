//
//  PHAssetCategory.swift
//  Tokopedia
//
//  Created by Ferico Samuel on 08/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Photos

extension PHAsset {
    func getPublicUrl() -> NSURL? {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        var publicURL = NSURL()

        manager.requestImage(for: self, targetSize: CGSize(width: self.pixelWidth, height: self.pixelHeight), contentMode: .aspectFit, options: options) { result, info in
            guard let image = result, let imageData = UIImagePNGRepresentation(image) else { return }
        
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd_HHmmssSSSS"
            let dateString = dateFormatter.string(from: Date())
            
            let imageName = "dddimage_\(dateString).png"
            let imagePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(imageName)
            
            do {
                try imageData.write(to: URL(fileURLWithPath: imagePath), options: .atomic)
            }
            catch {
            }
    
            publicURL = URL(fileURLWithPath: imagePath) as NSURL
        }
            
        return publicURL
    }
}
