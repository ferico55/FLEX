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
}
