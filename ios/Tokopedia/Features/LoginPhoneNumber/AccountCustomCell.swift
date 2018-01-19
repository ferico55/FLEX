//
//  CustomCell.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 11/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class AccountCustomCell: UIView {
    
    let nibName = "AccountCustomCell"
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }
    
    private func xibSetup() {
        Bundle.main.loadNibNamed(nibName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
}
