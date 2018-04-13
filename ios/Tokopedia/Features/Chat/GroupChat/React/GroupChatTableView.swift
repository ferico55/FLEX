//
//  GroupChatTableView.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 23/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Foundation
import React
import SwiftyJSON
import UIKit

public protocol GroupChatTableViewDelegate: class {
    func scrollToEnd()
    func appendNewMessage(data: ChatItem)
    func loadMoreData(data: GroupChatDataSources, scrolling: Bool)
    func onPressItem(customType: String, data: [String:Any])
}

@objc internal class GroupChatTableView: UIView, UITableViewDelegate, UITableViewDataSource, GroupChatTableViewDelegate {
    private var dataSource: GroupChatDataSources?
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        
        tableView.register(GroupChatPlainMessageCell.nib(), forCellReuseIdentifier: GroupChatPlainMessageCell.cellReuseIdentifier())
        tableView.register(GroupChatJoinCell.nib(), forCellReuseIdentifier: GroupChatJoinCell.cellReuseIdentifier())
        tableView.register(GroupChatPollingCell.nib(), forCellReuseIdentifier: GroupChatPollingCell.cellReuseIdentifier())
        tableView.register(GroupChatSprintSaleCell.nib(), forCellReuseIdentifier: GroupChatSprintSaleCell.cellReuseIdentifier())
        tableView.register(GroupChatAnnouncementCell.nib(), forCellReuseIdentifier: GroupChatAnnouncementCell.cellReuseIdentifier())
        tableView.register(GroupChatGratificationCell.nib(), forCellReuseIdentifier: GroupChatGratificationCell.cellReuseIdentifier())
        
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.delegate = self
        tableView.dataSource = self
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.sectionHeaderHeight = 1
        tableView.estimatedRowHeight = 100
        tableView.backgroundColor = .white
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.frame = self.frame
        return tableView
    }()
    
    internal var onScroll: RCTDirectEventBlock?
    internal var onScrollBegin: RCTDirectEventBlock?
    internal var onPressItem: RCTDirectEventBlock?
    internal var onPressRow: RCTDirectEventBlock?
    internal var initialData: NSArray? {
        set {
            if let newValue = newValue {
                let data = JSON(newValue)
                self.dataSource = GroupChatDataSources(json: data)
            }
        } get {
            return nil
        }
    }
    
    internal override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = self.bounds
        self.addSubview(self.tableView)
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Tableview Delegate & Datasource
    
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataSource?.list.count ?? 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource?.list[section].data.count ?? 1
    }
    
    internal func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = self.dataSource?.list[section].title ?? "Header"
        label.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0)
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.38)
        label.transform = CGAffineTransform(scaleX: 1, y: -1)
        label.textAlignment = .center
        return label
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let type = self.dataSource?.list[indexPath.section].data[indexPath.row].customType else {
            return UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
        
        switch type {
        case .join:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatJoinCell.cellReuseIdentifier()) as? GroupChatJoinCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            cell.setupView(data: self.dataSource?.list[indexPath.section].data[indexPath.row])
            return cell
        case .announcement:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatAnnouncementCell.cellReuseIdentifier()) as? GroupChatAnnouncementCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            cell.setupView(data: self.dataSource?.list[indexPath.section].data[indexPath.row])
            return cell
        case .pollingStart, .pollingFinish:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatPollingCell.cellReuseIdentifier()) as? GroupChatPollingCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            
            cell.setupView(data: self.dataSource?.list[indexPath.section].data[indexPath.row], pollingType: type)
            return cell
        case .normal, .chat, .generatedMsg:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatPlainMessageCell.cellReuseIdentifier()) as? GroupChatPlainMessageCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            cell.setupView(data: self.dataSource?.list[indexPath.section].data[indexPath.row], type: type)
            return cell
        case .flashsaleStart, .flashsaleEnd:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatSprintSaleCell.cellReuseIdentifier()) as? GroupChatSprintSaleCell, let products = self.dataSource?.list[indexPath.section].data[indexPath.row].data?["products"] as? NSArray , products.count == 2 else {
                let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
                cell.translatesAutoresizingMaskIntoConstraints = false
                cell.heightAnchor.constraint(equalToConstant: 0.0)
                return cell
            }
            cell.delegate = self
            cell.setupView(data: self.dataSource?.list[indexPath.section].data[indexPath.row], type: type)
            return cell
        case .gratificationMsg:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: GroupChatGratificationCell.cellReuseIdentifier()) as? GroupChatGratificationCell else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            cell.delegate = self
            cell.setupView(data: self.dataSource?.list[indexPath.section].data[indexPath.row])
            return cell
        default:
            return UITableViewCell(style: .default, reuseIdentifier: "cell")
        }
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let data = self.dataSource?.list[indexPath.section].data[indexPath.row] {
            var dictionary = ["customType": data.customType.rawValue] as [String: Any]
            if(data.customType == .flashsaleStart){
                dictionary["data"] = [
                    "campaign_id": data.data?["campaign_id"]
                    ] as [String : Any ]
            }
            self.onPressRow?(dictionary)
        }
    }
    
    internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let type = self.dataSource?.list[indexPath.section].data[indexPath.row].customType else {
            return UITableViewAutomaticDimension
        }
        
        switch type {
        case .pollingCancel, .pollingUpdate, .flashsaleUpcoming, .vibrateMsg:
            return 0.0
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    internal func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let type = self.dataSource?.list[indexPath.section].data[indexPath.row].customType else {
            return UITableViewAutomaticDimension
        }
        
        switch type {
        case .pollingCancel, .pollingUpdate, .flashsaleUpcoming, .vibrateMsg:
            return 0.0
        default:
            return UITableViewAutomaticDimension
        }
    }
    
    internal func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.onScroll == nil {
            return
        }
        
        let contentOffset = [
            "x": tableView.contentOffset.x,
            "y": tableView.contentOffset.y
        ]
        
        let contentSize = [
            "height": tableView.contentSize.height
        ]
        
        let eventDict = [
            "target": self.reactTag,
            "contentOffset": contentOffset,
            "contentSize": contentSize
        ] as [NSObject: AnyObject]
        
        self.onScroll?(eventDict)
    }
    
    internal func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.onScrollBegin?(["beginScroll":true])
    }
    
    // MARK: GroupChatTV Delegate
    @objc internal func scrollToEnd() {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc internal func appendNewMessage(data: ChatItem) {
        self.dataSource?.list.first?.data.insert(data, at: 0)
        self.tableView.reloadData()
    }
    
    @objc internal func loadMoreData(data: GroupChatDataSources, scrolling:Bool) {
        let oldContentHeight: CGFloat = tableView.contentSize.height
        let oldOffsetY: CGFloat = tableView.contentOffset.y
        
        self.dataSource = data
        self.tableView.reloadData()
        if !scrolling {
            self.tableView.layoutIfNeeded()
            let newContentHeight: CGFloat = tableView.contentSize.height
            var calculation = oldOffsetY + (newContentHeight - oldContentHeight)
            if(calculation < 0){
                calculation = 0
            }
            let newContentOffset = CGPoint(x: 0, y: calculation)
            self.tableView.setContentOffset(newContentOffset, animated: false)
        }
    }
    
    @objc internal func onPressItem(customType: String, data: [String:Any]) {
        let dictionary = [
            "customType": customType,
            "data": data
        ] as [String: Any]
        
        self.onPressItem?(dictionary)
    }
}
