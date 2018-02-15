//
//  LoginPhoneNumberViewController.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import MMNumberKeyboard
import RxSwift
import SwiftyJSON
import UIKit

public class LoginPhoneNumberViewController: UIViewController, UITextFieldDelegate, MMNumberKeyboardDelegate {
    
    @IBOutlet weak private var informationText: UILabel!
    @IBOutlet weak private var actionButton: UIButton!
    @IBOutlet weak private var phoneNumberHorizontalLine: UIView!
    @IBOutlet weak private var phoneNumberTextField: UITextField!
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var warningLabel: UILabel!
    
    @IBOutlet weak private var viewTrailing: NSLayoutConstraint!
    @IBOutlet weak private var viewLeading: NSLayoutConstraint!
    
    private let nextButtonEnabled = Variable(false)
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupNextButton()
    }
    
    @IBAction private func onTapNext(_ sender: UIButton) {
        let phoneNumber = self.phoneNumberTextField.text!
        self.setButtonLoading(true)
        
        AnalyticsManager.trackEventName("clickLogin", category: "login with phone", action: "click on selanjutnya", label: "")
        
        WalletService.checkPhoneNumberTokoCash(phoneNumber: phoneNumber).subscribe(onNext:{ [weak self] result in
            guard let `self` = self else { return }
            if result.code == "200000" {
                self.validateForm(true)
                self.setToOtpScene(result)
            }
            else if result.code == "412556" {
                self.setButtonLoading(false)
                let message : String = "Anda sudah 3 kali melakukan pengiriman OTP, silakan coba lagi dalam 60 menit"
                UIViewController.showNotificationWithMessage(message, type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
            }
            else if result.code == "" {
                self.validateForm(false)
            }else {
                self.setButtonLoading(false)
                let message : String = "Terjadi kesalahan pada server, silakan coba kembali"
                UIViewController.showNotificationWithMessage(message, type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
            }
            },onError:{ error in
                self.setButtonLoading(false)
                let message : String = "Terjadi kesalahan pada server, silakan coba kembali"
                UIViewController.showNotificationWithMessage(message, type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
        })
            .disposed(by: self.rx_disposeBag)
    }
    
    private func validateForm(_ status: Bool){
        self.setButtonLoading(false)
        
        if !status {
            self.phoneNumberHorizontalLine.backgroundColor = .fromHexString("#D50000")
            self.warningLabel.isHidden = false
            self.phoneNumberTextField.tintColor = .fromHexString("#D50000")
        } else {
            self.warningLabel.isHidden = true
            self.phoneNumberTextField.tintColor = .tpGreen()
        }
    }
    
    private func setButtonLoading (_ isLoading :Bool){
        let tag = 2308
        if isLoading {
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.actionButton.bounds.size.height
            let buttonWidth = self.actionButton.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            self.actionButton.setTitle("", for: .normal)
            self.actionButton.addSubview(indicator)
            indicator.startAnimating()
        } else {
            if let indicator = self.actionButton.viewWithTag(tag) as? UIActivityIndicatorView {
                indicator.stopAnimating()
                indicator.removeFromSuperview()
                self.actionButton.setTitle("Masuk", for: .normal)
            }
        }
    }
    
    private func setToOtpScene(_ tokoCashData: TokoCashLoginSendOTPResponse) {
        let controller = LoginPhoneNumberOTPViewController(nibName: nil, bundle: nil)
        controller.hidesBottomBarWhenPushed = true
        controller.tokoCashLoginSendOTPResponse = tokoCashData
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setupView() {
        self.navigationItem.title = "Masuk"
        self.titleLabel.text = "Masuk dengan Nomor Ponsel"
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.viewLeading.constant = 104
            self.viewTrailing.constant = 104
        }
        
        let numberKeyboard = MMNumberKeyboard(frame: .zero)
        numberKeyboard.allowsDecimalPoint = false
        numberKeyboard.delegate = self
        self.phoneNumberTextField.delegate = self
        self.phoneNumberTextField.inputView = numberKeyboard
    }
    
    private func setupNextButton() {
        self.nextButtonEnabled.asObservable()
            .subscribe(onNext:{ [weak self] enabled in
                guard let `self` = self else {
                    return
                }
                
                self.actionButton.isEnabled = enabled
                
                if enabled {
                    self.actionButton.backgroundColor = .tpGreen()
                    self.actionButton.setTitleColor(.white, for: .normal)
                } else {
                    self.actionButton.backgroundColor = .tpBorder()
                    self.actionButton.setTitleColor(UIColor.black.withAlphaComponent(0.26), for: .normal)
                }
            })
            .disposed(by: self.rx_disposeBag)
    }
    
    // MARK: Text Field Delegate
    
    @IBAction private func validateWhileTyping(_ textField: UITextField) {
        if let text = textField.text, text.count >= 9 && text.count < 15 {
            self.nextButtonEnabled.value = true
        } else {
            self.nextButtonEnabled.value = false
        }
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.phoneNumberTextField {
            self.phoneNumberHorizontalLine.backgroundColor = .tpGreen()
        }
        
        return true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == self.phoneNumberTextField {
            self.phoneNumberHorizontalLine.backgroundColor = .tpBorder()
        }
        
        return true
    }
}
