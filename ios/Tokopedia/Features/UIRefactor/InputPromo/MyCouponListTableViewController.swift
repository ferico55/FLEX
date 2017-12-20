//
//  MyCouponListTableViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import Unbox
import RxSwift

protocol MyCouponListTableViewDelegate {
    func showLoading(myCouponListTableViewController: MyCouponListTableViewController, show: Bool)
    func didUseVoucher(myCouponListTableViewController: MyCouponListTableViewController, voucherData: Any, serviceType: PromoServiceType)
}

class MyCouponListTableViewController: UITableViewController {
    
    private var coupons: [Coupon] = []
    
    var serviceType: PromoServiceType = .marketplace
    var delegate: MyCouponListTableViewDelegate? = nil
    var cart: DigitalCart? = nil
    
    private var noCouponView: UIView? = nil
    private var currentPage: Int64 = 1
    
    private let selfRefreshControl = UIRefreshControl()
    
    private var totalData: Int = 1000
    private var isRequesting = false
    
    init(serviceType: PromoServiceType, cart: DigitalCart?) {
        super.init(nibName: nil, bundle: nil)
        
        self.serviceType = serviceType
        self.cart = cart
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "CouponTableViewCell", bundle: nil), forCellReuseIdentifier: "CouponTableViewCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 132
        tableView.tableFooterView = UIView()
        tableView.contentInset = UIEdgeInsets(top: 16.0, left: 0, bottom: 0, right: 0)
        
        requestVoucher(page: 1, append: true)
        
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = selfRefreshControl
        } else {
            tableView.addSubview(selfRefreshControl)
        }
        
        // Configure Refresh Control
        selfRefreshControl.addTarget(self, action: #selector(getNewCoupons), for: .valueChanged)
        
        self.tableView.rx_reachedBottom
            .subscribe(onNext: { [weak self] _ in
                if ((self?.totalData ?? 0) > (self?.coupons.count ?? 0) && !(self?.isRequesting)!) {
                    self?.requestVoucher(page: (self?.currentPage ?? 0) + 1, append: true)
                }
            })
            .disposed(by: rx_disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getNewCoupons() {
        requestVoucher(page: 1, append: false)
    }
    
    func requestVoucher(page: Int64 = 1, append: Bool = false) {
        if !isRequesting {
            
            isRequesting = true
            
            TokopointsService.getCoupons(serviceType: serviceType, productId: self.cart?.productId, categoryId: self.cart?.categoryId, page: page, onSuccess: { [weak self] (getCouponResponse) in

                guard let `self` = self else {
                    return
                }

                if append {
                    self.coupons.append(contentsOf: getCouponResponse.coupons)
                }
                else {
                    self.coupons = getCouponResponse.coupons
                }

                self.displayData()

                self.selfRefreshControl.endRefreshing()
                self.isRequesting = false
                self.currentPage = page
                self.totalData = getCouponResponse.totalData
            }) { [weak self] (error) in
                guard let `self` = self else {
                    return
                }

                self.selfRefreshControl.endRefreshing()
                self.isRequesting = false

                self.displayData()

                StickyAlertView.showErrorMessage([(error as? MoyaError)?.userFriendlyErrorMessage() ?? ""])
            }
        }
    }
    
    func displayData() {
        if self.coupons.count == 0 {
            self.noCouponView = Bundle.main.loadNibNamed("NoCouponView", owner: self, options: nil)?[0] as? UIView
            self.noCouponView?.frame = self.tableView.frame
            if let noCouponView = self.noCouponView {
                self.tableView.backgroundView = noCouponView
            }
        }
        else {
            self.tableView.backgroundView = nil
        }
        
        self.tableView.reloadData()
    }
    
    func checkVoucherCode(voucherCode: String, row: Int) {
        
        if serviceType == .marketplace {
            RequestCart.fetchVoucherCode(voucherCode, isPromoSuggestion: false, showError: false, success: { transactionVoucher in
                self.delegate?.showLoading(myCouponListTableViewController: self, show: false)
                
                if let transactionVoucher = transactionVoucher {
                    transactionVoucher.data.data_voucher.voucher_code = voucherCode
                    transactionVoucher.data.data_voucher.coupon_title = self.coupons[row].title
                    self.delegate?.didUseVoucher(myCouponListTableViewController: self, voucherData: transactionVoucher.data.data_voucher, serviceType: self.serviceType)
                }
            }) {[weak self] (error) in
                guard let `self` = self else {
                    return
                }
                
                if let error = error {
                    var errorMessage = ""
                    switch (error as NSError).code  {
                    case NSURLErrorNotConnectedToInternet:
                        errorMessage = "Tidak ada koneksi internet."
                        break
                    case NSURLErrorBadServerResponse:
                        errorMessage = "Terjadi kendala pada server. Silahkan coba beberapa saat lagi."
                        break
                    default:
                        errorMessage = error.localizedDescription
                        break
                    }
                    
                    self.coupons[row].errorMessage = errorMessage
                    self.tableView.reloadData()
                }
                
                self.delegate?.showLoading(myCouponListTableViewController: self, show: false)
            }
        }
        else {
            guard let cart = self.cart else {
                return
            }
            AnalyticsManager.trackRechargeEvent(event: .tracking, cart: cart, action: "Click Gunakan Voucher - \(voucherCode)")
            DigitalProvider()
                .request(.voucher(categoryId: "\(cart.categoryId)", voucherCode: voucherCode))
                .map(to: DigitalVoucher.self)
                .subscribe(onNext: { [weak self] voucher in
                    if let weakSelf = self {
                        weakSelf.delegate?.showLoading(myCouponListTableViewController: weakSelf, show: false)
                        
                        voucher.couponTitle = self?.coupons[row].title ?? ""
                        weakSelf.delegate?.didUseVoucher(myCouponListTableViewController: weakSelf, voucherData: voucher, serviceType: weakSelf.serviceType)
                    }
                    }, onError: { [unowned self] error in
                        var errorMessage = ""
                        if let response = (error as! MoyaError).response {
                            let data = response.data
                            do {
                                let obj = try Unboxer(data:data)
                                errorMessage = try! obj.unbox(keyPath: "errors.0.title") as String
                            } catch {
                                errorMessage = (error as? MoyaError)?.userFriendlyErrorMessage() ?? ""
                            }
                        } else {
                            errorMessage = (error as? MoyaError)?.userFriendlyErrorMessage() ?? ""
                        }
                        
                        self.coupons[row].errorMessage = errorMessage
                        
                        self.tableView.reloadData()
                        
                        AnalyticsManager.trackRechargeEvent(event: .tracking, cart: cart, action: "Voucher Error - \(voucherCode)")
                        
                        self.delegate?.showLoading(myCouponListTableViewController: self, show: false)
                    })
                .disposed(by: self.rx_disposeBag)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupons.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CouponTableViewCell", for: indexPath) as! CouponTableViewCell
        let row = indexPath.row
        
        let coupon = coupons[row]

        cell.lblTitle.text = coupon.title
        cell.lblSubTitle.text = coupon.subTitle
        cell.lblDescription.text = coupon.couponDescription
        cell.lblExpireIn.text = " \(coupon.expired) "
        cell.lblExpireIn.layer.cornerRadius = 3
        cell.lblExpireIn.layer.masksToBounds = true
        cell.lblError.text = coupon.errorMessage
        cell.iconImgView.backgroundColor = .tpGray()
        cell.iconImgView.image = nil
        let iconUrl = URL(string: coupon.icon)
        if let iconUrl = iconUrl {
            let request: NSMutableURLRequest = NSMutableURLRequest(url: iconUrl)
            request.addValue("image/*", forHTTPHeaderField: "Accept")
            cell.iconImgView.setImageWithUrlRequest(request as URLRequest, success: { (request, response, image, success) in
                cell.iconImgView.image = image
                cell.iconImgView.backgroundColor = nil
            }, failure: nil)
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        AnalyticsManager.trackEventName(GA_EVENT_NAME_TOKOPOINTS, category: "tokopoints - kode promo & kupon page", action: "click coupon", label: coupons[indexPath.row].title)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        for coupon in coupons {
            coupon.errorMessage = ""
        }
        self.tableView.reloadData()
        
        self.delegate?.showLoading(myCouponListTableViewController: self, show: true)
        
        checkVoucherCode(voucherCode: coupons[indexPath.row].code, row: indexPath.row)
    }
}
