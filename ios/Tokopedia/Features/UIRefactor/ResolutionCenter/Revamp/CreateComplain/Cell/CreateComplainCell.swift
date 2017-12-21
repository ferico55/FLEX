//
//  CreateComplainCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 11/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class CreateComplainCell: UITableViewCell {

    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
//    MARK:- Status Update
    func setCompleted() {
        self.containerView.backgroundColor = UIColor.white
        self.containerView.layer.borderColor = UIColor.tpGreen().cgColor
        self.arrowImageView.image = #imageLiteral(resourceName: "greenTick")
    }
    func setActive() {
        self.containerView.backgroundColor = UIColor.white
        self.containerView.layer.borderColor = UIColor(white: 0.0, alpha: 0.12).cgColor
        self.arrowImageView.image = #imageLiteral(resourceName: "rightArrow")
    }
    func setDisabled() {
        self.containerView.backgroundColor = UIColor.tpGray2()
        self.containerView.layer.borderColor = UIColor(white: 0.0, alpha: 0.12).cgColor
        self.arrowImageView.image = #imageLiteral(resourceName: "rightArrow")
    }
}
