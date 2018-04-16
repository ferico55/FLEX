//
//  RegisterPhoneNumberViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 20/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftOverlays
import TPKeyboardAvoiding
import UIKit

public class RegisterPhoneNumberViewController: UIViewController, CentralizedOTPDelegate {
    
    // outlet
    @IBOutlet private var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet private weak var phoneNumberTextField: UITextField!
    @IBOutlet private weak var validationView: UIView!
    @IBOutlet private weak var descLabel: UILabel!
    @IBOutlet private weak var registerButton: UIButton!
    @IBOutlet private weak var privacyPolicyButton: UIButton!
    @IBOutlet private weak var termConditionButton: UIButton!
    
    // var
    private let doSendOtpTrigger = PublishSubject<Void>()
    private let doLoginTrigger = PublishSubject<Void>()
    private let doRegisterTrigger = PublishSubject<(otpType: CentralizedOTPType, otpResult: COTPResponse)>()
    
    // navigator
    private lazy var navigator: RegisterPhoneNumberNavigator = {
        let nv = RegisterPhoneNumberNavigator(navigationController: self.navigationController)
        return nv
    }()
    
    // view model
    private var viewModel: RegisterPhoneNumberViewModel
    
    public init() {
        self.viewModel = RegisterPhoneNumberViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Daftar dengan Nomor Ponsel"
        
        self.updateFormViewAppearance()
        self.configureTnC()
        self.bindViewModel()
        
        self.phoneNumberTextField.becomeFirstResponder()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsManager.trackScreenName("Register with phone number page")
    }
    
    private func bindViewModel() {
        
        let input = RegisterPhoneNumberViewModel.Input(phoneNumber: phoneNumberTextField.rx.text.orEmpty.asDriver(),
                                                       registerTrigger: registerButton.rx.tap.asDriver(),
                                                       doSendOtpTrigger: doSendOtpTrigger.asDriverOnErrorJustComplete(),
                                                       doLoginTrigger: doLoginTrigger.asDriverOnErrorJustComplete(),
                                                       doRegisterTrigger: doRegisterTrigger.asDriverOnErrorJustComplete())
        let output = viewModel.transform(input: input)
        
        output.isValidPhoneNumber
            .drive(registerButton.rx.isEnabled)
            .disposed(by: rx_disposeBag)
        
        output.descString
            .drive(descLabel.rx.text)
            .disposed(by: rx_disposeBag)
        
        output.activityIndicator.drive(onNext: { [weak self] isActive in
            guard let strongSelf = self else { return }
            if isActive {
                self?.view.endEditing(true)
                SwiftOverlays.showCenteredWaitOverlay(strongSelf.view)
            } else {
                SwiftOverlays.removeAllOverlaysFromView(strongSelf.view)
            }
        }).disposed(by: rx_disposeBag)
        
        output.isUserExist.drive(onNext: { [weak self] number in
            self?.askToLogin(with: number)
        }).disposed(by: rx_disposeBag)
        
        output.login.drive(onNext: navigator.toLoginPhoneNumber).disposed(by: rx_disposeBag)
        
        output.isNewUser.drive(onNext: { [weak self] number in
            self?.askToRegister(with: number)
        }).disposed(by: rx_disposeBag)
        
        output.successSendOTP.drive(onNext: { [weak self] modeDetail, accountInfo in
            guard let strongSelf = self else { return }
            strongSelf.navigator.toCOTP(modeDetail, accountInfo: accountInfo, delegate: strongSelf)
        }).disposed(by: rx_disposeBag)
        
        output.register.drive(onNext: { [weak self] _ in
            AnalyticsManager.trackEventName("clickRegister", category: "Register", action: "Register Success", label: "Phone Number")
            guard let vc = self?.navigationController?.viewControllers.first, vc.isModal() else {
                NotificationCenter.default.post(name: NSNotification.Name("didSuccessActivateAccount"), object: nil, userInfo: nil)
                return
            }
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }).disposed(by: rx_disposeBag)
        
        output.failedMessage.drive(onNext: { errorMessage in
            StickyAlertView.showErrorMessage(errorMessage)
        }).disposed(by: rx_disposeBag)
        
        output.cursorColor
            .drive(onNext: { [weak self] color in
                self?.phoneNumberTextField.tintColor = color
            })
            .disposed(by: rx_disposeBag)
        
        output.validationTextColor
            .drive(onNext: { [weak self] color in
                self?.descLabel.textColor = color
            })
            .disposed(by: rx_disposeBag)
        
        output.validationColor
            .drive(onNext: { [weak self] color in
                self?.validationView.backgroundColor = color
            })
            .disposed(by: rx_disposeBag)
        
        output.buttonBackgroundColor
            .drive(onNext: { [weak self] color in
                self?.registerButton.backgroundColor = color
            }).disposed(by: rx_disposeBag)
    }
    
    private func updateFormViewAppearance() {
        self.view.addSubview(self.scrollView)
        let contentViewWidth = UI_USER_INTERFACE_IDIOM() == .pad ? 560 : UIScreen.main.bounds.size.width
        self.scrollView.snp.makeConstraints { constraint in
            constraint.width.equalTo(contentViewWidth)
            constraint.top.equalTo(self.view.snp.top)
            constraint.bottom.equalTo(self.view.snp.bottom)
            constraint.centerX.equalTo(self.view.snp.centerX)
        }
    }
    
    // MARK: Action Button TnC
    private func configureTnC() {
        self.termConditionButton.rx.tap.asDriver()
            .drive(onNext: self.navigator.toTnC)
            .disposed(by: rx_disposeBag)
        
        self.privacyPolicyButton.rx.tap.asDriver()
            .drive(onNext: self.navigator.toPrivacyPolicy)
            .disposed(by: rx_disposeBag)
    }
    
    private func askToLogin(with number: String) {
        let alertController = UIAlertController(title: "Nomor Ponsel Sudah Terdaftar",
                                                message: "Masuk dengan nomor \(number)?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ubah", style: .default) { _ in }
        let loginAction = UIAlertAction(title: "Masuk", style: .default) { _ in
            self.doLoginTrigger.onNext()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(loginAction)
        self.present(alertController, animated: true)
    }
    
    private func askToRegister(with number: String) {
        let alertController = UIAlertController(title: number,
                                                message: "Apakah nomor ponsel yang Anda masukkan sudah benar?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Tidak", style: .default) { _ in }
        let registerAction = UIAlertAction(title: "Ya, Lanjut", style: .default) { _ in
            self.doSendOtpTrigger.onNext()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(registerAction)
        
        self.present(alertController, animated: true)
    }
    
    public func didSuccessVerificationOTP(otpType: CentralizedOTPType, otpResult: COTPResponse) {
        self.doRegisterTrigger.onNext((otpType: otpType, otpResult: otpResult))
    }
}
