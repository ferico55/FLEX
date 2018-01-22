//
//  RCPhotosCollectionCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class RCPhotosCollectionCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    var removeButtonHandler: (()->Void)?
    
    @IBAction private func removeImage(sender: UIButton) {
        if let handler = self.removeButtonHandler {
            handler()
        }
    }
}
