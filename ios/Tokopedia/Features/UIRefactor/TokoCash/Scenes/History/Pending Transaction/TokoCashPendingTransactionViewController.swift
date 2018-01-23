//
//  TokoCashPendingTransactionViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TokoCashPendingTransactionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    // view model
    var viewModel: TokoCashPendingTransactionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        bindViewModel()
    }
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .mapToVoid()
            .asDriverOnErrorJustComplete()
        let input = TokoCashPendingTransactionViewModel.Input(trigger: viewWillAppear,
                                                              selection: tableView.rx.itemSelected.asDriver())
        let output = viewModel.transform(input: input)
        
        output.items.drive(tableView.rx.items(cellIdentifier: TokoCashHistoryListItemTableViewCell.reuseID, cellType: TokoCashHistoryListItemTableViewCell.self)) { _, viewModel, cell in
            cell.bind(viewModel)
        }.addDisposableTo(rx_disposeBag)
        
        output.selectedItem
            .drive()
            .disposed(by: rx_disposeBag)
    }
}
