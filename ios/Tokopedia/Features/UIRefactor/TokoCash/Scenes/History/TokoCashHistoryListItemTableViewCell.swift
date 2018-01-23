//
//  TokoCashHistoryListItemTableViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class TokoCashHistoryListItemTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    func bind(_ viewModel: TokoCashHistoryListItemViewModel) {
        iconImageView.setImageWith(URL(string: viewModel.iconURI))
        titleLabel.text = viewModel.title
        descLabel.text = viewModel.desc
        dateLabel.text = viewModel.date
        amountLabel.text = viewModel.amount
        amountLabel.textColor = viewModel.amountColor
    }
}
