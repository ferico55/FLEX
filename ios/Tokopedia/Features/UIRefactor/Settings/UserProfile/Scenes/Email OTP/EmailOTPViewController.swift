//
//  EmailOTPViewController.swift
//  Tokopedia
//
//  Created by Dhio Etanasti on 3/26/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftOverlays
import UIKit

public class EmailOTPViewController: UIViewController, OTPInputViewDelegate, UITextViewDelegate {
    // outlet
    @IBOutlet weak private var subTitleLabel: UILabel!
    @IBOutlet weak private var stackViewOTP: OTPInputView!
    @IBOutlet weak private var clearOTPButton: UIButton!
    @IBOutlet weak private var errorLabel: UILabel!
    @IBOutlet weak private var verificationButton: UIButton!
    @IBOutlet weak private var informationTextView: UITextView!
    @IBOutlet weak private var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var resendLoadingIndicator: UIActivityIndicatorView!
    
    // var
    private let doOTPHasEntered = PublishSubject<Bool>()
    private let doOTPEnteredValue = PublishSubject<String>()
    private let doCountDown = PublishSubject<Void>()
    private let doResend = PublishSubject<Void>()
    private var otpEnteredText: String = ""
    
    // navigator
    private lazy var navigator: EmailOTPNavigator = {
        let nv = EmailOTPNavigator(navigationController: self.navigationController)
        return nv
    }()
    
    // view model
    private var viewModel: EmailOTPViewModel
    
    public init(email: String) {
        self.viewModel = EmailOTPViewModel(email)
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Verifikasi"
        
        setUpOTPStackView()
        bindViewModel()
        doCountDown.onNext()
    }
    
    private func setUpOTPStackView () {
        stackViewOTP.otpFieldsCount = 5
        stackViewOTP.delegate = self
        stackViewOTP.initalizeUI()
    }
    
    private func bindViewModel() {        
        let input = EmailOTPViewModel.Input(hasEnteredOTPtrigger: doOTPHasEntered.asDriverOnErrorJustComplete(),
                                            valueOTPtrigger: doOTPEnteredValue.asDriverOnErrorJustComplete(),
                                            startCountDownTrigger: doCountDown.asDriverOnErrorJustComplete(),
                                            verifyTrigger: verificationButton.rx.tap.asDriver(),
                                            resendTrigger: doResend.asDriverOnErrorJustComplete(),
                                            clearTrigger: clearOTPButton.rx.tap.asDriver())
        
        let output = viewModel.transform(input: input)
        
        output.subTitleLabel.drive(subTitleLabel.rx.text).disposed(by: rx_disposeBag)
        
        output.countDownStart.drive()
            .disposed(by: rx_disposeBag)
        
        output.countDownTick.drive(onNext: { [weak self] attString in
            self?.informationTextView.attributedText = attString
            self?.informationTextView.textAlignment = NSTextAlignment.center
            self?.informationTextView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.tpGreen()]
        }).disposed(by: rx_disposeBag)
        
        output.countDownStop.drive(onNext: { [weak self] attString in
            self?.informationTextView.attributedText = attString
            self?.informationTextView.textAlignment = NSTextAlignment.center
            self?.informationTextView.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.tpGreen()]
            self?.informationTextView.dataDetectorTypes = UIDataDetectorTypes.link
            self?.informationTextView.isSelectable = true
            self?.informationTextView.delegate = self
        }).disposed(by: rx_disposeBag)
        
        output.verifyButtonIsEnabled.drive(verificationButton.rx.isEnabled).disposed(by: rx_disposeBag)
        output.verifyButtonBackgroundColor.drive(onNext: { [weak self] color in
            self?.verificationButton.backgroundColor = color
        }).disposed(by: rx_disposeBag)
        
        output.verifyOTPActivityIndicator.drive(onNext: { [weak self] isLoading in
            guard let strongSelf = self else { return }
            strongSelf.stackViewOTP.isUserInteractionEnabled = !isLoading
            strongSelf.verificationButton.isUserInteractionEnabled = !isLoading
            if isLoading {
                strongSelf.view.endEditing(true)
                SwiftOverlays.showCenteredWaitOverlay(strongSelf.view)
            } else {
                SwiftOverlays.removeAllOverlaysFromView(strongSelf.view)
            }
        }).disposed(by: rx_disposeBag)
        
        output.isSuccessVerifyOTP.drive(onNext: { [weak self] _ in
            StickyAlertView.showSuccessMessage(["Email berhasil ditambahkan"])
            self?.navigator.backToProfileSettings()
        }).disposed(by: rx_disposeBag)
        
        output.resendActivityIndicator.drive(onNext: { [weak self] isLoading in
            self?.informationTextView.isHidden = isLoading
            if isLoading {
                self?.resendLoadingIndicator.startAnimating()
            } else {
                self?.resendLoadingIndicator.stopAnimating()
            }
        }).disposed(by: rx_disposeBag)
        
        output.isSuccessResend.drive(onNext: { [weak self] email in
            StickyAlertView.showSuccessMessage(["Berhasil mengirim ulang kode verifikasi ke \(email)"])
            self?.doCountDown.onNext()
        }).disposed(by: rx_disposeBag)
        
        output.messageErrors.drive(onNext: { messageErrors in
            StickyAlertView.showErrorMessage(messageErrors)
        }).disposed(by: rx_disposeBag)
        
        output.showStackErrorBorder.drive(onNext: { [weak self] _ in
            self?.stackViewOTP.showErrorBorder()
        }).disposed(by: rx_disposeBag)
        
        output.showStackSuccessBorder.drive(onNext: { [weak self] _ in
            self?.stackViewOTP.showSuccessBorder()
        }).disposed(by: rx_disposeBag)
        
        output.hideClearButton.drive(clearOTPButton.rx.isHidden).disposed(by: rx_disposeBag)
        
        output.clearOTP.drive(onNext: { [weak self] _ in
            self?.clearOTPButton.isHidden = true
            self?.errorLabel.text = ""
            self?.stackViewOTP.clearField()
        }).disposed(by: rx_disposeBag)
        
        output.failedVerifyOTPError.drive(errorLabel.rx.text).disposed(by: rx_disposeBag)
    }
    
    // OTP Stack View functions
    public func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    public func hasEnteredAllOTP(hasEntered: Bool, otpEntered: String) {
        doOTPHasEntered.onNext(hasEntered)
        if hasEntered {
            doOTPEnteredValue.onNext(otpEntered)
        }
    }

    // Information text view functions
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "resend" {
            doResend.onNext()
            return false
        } else {
            return true
        }
    }
}

