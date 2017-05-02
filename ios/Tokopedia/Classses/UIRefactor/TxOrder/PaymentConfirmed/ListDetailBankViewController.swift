//
//  ListDetailBankViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 3/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import AFNetworking
import Masonry
import RxSwift
import RxCocoa
import NSObject_Rx

class BankDetailCell : UITableViewCell {
    
    private lazy var cellImageView : UIImageView = {
        let cellImageView = UIImageView()
        cellImageView.contentMode = .scaleAspectFit
        return cellImageView
    }()
    
    private lazy var titleLabel : UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = UIFont.largeThemeMedium()
        titleLabel.textColor = UIColor.tpPrimaryBlackText()
        return titleLabel
    }()
    
    private lazy var descLabel : UILabel = {
        let descLabel = UILabel()
        descLabel.font = UIFont.microTheme()
        descLabel.textColor = UIColor.tpSecondaryBlackText()
        descLabel.numberOfLines = 0
        return descLabel
    }()
    
    init(bank: DetailBank) {
        super.init(style: .default , reuseIdentifier: "bankDetailCell")
        
        cellImageView.setImageWith(URL(string: bank.picture), placeholderImage: nil)
        self.contentView.addSubview(cellImageView)
        cellImageView.mas_makeConstraints { (make) in
            make?.height.equalTo()(38)
            make?.width.equalTo()(121)
            make?.top.equalTo()(21)
            make?.left.equalTo()(15)
        }
        
        titleLabel.text = bank.number
        self.contentView.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { (make) in
            make?.height.equalTo()(16)
            make?.left.equalTo()(self.cellImageView.mas_right)?.setOffset(20)
            make?.right.equalTo()(15)
            make?.top.equalTo()(15)
        }
        
        descLabel.text = "\(bank.accountName)\n\(bank.branch)"
        self.contentView.addSubview(descLabel)
        descLabel.mas_makeConstraints { (make) in
            make?.height.equalTo()(32)
            make?.left.equalTo()(self.titleLabel.mas_left)
            make?.top.equalTo()(self.titleLabel.mas_bottom)?.setOffset(5)
            make?.right.equalTo()(15)
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class ListDetailBankViewController: UIViewController {
    
    private var list : [DetailBank]!
    
    init(listBank:[DetailBank], title:String){
        list = listBank
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    private lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 76
        tableView.tableFooterView = UIView(frame:.zero)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        tableView.backgroundColor = UIColor.tpBackground()
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view = tableView
        Observable.from(list)
            .bindTo(tableView.rx.items) { (tableView, row, bank) in
                return BankDetailCell(bank: bank)
            }
            .disposed(by: rx_disposeBag)
        
    }
}
