//
//  EditSolutionSellerCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class EditSolutionSellerCell: UITableViewCell {
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var freeReturnLogoImageView: UIImageView!
    @IBOutlet var troubleLabel: UILabel!
    @IBOutlet var troubleDescriptionLabel: UILabel!
    @IBOutlet var freeReturnViewHeight: NSLayoutConstraint!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setViewModel(viewModel:ProductResolutionViewModel) {
        productImageView.setImageWithUrl(NSURL.init(string: viewModel.productImageURLString)!, placeHolderImage: UIImage.init(named: "icon_toped_loading_grey-01.png"))
        
        troubleLabel.text = viewModel.productTrouble
        troubleDescriptionLabel.text = viewModel.productTroubleDescription
        
        if viewModel.isFreeReturn {
            freeReturnViewHeight.constant = 0
        } else {
            freeReturnViewHeight.constant = 20
        }
    }
    
}
