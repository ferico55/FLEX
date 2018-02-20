//
//  TokoCashFilterCollectionViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

public class TokoCashFilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak private var filterView: UIView!
    @IBOutlet weak private var filterTitle: UILabel!
    @IBOutlet weak private var closeImageView: UIImageView!
    
    public func bind(_ viewModel: TokoCashFilterViewModel) {
        filterTitle.text = viewModel.title
        filterView.layer.borderColor = viewModel.color.cgColor
        
        if viewModel.selected == true {
            filterTitle.textColor = .white
            filterView.backgroundColor = viewModel.color
            closeImageView.tintColor = viewModel.color
            closeImageView.isHidden = false
        }else {
            filterTitle.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6999999881)
            filterView.backgroundColor = .white
            closeImageView.isHidden = true
        }
    }
}
