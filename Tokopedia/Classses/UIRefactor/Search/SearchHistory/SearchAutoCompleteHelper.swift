//
//  SearchAutoCompleteHelper.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 3/1/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(SearchAutoCompleteHelper)
class SearchAutoCompleteHelper: NSObject {
    
    class func setBoldText(label: UILabel, searchText: String){
        let attributedText = NSMutableAttributedString(string: label.text!)
        
        let boldRange = NSString(string: label.text!).range(of: label.text!, options: .caseInsensitive)
        
        let thinRange = NSString(string: label.text!).range(of: searchText, options: .caseInsensitive)
        
        attributedText.setAttributes([NSFontAttributeName: UIFont.title2ThemeMedium()], range: boldRange)
        attributedText.addAttributes([NSFontAttributeName:UIFont.title2Theme() , NSForegroundColorAttributeName:UIColor.tpSecondaryBlackText()], range: thinRange)
        
        label.attributedText = attributedText
    }
}
