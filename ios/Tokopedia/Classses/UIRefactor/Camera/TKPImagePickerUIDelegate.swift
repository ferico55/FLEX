//
//  TKPImagePickerUIDelegate.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import DKImagePickerController

open class TKPImagePickerUIDelegate: DKImagePickerControllerDefaultUIDelegate {
    
    override open func prepareLayout(_ imagePickerController: DKImagePickerController, vc: UIViewController) {
        self.imagePickerController = imagePickerController
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.createDoneButtonIfNeeded())
        self.updateDoneButtonTitle(self.createDoneButtonIfNeeded())
    }
    
    override open func createDoneButtonIfNeeded() -> UIButton {
        if self.doneButton == nil {
            let button = UIButton(type: .custom)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            button.addTarget(self.imagePickerController, action: #selector(DKImagePickerController.done), for: .touchUpInside)
            button.setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 0.7), for: .normal)
            self.doneButton = button
        }
        
        return self.doneButton!
    }
    
    override open func imagePickerController(_ imagePickerController: DKImagePickerController, didSelectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(self.createDoneButtonIfNeeded())
    }
    
    override open func imagePickerController(_ imagePickerController: DKImagePickerController, didDeselectAssets: [DKAsset]) {
        self.updateDoneButtonTitle(self.createDoneButtonIfNeeded())
    }
    
    override open func imagePickerController(_ imagePickerController: DKImagePickerController,
                                             showsCancelButtonForVC vc: UIViewController) {
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Batal",
                                                              style: .plain,
                                                              target: imagePickerController,
                                                              action:  #selector(imagePickerController.dismiss as (Void) -> Void))
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.createDoneButtonIfNeeded())
        
    }
    
    override open func updateDoneButtonTitle(_ button: UIButton) {
        if self.imagePickerController.selectedAssets.count > 0 {
            button.setTitle(String(format: "Selesai(%d)", self.imagePickerController.selectedAssets.count), for: .normal)
            button.isEnabled = true
        } else {
            button.setTitle("Selesai", for: .normal)
            button.isEnabled = false
        }
        
        button.sizeToFit()
    }

    open override func imagePickerControllerCollectionCameraCell() -> DKAssetGroupDetailBaseCell.Type {
        return TKPImagePickerCameraCell.self
    }
}
