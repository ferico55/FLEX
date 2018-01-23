//
//  SellerInfoInboxFilterViewController.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 04/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

// seller info filter currently must have atleast 1 active filter, and defaults to .forAll
class SellerInfoInboxFilterViewController: UIViewController {
    let tableView : UITableView = UITableView()
    let data      : [String]    = ["Semua", "For You", "Promo", "Insight", "Feature Update", "Event"]
    
    var onTapSelesai : ((_ selectedSectionId: SellerInfoItemSectionId) -> Void)? = nil
    var onTapX       : (() -> Void)? = nil
    
    var selectedSectionId: SellerInfoItemSectionId = .forAll // defaults to for all
    
    init(sectionId: SellerInfoItemSectionId) {
        super.init(nibName: nil, bundle: nil)
        self.selectedSectionId = sectionId
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setBarButton(withTitle: "Selesai", side: .right, font: UIFont.systemFont(ofSize: 14.0), textColor: UIColor(red: 66.0/255.0, green: 181.0/255.0, blue: 73.0/255.0, alpha: 1.0), action: #selector(SellerInfoInboxFilterViewController.didTapSelesai(_:)))
        self.setBarButton(withImage: #imageLiteral(resourceName: "icon_close_grey"), side: .left, action: #selector(SellerInfoInboxFilterViewController.didTapX(_:)))
        self.title = "Info Penjual"
        
        self.tableView.dataSource = self
        self.tableView.delegate   = self
        self.tableView.register(UINib(nibName: "SellerInfoInboxFilterCellView", bundle: nil), forCellReuseIdentifier: "sellerInfoInboxFilterCellIdentifier")
        self.tableView.tableFooterView = UIView() // remove footer view
        self.view.addSubview(self.tableView)
        self.tableView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1.0)
        // to allow us to alter table view layout margins/insets in ios 9/10
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
        
        self.tableView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.snp.top)
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        
        self.tableView.selectRow(at: IndexPath(row: self.selectedSectionId.rawValue, section: 0), animated: false, scrollPosition: .none)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func didTapX(_ sender: UITapGestureRecognizer) {
        self.onTapX?()
    }
    
    func didTapSelesai(_ sender: UITapGestureRecognizer) {
        self.onTapSelesai?(self.selectedSectionId)
    }
}

extension SellerInfoInboxFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "sellerInfoInboxFilterCellIdentifier") as? SellerInfoInboxFilterCellView else { fatalError("The dequeued cell is not an instance of sellerInfoInboxFilterCellIdentifier") }
        
        cell.titleLabel.text = self.data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let newSectionId = SellerInfoItemSectionId(rawValue: indexPath.row) {
            if self.selectedSectionId != newSectionId {
                self.selectedSectionId = newSectionId
            }
        }
        return
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.data.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56.0
    }
}
