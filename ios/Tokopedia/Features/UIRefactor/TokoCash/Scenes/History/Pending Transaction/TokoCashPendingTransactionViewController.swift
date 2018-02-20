//
//  TokoCashPendingTransactionViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

public class TokoCashPendingTransactionViewController: UIViewController {
    
    @IBOutlet weak private var tableView: UITableView!
    
    // view model
    public var viewModel: TokoCashPendingTransactionViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Transaksi Menunggu"
        
        configureTableView()
        bindViewModel()
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
        
        output.selectedItem.drive().disposed(by: rx_disposeBag)
    }
    
    private func configureTableView() {
        let nib = UINib(nibName: "TokoCashHistoryListItemTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TokoCashHistoryListItemTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 88
        tableView.rowHeight = UITableViewAutomaticDimension
    }
}
