//
//  SolutionTextCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class SolutionTextCell: UITableViewCell {

    @IBOutlet private weak var solutionLabel: UILabel!
    @IBOutlet private weak var selectedMarkView: UIImageView!
    func markSelected(selected: Bool) {
        if selected {
            self.selectedMarkView.isHidden = false
            self.solutionLabel.textColor = UIColor.tpGreen()
        } else {
            self.selectedMarkView.isHidden = true
            self.solutionLabel.textColor = UIColor(white: 0.0, alpha: 0.54)
        }
    }
    func updateWith(solution: RCCreateSolution, selected: RCCreateSolution?) {
        self.solutionLabel.text = solution.name
        self.markSelected(selected: (solution.id == selected?.id))
    }
}
