//
//  DigitalCartViewController.swift
//  Tokopedia
//
//  Created by Ronald on 3/3/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit
import OAStackView
import BEMCheckBox
import Unbox
import Moya
import MoyaUnbox
import MMNumberKeyboard
import RxSwift

class DigitalCartViewController:UIViewController, BEMCheckBoxDelegate, UITextFieldDelegate, NoResultDelegate {
    @IBOutlet weak var mainView: OAStackView!
    @IBOutlet weak var additionalView: OAStackView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var content: OAStackView!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var expandButton: UIView!
    @IBOutlet weak var voucherInputView: UIView!
    @IBOutlet weak var voucherCancelView: UIView!
    @IBOutlet weak var expandView: UIView!
    @IBOutlet weak var textBoxView: UIView!
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var operatorLabel: UILabel!
    @IBOutlet weak var expandLabel: UILabel!
    @IBOutlet weak var expandIcon: UIImageView!
    @IBOutlet weak var inputLabel: UILabel!
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var checkbox: BEMCheckBox!
    @IBOutlet weak var voucherText: UITextField!
    @IBOutlet weak var voucherName: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var discountLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var gunakanButton: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!
    
    var categoryId = ""
    var voucherCode = ""
    var transactionId = ""
    fileprivate var isOpen = false
    fileprivate var isVoucherUsed = false
    fileprivate var isDiscount = false
    fileprivate var networkManager:TokopediaNetworkManager = TokopediaNetworkManager()
    fileprivate var cart:DigitalCart = DigitalCart()
    fileprivate var voucher:DigitalVoucher = DigitalVoucher()
    fileprivate var noResultView: NoResultReusableView!
    
    let cartPayment = PublishSubject<DigitalCartPayment>()
    
    lazy fileprivate var mainActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicator.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleTopMargin]
        return indicator
    }()
    
    lazy fileprivate var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.frame.origin = CGPoint(x: 20, y: 16)
        return indicator
    }()
    
    lazy fileprivate var actIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.center = CGPoint(x: self.gunakanButton.bounds.size.width/2, y: self.gunakanButton.bounds.size.height/2)
        return indicator
    }()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "DigitalCartViewController", bundle: nil)
    }
    
    convenience init(cart: Observable<String>) {
        self.init(nibName: nil, bundle: nil)
        cart.subscribe(onNext: { [weak self] (categoryId) in
            guard let `self` = self else { return }
            if !categoryId.isEmpty {
                self.categoryId = categoryId
                self.getCart()
            } else {
                self.view.addSubview(self.noResultView)
                self.content.isHidden = true
            }
        }, onError: { [weak self] (error) in
            guard let `self` = self else { return }
            let message = error as? String ?? error.localizedDescription
            
            StickyAlertView.showErrorMessage([message])
            self.noResultView = NoResultReusableView(frame: UIScreen.main.bounds)
            self.noResultView.generateAllElements("no-result.png", title: "Oops, Terjadi Kendala", desc: "Silahkan coba beberapa saat lagi menyelesaikan transaksi anda", btnTitle: nil)
            self.view.addSubview(self.noResultView)
            self.content.isHidden = true
            self.mainActivityIndicator.stopAnimating()
        }).disposed(by: self.rx_disposeBag)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mainActivityIndicator.center = self.view.center
        self.view.addSubview(self.mainActivityIndicator)
        self.mainActivityIndicator.startAnimating()
        initView()
        if !self.categoryId.isEmpty {
            getCart()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        
        AnalyticsManager.trackScreenName("Recharge Cart Page")
    }
    
    fileprivate func setExpandButton() {
        if (isOpen) {
            self.expandLabel.text = "Tutup"
            self.expandIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi);
            container.isHidden = false
        } else {
            self.expandLabel.text = "Lihat Detail"
            self.expandIcon.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2);
            container.isHidden = true
        }
    }
    
    fileprivate func setExpandView() {
        if ((self.cart.additionalInfo?.count)! > 0) {
            expandView.isHidden = false
        } else {
            expandView.isHidden = true
        }
    }
    
    fileprivate func setInputView() {
        if (self.cart.userInputPrice != nil) {
            textBoxView.isHidden = false
            inputLabel.text = "Masukkan jumlah nominal yang akan dibayar; \((self.cart.userInputPrice?.minText)!) sampai \((self.cart.userInputPrice?.maxText)!)"
        } else {
            textBoxView.isHidden = true
        }
    }
    
    fileprivate func setDiscountView() {
        if (isDiscount) {
            discountView.isHidden = false
            totalLabel.text = self.voucher.total
            discountLabel.text = self.voucher.discount
        } else {
            discountView.isHidden = true
            totalLabel.text = self.cart.priceText
        }
    }
    
    fileprivate func setVoucherUsed() {
        if (checkbox.on) {
            voucherInputView.isHidden = false
            AnalyticsManager.trackRechargeEvent(event: .tracking, cart: self.cart, action: "Click Voucher Checklist")
        } else {
            voucherInputView.isHidden = true
            isVoucherUsed = false
            setVoucherCanceled()
        }
    }
    
    fileprivate func setVoucherCanceled() {
        if (isVoucherUsed) {
            voucherCancelView.isHidden = false
            self.voucherName.text = self.voucher.message
            if (self.voucher.discountAmount > 0) {
                isDiscount = true
            } else {
                isDiscount = false
            }
        } else {
            voucherCancelView.isHidden = true
            self.voucherName.text = ""
            isDiscount = false
            self.voucherText.text = ""
            self.voucherCode = ""
        }
        setDiscountView()
    }
    
    fileprivate func setMainInfo() {
        let infos = self.cart.mainInfo
        mainView.addArrangedSubview(space(15))
        for info in infos {
            mainView.addArrangedSubview(setLabelAndValue(label: info.label, value: info.value))
            mainView.addArrangedSubview(space(2))
        }
        mainView.addArrangedSubview(space(15))
    }
    
    fileprivate func setAdditionalInfo() {
        let infos = self.cart.additionalInfo
        for info in infos! {
            let titleView = OAStackView()
            let t = UILabel()
            t.font = t.font.withSize(14)
            t.textColor = UIColor.black.withAlphaComponent(0.54)
            t.setText(info.title, animated: true)
            titleView.addArrangedSubview(t)
            additionalView.addArrangedSubview(titleView)
            additionalView.addArrangedSubview(space(15))
            
            for detail in info.detail {
                additionalView.addArrangedSubview(setLabelAndValue(label: detail.label, value: detail.value))
                additionalView.addArrangedSubview(space(2))
            }
            additionalView.addArrangedSubview(space(15))
        }
    }
    
    fileprivate func setVoucher() {
        guard !self.cart.voucherCode.isEmpty else { return }
        checkbox.on = true
        setVoucherUsed()
        voucherText.text = self.cart.voucherCode
        getVoucher()
    }
    
    fileprivate func setLabelAndValue(label:String, value:String) -> OAStackView {
        let view = OAStackView()
        
        let l = UILabel()
        l.font = l.font.withSize(12)
        l.textColor = UIColor.black.withAlphaComponent(0.54)
        l.setText(label, animated: true)
        if (!label.isEmpty) {
            view.addArrangedSubview(l)
        }
        
        let v = UILabel()
        v.font = v.font.withSize(12)
        v.textColor = UIColor.black.withAlphaComponent(0.54)
        v.setText(value, animated: true)
        view.addArrangedSubview(v)
        
        view.distribution = .fillEqually
        view.mas_makeConstraints { (make) in
            make?.height.mas_equalTo()(20)
        }
        return view
    }
    
    fileprivate func initView() {
        self.content.isHidden = true
        self.expandLabel.tintColor = UIColor.tpGreen()
        self.expandIcon.image = self.expandIcon.image?.withRenderingMode(.alwaysTemplate)
        self.expandIcon.tintColor = UIColor.tpGreen()
        let tapExpandGesture = UITapGestureRecognizer(target: self, action: #selector(self.expand(_:)))
        tapExpandGesture.numberOfTapsRequired = 1
        self.expandButton.isUserInteractionEnabled = true
        self.expandButton.addGestureRecognizer(tapExpandGesture)
        setExpandButton()

        container.isHidden = true
        voucherInputView.isHidden = true
        voucherCancelView.isHidden = true
        discountView.isHidden = true
        textBoxView.isHidden = true
        
        self.checkbox.boxType = .square
        self.checkbox.lineWidth = 1
        self.checkbox.onTintColor = UIColor.white
        self.checkbox.onCheckColor = UIColor.white
        self.checkbox.onFillColor = UIColor.tpGreen()
        self.checkbox.animationDuration = 0
        self.checkbox.delegate = self
        self.checkbox.accessibilityIdentifier = "donationCheckBox"
        self.checkbox.isAccessibilityElement = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        noResultView = NoResultReusableView(frame: UIScreen.main.bounds)
        noResultView.delegate = self
        noResultView.generateAllElements("icon_no_data_grey.png", title: "Whoops!\nTidak ada koneksi Internet", desc: "Harap coba lagi", btnTitle: "Coba Kembali")
        checkoutButton.addSubview(activityIndicator)
        gunakanButton.addSubview(actIndicator)
        
        let keyboard =  MMNumberKeyboard(frame: CGRect.zero)
        keyboard.allowsDecimalPoint = false
        self.inputText.inputView = keyboard
    }
    
    fileprivate func setData() {
        setExpandView()
        setInputView()
        setMainInfo()
        setAdditionalInfo()
        setVoucher()
        
        categoryLabel.setText(self.cart.categoryName, animated: true)
        operatorLabel.setText(self.cart.operatorName, animated: true)
        image.setImageWith(URL(string: self.cart.icon)!)
        navigationItem.title = self.cart.title
        totalLabel.text = self.cart.priceText
        priceLabel.text = self.cart.priceText
    }
    
    func expand(_ sender:UITapGestureRecognizer) {
        self.isOpen = !self.isOpen
        setExpandButton()
    }
    
    fileprivate func getCart() {
        DigitalProvider()
            .request(.getCart(categoryId))
            .map(to: DigitalCart.self)
            .do(onError: { [unowned self] error in
                    self.view.addSubview(self.noResultView)
                    self.content.isHidden = true
                }
            )
            .subscribe(onNext: { [weak self] cart in
                        self?.content.isHidden = false
                        self?.cart = cart
                        self?.transactionId = cart.cartId
                        self?.setData()
                
                        self?.mainActivityIndicator.stopAnimating()
                        AnalyticsManager.trackRechargeEvent(event: .homepage, cart: cart, action: "View Checkout Page")
                    },
                       onError: { [unowned self] error in
                        self.mainActivityIndicator.stopAnimating()
                        self.view.addSubview(self.noResultView)
                        self.content.isHidden = true
                    })
            .disposed(by: self.rx_disposeBag)

    }
    
    fileprivate func payment() {
        var amount:Double = 0
        if ((self.cart.userInputPrice) != nil) {
            if (self.inputText.text == "") {
                StickyAlertView.showErrorMessage(["Angka harus diisi"])
                return
            }
            
            if (Double(self.inputText.text!)! < self.cart.userInputPrice!.min || Double(self.inputText.text!)! > self.cart.userInputPrice!.max) {
                StickyAlertView.showErrorMessage(["Angka melewati batas yang ditentukan"])
                return
            }
        }
        
        if (self.inputText.text != "") {
            amount = Double(self.inputText.text!)!
        } else {
            amount = 0
        }
        
        if (checkbox.on) {
            self.voucherCode = self.voucherText.text!
        }
        checkoutButton.setTitle("Sedang proses...", for: .normal)
        checkoutButton.isEnabled = false
        
        activityIndicator.startAnimating()
        AnalyticsManager.trackRechargeEvent(event: .tracking, cart: self.cart, action: "Click Lanjut - Checkout Page")
        
        DigitalProvider()
            .request(.payment(voucherCode: self.voucherCode, transactionAmount: amount, transactionId:self.transactionId))
            .map(to: DigitalCartPayment.self)
            .do(
                onNext: { [weak self] payment in
                 self?.revertCheckoutButton()
                },
                onError: { [unowned self] error in
                    var errorMessage = ""
                    if let response = (error as! MoyaError).response {
                        let data = response.data
                        do {
                            let obj = try Unboxer(data:data)
                            errorMessage = try! obj.unbox(keyPath: "errors.0.title") as String
                            StickyAlertView.showErrorMessage([errorMessage])
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
            .disposed(by: self.rx_disposeBag)
    }
    
    fileprivate func getVoucher() {
        voucherCode = self.voucherText.text!
        voucherCode = voucherCode.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        AnalyticsManager.trackRechargeEvent(event: .tracking, cart: self.cart, action: "Click Gunakan Voucher - \(voucherCode)")
        if (!voucherCode.isEmpty) {
            self.dismissKeyboard()
            gunakanButton.setTitle("", for: .normal)
            gunakanButton.isEnabled = false
            actIndicator.startAnimating()
            DigitalProvider()
                .request(.voucher(categoryId: categoryId, voucherCode: voucherCode))
                .map(to: DigitalVoucher.self)
                .do(
                    onNext: { [weak self] voucher in
                        self?.revertGunakanButton()
                    },
                    onError: { [unowned self] error in
                        var errorMessage = ""
                        if let response = (error as! MoyaError).response {
                            let data = response.data
                            do {
                                let obj = try Unboxer(data:data)
                                errorMessage = try! obj.unbox(keyPath: "errors.0.title") as String
                                StickyAlertView.showErrorMessage([errorMessage])
                            } catch {
                                print(error.localizedDescription)
                                errorMessage = error.localizedDescription
                            }
                        } else {
                            errorMessage = "Kendala koneksi internet, silakan coba kembali"
                            StickyAlertView.showErrorMessage([errorMessage])
                        }
                        AnalyticsManager.trackRechargeEvent(event: .tracking, cart: self.cart, action: "Voucher Error - \(self.voucherCode)")
                        self.isVoucherUsed = false
                        self.setVoucherCanceled()
                        self.revertGunakanButton()
                    }
                )
                .subscribe(onNext: { [weak self] voucher in
                    self?.voucher = voucher
                    self?.isVoucherUsed = true
                    self?.setVoucherCanceled()
                })
                .disposed(by: self.rx_disposeBag)
        } else {
            StickyAlertView.showErrorMessage(["Kode promo tidak boleh kosong"])
        }
    }

    @IBAction func voucherUse(_ sender: Any) {
        getVoucher()
    }
    
    @IBAction func voucherCancel(_ sender: Any) {
        isVoucherUsed = false
        setVoucherCanceled()
        checkbox.on = false
        setVoucherUsed()
        AnalyticsManager.trackRechargeEvent(event: .tracking, cart: self.cart, action: "Click Batalkan Voucher")
    }
    
    @IBAction func payment(_ sender: Any) {
        payment()
    }
    
    func didTap(_ checkBox: BEMCheckBox) {
        setVoucherUsed()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func space(_ height:Int) -> UIView {
        let space = UIView()
        space.mas_makeConstraints { (make) in
            make?.height.mas_equalTo()(height)
        }
        return space
    }
    
    public func buttonDidTapped(_ sender: Any!) {
        if (noResultView.isDescendant(of: self.view)) {
            noResultView.removeFromSuperview()
        }
        getCart()
    }
    
    func revertCheckoutButton() {
        checkoutButton.setTitle("Lanjut", for: .normal)
        checkoutButton.isEnabled = true
        
        activityIndicator.stopAnimating()
    }
    
    func revertGunakanButton() {
        gunakanButton.setTitle("Gunakan", for: .normal)
        gunakanButton.isEnabled = true
        
        actIndicator.stopAnimating()
    }
}
