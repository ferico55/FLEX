//
//  TKPImagePickerCameraCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import DKImagePickerController

class TKPImagePickerCameraCell: DKAssetGroupDetailBaseCell {
    
    class override func cellReuseIdentifier() -> String {
        return "CustomGroupDetailCameraCell"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let cameraView : TPLiveCameraView = TPLiveCameraView.init(frame: self.contentView.frame)
        cameraView.startLiveVideo()
        self.contentView.addSubview(cameraView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
