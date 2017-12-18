//
//  ReplacementListViewController.swift
//  Tokopedia
//
//  Created by Renny Runiawati on 2/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Masonry
import OAStackView
import RxSwift
import RxCocoa
import NSObject_Rx
import Moya

@objc(ReplacementListViewController)
class ReplacementListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var filterButton: UIButton!
    @IBOutlet var sortButton: UIButton!
    @IBOutlet var footerView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    let headerView : ReplacementListHeaderView = ReplacementListHeaderView()
    let refreshControl : UIRefreshControl = UIRefreshControl()
    let viewModel = ReplacementListViewModel()
    var splitView: UIViewController?
    lazy var noDataView : NoResultReusableView = {
        let noResultView = NoResultReusableView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:300))
        noResultView.setNoResultImage("icon_no_data_grey")
        noResultView.setNoResultTitle("Tidak ada peluang")
        noResultView.setNoResultDesc("")
        noResultView.hideButton(true)
        return noResultView
    }()
    lazy var failedToLoadView: NoResultReusableView = {
        let noResultView = NoResultReusableView(frame: CGRect(x:0, y:0, width:UIScreen.main.bounds.size.width, height:300))
        noResultView.setNoResultImage("icon_retry_grey")
        noResultView.setNoResultTitle("Kendala koneksi internet")
        noResultView.setNoResultDesc("Silakan mencoba kembali")
        noResultView.setNoResultButtonTitle("Coba kembali")
        return noResultView
    }()
    private var loadingView : LoadingView = LoadingView()
    
    var filterOptions = FilterData()
    var selectedFilter: Filters = Filters()
    var selectedFilterParameter: [String: String] = [:]
    var selectedSortParameter: [String: String] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupTableView()
        setupLoading()
        setupSearchBar()
        setupButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.trackScreenName("Replacement List Page")
    }
    
    func setupView() {
        self.title = "Peluang"
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            let backButtonItem = UIBarButtonItem(image: UIImage(named:"icon_arrow_white"), style: .plain, target: self, action: #selector(self.back))
            self.navigationItem.leftBarButtonItem = backButtonItem
        }
        
        tableView.backgroundColor = UIColor.tpBackground()
        tableView.tableHeaderView = self.headerView
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
        tableView.tableFooterView = self.footerView
        tableView.keyboardDismissMode = .onDrag
        tableView.addSubview(refreshControl)
    }
    
    func back() {
        splitView!.navigationController?.popViewController(animated: true)
    }
    
    func setupLoading() {
        refreshControl.rx.controlEvent(.valueChanged)
            .bindTo(viewModel.refreshTrigger)
            .disposed(by: rx_disposeBag)
        
        viewModel.loading.asObservable()
            .do(onNext: { isLoading in
                if(!isLoading) {
                    self.refreshControl.endRefreshing()
                }
            })
            .bindTo(isLoading(for: activityIndicator))
            .disposed(by: rx_disposeBag)
        
    }
    
    func isLoading(for act: UIActivityIndicatorView) -> AnyObserver<Bool> {
        return UIBindingObserver(UIElement: act, binding: { (act, isLoading) in
            switch isLoading {
            case true:
                AnalyticsManager.trackEventName("scrollPeluang", category: GA_EVENT_CATEGORY_REPLACEMENT, action: "Scroll", label: "Navigate page")
                self.tableView.tableFooterView = self.footerView
                act.startAnimating()
            case false:
                self.setupNoData(self.viewModel.rxReplacements.value.count == 0)
                if self.viewModel.currentPage == 1 &&
                    UI_USER_INTERFACE_IDIOM() == .pad &&
                    self.viewModel.rxReplacements.value.count > 0 {
                    self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
                    self.tableView.delegate?.tableView!(self.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
                }
                AnalyticsManager.trackEventName("loadPeluang", category: GA_EVENT_CATEGORY_REPLACEMENT, action: "Load", label: "\(self.viewModel.currentPage)")
                act.stopAnimating()
            }
        }).asObserver()
    }
    
    func setupTableView() {
        viewModel.rxReplacements
            .asDriver()
            .drive(self.tableView.rx.items) { (tableView, row, replacement) in
                let cell = ReplacementListCell(replacement: replacement)
                return cell
            }
            .disposed(by: rx_disposeBag)
        
        tableView.rx_reachedBottom
            .map{ _ in ()}
            .bindTo(viewModel.loadNextPageTrigger)
            .disposed(by: rx_disposeBag)
        
        tableView.rx
            .modelSelected(Replacement.self)
            .subscribe(onNext: { replacement in
                let vc = ReplacementDetailViewController(replacement)
                vc.didTakeReplacement = {
                    self.viewModel.refreshTrigger.onNext()
                }
                if UI_USER_INTERFACE_IDIOM() == .pad {
                    let navDetail = UINavigationController(rootViewController: vc)
                    self.splitViewController?.replaceDetailViewController(navDetail)
                } else {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: rx_disposeBag)
    }
    
    func setupButtons(){
        
        loadingView.buttonRetry.rx
            .tap
            .bindTo(viewModel.loadNextPageTrigger)
            .disposed(by: rx_disposeBag)
        
        noDataView.button.rx
            .tap
            .bindTo(viewModel.refreshTrigger)
            .disposed(by: rx_disposeBag)
        
        failedToLoadView.button.rx
            .tap
            .bindTo(viewModel.refreshTrigger)
            .disposed(by: rx_disposeBag)
        
        sortButton.rx
            .tap
            .subscribe(onNext: { [unowned self] in
                
                _ = FiltersController(
                    source: .replacement,
                    selectedSort: self.selectedFilter.sort,
                    presentedVC: self,
                    rootCategoryID:"" ,
                    onCompletion: { (selectedSort, sortParameter) in
                        
                    AnalyticsManager.trackEventName("clickPeluang", category: GA_EVENT_CATEGORY_REPLACEMENT, action: "Click", label: selectedSort.name)
                    
                    self.selectedFilter.sort = selectedSort
                    self.selectedSortParameter = sortParameter
                    self.viewModel.filter.value = self.selectedFilterParameter.merged(with: self.selectedSortParameter)
                    
                })
                
            })
            .disposed(by: rx_disposeBag)
        
        filterButton.rx
            .tap
            .subscribe(onNext: { [unowned self] in
                _ = FiltersController.init(
                    searchDataSource: .replacement,
                    filterResponse: self.filterOptions,
                    rootCategoryID: "",
                    selectedFilters: self.selectedFilter.filters,
                    presentedVC: self,
                    onCompletion: { (selectedFilters, filterParameter) in
                    
                    self.selectedFilter.filters = selectedFilters
                    self.selectedFilterParameter = filterParameter
                    self.viewModel.filter.value = self.selectedFilterParameter.merged(with: self.selectedSortParameter)
                    
                }, onReceivedFilterDataOption: { (filterOptions) in
                    self.filterOptions = filterOptions

                })
            })
            .disposed(by: rx_disposeBag)
    }
    
    func setupNoData(_ isNoData: Bool) {
        guard viewModel.isError == false else {
            if viewModel.rxReplacements.value.count > 0 {
                self.tableView.tableFooterView = self.loadingView
            } else {
                self.tableView.tableFooterView = self.failedToLoadView
                let detailViewController = UIViewController()
                detailViewController.view.backgroundColor = .tpBackground()
                let detailNav = UINavigationController(rootViewController: detailViewController)
                self.splitViewController?.replaceDetailViewController(detailNav)
            }
            return
        }
        
        switch isNoData {
            case true:
                self.tableView.tableFooterView = self.noDataView
                let detailViewController = UIViewController()
                detailViewController.view.backgroundColor = .tpBackground()
                let detailNav = UINavigationController(rootViewController: detailViewController)
                self.splitViewController?.replaceDetailViewController(detailNav)
                break
            case false:
                self.tableView.tableFooterView = UIView(frame:CGRect(x:0, y:0, width:1, height:1))
                break
        }
    }
    
    func setupSearchBar() {
        headerView.searchBar.rx
            .text
            .orEmpty
            .bindTo(viewModel.query)
            .disposed(by: rx_disposeBag)
        
        headerView.searchBar.rx
            .cancelButtonClicked
            .map{ "" }
            .bindTo(viewModel.query)
            .disposed(by: rx_disposeBag)
        
        headerView.searchBar.rx
            .searchButtonClicked
            .bindTo(viewModel.refreshTrigger)
            .disposed(by: rx_disposeBag)
        
        viewModel.query.asObservable().filter({ query -> Bool in
            return query != ""
        }).subscribe(onNext: { query in
            AnalyticsManager.trackEventName("submitPeluang", category: GA_EVENT_CATEGORY_REPLACEMENT, action: "Submit", label: query)
        }).disposed(by: rx_disposeBag)
    }
}
