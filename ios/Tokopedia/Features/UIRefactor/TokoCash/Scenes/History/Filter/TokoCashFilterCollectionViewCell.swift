//
//  TokoCashFilterCollectionViewCell.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class TokoCashFilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var filterTitle: UILabel!
    @IBOutlet weak var closeImageView: UIImageView!
    
    func bind(_ viewModel: TokoCashFilterViewModel) {
        filterTitle.text = viewModel.title
        filterView.layer.borderColor = viewModel.color.cgColor
        
        if viewModel.selected == true {
            filterTitle.textColor = .white
            filterView.backgroundColor = viewModel.color
            closeImageView.tintColor = viewModel.color
            closeImageView.isHidden = false
        }else {
            filterTitle.textColor = UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.7)
            filterView.backgroundColor = .white
            closeImageView.isHidden = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        self.contentView.translatesAutoresizingMaskIntoConstraints = false
    }
}
