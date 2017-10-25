//
//  ListBankViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 3/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Masonry
import RxSwift
import RxCocoa
import NSObject_Rx

struct Bank {
    let name: String
    let picture: String
    let accountBanks: [DetailBank]
}

struct DetailBank {
    let number: String
    let branch: String
    let picture: String
    let accountName: String
}

class BankCell : UITableViewCell {
    
    private lazy var cellImageView : UIImageView = {
        let cellImageView = UIImageView()
        cellImageView.contentMode = .scaleAspectFit
        return cellImageView
    }()
    
    private let titleLabel = UILabel()
   
    init(bank: Bank) {
        super.init(style: .default , reuseIdentifier: "bankCell")
        
        cellImageView.setImageWith(URL(string: bank.picture)!)
        self.contentView.addSubview(cellImageView)
        cellImageView.mas_makeConstraints { (make) in
            make?.height.equalTo()(35)
            make?.width.equalTo()(64)
            make?.top.equalTo()(21)
            make?.left.equalTo()(15)
        }
        
        titleLabel.text = bank.name
        self.contentView.addSubview(titleLabel)
        titleLabel.mas_makeConstraints { (make) in
            make?.height.equalTo()(76)
            make?.left.equalTo()(self.cellImageView.mas_right)?.setOffset(20)
            make?.right.equalTo()(15)
            make?.top.equalTo()(0)
        }
        self.accessoryType = .disclosureIndicator
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class ListBankViewController: UIViewController {
    
    fileprivate let listBank = [
        Bank(
            name: "Bank BCA",
            picture: "https://ecs7.tokopedia.net/img/icon-bca.png",
            accountBanks: [
                DetailBank(
                    number: "178 303 7878",
                    branch: "BCA Permata Hijau",
                    picture: "https://ecs7.tokopedia.net/img/icon-bca.png",
                    accountName: "a/n PT. Tokopedia"
                ),
                DetailBank(
                    number: "372 309 8781",
                    branch: "BCA Kedoya Permai",
                    picture: "https://ecs7.tokopedia.net/img/icon-bca.png",
                    accountName: "a/n PT. Tokopedia"
                ),
                DetailBank(
                    number: "372 177 3939",
                    branch: "BCA Kedoya Permai",
                    picture: "https://ecs7.tokopedia.net/img/icon-bca.png",
                    accountName: "a/n PT. Tokopedia"
                ),
                DetailBank(
                    number: "372 178 5066",
                    branch: "BCA Kedoya Permai",
                    picture: "https://ecs7.tokopedia.net/img/icon-bca.png",
                    accountName: "a/n PT. Tokopedia"
                )
            ]
        ),
        Bank(
            name: "Bank Mandiri",
            picture: "https://ecs7.tokopedia.net/img/icon-mandiri.png",
            accountBanks: [
                DetailBank(
                    number: "102-00-0526387-3",
                    branch: "Mandiri Permata Hijau",
                    picture: "https://ecs7.tokopedia.net/img/icon-mandiri.png",
                    accountName: "a/n PT. Tokopedia"
                ),
                DetailBank(
                    number: "1650070070017",
                    branch: "Mandiri Kebon Jeruk",
                    picture: "https://ecs7.tokopedia.net/img/icon-mandiri.png",
                    accountName: "a/n PT. Tokopedia"
                ),
                DetailBank(
                    number: "1650030073333",
                    branch: "Mandiri Kebon Jeruk",
                    picture: "https://ecs7.tokopedia.net/img/icon-mandiri.png",
                    accountName: "a/n PT. Tokopedia"
                )
            ]
        ),
        Bank(
            name: "Bank BNI",
            picture: "https://ecs7.tokopedia.net/img/icon-bni.png",
            accountBanks: [
                DetailBank(
                    number: "800 600 6009",
                    branch: "BNI Kebon Jeruk",
                    picture: "https://ecs7.tokopedia.net/img/icon-bni.png",
                    accountName: "a/n PT. Tokopedia"
                )
            ]
        ),
        Bank(
            name: "Bank BRI",
            picture: "https://ecs7.tokopedia.net/img/icon-bri.png",
            accountBanks: [
                DetailBank(
                    number: "037 701 000 435 301",
                    branch: "BRI Kebon Jeruk",
                    picture: "https://ecs7.tokopedia.net/img/icon-bri.png",
                    accountName: "a/n PT. Tokopedia"
                ),
                DetailBank(
                    number: "037 701 000 692 301",
                    branch: "BRI Kebon Jeruk",
                    picture: "https://ecs7.tokopedia.net/img/icon-bri.png",
                    accountName: "a/n PT. Tokopedia"
                )
            ]
        ),
        Bank(
            name: "Bank CIMB Niaga",
            picture: "https://ecs7.tokopedia.net/img/Logo-CIMB.png",
            accountBanks: [
                DetailBank(
                    number: "1770100731002",
                    branch: "CIMB Tomang Tol",
                    picture: "https://ecs7.tokopedia.net/img/Logo-CIMB.png",
                    accountName: "a/n PT. Tokopedia"
                )
            ]
        )
    ]
    
    private lazy var tableView : UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 76
        tableView.backgroundColor = UIColor.tpBackground()
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        tableView.tableFooterView = UIView(frame: .zero)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Rekening Tokopedia"
        
        self.view = tableView
        Observable.from(listBank)
            .bindTo(tableView.rx.items) { (tableView, row, bank) in
                return BankCell(bank: bank)
            }
            .disposed(by: rx_disposeBag)
        
        tableView.rx
            .itemSelected
            .map { [unowned self] in self.listBank[$0.row] }
            .subscribe(onNext: { bank in
                let vc = ListDetailBankViewController(listBank:bank.accountBanks, title:bank.name)
                self.navigationController?.pushViewController(vc, animated:true)
            })
            .disposed(by: rx_disposeBag)
        
    }
}
