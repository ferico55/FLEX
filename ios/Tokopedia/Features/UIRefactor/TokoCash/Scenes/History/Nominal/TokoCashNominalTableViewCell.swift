//
//  TokoCashNominalTableViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 07/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

public class TokoCashNominalTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var titleLabel: UILabel!
    
    public func bind(_ viewModel: TokoCashNominalItemViewModel) {
        self.titleLabel.text = viewModel.title
    }
}
