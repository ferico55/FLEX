//
//  CategoryNavigationTableViewCell.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 6/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class CategoryNavigationTableViewCell: UITableViewCell {
    @IBOutlet private var arrowImageView: UIImageView!
    @IBOutlet private var categoryNameLabel: UILabel!
    
    @IBOutlet private var categoryNameLabelLeftConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setListOption(listOption: ListOption) {
        self.setCategoryName(name: listOption.name)
        if let hasChildCategories = listOption.hasChildCategories{
            if hasChildCategories {
                self.showArrowImage()
            } else {
                self.hideArrowImage()
            }
        }
    }
    
    func setCategoryNameIndentation(level: Int) {
        categoryNameLabelLeftConstraint.constant = CGFloat(10 * level)
    }
    
    private func setCategoryName(name: String) {
        self.categoryNameLabel.text = name
    }
    
    private func hideArrowImage() {
        self.arrowImageView.isHidden = true
    }
    
    private func showArrowImage() {
        self.arrowImageView.isHidden = false
    }
    
    private func rotateArrow() {
        self.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
    }
    
}
