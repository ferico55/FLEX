//
//  ReplacementListHeaderView.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Masonry
import OAStackView

class ReplacementListHeaderView: UIView  {

    private lazy var annoucementView : UIView = {
        let annoucementView = UIView()
        annoucementView.backgroundColor = UIColor(red:255.0/255.0 , green: 252.0/255.0, blue: 211.0/255.0, alpha: 1)
        return annoucementView
    }()

    private lazy var announcementLabel : UILabel = {
        let announcementLabel = UILabel()
        announcementLabel.textAlignment = .center
        announcementLabel.font = UIFont.microTheme()
        announcementLabel.textColor = UIColor.tpSecondaryBlackText()
        announcementLabel.text = self.announcementString
        announcementLabel.numberOfLines = 0
        return announcementLabel
    }()
    
    private var announcementString : String = "Di halaman ini anda dapat mengambil pesanan yang ditolak oleh seller lain"
    
    private lazy var searchView : UIView = {
        let searchView = UIView()
        searchView.backgroundColor = UIColor.clear
        return searchView
    }()
    
    lazy var searchBar : UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Cari Produk"
        return searchBar
    }()
    
    init() {
        super.init(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height: 128))
        
        let stackView = OAStackView()
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        stackView.axisValue = 1

        annoucementView.addSubview(announcementLabel)
        stackView.addArrangedSubview(annoucementView)
        annoucementView.snp.makeConstraints { make in
            make.top.left.right.equalTo(0)
            make.height.greaterThanOrEqualTo(65)
        }
        announcementLabel.snp.makeConstraints { make in
            make.left.top.equalTo(18)
            make.bottom.right.equalTo(-18)
            make.height.greaterThanOrEqualTo(30)
        }
        
        searchView.addSubview(searchBar)
        stackView.addArrangedSubview(searchView)
        searchView.snp.makeConstraints { make in
            make.top.equalTo(self.annoucementView.snp.bottom)
            make.left.right.equalTo(0)
            make.height.equalTo(62)
        }
        searchBar.snp.makeConstraints { make in
            make.left.top.equalTo(0)
            make.bottom.right.equalTo(0)
            make.height.equalTo(42)
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
