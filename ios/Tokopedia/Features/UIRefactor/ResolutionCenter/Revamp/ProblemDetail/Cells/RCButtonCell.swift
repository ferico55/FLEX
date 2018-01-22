//
//  RCButtonCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 02/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class RCButtonCell: UITableViewCell {
    @IBOutlet weak var button: UIButton!
    var buttonHandler: (()->Void)?
    @IBAction private func buttonTapped(sender: UIButton) {
        if let handler = self.buttonHandler {
            handler()
        }
    }
    func markButtonHighlighted() {
        button.backgroundColor = UIColor.tpGreen()
        button.setTitleColor(.white, for: .normal)
        button.layer.borderWidth = 0.0
    }
    func markButtonEnabled() {
        button.backgroundColor = .white
        button.setTitleColor(UIColor(white: 0.0, alpha: 0.38), for: .normal)
        button.layer.borderWidth = 1.0
    }
    func markButtonDisabled() {
        button.backgroundColor = UIColor(white: 0.0, alpha: 0.12)
        button.setTitleColor(UIColor(white: 0.0, alpha: 0.38), for: .normal)
        button.layer.borderWidth = 0.0
    }
}
