//
//  EditSolutionSellerCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit


class EditSolutionSellerCell: UITableViewCell {
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var freeReturnLogoImageView: UIImageView!
    @IBOutlet weak var troubleLabel: UILabel!
    @IBOutlet weak var troubleDescriptionLabel: UILabel!
    @IBOutlet weak var freeReturnViewHeight: NSLayoutConstraint!
    @IBOutlet weak var productNameLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setViewModel(viewModel:ProductResolutionViewModel) {
        productImageView.setImageWithUrl(NSURL.init(string: viewModel.productImageURLString)!, placeHolderImage: UIImage.init(named: "icon_toped_loading_grey-01.png"))
        
        troubleLabel.text = viewModel.productTrouble
        troubleDescriptionLabel.text = viewModel.productTroubleDescription
        productNameLabel.text = viewModel.productName
        
        if viewModel.isFreeReturn {
            freeReturnViewHeight.constant = 0
        } else {
            freeReturnViewHeight.constant = 20
        }
    }
    
}
