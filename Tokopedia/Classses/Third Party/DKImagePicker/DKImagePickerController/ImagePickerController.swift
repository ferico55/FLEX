//
//  ImagePickerController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 3/28/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc class ImagePickerController: NSObject {
    
    class func showImagePicker(viewController:UIViewController, assetType: DKImagePickerControllerAssetType,
        allowMultipleSelect: Bool,
        showCancel:Bool,
        showCamera:Bool,
        maxSelected:Int,
        selectedAssets:NSArray?,
        completion: (assets: [DKAsset]) -> Void){
            
            let pickerController = DKImagePickerController()
            pickerController.assetType = assetType
            pickerController.showCancelButton = showCancel
            pickerController.allowMultipleTypes = allowMultipleSelect
            if (showCamera){
                pickerController.sourceType = [.Camera, .Photo]
            } else {
                pickerController.sourceType = [.Photo]
            }
            pickerController.maxSelectableCount = maxSelected
            if (selectedAssets?.count > 0 && selectedAssets != nil){
                pickerController.selectedAssets = selectedAssets as! [DKAsset]
            }
            pickerController.didSelectAssets = {(assets: [DKAsset]) in
                return completion(assets: assets)
            }
            viewController.presentViewController(pickerController, animated: true) {}
    }

}
