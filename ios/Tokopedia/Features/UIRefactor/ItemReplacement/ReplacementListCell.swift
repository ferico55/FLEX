//
//  ReplacementListCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 3/13/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class ReplacementListCell: UITableViewCell {
    
    private var replacement: Replacement!
    
    lazy var thumbnail : UIImageView = {
        let thumb = UIImageView()
        return thumb
    }()
    
    lazy var dateExpired : UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(red: 185.0/255.0, green: 74.0/255.0, blue: 72.0/255.0, alpha: 1)
        label.textColor = UIColor.tpPrimaryWhiteText()
        label.font = UIFont.microTheme()
        return label
    }()
    
    lazy var replacementMultiplier: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        label.textColor = UIColor.tpPrimaryWhiteText()
        label.font = UIFont.microTheme()
        return label
    }()
    
    lazy var productName : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.tpPrimaryBlackText()
        label.font = UIFont.smallTheme()
        return label
    }()
    
    lazy var productPrice : UILabel = {
        let label = UILabel()
        label.textColor = UIColor.tpOrange()
        label.font = UIFont.smallTheme()
        return label
    }()

    init(replacement: Replacement) {
        super.init(style: .default , reuseIdentifier: "ReplacementListCell")
        
        self.replacement = replacement
        
        self.contentView.addSubview(thumbnail)
        thumbnail.setImageWithUrl(URL(string: (replacement.products.first?.thumbnailUrlString)!)!)
        thumbnail.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalTo(10)
            make.width.equalTo(55)
            make.height.equalTo(55)
        }
        
        self.contentView.addSubview(dateExpired)
        
        if let deadline = replacement.deadline {
            dateExpired.text = " \(deadline.processText) "
        } else {
            dateExpired.text = ""
        }
        
        dateExpired.backgroundColor = UIColor.fromHexString(replacement.deadline.backgroundColorHex)
        dateExpired.layer.masksToBounds = true
        dateExpired.layer.cornerRadius = 2
        dateExpired.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(self.thumbnail.snp.right).offset(15)
            make.height.equalTo(18)
        }
        
        self.contentView.addSubview(replacementMultiplier)
        
        if let multiplierText = replacement.multiplierText {
            replacementMultiplier.text = " \(multiplierText) "
        } else {
            replacementMultiplier.text = ""
        }
        
        replacementMultiplier.textColor = UIColor.fromHexString(replacement.multiplierColor)
        replacementMultiplier.layer.masksToBounds = true
        replacementMultiplier.layer.borderColor = UIColor.fromHexString(replacement.multiplierColor).cgColor
        replacementMultiplier.layer.borderWidth = 1
        replacementMultiplier.layer.cornerRadius = 2
        replacementMultiplier.snp.makeConstraints { make in
            make.left.equalTo(self.dateExpired.snp.right).offset(8)
            make.centerY.equalTo(self.dateExpired.snp.centerY)
            make.height.equalTo(18)
        }
        
        self.contentView.addSubview(productName)
        productName.text = replacement.products.first?.name
        productName.snp.makeConstraints { make in
            make.top.equalTo(self.dateExpired.snp.bottom).offset(2)
            make.left.equalTo(self.thumbnail.snp.right).offset(15)
            make.height.greaterThanOrEqualTo(18)
            make.rightMargin.equalTo(15)
        }
        
        self.contentView.addSubview(productPrice)
        productPrice.text = replacement.detail.totalPriceIdr
        productPrice.snp.makeConstraints { make in
            make.top.equalTo(self.productName.snp.bottom).offset(2)
            make.bottom.equalTo(-10)
            make.left.equalTo(self.thumbnail.snp.right).offset(15)
            make.height.equalTo(18)
        }
    
        self.accessoryType = .disclosureIndicator
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            self.backgroundColor = UIColor(colorLiteralRed: 232/255.0, green: 245/255.0, blue: 233/255.0, alpha: 1)
            self.dateExpired.backgroundColor = UIColor.fromHexString(self.replacement.deadline.backgroundColorHex)
        } else {
            self.backgroundColor = UIColor.white
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
