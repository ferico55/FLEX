//
//  TokoCashDateRangeItemTableViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 22/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

class TokoCashDateRangeItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    
    func bind(_ viewModel: TokoCashDateRangeItemViewModel) {
        titleLabel.text = viewModel.title
        descLabel.text = viewModel.desc
        
        self.accessoryType = viewModel.selected == true ? .checkmark : .none
    }
}
