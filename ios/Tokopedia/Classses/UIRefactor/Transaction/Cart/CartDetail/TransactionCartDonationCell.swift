//
//  TransactionCartDonationCell.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import OAStackView
import BEMCheckBox

class TransactionCartDonationCell: UITableViewCell {
    
    var donation : Donation!
    var onTapCheckBox :((Bool) -> Void)?
    
    lazy fileprivate var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = self.donation.title
        titleLabel.font = UIFont.largeTheme()
        return titleLabel
    }()
    
    lazy fileprivate var infoLabel: UILabel = {
        let infoLabel = UILabel()
        infoLabel.text = self.donation.info
        infoLabel.font = UIFont.microTheme()
        infoLabel.textColor = UIColor(red: 158.0/255, green: 158.0/255, blue: 158.0/255, alpha: 1)
        return infoLabel
    }()
    
    lazy fileprivate var checkBox: BEMCheckBox = {
        let checkBox = BEMCheckBox()
        checkBox.boxType = .square
        checkBox.lineWidth = 1
        checkBox.onTintColor = UIColor.white
        checkBox.onCheckColor = UIColor.white
        checkBox.onFillColor = UIColor(red: 66.0/255, green: 181.0/255, blue: 73.0/255, alpha: 1)
        checkBox.animationDuration = 0
        checkBox.delegate = self
        checkBox.accessibilityIdentifier = "donationCheckBox"
        checkBox.isAccessibilityElement = true
        return checkBox
    }()
    
    lazy fileprivate var infoButton: UIButton = {
        let infoButton = UIButton()
        infoButton.setImage(UIImage(named: "icon_info_grey_small"), for: .normal)
        infoButton.addTarget(self, action: #selector(TransactionCartDonationCell.didTapInfo), for: .touchUpInside)
        return infoButton
    }()
    
    init(donation: Donation) {
        super.init(style: .default , reuseIdentifier: "donationCell")
        self.accessibilityIdentifier = "donationCell"
        self.donation = donation
        self.configUI()
    }
    
    fileprivate func configUI(){
        self.contentView.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { (make) in
            make?.height.equalTo()(35)
            make?.left.equalTo()(15)
            make?.right.equalTo()(15)
            make?.top.equalTo()(5)
        }
        
        self.contentView.addSubview(checkBox)
        checkBox.mas_makeConstraints { (make) in
            make?.height.equalTo()(20)
            make?.width.equalTo()(20)
            make?.left.equalTo()(15)
            make?.top.equalTo()(self.titleLabel.mas_bottom)
        }
        
        self.contentView.addSubview(infoLabel)
        infoLabel.mas_makeConstraints { (make) in
            make?.height.equalTo()(20)
            make?.left.equalTo()(self.checkBox.mas_right)?.offset()(8)
            make?.top.equalTo()(self.titleLabel.mas_bottom)
        }
        
        self.contentView.addSubview(infoButton)
        infoButton.mas_makeConstraints { (make) in
            make?.height.equalTo()(20)
            make?.width.equalTo()(20)
            make?.left.equalTo()(self.infoLabel.mas_right)?.offset()(8)
            make?.top.equalTo()(self.titleLabel.mas_bottom)
        }
        
        self.checkBox.on = donation.isSelected
    }
    
    @objc fileprivate func didTapInfo(){
        let alert = AlertDonation.init(title: donation.popUpTitle, info: donation.popUpInfo, imageUrlString:donation.popUpImage)
        alert.show()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TransactionCartDonationCell: BEMCheckBoxDelegate {

    func didTap(_ checkBox: BEMCheckBox) {
        onTapCheckBox?(checkBox.on)
    }
    
}
