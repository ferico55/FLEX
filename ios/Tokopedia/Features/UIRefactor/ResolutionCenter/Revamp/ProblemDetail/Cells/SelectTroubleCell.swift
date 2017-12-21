//
//  SelectTroubleCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 07/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class SelectTroubleCell: UITableViewCell {
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var selectedMarkView: UIImageView!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.markSelected(selected: selected)
    }
    func markSelected(selected: Bool) {
        if selected {
            self.selectedMarkView.isHidden = false
            self.titleLabel.textColor = UIColor.tpGreen()
        } else {
            self.selectedMarkView.isHidden = true
            self.titleLabel.textColor = UIColor(white: 0.0, alpha: 0.7)
        }
    }
    func updateWith(trouble: RCTrouble) {
        self.titleLabel.text = trouble.name
    }
}
