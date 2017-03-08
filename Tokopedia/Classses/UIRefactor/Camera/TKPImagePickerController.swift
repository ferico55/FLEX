//
//  ImagePickerController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 3/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit
import DKImagePickerController
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


@objc class TKPImagePickerController: NSObject {
    
    class func showImagePicker(_ viewController:UIViewController, assetType: DKImagePickerControllerAssetType,
        allowMultipleSelect: Bool,
        showCancel:Bool,
        showCamera:Bool,
        maxSelected:Int,
        selectedAssets:NSArray?,
        completion: @escaping (_ assets: [DKAsset]) -> Void){
            
        let pickerController = DKImagePickerController()
        pickerController.UIDelegate = TKPImagePickerUIDelegate()
        pickerController.assetType = assetType
        pickerController.showsCancelButton = showCancel
        pickerController.allowMultipleTypes = allowMultipleSelect
        pickerController.maxSelectableCount = maxSelected
        if (selectedAssets?.count > 0 && selectedAssets != nil){
            pickerController.selectedAssets = selectedAssets as! [DKAsset]
        }
        pickerController.didSelectAssets = {(assets: [DKAsset]) in
            let numberOfPhotos = min(assets.count, maxSelected)
            return completion(Array(assets[0..<numberOfPhotos]))
        }
        viewController.present(pickerController, animated: true) {}
    }
    
    class func resizedImage(_ originalImage:UIImage) -> (UIImage){
        
        var actualHeight = originalImage.size.height
        var actualWidth = originalImage.size.width
        var imgRatio = actualWidth/actualHeight
        let maxImageSize = CGSize(width: 600, height: 600)
        let widthView = maxImageSize.width;
        let heightView = maxImageSize.height;
        let maxRatio = widthView/heightView;
        
        if (imgRatio != maxRatio){
            if (imgRatio < maxRatio){
                imgRatio = heightView / actualHeight
                actualHeight = heightView
                actualWidth = imgRatio * actualWidth
            } else {
                imgRatio = widthView / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = widthView
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight);
        UIGraphicsBeginImageContext(rect.size)
        originalImage.draw(in: rect)
        let resized : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return resized
    }
}
