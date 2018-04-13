//
//  InputPromoViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import MXSegmentedPager
import UIKit

@objc
internal protocol InputPromoViewDelegate {
    @objc optional func didUseVoucher(_ inputPromoViewController: InputPromoViewController, voucherData: Any, serviceType: PromoServiceType, promoType: PromoType)
}

@objc internal enum PromoType: Int {
    case voucher
    case coupon
}

internal class InputPromoViewController: MXSegmentedPagerController, InputPromoCodeViewDelegate, MyCouponListTableViewDelegate {
    public weak var delegate: InputPromoViewDelegate?
    private var serviceType: PromoServiceType = .marketplace
    public var cart: DigitalCart?
    public var couponEnabled = false
    private var placeholderView: UIView?
    private var defaultTab = PromoType.voucher
    
    private var loadingWindow = UIWindow()
    
    private var inputPromoCodeViewController: InputPromoCodeViewController?
    private var myCouponListTableViewController: MyCouponListTableViewController?
    
    public init(serviceType: PromoServiceType, cart: DigitalCart?, couponEnabled: Bool, defaultTab: PromoType) {
        super.init(nibName: nil, bundle: nil)
        
        setProperties(serviceType: serviceType, cart: cart, couponEnabled: couponEnabled, defaultTab: defaultTab)
    }
    
    public init(serviceType: PromoServiceType, couponEnabled: Bool, defaultTab: PromoType) {
        super.init(nibName: nil, bundle: nil)
        
        setProperties(serviceType: serviceType, cart: nil, couponEnabled: couponEnabled, defaultTab: defaultTab)
    }
    
    private func setProperties(serviceType: PromoServiceType, cart: DigitalCart?, couponEnabled: Bool, defaultTab: PromoType) {
        self.serviceType = serviceType
        self.cart = cart
        self.couponEnabled = couponEnabled
        self.defaultTab = defaultTab
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedPager.segmentedControl.backgroundColor = .white
        segmentedPager.segmentedControl.selectionIndicatorLocation = .down
        segmentedPager.segmentedControl.selectionIndicatorColor = .tpGreen()
        segmentedPager.segmentedControl.selectionIndicatorHeight = 2
        segmentedPager.segmentedControl.selectionStyle = .fullWidthStripe
        segmentedPager.segmentedControl.titleTextAttributes = [
            NSForegroundColorAttributeName: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.38),
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
        loadingWindow.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.3)
        loadingWindow.frame = UIScreen.main.bounds
        let loadingView = Bundle.main.loadNibNamed("SelectCouponLoadingView", owner: self, options: nil)?[0] as? UIView
        loadingView?.frame = UIScreen.main.bounds
        if let loadingView = loadingView {
            loadingWindow.addSubview(loadingView)
        }
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem(image: #imageLiteral(resourceName: "icon_close_grey"), style: .done, target: self, action: #selector(btnCloseDidTapped(_:))), animated: false)
        
        let label = UILabel()
        label.text = "Checkout"
        label.alpha = 0.7
        label.textAlignment = .left
        label.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.navigationController?.navigationBar.frame.height ?? 0)
        self.navigationItem.titleView = label
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override open func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let navigationController = self.navigationController else {
            return
        }
        segmentedPager.pager.showPage(at: defaultTab.rawValue, animated: false)
        if couponEnabled && !UserDefaults.standard.bool(forKey: "coupon_onboarding_shown") {
            let vc = OnboardingViewController(title: "Kode Promo dan Kupon tidak dapat digabung.", message: "Penggunaan Kode Promo tidak dapat digabung dengan Kupon yang Anda miliki.", currentStep: 1, totalStep: 1, anchorView: segmentedPager.segmentedControl, presentingViewController: navigationController, fromPresentedViewController: false, callback: { (action) in
                self.placeholderView?.removeFromSuperview()
                self.placeholderView = nil
            })
            
            vc.showOnboarding()
            
            UserDefaults.standard.set(true, forKey: "coupon_onboarding_shown")
            UserDefaults.standard.synchronize()
        }
    }
    
    // MXSegmentedPagerController delegates
    override internal func numberOfPages(in segmentedPager: MXSegmentedPager) -> Int {
        if couponEnabled {
            return 2
        }
        
        return 1
    }
    
    override internal func segmentedPager(_ segmentedPager: MXSegmentedPager, titleForSectionAt index: Int) -> String {
        switch index {
        case 0:
            return "Kode Promo"
        case 1:
            return "Kupon Saya"
        default:
            return ""
        }
    }
    
    override internal func segmentedPager(_ segmentedPager: MXSegmentedPager, viewForPageAt index: Int) -> UIView {
        switch index {
        case 0:
            return (inputPromoCodeViewController?.view)!
        case 1:
            return (myCouponListTableViewController?.view)!
        default:
            return (inputPromoCodeViewController?.view)!
        }
    }
    
    override internal func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelect view: UIView) {
        inputPromoCodeViewController?.view.endEditing(true)
    }
    
    override internal func segmentedPager(_ segmentedPager: MXSegmentedPager, didSelectViewWith index: Int) {
        if index == 1 {
            AnalyticsManager.trackEventName(GA_EVENT_NAME_TOKOPOINTS, category: "tokopoints - kode promo & kupon page", action: "click kupon saya", label: "kupon saya")
        }
    }

    @IBAction private func btnCloseDidTapped(_ sender: Any) {
        AnalyticsManager.trackEventName(GA_EVENT_NAME_TOKOPOINTS, category: "tokopoints - kode promo & kupon page", action: "click close button", label: "close")
        
        dismiss(animated: true, completion: nil)
    }
    
    // MyCouponListTableViewDelegate
    internal func showLoading(myCouponListTableViewController: MyCouponListTableViewController, show: Bool) {
        if show {
            loadingWindow.makeKeyAndVisible()
        }
        else {
            loadingWindow.resignKey()
            loadingWindow.isHidden = true
        }
    }
    
    internal func didUseVoucher(myCouponListTableViewController: MyCouponListTableViewController, voucherData: Any, serviceType: PromoServiceType) {
        self.delegate?.didUseVoucher?(self, voucherData: voucherData, serviceType: serviceType, promoType: .coupon)
        dismiss(animated: true, completion: nil)
    }
    
    // InputPromoCodeViewDelegate
    internal func showLoading(inputPromoCodeViewController: InputPromoCodeViewController, show: Bool) {
        if show {
            loadingWindow.makeKeyAndVisible()
        }
        else {
            loadingWindow.resignKey()
            loadingWindow.isHidden = true
        }
    }
    
    internal func didUseVoucher(inputPromoCodeViewController: InputPromoCodeViewController, voucherData: Any, serviceType: PromoServiceType) {
        self.delegate?.didUseVoucher?(self, voucherData: voucherData, serviceType: serviceType, promoType: .voucher)
        dismiss(animated: true, completion: nil)
    }
    
    // OnboardingViewControllerDelegate
    internal func didTapNextButton() {
        self.placeholderView?.removeFromSuperview()
        self.placeholderView = nil
    }
    
    internal func didTapBackButton() {
        self.placeholderView?.removeFromSuperview()
        self.placeholderView = nil
    }
    
    internal func didDimissOnboarding() {
        self.placeholderView?.removeFromSuperview()
        self.placeholderView = nil
    }
}
