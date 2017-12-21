//
//  ProblematicProductCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 12/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ProblematicProductCell: UITableViewCell {
    @IBOutlet private weak var productTitleLabel: UILabel!
    @IBOutlet private weak var freeReturnView: UIView!
    @IBOutlet private weak var productImageView: UIImageView!
    @IBOutlet private weak var checkboxButton: UIButton!
    var checkboxButtonHandler: ((_ cell: ProblematicProductCell)->Void)?
//    MARK:- Lifecycle
    override func prepareForReuse() {
        super.prepareForReuse()
        self.productImageView.cancelImageRequestOperation()
    }
    //    MARK:- Action
    @IBAction private func checkboxButtonTapped(sender: UIButton) {
        if let handler = self.checkboxButtonHandler {
            handler(self)
        }
    }
    func updateWithProblem(item: RCProblemItem) {
        if item.problem.type == 1 {
            self.productImageView.image = #imageLiteral(resourceName: "shippingChargeIssue")
        } else {
            if let imageUrl = URL(string: item.order.product.thumb) {
                self.productImageView.setImageWith(imageUrl)
            }
        }
        self.productTitleLabel.text = item.problem.name
        self.freeReturnView.isHidden = !item.order.detail.isFreeReturn
        if item.isSelected {
            self.checkboxButton.setImage(#imageLiteral(resourceName: "checkboxOn"), for: .normal)
        } else {
            self.checkboxButton.setImage(#imageLiteral(resourceName: "checkboxOff"), for: .normal)
        }
    }
}
