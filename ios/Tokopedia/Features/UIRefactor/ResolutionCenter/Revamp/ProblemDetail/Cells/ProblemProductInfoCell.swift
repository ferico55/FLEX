//
//  ProblemProductInfoCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 01/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProblemProductInfoCell: UITableViewCell {
    @IBOutlet private weak var productTitleLabel: UILabel!
    @IBOutlet private weak var freeReturnView: UIView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var productPriceLabel: UILabel!
    func updateWithProblem(item: RCProblemItem) {
        if let urlString = item.order?.product.thumb, let imageUrl = URL(string: urlString) {
            self.productImageView.setImageWith(imageUrl)
        }
        self.productTitleLabel.text = item.problem.name
        self.productPriceLabel.text = item.order?.product.amount.idr
        if let show = item.order?.detail.isFreeReturn {
            self.freeReturnView.isHidden = !show
        }
    }
}
