//
//  GoodCountCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 02/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class GoodCountCell: UITableViewCell {
    @IBOutlet private weak var minusButton: UIButton!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var countLabel: UILabel!
    var quantity = 1
    var orderedQuantity = 0
    var valueChangedHandler: (()->Void)?
    func refresh() {
        if self.quantity < self.orderedQuantity {
            self.plusButton.setImage(#imageLiteral(resourceName: "plus_green"), for: .normal)
        } else {
            self.plusButton.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
        }
        if self.quantity > 1 {
            self.minusButton.setImage(#imageLiteral(resourceName: "minus_green"), for: .normal)
        } else {
            self.minusButton.setImage(#imageLiteral(resourceName: "minus"), for: .normal)
        }
        self.countLabel.text = "\(self.quantity)"
    }
    @IBAction private func minusButtonTapped(sender: UIButton) {
        if self.quantity > 1 {
            self.quantity -= 1
            self.refresh()
            if let handler = self.valueChangedHandler {
                handler()
            }
        }
    }
    @IBAction private func plusButtonTapped(sender: UIButton) {
        if self.quantity < self.orderedQuantity {
            self.quantity += 1
            self.refresh()
            if let handler = self.valueChangedHandler {
                handler()
            }
        }
    }
}
