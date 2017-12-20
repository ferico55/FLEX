//
//  InputPromoViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import MXSegmentedPager

@objc
protocol InputPromoViewDelegate {
    @objc optional func didUseVoucher(_ inputPromoViewController: InputPromoViewController, voucherData: Any, serviceType: PromoServiceType, promoType: PromoType)
}

@objc enum PromoType: Int {
    case coupon
    case voucher
}

class InputPromoViewController: MXSegmentedPagerController, InputPromoCodeViewDelegate, MyCouponListTableViewDelegate {
    
    var delegate: InputPromoViewDelegate? = nil
    var serviceType: PromoServiceType = .marketplace
    var cart: DigitalCart? = nil
    var couponEnabled = false
    var placeholderView: UIView? = nil
    
    var loadingWindow = UIWindow()
    
    private var inputPromoCodeViewController: InputPromoCodeViewController? = nil
    private var myCouponListTableViewController: MyCouponListTableViewController? = nil
    
    init(serviceType: PromoServiceType, cart: DigitalCart?, couponEnabled: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        setProperties(serviceType: serviceType, cart: cart, couponEnabled: couponEnabled)
    }
    
    init(serviceType: PromoServiceType, couponEnabled: Bool) {
        super.init(nibName: nil, bundle: nil)
        
        setProperties(serviceType: serviceType, cart: nil, couponEnabled: couponEnabled)
    }
    
    func setProperties(serviceType: PromoServiceType, cart: DigitalCart?, couponEnabled: Bool) {
        self.serviceType = serviceType
        self.cart = cart
        self.couponEnabled = couponEnabled
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedPager.segmentedControl.backgroundColor = .white
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.selectionIndicatorColor = .tpGreen()
        segmentedPager.segmentedControl.selectionIndicatorHeight = 2
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor(white: 0.0, alpha: 0.38),
            NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)
        ]
        segmentedPager.segmentedControl.selectedTitleTextAttributes = [NSForegroundColorAttributeName: UIColor.tpGreen()]
        segmentedPager.segmentedControl.isVerticalDividerEnabled = true
        segmentedPager.segmentedControl.verticalDividerWidth = 1
        segmentedPager.segmentedControl.verticalDividerColor = .tpBorder()
        segmentedPager.segmentedControl.borderColor = .tpBorder()
        segmentedPager.segmentedControl.borderType = .bottom
        segmentedPager.segmentedControl.borderWidth = 1
        
        inputPromoCodeViewController = InputPromoCodeViewController(serviceType: serviceType, cart: cart)
        inputPromoCodeViewController?.delegate = self
        
        myCouponListTableViewController = MyCouponListTableViewController(serviceType: serviceType, cart: cart)
        myCouponListTableViewController?.delegate = self
        
        if !couponEnabled {
            segmentedPager.segmentedControlEdgeInsets = UIEdgeInsets(top: -44, left: 0, bottom: 0, right: 0)
        }
        
        loadingWindow = UIWindow()
        loadingWindow.backgroundColor = UIColor(white: 0, alpha: 0.3)
        loadingWindow.frame = UIScreen.main.bounds
        let loadingView = Bundle.main.loadNibNamed("SelectCouponLoadingView", owner: self, options: nil)?[0] as? UIView
        loadingView?.frame = UIScreen.main.bounds
        if let loadingView = loadingView {
            loadingWindow.addSubview(loadingView)
        }
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(named: "icon_close_grey"), style: .done, target: self, action: #selector(btnCloseDidTapped(_:))), animated: false)
        
        let label = UILabel()
        label.text = "Checkout"
        label.alpha = 0.7
        label.textAlignment = .left
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.navigationController?.navigationBar.frame.height ?? 0)
        self.navigationItem.titleView = label
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let navigationController = self.navigationController else {
            return
        }
        if couponEnabled && !UserDefaults.standard.bool(forKey: "coupon_onboarding_shown") {
            let vc = OnboardingViewController(title: "Kode Promo dan Kupon tidak dapat digabung.", message: "Penggunaan Kode Promo tidak dapat digabung dengan Kupon yang Anda miliki.", currentStep: 1, totalStep: 1, anchorView: segmentedPager.segmentedControl, presentingViewController: navigationController, callback: { (action) in
                self.placeholderView?.removeFromSuperview()
                self.placeholderView = nil
            })
            
            vc.showOnboarding()
            
            UserDefaults.standard.set(true, forKey: "coupon_onboarding_shown")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MXSegmentedPagerController delegates
    override func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        if couponEnabled {
            return 2
        }
        
        return 1
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        switch index {
        case 0:
            return "Kode Promo"
        case 1:
            return "Kupon Saya"
        default:
            return ""
        }
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        switch index {
        case 0:
            return (inputPromoCodeViewController?.view)!
        case 1:
            return (myCouponListTableViewController?.view)!
        default:
            return (inputPromoCodeViewController?.view)!
        }
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelect view: UIView) {
        inputPromoCodeViewController?.view.endEditing(true)
    }
    
    override func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelectViewWith index: Int) {
        if index == 1 {
            AnalyticsManager.trackEventName(GA_EVENT_NAME_TOKOPOINTS, category: "tokopoints - kode promo & kupon page", action: "click kupon saya", label: "kupon saya")
        }
    }

    @IBAction func btnCloseDidTapped(_ sender: Any) {
        AnalyticsManager.trackEventName(GA_EVENT_NAME_TOKOPOINTS, category: "tokopoints - kode promo & kupon page", action: "click close button", label: "close")
        
        dismiss(animated: true, completion: nil)
    }
    
    // MyCouponListTableViewDelegate
    func showLoading(myCouponListTableViewController: MyCouponListTableViewController, show: Bool) {
        if show {
            loadingWindow.makeKeyAndVisible()
        }
        else {
            loadingWindow.resignKey()
            loadingWindow.isHidden = true
        }
    }
    
    func didUseVoucher(myCouponListTableViewController: MyCouponListTableViewController, voucherData: Any, serviceType: PromoServiceType) {
        self.delegate?.didUseVoucher?(self, voucherData: voucherData, serviceType: serviceType, promoType: .coupon)
        dismiss(animated: true, completion: nil)
    }
    
    // InputPromoCodeViewDelegate
    func showLoading(inputPromoCodeViewController: InputPromoCodeViewController, show: Bool) {
        if show {
            loadingWindow.makeKeyAndVisible()
        }
        else {
            loadingWindow.resignKey()
            loadingWindow.isHidden = true
        }
    }
    
    func didUseVoucher(inputPromoCodeViewController: InputPromoCodeViewController, voucherData: Any, serviceType: PromoServiceType) {
        self.delegate?.didUseVoucher?(self, voucherData: voucherData, serviceType: serviceType, promoType: .voucher)
        dismiss(animated: true, completion: nil)
    }
    
    // OnboardingViewControllerDelegate
    func didTapNextButton() {
        self.placeholderView?.removeFromSuperview()
        self.placeholderView = nil
    }
    
    func didTapBackButton() {
        self.placeholderView?.removeFromSuperview()
        self.placeholderView = nil
    }
    
    func didDimissOnboarding() {
        self.placeholderView?.removeFromSuperview()
        self.placeholderView = nil
    }
}
