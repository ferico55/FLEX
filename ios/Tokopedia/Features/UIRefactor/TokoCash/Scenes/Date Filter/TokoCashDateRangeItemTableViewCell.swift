//
//  TokoCashDateRangeItemTableViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 22/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation

public class TokoCashDateRangeItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descLabel: UILabel!
    
    public func bind(_ viewModel: TokoCashDateRangeItemViewModel) {
        titleLabel.text = viewModel.title
        descLabel.text = viewModel.desc
        
        self.accessoryType = viewModel.selected == true ? .checkmark : .none
    }
}
