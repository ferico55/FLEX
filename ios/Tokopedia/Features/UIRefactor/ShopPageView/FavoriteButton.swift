//
//  FavoriteButton.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 02/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

class FavoriteButton: UIButton {

    var isFavorite: Bool = false {
        didSet {
            self.updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func updateUI() {
        let green = UIColor(red: 0.259, green: 0.710, blue: 0.286, alpha: 1.00)
        var iconImage = self.isFavorite ? #imageLiteral(resourceName: "icon_check_favorited"):#imageLiteral(resourceName: "icon_follow_plus")
        iconImage = iconImage.withRenderingMode(.alwaysOriginal)
        
        self.setTitle(self.isFavorite ? "Favorit" : "Favoritkan", for: .normal)
        self.setTitleColor(self.isFavorite ? .gray : .white, for: .normal)
        self.setImage(iconImage, for: .normal)
        self.titleLabel?.font = UIFont.largeTheme()
        
        self.layer.borderWidth     = 1.0
        self.layer.cornerRadius    = 4.0
        self.layer.borderColor     = self.isFavorite ? UIColor.gray.cgColor : green.cgColor
        self.backgroundColor       = self.isFavorite ? .white : green
        self.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 8.0)
    }
}
