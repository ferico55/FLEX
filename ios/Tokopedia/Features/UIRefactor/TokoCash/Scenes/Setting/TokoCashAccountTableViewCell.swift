//
//  TokoCashAccountTableViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class TokoCashAccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var authDateLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    func bind(_ viewModel: TokoCashAccountViewModel) {
        identifierLabel.text = viewModel.identifier
        authDateLabel.text = viewModel.authDate
    }
}
