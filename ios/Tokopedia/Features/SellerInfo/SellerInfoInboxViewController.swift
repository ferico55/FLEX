//
//  SellerInfoInboxViewController.swift
//  Tokopedia
//
//  Created by Hans Arijanto on 03/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import RxDataSources

class SellerInfoInboxViewController: UIViewController, NoResultDelegate {
    
    // ui
    let tableView : UITableView       = UITableView()
    
    private var filterButton         : UIView?           = nil
    private var refreshControl       : UIRefreshControl  = UIRefreshControl()
    private var bottomRefreshControl : UIRefreshControl  = UIRefreshControl()
    
    private var noResultsView : UIView?               = nil
    private var failedView    : NoResultReusableView? = nil
    
    // view model
    private(set) var viewModel : SellerInfoInboxViewModel = SellerInfoInboxViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Info Penjual"
        
        self.setupTableView()
        self.view.addSubview(self.tableView)
        
        self.setupRefreshControls()
        self.tableView.addSubview(refreshControl)
        
        // setup no results view
        self.setupNoResultsView()
        self.tableView.backgroundView = self.noResultsView
        
        self.setupFailedView()
        if let view = self.failedView {
            self.view.addSubview(view)
        }
        
        self.tableView.snp.makeConstraints({ (make) in
            make.top.equalTo(self.view.snp.top)
            make.left.equalTo(self.view.snp.left)
            make.right.equalTo(self.view.snp.right)
            make.bottom.equalTo(self.view.snp.bottom)
        })
        
        // setup filter button
        self.setupFilterButton()
        if let button = self.filterButton  {
            self.view.addSubview(button)
            button.snp.makeConstraints({ (make) in
                make.centerX.equalTo(self.view.snp.centerX)
                make.bottom.equalTo(self.view.snp.bottom).offset(-19.5)
                make.width.equalTo(120.0)
                make.height.equalTo(40.0)
            })
        }
        
        self.pullData() // grab items
    }
    
    // MARK: UI Setup (observable linking)
    // setup table and refresh conrol at top and bottom, and background view
    private func setupTableView() {

        self.tableView.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1.0)
        self.tableView.tableFooterView = UIView()
        self.tableView.tableHeaderView = UIView()
        
        let cellIdentifier = "sellerInfoInboxCellIdentifier"
        self.tableView.register(UINib(nibName: "SellerInfoInboxCellView", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        let dataSource = RxTableViewSectionedReloadDataSource<SellerInfoItemSectionModel>()
        dataSource.configureCell = { [weak self] ds, tv, ip, item in
            guard let `self` = self, let cell = tv.dequeueReusableCell(withIdentifier: cellIdentifier, for: ip) as? SellerInfoInboxCellView else { return UITableViewCell() } // make sure cell exist
            cell.titleLabel.text = item.title
            cell.thumbnail.setImageWith(URL(string: item.infoThumbnailUrl))
            cell.typeLabel.text = item.section.id.describe()
            cell.isReadMode(item.isRead) // update isRead mode
            cell.dateLabel.text = self.viewModel.formatForCell(item.createDate)
            return cell
        }
        
        dataSource.titleForHeaderInSection = { [weak self] ds, section in
            guard let `self` = self, let items = self.viewModel.items(section: section), let item = items.first else { return "" }
            return self.viewModel.formatForHeader(item.createDate)
        }
        
        self.viewModel.Osections.observeOn(MainScheduler.instance).bindTo(self.tableView.rx.items(dataSource: dataSource)).disposed(by: self.rx_disposeBag)
        self.tableView.delegate   = self
        // to allow us to alter table view layout margins/insets in ios 9/10
        self.tableView.cellLayoutMarginsFollowReadableWidth = false
    }
    
    private func setupRefreshControls() {
        // setup refresh controls
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(SellerInfoInboxViewController.didPullToRefresh(_:)), for: UIControlEvents.valueChanged)
    
        bottomRefreshControl.addTarget(self, action: #selector(SellerInfoInboxViewController.didPushToRefresh(_:)), for: UIControlEvents.valueChanged)
        bottomRefreshControl.triggerVerticalOffset = 100.0
        self.viewModel.hasNextPage.asObservable().observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] hasNext in
                guard let `self` = self else { return }
                self.tableView.bottomRefreshControl = hasNext ? self.bottomRefreshControl : nil
        }).disposed(by: self.rx_disposeBag)
        
        self.viewModel.pullingData.asObservable().observeOn(MainScheduler.instance)
            .subscribe(onNext: { [weak self] pullingData in
                guard let `self` = self else { return }
                
                // animate pull to refresh if we're pulling data for the first page
                if pullingData && self.viewModel.nextPage.value == 1 {
                    self.animatePullDownToRefresh()
                }

                if !pullingData {
                    self.refreshControl.endRefreshing()
                    self.bottomRefreshControl.endRefreshing()
                }
        }).disposed(by: self.rx_disposeBag)
    }
    
    // setup filter button and assign tap gesture
    private func setupFilterButton() {
        self.filterButton = UIView.loadFirstFromNib(name: "SellerInfoFilterButton", type: UIView.self, owner: self)
        self.filterButton?.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SellerInfoInboxViewController.didTapFilterButton(_:)))
        self.filterButton?.addGestureRecognizer(tapGesture)
    }
    
    private func setupNoResultsView() {
        self.noResultsView = UIView.loadFirstFromNib(name: "SellerInfoNoResultsView", type: UIView.self, owner: self)
        self.viewModel.OshouldHideNoResults.observeOn(MainScheduler.instance).bindTo(self.noResultsView!.rx.isHidden).disposed(by: self.rx_disposeBag)
    }
    
    private func setupFailedView() {
        let failedView = NoResultReusableView(frame: UIScreen.main.bounds)
        failedView.delegate        = self
        failedView.backgroundColor = UIColor.white
        failedView.isHidden        = true
        failedView.generateAllElements("icon_no_data_grey.png", title: "Whoops!\nTidak ada koneksi Internet", desc: "Harap coba lagi", btnTitle: "Coba Kembali")
        
        self.failedView = failedView
    }
    
    private func animatePullDownToRefresh() {
        if !self.refreshControl.isRefreshing {
            self.refreshControl.beginRefreshing()
        }
        let contentOffset = CGPoint(x: 0, y: -self.refreshControl.frame.height)
        self.tableView.setContentOffset(contentOffset, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Callbacks (button presses)
    // table view top pull to refresh
    func didPullToRefresh(_ sender: AnyObject) {
        self.resetData()
    }
    
    // table view bottom push to refresh
    func didPushToRefresh(_ sender: AnyObject) {
        self.pullData()
    }
    
    // setup filter button's callbacks and presents filter view
    func didTapFilterButton(_ sender: UITapGestureRecognizer) {
        let controller = SellerInfoInboxFilterViewController(sectionId: self.viewModel.filter)
        
        controller.onTapX = { [weak self] in
            guard let `self` = self else { return }
            self.didTapX()
        }
        
        controller.onTapSelesai = { [weak self] (filter) in
            guard let `self` = self else { return }
            self.didTapSelesai(filter)
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func didTapSelesai(_ filter: SellerInfoItemSectionId) {
        if self.viewModel.filter != filter {
            self.viewModel.filter = filter
            self.resetData()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    private func didTapX() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // no results reuseable view delegate (when coba kembali is pressed)
    func buttonDidTapped(_ sender: Any!) {
        self.failedView?.isHidden = true
        self.pullData() // grab items
    }
    
    // MARK: Data (network request, main data manipulation)
    // pulls data but resets pagination and current data
    private func resetData() {
        if self.viewModel.pullingData.value { return }
        // reset pagination and data
        self.viewModel.reset()
        // pull data
        self.pullData()
    }
    
    // setup and execute network request for more seller info items
    private func pullData() {
        if self.viewModel.pullingData.value { return }
        self.viewModel.pullingData.value = true
        
        let onSuccess: (_ dates: [String], _ groupedItems: [String: [SellerInfoItem]], _ hasNext: Bool)->Void = { [weak self] dates, groupedItems, hasNext in
            guard let `self` = self else { return }
            
            self.viewModel.pullingData.value = false
            
            // append data
            self.viewModel.add(dates)
            self.viewModel.add(groupedItems)
            
            self.viewModel.nextPage.value   += 1 // increment for pagination
            self.viewModel.hasNextPage.value = hasNext
        }
        
        let onFail: (_ error: Error)->Void = { [weak self] error in
            guard let `self` = self else { return }
            self.viewModel.pullingData.value = false
            
            // show failed view when we fail to grab data
            DispatchQueue.main.async {
                self.failedView?.isHidden = false
            }
        }
        
        // fetch seller info data
        let provider = NetworkProvider<SellerInfoTarget>()
        let target: SellerInfoTarget = .getAllInfo(page: self.viewModel.nextPage.value, filter: self.viewModel.filter)
        
        provider.request(target)
            .map(to: SellerInfoList.self)
            .subscribe(onNext: { list in
                let groupedList = list.groupedSellerInfoItems()
                onSuccess(groupedList.0, groupedList.1, list.hasNext)
            }, onError: { error in
                onFail(error)
            })
            .disposed(by: self.rx_disposeBag)
        
    }
}

// MARK: TableView Delegate (data source handled by Rx)
extension SellerInfoInboxViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = self.viewModel.item(indexPath: indexPath) {
            // this is a patch, sometime be returns an empty external link
            if item.externalLink.count > 0 {
                let vc = WebViewController()
                vc.strURL = item.externalLink
                vc.strTitle = item.title
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }

        self.tableView.deselectRow(at: indexPath, animated: true)
        return
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.semiboldSystemFont(ofSize: 13.0)
        header.textLabel?.textColor = UIColor.tpSecondaryBlackText()
        header.backgroundView?.backgroundColor = UIColor(red: 248.0/255.0, green: 248.0/255.0, blue: 248.0/255.0, alpha: 1.0)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 95.0
    }
}
