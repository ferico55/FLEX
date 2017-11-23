//
//  ZipcodeRecommendationTableView.swift
//  Tokopedia
//
//  Created by Valentina Widiyanti Amanda on 11/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

@objc(ZipcodeRecommendationTableView)
class ZipcodeRecommendationTableView: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var allZipCodes: [String]?
    var shownZipCodes: [String]?
    var tableView: UITableView!
    var tableHeader: UIView!
    var textField: UITextField! {
        didSet {
            setupRx()
        }
    }
    
    var didSelectZipcode: ((String) -> Void)?
    
    override init() {
        super.init()
        tableView = UITableView()
        tableHeader = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 1))
        setTableView()
    }
    
    func setTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableHeader.backgroundColor = UIColor.tpBorder()
        tableView.tableHeaderView = tableHeader
        tableView.tableFooterView = tableHeader
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.allZipCodes != nil {
            return 1
        } else {return 0}
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let shown = self.shownZipCodes {
            return shown.count
        } else {return 0}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let shown = shownZipCodes {
            cell.textLabel?.text = shown[indexPath.row]
        }
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 9.0
        imageView.layer.borderColor = UIColor.tpBorder().cgColor
        imageView.layer.backgroundColor = UIColor.tpBorder().cgColor
        cell.accessoryView = imageView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let shownZipCodes = self.shownZipCodes {
            didSelectZipcode?(shownZipCodes[indexPath.row] as String)
            
            let selectedCell = tableView.cellForRow(at: indexPath)
            
            let img = UIImage(named: "icon_check_green")!
            let imgView:UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
            imgView.clipsToBounds = true
            imgView.contentMode = UIViewContentMode.scaleAspectFit
            imgView.backgroundColor = UIColor.clear
            imgView.image = img
            selectedCell?.accessoryView = imgView
        }
    }
    
    func setZipcodeCells(postalCodes: [String]?) -> Void {
        self.allZipCodes = postalCodes
        self.shownZipCodes = allZipCodes
        self.tableView.reloadData()
        
    }
    
    func setupRx() {
        textField.rx.text.orEmpty
        .subscribe(onNext: { [weak self] query in
            guard let `self` = self else {
                return
            }
            self.shownZipCodes = self.allZipCodes?.filter { $0.hasPrefix(query) }
            self.tableView.reloadData()
        })
        .addDisposableTo(rx_disposeBag)
    }
}
