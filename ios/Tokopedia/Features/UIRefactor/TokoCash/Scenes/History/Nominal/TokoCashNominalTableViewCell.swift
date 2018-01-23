//
//  TokoCashNominalTableViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 07/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class TokoCashNominalTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    func bind(_ viewModel: TokoCashNominalItemViewModel) {
        self.titleLabel.text = viewModel.title
    }
}
