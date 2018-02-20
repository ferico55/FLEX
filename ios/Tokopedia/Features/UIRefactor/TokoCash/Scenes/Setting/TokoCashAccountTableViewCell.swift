//
//  TokoCashAccountTableViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

public class TokoCashAccountTableViewCell: UITableViewCell {
    
    @IBOutlet weak private var identifierLabel: UILabel!
    @IBOutlet weak private var authDateLabel: UILabel!
    @IBOutlet weak public var deleteButton: UIButton!
    
    public func bind(_ viewModel: TokoCashAccountViewModel) {
        identifierLabel.text = viewModel.identifier
        authDateLabel.text = viewModel.authDate
    }
}
