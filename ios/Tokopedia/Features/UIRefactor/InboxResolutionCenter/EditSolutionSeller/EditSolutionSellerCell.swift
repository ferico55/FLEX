//
//  EditSolutionSellerCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 8/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class EditSolutionSellerCell: UITableViewCell {
    @IBOutlet weak var freeReturnLogoImageView: UIImageView!
    @IBOutlet weak var troubleLabel: UILabel!
    @IBOutlet weak var troubleDescriptionLabel: UILabel!
    @IBOutlet weak var freeReturnViewHeight: NSLayoutConstraint!
    @IBOutlet weak var productNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setViewModel(_ viewModel:ProductResolutionViewModel) {
        troubleLabel.text = viewModel.productTrouble
        troubleDescriptionLabel.text = viewModel.productTroubleDescription
        productNameLabel.text = viewModel.productName
        
        if viewModel.isFreeReturn {
            freeReturnViewHeight.constant = 20
        } else {
            freeReturnViewHeight.constant = 0
        }
    }
    
}
