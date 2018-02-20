//
//  TokoCashHistoryListItemTableViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 09/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

public class TokoCashHistoryListItemTableViewCell: UITableViewCell {

    @IBOutlet weak private var iconImageView: UIImageView!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var descLabel: UILabel!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var amountLabel: UILabel!
    
    public func bind(_ viewModel: TokoCashHistoryListItemViewModel) {
        iconImageView.setImageWith(URL(string: viewModel.iconURI))
        titleLabel.text = viewModel.title
        descLabel.text = viewModel.desc
        dateLabel.text = viewModel.date
        amountLabel.text = viewModel.amount
        amountLabel.textColor = viewModel.amountColor
    }
}
