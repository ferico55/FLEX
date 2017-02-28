//
//  SearchAutoCompleteCategoryCell.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 2/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Foundation

class SearchAutoCompleteCategoryCell: UICollectionViewCell {

    @IBOutlet private var categoryLabel: UILabel!
    @IBOutlet private (set) var searchTextLabel: UILabel!

    var didTapAutoFillButton: ((_ searchText: String) -> Void)?
    
    @IBAction private func didTapAutoFillButton(_ sender: UIButton) {
        didTapAutoFillButton?(searchTextLabel.text!)
    }
    
    func setSearchItem(item: SearchSuggestionItem) {
        categoryLabel.text = item.recom
        searchTextLabel.text = item.keyword
    }
    
    func setGreenSearchText(searchText: String) {
        guard searchText != "" else { return }
        
        let attributedText = NSMutableAttributedString(string: searchTextLabel.text!)
        let range = NSString(string: searchTextLabel.text!).range(of: searchText, options: .caseInsensitive)
        
        attributedText.setAttributes([NSForegroundColorAttributeName: UIColor.tpGreen()], range: range)
        
        searchTextLabel.attributedText = attributedText
        
    }
    
    
}
