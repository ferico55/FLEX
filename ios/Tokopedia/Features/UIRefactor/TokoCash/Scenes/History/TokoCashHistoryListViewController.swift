//
//  TokoCashWalletHistoryListViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

public class TokoCashHistoryListViewController: UIViewController {
    
    @IBOutlet weak private var dateFilterView: UIView!
    @IBOutlet weak private var dateFilterLabel: UILabel!
    @IBOutlet weak private var pendingTransactionButton: UIButton!
    @IBOutlet weak private var pendingTransactionView: UIView!
    @IBOutlet weak private var dateFilterButton: UIButton!
    @IBOutlet weak private var collectionView: UICollectionView!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet private var emptyState: UIView!
    @IBOutlet private var emptyStateTopup: UIView!
    
    private let refreshControl = UIRefreshControl()
    
    // view model
    public var viewModel: TokoCashHistoryListViewModel!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Riwayat Transaksi"
        
        configureCollectionView()
        configureTableView()
        bindViewModel()
    }
    
    private func configureCollectionView() {
        let nib = UINib(nibName: "TokoCashFilterCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "TokoCashFilterCollectionViewCell")
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 94, height: 60)
        }
    }
    
    private func configureTableView() {
        let nib = UINib(nibName: "TokoCashHistoryListItemTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TokoCashHistoryListItemTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableViewAutomaticDimension
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    private func bindViewModel() {
        assert(viewModel != nil)
        
        let pull = refreshControl.rx
            .controlEvent(.valueChanged)
            .asDriver()
        
        let input = TokoCashHistoryListViewModel.Input(trigger: Driver.just(),
                                                       pullTrigger: pull,
                                                       pendingTransactionTrigger: pendingTransactionButton.rx.tap.asDriver(),
                                                       dateFilterTrigger: dateFilterButton.rx.tap.asDriver(),
                                                       filter: collectionView.rx.itemSelected.asDriver(),
                                                       selection: tableView.rx.itemSelected.asDriver(),
                                                       nextPageTrigger: tableView.rx_reachedBottom.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.fetching
            .drive(refreshControl.rx.isRefreshing)
            .disposed(by: rx_disposeBag)
        
        output.showPendingTransaction
            .drive(onNext: { isHidden in
                UIView.animate(withDuration: 0.3) {
                    self.pendingTransactionView.isHidden = isHidden
                }
            })
            .disposed(by: rx_disposeBag)
        
        output.dateString
            .drive(dateFilterLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.pendingTransaction
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.dateFilter
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.headers.drive(collectionView.rx.items(cellIdentifier: "TokoCashFilterCollectionViewCell", cellType: TokoCashFilterCollectionViewCell.self)) { _, viewModel, cell in
            cell.bind(viewModel)
        }.addDisposableTo(rx_disposeBag)
        
        output.showHeader
            .drive(collectionView.rx.isHidden)
            .addDisposableTo(rx_disposeBag)
        
        output.items.drive(tableView.rx.items(cellIdentifier: TokoCashHistoryListItemTableViewCell.reuseID, cellType: TokoCashHistoryListItemTableViewCell.self)) { _, viewModel, cell in
            cell.bind(viewModel)
        }.addDisposableTo(rx_disposeBag)
        
        output.isEmptyState
            .drive(onNext: { isEmptyState in
                self.tableView.backgroundView?.layer.opacity = isEmptyState ? 1.0 : 0.0
            }).addDisposableTo(rx_disposeBag)
        
        output.emptyState
            .drive(onNext: { type in
                guard type != "topup" else { self.tableView.backgroundView = self.emptyStateTopup; return }
                self.tableView.backgroundView = self.emptyState
            }).addDisposableTo(rx_disposeBag)
        
        output.selectedItem
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.page
            .drive()
            .disposed(by: rx_disposeBag)
    }
}
