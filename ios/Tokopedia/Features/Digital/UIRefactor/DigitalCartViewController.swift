//
//  DigitalCartViewController.swift
//  Tokopedia
//
//  Created by Ronald on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import MMNumberKeyboard
import Moya
import MoyaUnbox
import OAStackView
import RxSwift
import UIKit
import Unbox

internal class DigitalCartViewController: UIViewController, UITextFieldDelegate, NoResultDelegate, InputPromoViewDelegate {
    @IBOutlet private weak var mainView: OAStackView!
    @IBOutlet private weak var additionalView: OAStackView!
    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var content: OAStackView!
    @IBOutlet private weak var discountView: UIView!
    @IBOutlet private weak var expandButton: UIView!
    @IBOutlet private weak var expandView: UIView!
    @IBOutlet private weak var textBoxView: UIView!
    
    @IBOutlet private weak var image: UIImageView!
    @IBOutlet private weak var categoryLabel: UILabel!
    @IBOutlet private weak var operatorLabel: UILabel!
    @IBOutlet private weak var expandLabel: UILabel!
    @IBOutlet private weak var expandIcon: UIImageView!
    @IBOutlet private weak var inputLabel: UILabel!
    @IBOutlet private weak var inputText: UITextField!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var discountLabel: UILabel!
    @IBOutlet private weak var totalLabel: UILabel!
    @IBOutlet private weak var checkoutButton: UIButton!
    
    @IBOutlet private weak var usedVoucherContainerView: UIView!
    @IBOutlet private weak var lblUsedVoucher: UILabel!
    @IBOutlet private weak var lblVoucherMessage: UILabel!
    @IBOutlet private weak var btnUseVoucher: UIButton!
    
    internal var categoryId = ""
    internal var transactionId = ""
    fileprivate var isOpen = false
    fileprivate var isVoucherUsed = false
    fileprivate var isDiscount = false
    fileprivate var networkManager: TokopediaNetworkManager = TokopediaNetworkManager()
    fileprivate var cart: DigitalCart = DigitalCart()
    fileprivate var voucher: DigitalVoucher = DigitalVoucher()
    fileprivate var noResultView: NoResultReusableView!
    private var promoType: PromoType = .voucher
    
    internal let cartPayment = PublishSubject<DigitalCartPayment>()
    
    fileprivate lazy var mainActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleTopMargin]
        return indicator
    }()
    
    fileprivate lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.frame.origin = CGPoint(x: 20, y: 16)
        return indicator
    }()
    
    internal override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DigitalCartViewController", bundle: nil)
    }
    
    internal convenience init(cart: Observable<String>) {
        self.init(nibName: nil, bundle: nil)
        cart.subscribe(onNext: { [weak self] categoryId in
            guard let `self` = self else { return }
            if !categoryId.isEmpty {
                self.categoryId = categoryId
                self.getCart()
            } else {
                self.view.addSubview(self.noResultView)
                self.content.isHidden = true
            }
        }, onError: { [weak self] error in
            guard let `self` = self else { return }
            let message = error as? String ?? error.localizedDescription
            
            StickyAlertView.showErrorMessage([message])
            self.noResultView = NoResultReusableView(frame: UIScreen.main.bounds)
            self.noResultView.generateAllElements("no-result.png", title: "Oops, Terjadi Kendala", desc: "Silahkan coba beberapa saat lagi menyelesaikan transaksi anda", btnTitle: nil)
            self.view.addSubview(self.noResultView)
            self.content.isHidden = true
            self.mainActivityIndicator.stopAnimating()
        }).disposed(by: rx_disposeBag)
        
    }
    
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func viewDidLoad() {
        super.viewDidLoad()
        
        mainActivityIndicator.center = view.center
        view.addSubview(mainActivityIndicator)
        mainActivityIndicator.startAnimating()
        
        initView()
        if !categoryId.isEmpty {
            getCart()
        }
    }
    
    internal override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.trackScreenName("Recharge Cart Page")
    }
    
    fileprivate func setExpandButton() {
        if isOpen {
            expandLabel.text = "Tutup"
            expandIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            container.isHidden = false
        } else {
            expandLabel.text = "Lihat Detail"
            expandIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2)
            container.isHidden = true
        }
    }
    
    fileprivate func setExpandView() {
        if let count = cart.additionalInfo?.count, count > 0 {
            expandView.isHidden = false
        } else {
            expandView.isHidden = true
        }
    }
    
    fileprivate func setInputView() {
        if let userInputPrice = cart.userInputPrice {
            textBoxView.isHidden = false
            inputLabel.text = "Masukkan jumlah nominal yang akan dibayar; \(userInputPrice.minText) sampai \(userInputPrice.maxText)"
        } else {
            textBoxView.isHidden = true
        }
    }
    
    fileprivate func setDiscountView() {
        if isDiscount {
            discountView.isHidden = false
            totalLabel.text = voucher.total
            discountLabel.text = voucher.discount
        } else {
            discountView.isHidden = true
            totalLabel.text = cart.priceText
        }
    }
    
    fileprivate func setVoucherCanceled() {
        if isVoucherUsed {
            var usedCouponString: String = ""
            var startVoucher = 0
            switch promoType {
            case .coupon:
                usedCouponString = "Kupon Saya: \(voucher.couponTitle)"
                startVoucher = 12
            case .voucher:
                usedCouponString = "Kode Voucher: \(voucher.voucherCode)"
                startVoucher = 13
            }
            let myCouponString = NSMutableAttributedString(string: usedCouponString, attributes: [NSFontAttributeName: lblUsedVoucher.font])
            myCouponString.addAttribute(NSForegroundColorAttributeName, value: #colorLiteral(red: 0.9921568627, green: 0.3450980392, blue: 0.1882352941, alpha: 1), range: NSRange(location: startVoucher, length: myCouponString.length - startVoucher))
            
            lblUsedVoucher.attributedText = myCouponString
            lblVoucherMessage.text = voucher.message.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if voucher.discountAmount > 0 {
                isDiscount = true
            } else {
                isDiscount = false
            }
            
            btnUseVoucher.isHidden = true
            usedVoucherContainerView.isHidden = false
        } else {
            isDiscount = false
            
            btnUseVoucher.isHidden = false
            usedVoucherContainerView.isHidden = true
        }
        
        setDiscountView()
    }
    
    fileprivate func setMainInfo() {
        let infos = cart.mainInfo
        mainView.addArrangedSubview(space(15))
        for info in infos {
            mainView.addArrangedSubview(setLabelAndValue(label: info.label, value: info.value))
            mainView.addArrangedSubview(space(2))
        }
        mainView.addArrangedSubview(space(15))
    }
    
    fileprivate func setAdditionalInfo() {
        if let infos = cart.additionalInfo {
            for info in infos {
                let titleView = OAStackView()
                let infoLabel = UILabel()
                infoLabel.font = infoLabel.font.withSize(14)
                infoLabel.textColor = UIColor.black.withAlphaComponent(0.54)
                infoLabel.setText(info.title, animated: true)
                titleView.addArrangedSubview(infoLabel)
                additionalView.addArrangedSubview(titleView)
                additionalView.addArrangedSubview(space(15))
                
                for detail in info.detail {
                    additionalView.addArrangedSubview(setLabelAndValue(label: detail.label, value: detail.value))
                    additionalView.addArrangedSubview(space(2))
                }
                additionalView.addArrangedSubview(space(15))
            }
        }
    }
    
    fileprivate func setLabelAndValue(label: String, value: String) -> OAStackView {
        let view = OAStackView()
        
        let textLabel = UILabel()
        textLabel.font = textLabel.font.withSize(12)
        textLabel.textColor = UIColor.black.withAlphaComponent(0.54)
        textLabel.setText(label, animated: true)
        if !label.isEmpty {
            view.addArrangedSubview(textLabel)
        }
        
        let valueLabel = UILabel()
        valueLabel.font = valueLabel.font.withSize(12)
        valueLabel.textColor = UIColor.black.withAlphaComponent(0.54)
        valueLabel.setText(value, animated: true)
        view.addArrangedSubview(valueLabel)
        
        view.distribution = .fillEqually
        view.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        return view
    }
    
    fileprivate func initView() {
        content.isHidden = true
        expandLabel.tintColor = UIColor.tpGreen()
        expandIcon.image = expandIcon.image?.withRenderingMode(.alwaysTemplate)
        expandIcon.tintColor = UIColor.tpGreen()
        let tapExpandGesture = UITapGestureRecognizer(target: self, action: #selector(self.expand(_:)))
        tapExpandGesture.numberOfTapsRequired = 1
        expandButton.isUserInteractionEnabled = true
        expandButton.addGestureRecognizer(tapExpandGesture)
        setExpandButton()
        
        container.isHidden = true
        discountView.isHidden = true
        textBoxView.isHidden = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        noResultView = NoResultReusableView(frame: UIScreen.main.bounds)
        noResultView.delegate = self
        noResultView.generateAllElements("icon_no_data_grey.png", title: "Whoops!\nTidak ada koneksi Internet", desc: "Harap coba lagi", btnTitle: "Coba Kembali")
        checkoutButton.addSubview(activityIndicator)
        
        let keyboard = MMNumberKeyboard(frame: CGRect.zero)
        keyboard.allowsDecimalPoint = false
        inputText.inputView = keyboard
        
        usedVoucherContainerView.layer.borderColor = UIColor.tpGreen().cgColor
        usedVoucherContainerView.layer.borderWidth = 1
    }
    
    fileprivate func setData() {
        setExpandView()
        setInputView()
        setMainInfo()
        setAdditionalInfo()
        
        categoryLabel.setText(cart.categoryName, animated: true)
        operatorLabel.setText(cart.operatorName, animated: true)
        if let url = URL(string: cart.icon) {
            image.setImageWith(url)
        }
        navigationItem.title = cart.title
        totalLabel.text = cart.priceText
        priceLabel.text = cart.priceText
        
        AnalyticsManager.trackEventName("viewDigitalNative", category: "digital - \(cart.categoryName)", action: "view checkout", label: "")
    }
    
    fileprivate func getVoucher(voucherCode: String) {
        AnalyticsManager.trackRechargeEvent(event: .tracking, cart: cart, action: "Click Gunakan Voucher - \(voucherCode)")
        
        DigitalProvider()
            .request(.voucher(categoryId: categoryId, voucherCode: voucherCode))
            .map(to: DigitalVoucher.self)
            .subscribe(onNext: { [weak self] voucher in
                guard let `self` = self else {
                    return
                }
                
                self.voucher = voucher
                self.isVoucherUsed = true
                self.promoType = .voucher
                
                self.setVoucherCanceled()
            }, onError: { [unowned self] _ in
                // silent error
                
                AnalyticsManager.trackRechargeEvent(event: .tracking, cart: self.cart, action: "Voucher Error - \(voucherCode)")
                
                self.isVoucherUsed = false
                self.setVoucherCanceled()
                self.clearPromoCodeOnError()
                self.content.isHidden = false
                self.mainActivityIndicator.stopAnimating()
                
                if self.cart.isCouponActive == "1" {
                    self.btnUseVoucher.setTitle("Gunakan Kode Promo atau Kupon", for: .normal)
                } else {
                    self.btnUseVoucher.setTitle("Gunakan Kode Promo", for: .normal)
                }
            }, onCompleted: {
                
                self.content.isHidden = false
                self.mainActivityIndicator.stopAnimating()
                
                if self.cart.isCouponActive == "1" {
                    self.btnUseVoucher.setTitle("Gunakan Kode Promo atau Kupon", for: .normal)
                } else {
                    self.btnUseVoucher.setTitle("Gunakan Kode Promo", for: .normal)
                }
            })
            .disposed(by: rx_disposeBag)
    }
    private func clearPromoCodeOnError() {
        if UserDefaults.standard.string(forKey: API_VOUCHER_CODE_KEY) != nil {
            UserDefaults.standard.removeObject(forKey: API_VOUCHER_CODE_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    internal func expand(_ sender: UITapGestureRecognizer) {
        isOpen = !isOpen
        setExpandButton()
    }
    
    fileprivate func getCart() {
        DigitalProvider()
            .request(.getCart(categoryId))
            .map(to: DigitalCart.self)
            .do(onError: { [unowned self] _ in
                self.view.addSubview(self.noResultView)
                self.content.isHidden = true
            }
            )
            .subscribe(onNext: { [weak self] cart in
                guard let `self` = self else {
                    return
                }
                
                self.cart = cart
                self.transactionId = cart.cartId
                self.setData()
                
                if let autoCode = self.cart.autoCode, !autoCode.code.isEmpty, autoCode.success {
                    self.voucher = DigitalVoucher(voucherCode: autoCode.code, userId: "", discount: autoCode.discount, discountAmount: autoCode.discountAmount, cashback: "", cashbackAmount: 0, total: autoCode.total, totalAmount: autoCode.totalAmount, message: autoCode.message)
                    self.voucher.couponTitle = autoCode.title
                    self.isVoucherUsed = true
                    self.promoType = autoCode.isCoupon ? .coupon : .voucher
                    self.setVoucherCanceled()
                    self.content.isHidden = false
                    self.mainActivityIndicator.stopAnimating()
                } else if let voucherCode = UserDefaults.standard.string(forKey: API_VOUCHER_CODE_KEY) {
                    self.getVoucher(voucherCode: voucherCode)
                } else {
                    self.content.isHidden = false
                    self.mainActivityIndicator.stopAnimating()
                    
                    if cart.isCouponActive == "1" {
                        self.btnUseVoucher.setTitle("Gunakan Kode Promo atau Kupon", for: .normal)
                    } else {
                        self.btnUseVoucher.setTitle("Gunakan Kode Promo", for: .normal)
                    }
                }
            },
            onError: { [unowned self] _ in
                self.mainActivityIndicator.stopAnimating()
                self.view.addSubview(self.noResultView)
                self.content.isHidden = true
            })
            .disposed(by: rx_disposeBag)
        
    }
    
    fileprivate func payment() {
        var amount: Double = 0
        if let userInputPrice = cart.userInputPrice {
            if let text = inputText.text {
                if text.isEmpty {
                    StickyAlertView.showErrorMessage(["Angka harus diisi"])
                    return
                }
                
                if Double(text) ?? 0 < userInputPrice.min || Double(text) ?? 0 > userInputPrice.max {
                    StickyAlertView.showErrorMessage(["Angka melewati batas yang ditentukan"])
                    return
                }
            }
        }
        
        if let text = inputText.text, !text.isEmpty {
            amount = Double(text) ?? 0
        } else {
            amount = 0
        }
        
        AnalyticsManager.trackEventName("viewDigitalNative", category: "digital - \(cart.categoryName)", action: "proceed to payment", label: isVoucherUsed ? "promo" : "no promo")
        
        checkoutButton.setTitle("Sedang proses...", for: .normal)
        checkoutButton.isEnabled = false
        
        activityIndicator.startAnimating()
        
        DigitalProvider()
            .request(.payment(voucherCode: voucher.voucherCode, transactionAmount: amount, transactionId: transactionId))
            .map(to: DigitalCartPayment.self)
            .do(
                onNext: { [weak self] _ in
                    self?.revertCheckoutButton()
                },
                onError: { [unowned self] error in
                    var errorMessage = ""
                    if let response = (error as? MoyaError)?.response {
                        let data = response.data
                        do {
                            let obj = try Unboxer(data: data)
                            if let errorTitle = try? obj.unbox(keyPath: "errors.0.title") as String {
                                StickyAlertView.showErrorMessage([errorTitle])
                                errorMessage = errorTitle
                            }
                        } catch {
                            print(error.localizedDescription)
                            errorMessage = error.localizedDescription
                        }
                    } else {
                        errorMessage = "Kendala koneksi internet, silakan coba kembali"
                        StickyAlertView.showErrorMessage([errorMessage])
                    }
                    AnalyticsManager.trackRechargeEvent(event: .tracking, cart: self.cart, action: "Checkout Error - \(errorMessage)")
                    self.revertCheckoutButton()
                }
            )
            .subscribe(onNext: { [weak self] cartPayment in
                if let error = cartPayment.errorMessage {
                    StickyAlertView.showErrorMessage([error])
                } else {
                    self?.cartPayment.onNext(cartPayment)
                }
            })
            .disposed(by: rx_disposeBag)
    }
    
    @IBAction private func payment(_ sender: Any) {
        payment()
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    internal func dismissKeyboard() {
        view.endEditing(true)
    }
    
    internal func space(_ height: Int) -> UIView {
        let space = UIView()
        space.snp.makeConstraints { make in
            make.height.equalTo(height)
        }
        return space
    }
    
    public func buttonDidTapped(_ sender: Any!) {
        if noResultView.isDescendant(of: view) {
            noResultView.removeFromSuperview()
        }
        getCart()
    }
    
    internal func revertCheckoutButton() {
        checkoutButton.setTitle("Lanjut", for: .normal)
        checkoutButton.isEnabled = true
        
        activityIndicator.stopAnimating()
    }
    
    @IBAction private func btnUseVoucherDidTapped(_ sender: Any) {
        let vc = InputPromoViewController(serviceType: .digital, cart: cart, couponEnabled: (cart.isCouponActive == "1"), defaultTab: cart.defaultTab == "voucher" ? PromoType.voucher : PromoType.coupon)
        vc.delegate = self
        let nvc = UINavigationController(rootViewController: vc)
        navigationController?.present(nvc, animated: true, completion: nil)
    }
    
    @IBAction private func btnCancelVoucherDidTapped(_ sender: Any) {
        DigitalProvider().request(.cancelVoucher()).subscribe(onNext: { [weak self] _ in
            guard let `self` = self else { return }
            self.isVoucherUsed = false
            self.setVoucherCanceled()
            AnalyticsManager.trackRechargeEvent(event: .tracking, cart: self.cart, action: "Click Batalkan Voucher")
        }).disposed(by: rx_disposeBag)
    }
    // InputPromoViewDelegate
    internal func didUseVoucher(_ inputPromoViewController: InputPromoViewController, voucherData: Any, serviceType: PromoServiceType, promoType: PromoType) {
        if let voucher = voucherData as? DigitalVoucher {
            self.voucher = voucher
        }
        isVoucherUsed = true
        self.promoType = promoType
        
        setVoucherCanceled()
    }
}
