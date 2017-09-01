
//
//  TokoCashActivationOTPViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 8/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import VMaskTextField
import RxSwift
import RxCocoa

class TokoCashActivationOTPViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var otpButton: UIButton!
    @IBOutlet weak var verificationCodeView: UIView!
    @IBOutlet weak var verificationCodeTextField: VMaskTextField!
    @IBOutlet weak var verificationButton: UIButton!
    @IBOutlet weak var otpButtonActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var verificationButtonActivityIndicator: UIActivityIndicatorView!
    
    private let phoneNumber = Variable("")
    private let enableOTPButton = Variable(true)
    private let enableVerificationButton = Variable(false)
    private let isLoadingSendOTP = Variable(false)
    private let isLoadingSendVerification = Variable(false)
    private let isRunning = Variable(false)
    private let resendOTPString = "Kirim SMS Ulang"
    private let resendTimer = 90
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verificationCodeTextField.delegate = self
        verificationCodeTextField.mask = "#  #  #  #  #  #"
        
        setupPhoneNumber()
        setupOTPButton()
        setupVerificationButton()
        setupOTPButtonActivityIndicator()
        setupVerificationButtonActivityIndicator()
        
        requestPhoneNumber()
        didTapSendOTPButton()
        setupTimer()
        didTapVerificationButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.trackScreenName("Tokocash Activation - Phone Verification Page")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Setup View
    private func setupPhoneNumber() {
        if let phone = UserAuthentificationManager().getUserPhoneNumber() {
            phoneNumber.value = phone
        }
        phoneNumber
            .asObservable()
            .bindTo(self.phoneNumberLabel.rx.text)
            .addDisposableTo(self.rx_disposeBag)
    }
    
    private func setupOTPButton(){
        enableOTPButton.asObservable()
            .subscribe(onNext: { [weak self] isEnable in
                guard let `self` = self else {return}
                self.otpButton.isEnabled = isEnable
                self.otpButton.layer.borderWidth = 1.0
                if (isEnable){
                    self.otpButton.backgroundColor = UIColor.tpGreen()
                    self.otpButton.layer.borderColor = UIColor.clear.cgColor
                }else {
                    self.otpButton.backgroundColor = UIColor.clear
                    self.otpButton.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12).cgColor
                }
            })
            .addDisposableTo(self.rx_disposeBag)
    }
    
    private func setupVerificationButton(){
        enableVerificationButton.asObservable()
            .subscribe(onNext: { isEnable in
                self.verificationButton.isEnabled = isEnable
                if (isEnable){
                    self.verificationCodeView.isHidden = false
                    self.verificationButton.backgroundColor = .tpGreen()
                }else {
                    self.verificationCodeView.isHidden = true
                    self.verificationButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.12)
                }
            })
            .addDisposableTo(self.rx_disposeBag)
    }
    
    private func setupOTPButtonActivityIndicator() {
        isLoadingSendOTP.asObservable().subscribe(onNext: { (isLoading) in
            if isLoading {
                self.otpButtonActivityIndicator.startAnimating()
                self.otpButton.setTitle("", for: .disabled)
                self.otpButton.isEnabled = false
            }else {
                self.otpButtonActivityIndicator.stopAnimating()
                self.otpButton.setTitle(self.resendOTPString, for: .disabled)
                self.otpButton.isEnabled = true
            }
        }).addDisposableTo(self.rx_disposeBag)
    }
    
    private func setupVerificationButtonActivityIndicator() {
        isLoadingSendVerification.asObservable().subscribe(onNext: { (isLoading) in
            if isLoading {
                self.verificationButtonActivityIndicator.startAnimating()
                self.verificationButton.setTitle("", for: .disabled)
                self.verificationButton.isEnabled = false
            }else {
                self.verificationButtonActivityIndicator.stopAnimating()
                self.verificationButton.setTitle("Varification", for: .disabled)
                self.verificationButton.isEnabled = true
            }
        }).addDisposableTo(self.rx_disposeBag)
    }
    
    //MARK: - Action
    private func requestPhoneNumber() {
        if self.phoneNumber.value.isEmpty {
            OTPRequest.getPhoneNumber(
                onSuccess: { (phoneNumber) in
                    self.phoneNumber.value = phoneNumber
            },onFailure: {
            })
        }
    }
    
    private func didTapSendOTPButton(){
        otpButton.rx.tap.subscribe(onNext: { [unowned self] in
            self.isLoadingSendOTP.value = true
            WalletService.requestOTPTokoCash()
                .subscribe(onNext: { succsess in
                    self.isLoadingSendOTP.value = false
                    if succsess {
                        self.enableOTPButton.value = false
                        self.isRunning.value = true
                        self.enableVerificationButton.value = true
                    }
                }, onError:{ error in
                    self.isLoadingSendOTP.value = false
                    debugPrint("Error :", error.localizedDescription)
                }).disposed(by: self.rx_disposeBag)
        }).addDisposableTo(self.rx_disposeBag)
    }
    
    private func setupTimer() {
        isRunning.asObservable()
            .subscribe(onNext: { (isRunning) in
                if isRunning {
                    Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                        .takeWhile({ (n) -> Bool in
                            return n < self.resendTimer
                        }).subscribe(onNext: { (timer) in
                            self.otpButton .setTitle("\(self.resendOTPString) (\(self.resendTimer - timer))", for: .disabled)
                        }, onError: { (error) in
                            debugPrint("Error :", error.localizedDescription)
                        }, onCompleted: {
                            self.otpButton .setTitle(self.resendOTPString, for: .normal)
                            self.enableOTPButton.value = true
                        }).addDisposableTo(self.rx_disposeBag)
                }
            }).addDisposableTo(self.rx_disposeBag)
    }
    
    private func didTapVerificationButton() {
        verificationButton.rx.tap.subscribe(onNext: { [unowned self] in
            
            guard let inputCode = self.verificationCodeTextField.text  else { return }
            let otpCode = (inputCode.replacingOccurrences(of: " ", with: ""))
            
            if otpCode.characters.count < 6 {
                StickyAlertView.showErrorMessage(["Kode OTP harus terdiri dari 6 angka"])
            }else {
                self.isLoadingSendVerification.value = true
                WalletService.activationTokoCash(verificationCode: otpCode)
                    .subscribe(onNext: { succsess in
                        self.isLoadingSendVerification.value = false
                        if succsess {
                            self.performSegue(withIdentifier: "tokoCashActivationSuccessSegue", sender: nil)
                        }
                    }, onError:{ error in
                        debugPrint("Error :", error)
                        self.isLoadingSendVerification.value = false
                    }).disposed(by: self.rx_disposeBag)
            }
        }).addDisposableTo(self.rx_disposeBag)
    }
    
    //MARK: - UITextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return verificationCodeTextField.shouldChangeCharacters(in: range, replacementString: string)
    }
}
