//
//  MyWishlistSearchCollectionReusableView.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 1/23/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

@objc(MyWishlistSearchCollectionReusableView)
class MyWishlistSearchCollectionReusableView: UICollectionReusableView {

    @IBOutlet private (set) var searchResultCountLabel: UILabel!
    @IBOutlet var searchWishlistTextField: UITextField!
    
    var didTapResetButton: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        let spaceLoveIconView = UIView(frame: CGRectMake(0, 0, 30, 20))
    
        searchWishlistTextField.leftView = spaceLoveIconView
        searchWishlistTextField.leftViewMode = .Always
        
        let str = NSAttributedString(string: "Cari wishlist kamu", attributes: [NSForegroundColorAttributeName:UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.32)])
        searchWishlistTextField.attributedPlaceholder = str
        
        // Initialization code
    }
    @IBAction func didTapResetButton(sender: UIButton) {
        didTapResetButton?()
    }
    
}
