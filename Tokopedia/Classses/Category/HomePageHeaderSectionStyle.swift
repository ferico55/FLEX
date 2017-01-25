//
//  HomePageHeaderSectionStyle.swift
//  Tokopedia
//
//  Created by Billion Goenawan on 1/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import OAStackView

class HomePageHeaderSectionStyle {
    
    class func setHeaderTitle(forStackView stackView: OAStackView, title: String) {
        let categoryTitlelabel: UILabel = UILabel()
        categoryTitlelabel.text = title
        categoryTitlelabel.font = UIFont.largeTheme()
        categoryTitlelabel.textColor = UIColor(red: 102.0/255, green: 102.0/255, blue: 102.0/255, alpha: 1.0)
        categoryTitlelabel.mas_makeConstraints({ (make) in
            make.height.equalTo()(38)
        })
        stackView.addArrangedSubview(categoryTitlelabel)
    }
    
    class func setHeaderUpperSeparator(forStackView stackView: OAStackView) {
        let upperSeparatorView = UIView()
        upperSeparatorView.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(2)
        })
        let tinyOrangeView = UIView()
        tinyOrangeView.backgroundColor = UIColor(red: 255.0/255, green: 87.0/255, blue: 34.0/255, alpha: 1.0)
        tinyOrangeView.frame = CGRect(x: 0, y: 0, width: 20, height: 2)
        upperSeparatorView.addSubview(tinyOrangeView)
        stackView.addArrangedSubview(upperSeparatorView)
        let topEmptyView = UIView()
        topEmptyView.mas_makeConstraints({ (make) in
            make.height.mas_equalTo()(15)
        })
        stackView.addArrangedSubview(topEmptyView)
    }
}
