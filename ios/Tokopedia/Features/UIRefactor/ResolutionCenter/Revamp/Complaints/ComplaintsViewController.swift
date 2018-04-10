//
//  ComplaintsViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 26/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import Moya
import UIKit

@objc
internal enum ComplaintUserType: Int {
    case seller
    case customer
}

internal class ComplaintsViewController: UIViewController {
    
    // MARK: outlets
    @IBOutlet internal weak var tableView: UITableView!
    @IBOutlet internal weak var inboxEmptyView: UIView!
    @IBOutlet internal weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet internal weak var imgViewEmptyInbox: UIImageView!
    @IBOutlet internal weak var lblTitleEmptyInbox: UILabel!
    @IBOutlet internal weak var lblMessageEmptyInbox: UILabel!
    @IBOutlet internal weak var btnResetFilter: UIButton!
    
    // MARK: variables
    fileprivate var headerView: UICollectionView?
    fileprivate var complaints: [ComplaintInbox] = []
    fileprivate let cellReuseIdentifier = "complaintTableViewCell"
    fileprivate let filterCellReuseIdentifier = "complaintFilterCollectionViewCell"
    fileprivate let collectionViewHeight: CGFloat = 75
    fileprivate let refreshControl = UIRefreshControl()
    fileprivate var quickFilters: [ComplaintQuickFilterData] = []
    fileprivate var selectedFilters: [String] = []
    fileprivate var btnSortFilterView: FloatingSortFilterViewController?
    fileprivate var quickSorts: [SimpleOnOffListObject] = [
        SimpleOnOffListObject(title: "Komplain Terbaru", isSelected: true),
        SimpleOnOffListObject(title: "Komplain Terlama", isSelected: false),
        SimpleOnOffListObject(title: "Terakhir Dibalas", isSelected: false)
    ]
    fileprivate let sort: [[String: String]] = [
        ["sortBy": "2", "asc": "0"],
        ["sortBy": "2", "asc": "1"],
        ["sortBy": "1", "asc": "0"]
    ]
    fileprivate var selectedSortIndex = 0
    fileprivate var isBusy = false
    
    fileprivate let limit = "10"
    fileprivate var startId = ""
    fileprivate var startTime = ""
    fileprivate var endTime = ""
    
    fileprivate var stateChanged = false
    fileprivate var firstLoad = true
    
    fileprivate var canLoadMore = false
    
    fileprivate var cellHeights: [IndexPath: CGFloat] = [:]
    
    fileprivate let placeholderImage = UIImage(color: .tpGray())
    
    @objc
    internal var userType: ComplaintUserType = .customer
    
    internal init(userType: ComplaintUserType) {
        super.init(nibName: nil, bundle: nil)
        
        self.userType = userType
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        switch userType {
        case .customer:
            self.title = "Komplain Sebagai Pembeli"
        case .seller:
            self.title = "Komplain Sebagai Penjual"
        }
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        
        refreshControl.addTarget(self, action: #selector(refreshComplaints), for: .valueChanged)
        
        tableView.register(UINib(nibName: "ComplaintTableViewCell", bundle: nil), forCellReuseIdentifier: cellReuseIdentifier)
        tableView.rowHeight = UITableViewAutomaticDimension
        
        headerView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: collectionViewHeight), collectionViewLayout: UICollectionViewFlowLayout())
        headerView?.delegate = self
        headerView?.dataSource = self
        headerView?.register(UINib(nibName: "ComplaintFilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: filterCellReuseIdentifier)
        headerView?.contentInset = UIEdgeInsets(top: 16, left: 8, bottom: 16, right: 0)
        headerView?.backgroundColor = UIColor.clear
        headerView?.bounces = true
        if let flowLayout = headerView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 8
            flowLayout.estimatedItemSize = .zero
            flowLayout.scrollDirection = .horizontal
        }
        
        btnSortFilterView = FloatingSortFilterViewController()
        if let btnSortFilterView = btnSortFilterView {
            self.addChildViewController(btnSortFilterView)
            btnSortFilterView.view.widthAnchor.constraint(equalToConstant: 194).isActive = true
            btnSortFilterView.view.heightAnchor.constraint(equalToConstant: 35).isActive = true
            btnSortFilterView.view.frame.origin.y = self.view.frame.height - 35 - 16
            self.view.addSubview(btnSortFilterView.view)
            btnSortFilterView.view.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            btnSortFilterView.view.bottomAnchor.constraint(equalTo: view.safeAreaBottomAnchor, constant: -16).isActive = true
            
            btnSortFilterView.delegate = self
        }
        
        activityIndicator.startAnimating()
        btnSortFilterView?.view.isHidden = true
        requestComplaints(append: true)
    }

    internal override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    internal func refreshComplaints() {
        startId = ""
        
        if isBusy {
            stateChanged = true // just notify to redo request
        }
        else {
            requestComplaints(append: false)
        }
    }
    
    fileprivate func requestComplaints(append: Bool) {
        if isBusy {
            return
        }
        
        isBusy = true
        
        let sortBy = sort[selectedSortIndex]["sortBy"]
        let asc = sort[selectedSortIndex]["asc"]
        var filterBy = ""
        selectedFilters = []
        for filter in quickFilters where filter.isSelected {
            if !filterBy.isEmpty {
                filterBy.append(",")
            }
            filterBy.append(filter.value)
            selectedFilters.append(filter.value)
        }
        if !startTime.isEmpty {
            if !filterBy.isEmpty {
                filterBy.append(",")
            }
            filterBy.append("4")
        }
        
        var target = RCService.getInboxBuyer(limit: limit, startId: startId, sortBy: sortBy ?? "2", asc: asc ?? "0", filter: filterBy, startTime: startTime, endTime: endTime)
        if userType == .seller {
            target = RCService.getInboxSeller(limit: limit, startId: startId, sortBy: sortBy ?? "2", asc: asc ?? "0", filter: filterBy, startTime: startTime, endTime: endTime)
        }
        
        let _ = NetworkProvider<RCService>()
            .request(target)
            .mapJSON()
            .mapTo(object: ComplaintData.self)
            .subscribe(onNext: { [weak self] (response) in
                guard let `self` = self else {
                    return
                }
                
                self.isBusy = false
                
                // if request is not outdated
                if !self.stateChanged {
                    if append {
                        self.complaints.append(contentsOf: response.inboxes)
                    }
                    else {
                        self.complaints = response.inboxes
                        self.refreshControl.endRefreshing()
                    }
                    
                    self.quickFilters = response.quickFilters
                    self.canLoadMore = response.canLoadMore
                    
                    // set selected filters
                    for i in 0 ..< self.quickFilters.count {
                        if self.selectedFilters.contains(self.quickFilters[i].value) {
                            self.quickFilters[i].isSelected = true
                        }
                    }
                    
                    self.tableView.reloadData()
                    self.headerView?.reloadData()
                    
                    // set new start id
                    self.startId = self.complaints.isEmpty ? "" : self.complaints[self.complaints.count - 1].id
                    
                    self.setupView()
                }
                else {
                    self.stateChanged = false
                    self.requestComplaints(append: false)
                }
            }, onError: {[weak self] (error) in
                guard let `self` = self else {
                    return
                }
                
                self.isBusy = false
                
                // if request is not outdated
                if !self.stateChanged {
                    if !append {
                        self.refreshControl.endRefreshing()
                    }
                    
                    self.setupView()
                    
                    StickyAlertView.showErrorMessage([(error as? MoyaError)?.userFriendlyErrorMessage() ?? ""])
                }
                else {
                    self.stateChanged = false
                    self.requestComplaints(append: false)
                }
            })
    }
    
    fileprivate func setupView() {
        if self.complaints.isEmpty {
            self.tableView.isHidden = true
            self.inboxEmptyView.isHidden = false
            if self.firstLoad {
                self.btnSortFilterView?.view.isHidden = true
                
                self.imgViewEmptyInbox.image = #imageLiteral(resourceName: "inbox_empty_first_load")
                self.lblTitleEmptyInbox.text = "Tidak ada komplain"
                self.lblMessageEmptyInbox.text = "Saat ini Anda belum memiliki Komplain."
                self.btnResetFilter.titleLabel?.text = "Coba Lagi"
            }
            else {
                self.imgViewEmptyInbox.image = #imageLiteral(resourceName: "inbox_empty")
                self.lblTitleEmptyInbox.text = "Oopppsss…"
                self.lblMessageEmptyInbox.text = "Kami tidak dapat menemukan komplain yang Anda cari."
                self.btnResetFilter.titleLabel?.text = "Reset Filter"
            }
        }
        else {
            self.firstLoad = false
            
            self.tableView.isHidden = false
            self.inboxEmptyView.isHidden = true
            self.btnSortFilterView?.view.isHidden = false
        }
        
        self.activityIndicator.stopAnimating()
    }
    
    fileprivate func isValidHexColor(value: String) -> Bool {
        let test = NSPredicate(format: "SELF MATCHES %@", "#?([0-9A-F]{3}|[0-9A-F]{6})")
        let newValue = value.uppercased()
        let result = test.evaluate(with: newValue)
        return result
    }
    
    // MARK: actions
    @IBAction private func btnResetDidTapped(_ sender: Any) {
        inboxEmptyView.isHidden = true
        activityIndicator.startAnimating()
        
        if !firstLoad {
            for i in 0 ..< quickFilters.count {
                quickFilters[i].isSelected = false
            }
            startTime = ""
            endTime = ""
            headerView?.reloadData()
            refreshComplaints()
        }
        else {
            requestComplaints(append: true)
        }
    }
}

extension ComplaintsViewController: UITableViewDelegate {
    internal func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return complaints.count
    }
    
    internal func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellHeights[indexPath] = cell.frame.size.height
    }
    
    internal func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let height = cellHeights[indexPath] else {
            return UITableViewAutomaticDimension
        }
        return height
    }
    
    internal func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    
    internal func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return collectionViewHeight
    }
    
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        // open webview
        let auth = UserAuthentificationManager()
        let vc = WebViewController()
        vc.shouldAuthorizeRequest = true
        vc.strURL = auth.webViewUrl(fromUrl: "\(NSString.mobileSiteUrl())/resolution/\(complaints[indexPath.row].resolutionId)/mobile")
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension ComplaintsViewController: UITableViewDataSource {
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellOrDie(withIdentifier: cellReuseIdentifier, for: indexPath) as ComplaintTableViewCell
        
        let row = indexPath.row
        let complaint = complaints[row]
        
        // status
        if isValidHexColor(value: complaint.statusFontColorHex) {
            cell.lblStatus.textColor = UIColor.fromHexString(complaint.statusFontColorHex)
        }
        else {
            cell.lblStatus.textColor = UIColor.tpPrimaryBlackText()
        }
        if isValidHexColor(value: complaint.statusBgColorHex) {
            cell.lblStatus.backgroundColor = UIColor.fromHexString(complaint.statusBgColorHex)
        }
        else {
            cell.lblStatus.backgroundColor = .clear
        }
        cell.lblStatus.text = complaint.status
        
        // reference
        cell.lblSubject.text = complaint.orderNumber
        
        // is read
        cell.isReadIndicator.isHidden = complaint.isRead == "2" ? true : false
        
        // author
        if self.userType == .customer {
            cell.lblAuthorType.text = "Penjual :"
            cell.lblName.text = complaint.seller
        }
        else {
            cell.lblAuthorType.text = "Pembeli :"
            cell.lblName.text = complaint.customer
        }
        
        // auto execute
        cell.lblNoExpiry.isHidden = true
        cell.lblExpiry.isHidden = true
        if complaint.statusInt != "500" && complaint.statusInt != "0" && !complaint.autoExecuteTime.isEmpty {
            cell.lblExpiry.isHidden = false
            if isValidHexColor(value: complaint.autoExecuteTimeColorHex) {
                cell.lblExpiry.backgroundColor = UIColor.fromHexString(complaint.autoExecuteTimeColorHex)
            }
            else {
                cell.lblExpiry.backgroundColor = .clear
            }
            cell.lblExpiry.text = complaint.autoExecuteTime
        }
        else {
            cell.lblNoExpiry.isHidden = false
        }
        
        // last replied
        cell.lblLastReplied.text = complaint.lastReplyTime
        
        // free return
        cell.lblFreeReturn.text = complaint.isFreeReturn == "1" ? "Ya" : "-"
        
        // product images
        cell.imgProduct1.isHidden = true
        cell.imgProduct2.isHidden = true
        cell.imgProduct3.isHidden = true
        cell.lblMoreProducts.isHidden = true
        if !complaint.productImageUrls.isEmpty {
            cell.imgProduct1.setImageWith(URL(string: complaint.productImageUrls[0]), placeholderImage: placeholderImage)
            cell.imgProduct1.isHidden = false
            cell.noImageConstraint.priority = 900
            if complaint.productImageUrls.count > 1 {
                cell.imgProduct2.setImageWith(URL(string: complaint.productImageUrls[1]), placeholderImage: placeholderImage)
                cell.imgProduct2.isHidden = false
                if complaint.productImageUrls.count > 2 {
                    cell.imgProduct3.setImageWith(URL(string: complaint.productImageUrls[2]), placeholderImage: placeholderImage)
                    cell.imgProduct3.isHidden = false
                    if complaint.productImageUrls.count > 3 {
                        cell.lblMoreProducts.text = "+\(complaint.productImageUrls.count - 3) Produk Lainnya"
                        cell.lblMoreProducts.isHidden = false
                    }
                }
            }
        }
        else {
            cell.noImageConstraint.priority = 999
        }
        
        // load more
        if row > complaints.count - 5 && canLoadMore {
            requestComplaints(append: true)
        }
        
        return cell
    }
}

extension ComplaintsViewController: UICollectionViewDelegate {
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quickFilters.count
    }
    
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        quickFilters[indexPath.row].isSelected = !quickFilters[indexPath.row].isSelected
        collectionView.reloadData()
        
        if isBusy {
            stateChanged = true // just notify to redo request
        }
        else {
            complaints = []
            tableView.reloadData()
            activityIndicator.startAnimating()
            refreshComplaints()
        }
    }
}

extension ComplaintsViewController: UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: .zero)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.mediumSystemFont(ofSize: 11)
        
        var str = quickFilters[indexPath.row].title
        if let range = str.range(of: " ", options: .caseInsensitive) {
            str = str.replacingCharacters(in: range, with: "\n")
        }
        
        label.text = str
        label.sizeToFit()
        
        return CGSize(width: label.frame.width + 16, height: label.frame.height + 16)
    }
}

extension ComplaintsViewController: UICollectionViewDataSource {
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellOrDie(withIdentifier: filterCellReuseIdentifier, for: indexPath) as ComplaintFilterCollectionViewCell
        
        let row = indexPath.row
        let quickFilter = self.quickFilters[row]
        
        cell.isSelected = quickFilter.isSelected
        
        var str = quickFilter.title
        if let range = str.range(of: " ", options: .caseInsensitive) {
            str = str.replacingCharacters(in: range, with: "\n")
        }
        
        cell.lblStatus.text = str
        
        return cell
    }
}

extension ComplaintsViewController: FloatingSortFilterViewDelegate {
    internal func btnSortDidTapped() {
        let sortView = ComplaintSortView(title: "Urutkan", data: quickSorts, allowMultipleSelection: false)
        sortView.delegate = self
        sortView.show(animated: true)
    }
    
    internal func btnFilterDidTapped() {
        let vc = ComplaintFilterViewController()
        vc.showDatePicker = true
        vc.data = quickFilters
        vc.startTime = Date.fromString(startTime, format: "dd/MM/yyyy")
        vc.endTime = Date.fromString(endTime, format: "dd/MM/yyyy")
        vc.delegate = self
        let nvc = UINavigationController(rootViewController: vc)
        self.navigationController?.present(nvc, animated: true, completion: nil)
    }
}

extension ComplaintsViewController: ComplaintSortViewDelegate {
    internal func complaintSortView(_ complaintSortView: ComplaintSortView, didSelectItemAt index: Int) {
        if index >= quickSorts.count {
            return
        }
        if quickSorts[index].isSelected {
            return
        }
        quickSorts[index].isSelected = true
        selectedSortIndex = index
        
        for i in 0 ..< quickSorts.count where i != index {
            quickSorts[i].isSelected = false
        }
        
        if isBusy {
            stateChanged = true // just notify to redo request
        }
        else {
            complaints = []
            tableView.reloadData()
            activityIndicator.startAnimating()
            refreshComplaints()
        }
    }
}

extension ComplaintsViewController: ComplaintFilterViewDelegate {
    internal func complaintFilterViewController(_ complaintFilterViewController: ComplaintFilterViewController, didApplyFilter filter: [ComplaintQuickFilterData], withDateFilter startTime: Date?, endTime: Date?) {
        quickFilters = filter
        headerView?.reloadData()
        
        if let startTime = startTime {
            self.startTime = startTime.string("dd/MM/yyyy")
        }
        else {
            self.startTime = ""
        }
        
        if let endTime = endTime {
            self.endTime = endTime.string("dd/MM/yyyy")
        }
        else {
            self.endTime = ""
        }
        
        if isBusy {
            stateChanged = true // just notify to redo request
        }
        else {
            complaints = []
            tableView.reloadData()
            inboxEmptyView.isHidden = true
            activityIndicator.startAnimating()
            refreshComplaints()
        }
    }
}
