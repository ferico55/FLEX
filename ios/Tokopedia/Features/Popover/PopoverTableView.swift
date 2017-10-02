//
//  TablePopover.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 9/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Popover
import RxCocoa
import RxSwift

class PopoverItem: NSObject {
    var action: ((PopoverItem)->Void)?
    var title = ""
    
    init(title: String, action: ((PopoverItem)->Void)?) {
        self.action = action
        self.title = title
    }
}

class PopoverTableView: NSObject {
    
    func showFromView(_ view: UIButton, items: [PopoverItem]) {
        let popoverOptions: [PopoverOption] = [
            .type(.down),
            .blackOverlayColor(UIColor(white: 0.0, alpha: 0.6))
        ]
        
        let popover = Popover(options: popoverOptions)
        
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.size.width), height: items.count * 50))
        tableView.rowHeight = 50;
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        Observable.from(optional: items)
            .bindTo(tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { row, item, cell in
                cell.textLabel?.text = item.title
            }.disposed(by: view.rx_disposeBag)

        tableView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                let item = items[indexPath.row]
                item.action?(item)
                popover.dismiss()
            }).disposed(by: view.rx_disposeBag)

        tableView.isScrollEnabled = false

        popover.show(tableView, fromView: view)
    }
}
