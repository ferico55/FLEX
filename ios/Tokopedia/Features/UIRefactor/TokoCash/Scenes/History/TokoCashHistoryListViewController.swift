//
//  TokoCashWalletHistoryListViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 9/6/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TokoCashHistoryListViewController: UIViewController, TokoCashDateFilterDelegate {
    
    @IBOutlet weak var dateFilterView: UIView!
    @IBOutlet weak var dateFilterLabel: UILabel!
    @IBOutlet weak var pendingTransactionButton: UIButton!
    @IBOutlet weak var pendingTransactionView: UIView!
    @IBOutlet weak var dateFilterButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var emptyState: UIView!
    @IBOutlet var emptyStateTopup: UIView!
    
    private let refreshControl = UIRefreshControl()
    private let isDateRange = Variable(true)
    private var dateRange: Variable<TokoCashDateRangeItem> = Variable(TokoCashDateRangeItem("7 Hari Terakhir", fromDate: Date.aWeekAgo(), toDate: Date(), selected: true))
    private let fromDate = Variable<Date>(Date.aWeekAgo())
    private let toDate = Variable<Date>(Date())
    
    // view model
    var viewModel: TokoCashHistoryListViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureRefreshControl()
        configureCollectionView()
        configureTableView()
        bindViewModel()
    }
    
    private func configureRefreshControl() {
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    private func configureCollectionView() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 94, height: 60)
        }
    }
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        tableView.backgroundView = emptyState
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
                                                       isDateRange: isDateRange.asDriver(),
                                                       dateRange: dateRange.asDriver(),
                                                       fromDate: fromDate.asDriver(),
                                                       toDate: toDate.asDriver(),
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
                UIView.animate(withDuration: 0.3){
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
        
        output.headers.drive(collectionView.rx.items(cellIdentifier: "filterCell", cellType: TokoCashFilterCollectionViewCell.self)) { tv, viewModel, cell in
            cell.bind(viewModel)
            }.addDisposableTo(rx_disposeBag)
        
        output.showHeader
            .drive(collectionView.rx.isHidden)
            .addDisposableTo(rx_disposeBag)
        
        output.items.drive(tableView.rx.items(cellIdentifier: TokoCashHistoryListItemTableViewCell.reuseID, cellType: TokoCashHistoryListItemTableViewCell.self)) { tv, viewModel, cell in
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
        
        output.filterItems
            .drive()
            .disposed(by: rx_disposeBag)
        
        output.nextPage
            .drive()
            .disposed(by: rx_disposeBag)
    }
    
    func getDateRange(_ selectedDateRange: TokoCashDateRangeItem, fromDate: Date, toDate: Date) {
        self.dateRange.value = selectedDateRange
        self.fromDate.value = fromDate
        self.toDate.value = toDate
    }
}
