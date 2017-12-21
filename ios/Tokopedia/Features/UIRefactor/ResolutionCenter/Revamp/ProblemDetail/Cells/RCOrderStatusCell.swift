//
//  RCOrderStatusCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 02/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
class RCOrderStatusCell: UITableViewCell {
    @IBOutlet private weak var reachedButton: UIButton!
    @IBOutlet private weak var notReachedButton: UIButton!
    @IBOutlet private weak var infoButton: UIButton!
    var reachedButtonHandler: (()->Void)?
    var notReachedButtonHandler: (()->Void)?
    var infoButtonHandler: (()->Void)?
    var isDeliveryDatePassed = false
    override func awakeFromNib() {
        super.awakeFromNib()
        self.infoButton.imageView?.contentMode = .scaleToFill
    }
//    MARK:- Actions
    @IBAction private func reachedButtonTapped(sender: UIButton) {
        self.select(reachedButton: true)
        if let handler = self.reachedButtonHandler {
            handler()
        }
    }
    @IBAction private func notReachedButtonTapped(sender: UIButton) {
        if !self.isDeliveryDatePassed {return}
        self.select(reachedButton: false)
        if let handler = self.notReachedButtonHandler {
            handler()
        }
    }
    @IBAction private func infoButtonTapped(sender: UIButton) {
        if let handler = self.infoButtonHandler {
            handler()
        }
    }
//    MARK:- Data update
    func updateWith(problemItem: RCProblemItem) {
        if let selectedStatus = problemItem.selectedStatus {
            if selectedStatus.delivered == true {
                self.select(reachedButton: true)
            } else {
                self.select(reachedButton: false)
            }
        }
    }
    func select(reachedButton: Bool) {
        self.infoButton.isHidden = self.isDeliveryDatePassed
        if self.isDeliveryDatePassed {
            if reachedButton {
                self.markButtonSelected(button: self.reachedButton)
                self.markButtonEnabled(button: self.notReachedButton)
            } else {
                self.markButtonSelected(button: self.notReachedButton)
                self.markButtonEnabled(button: self.reachedButton)
            }
        } else {
            self.markButtonSelected(button: self.reachedButton)
            self.markButtonDisabled(button: self.notReachedButton)
        }
    }
//    MARK:- Status Update
    func markButtonSelected(button: UIButton) {
        button.backgroundColor = UIColor.tpGreen()
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 0.0
    }
    func markButtonEnabled(button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(UIColor.tpGreen(), for: .normal)
        button.layer.borderWidth = 1.0
    }
    func markButtonDisabled(button: UIButton) {
        button.backgroundColor = UIColor.tpBorder()
        button.setTitleColor(UIColor(white: 0, alpha: 0.38), for: .normal)
        button.layer.borderWidth = 0.0
    }
}
