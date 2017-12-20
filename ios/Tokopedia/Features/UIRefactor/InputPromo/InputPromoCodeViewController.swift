//
//  InputPromoCodeViewController.swift
//  Tokopedia
//
//  Created by Oscar Yuandinata on 11/28/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import Moya
import Unbox

protocol InputPromoCodeViewDelegate {
    func showLoading(inputPromoCodeViewController: InputPromoCodeViewController, show: Bool)
    func didUseVoucher(inputPromoCodeViewController: InputPromoCodeViewController, voucherData: Any, serviceType: PromoServiceType)
}

class InputPromoCodeViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var controlView: UIView!
    @IBOutlet weak var txtInputPromo: UITextField!
    @IBOutlet weak var btnUsePromo: UIButton!
    @IBOutlet weak var lblError: UILabel!
    
    var delegate: InputPromoCodeViewDelegate? = nil
    var serviceType: PromoServiceType = .marketplace
    var cart: DigitalCart? = nil
    
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

        (txtInputPromo.value(forKey: "textInputTraits") as AnyObject).setValue(UIColor.tpGreen(), forKey: "insertionPointColor")
        btnUsePromo.setTitle("Gunakan Kode", for: .normal)
        btnUsePromo.setTitle("", for: .disabled)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        txtInputPromo.addBottomBorder(with: .tpBorder(), andWidth: 1.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnUsePromoDidTapped(_ sender: Any) {
        self.view.endEditing(true)
        
        self.delegate?.showLoading(inputPromoCodeViewController: self, show: true)
        checkPromoCode()
    }
    
    func showError(message: String) {
        txtInputPromo.addBottomBorder(with: .tpRedError(), andWidth: 1)
        
        lblError.isHidden = false
        lblError.text = message
    }
    
    func checkPromoCode() {
        let voucherCode = txtInputPromo.text
        
        if voucherCode == nil || voucherCode!.isEmpty {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "AddErrorMessage"), object: nil, userInfo: ["errorMessage": "Masukkan kode promo terlebih dahulu.", "buttonTitle": ""])
            let _ = UIViewController.showNotificationWithMessage("Masukkan kode promo terlebih dahulu", type: NotificationType.error.rawValue, duration: 4.0, buttonTitle: nil, dismissable: true, action: nil)
            
            self.delegate?.showLoading(inputPromoCodeViewController: self, show: false)
            
            return
        }
        
        if serviceType == .marketplace {
            RequestCart.fetchVoucherCode(voucherCode, isPromoSuggestion: false, showError: false, success: { [weak self] transactionVoucher in
                guard let `self` = self else {
                    return
                }
                
                self.delegate?.showLoading(inputPromoCodeViewController: self, show: false)
                
                if let transactionVoucher = transactionVoucher {
                    transactionVoucher.data.data_voucher.voucher_code = voucherCode?.uppercased()
                    self.delegate?.didUseVoucher(inputPromoCodeViewController: self, voucherData: transactionVoucher.data.data_voucher, serviceType: self.serviceType)
                }
            }) { [weak self] (error) in
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
                    self.showError(message: errorMessage)
                }
                
                self.delegate?.showLoading(inputPromoCodeViewController: self, show: false)
            }
        }
        else {
            guard let cart = self.cart, let voucherCode = voucherCode else {
                return
            }
            AnalyticsManager.trackRechargeEvent(event: .tracking, cart: cart, action: "Click Gunakan Voucher - \(voucherCode)")
            DigitalProvider()
                .request(.voucher(categoryId: self.cart?.categoryId ?? "", voucherCode: voucherCode))
                .map(to: DigitalVoucher.self)
                .subscribe(onNext: { [weak self] (voucher) in
                    guard let `self` = self else {
                        return
                    }
                    
                    self.delegate?.showLoading(inputPromoCodeViewController: self, show: false)
                        
                    self.delegate?.didUseVoucher(inputPromoCodeViewController: self, voucherData: voucher, serviceType: self.serviceType)
                }, onError: { [weak self] (error) in
                    guard let `self` = self else {
                        return
                    }
                    
                    var errorMessage = ""
                    if let response = (error as! MoyaError).response {
                        let data = response.data
                        do {
                            let obj = try Unboxer(data:data)
                            errorMessage = try! obj.unbox(keyPath: "errors.0.title") as String
                            self.showError(message: errorMessage)
                        } catch {
                            print(error.localizedDescription)
                            errorMessage = error.localizedDescription
                        }
                    } else {
                        errorMessage = "Kendala koneksi internet, silakan coba kembali"
                        self.showError(message: errorMessage)
                    }
                    AnalyticsManager.trackRechargeEvent(event: .tracking, cart: cart, action: "Voucher Error - \(voucherCode)")
                    
                    self.delegate?.showLoading(inputPromoCodeViewController: self, show: false)
                })
                .disposed(by: self.rx_disposeBag)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.delegate?.showLoading(inputPromoCodeViewController: self, show: true)
        checkPromoCode()
        
        return textField.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lblError.isHidden = true
        txtInputPromo.addBottomBorder(with: .tpGreen(), andWidth: 1.0)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        txtInputPromo.addBottomBorder(with: .tpBorder(), andWidth: 1.0)
    }

    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
