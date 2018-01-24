//
//  AccountActivationViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import VMaskTextField
import RxSwift

class AccountActivationViewController: UIViewController, UITextFieldDelegate {
    
    private let email: String?
    var isLoginPresented = false
    
    @IBOutlet private var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet private var registeredEmail: UILabel!
    @IBOutlet private var uniqueCodeTextField: VMaskTextField!
    @IBOutlet private var activateButton: UIButton!
    @IBOutlet private var resendEmailButton: UIButton!
    @IBOutlet private var uniqueCodeHorizontalLine: UIView!
    
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        return activityIndicator
    }()
    
    private let activationButtonEnabled = Variable(false)
    private let activationButtonIsLoading = Variable(false)
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Aktivasi Akun"
        self.setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AnalyticsManager.trackScreenName("Account Activation Page")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupView() {
        self.scrollView.accessibilityLabel = "accountActivationScrollView"
        
        self.uniqueCodeTextField.delegate = self
        self.uniqueCodeTextField.mask = "#  #  #  #  #"
        
        self.registeredEmail.text = self.email
        
        let halfButtonHeight = self.activateButton.bounds.size.height / 2
        let buttonWidth = self.activateButton.bounds.size.width
        
        self.activityIndicator.center = CGPoint(x: buttonWidth - halfButtonHeight, y: halfButtonHeight)
        
        self.activateButton.addSubview(self.activityIndicator)
        
        self.activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(self.activateButton.snp.centerX)
            make.centerY.equalTo(self.activateButton.snp.centerY)
        }
        
        self.updateFormViewAppearance()
        self.setupActivationButton()
        
        self.uniqueCodeTextField.bk_shouldBeginEditingBlock = { [weak self] _ in
            self?.uniqueCodeHorizontalLine.backgroundColor = .tpGreen()
            
            return true
        }
        
        self.uniqueCodeTextField.bk_shouldEndEditingBlock = { [weak self] _ in
            self?.uniqueCodeHorizontalLine.backgroundColor = .tpBorder()
            
            return true
        }
    }
    
    private func setupActivationButton() {
        self.activationButtonEnabled.asObservable()
            .subscribe(onNext: { [weak self] enabled in
                guard let `self` = self else {
                    return
                }
                
                self.activateButton.isEnabled = enabled
                
                self.activateButton.backgroundColor = enabled ? .tpGreen() : .tpBorder()
                self.activateButton.setTitleColor(enabled ? .white : UIColor.black.withAlphaComponent(0.26), for: .normal)
            })
            .disposed(by: rx_disposeBag)
        
        self.activationButtonIsLoading.asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                guard let `self` = self else {
                    return
                }
                
                self.activateButton.isEnabled = !isLoading
                
                isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
                
                self.activateButton.setTitle(isLoading ? "" : "Aktivasi Sekarang", for: .normal)
            })
            .disposed(by: rx_disposeBag)
    }
    
    private func updateFormViewAppearance() {
        self.view.addSubview(self.scrollView)
        
        let width = UI_USER_INTERFACE_IDIOM() == .pad ? 560 : UIScreen.main.bounds.size.width
        
        self.scrollView.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.top.equalTo(self.view.snp.top)
            make.bottom.equalTo(self.view.snp.bottom)
            make.centerX.equalTo(self.view.snp.centerX)
        }
    }
    
    // MARK: Action Button Methods
    @IBAction func onTapResendEmailButton(_ sender: Any) {
        guard let email = self.email else {
            return
        }
        
        AnalyticsManager.trackEventName("clickActivation", category: GA_EVENT_CATEGORY_ACTIVATION, action: GA_EVENT_ACTION_CLICK, label: "Resend Email")
        UserRequest.resendActivationEmail(
            email: email,
            onSuccess: { result in
                let status = result.status
                
                if status == .success {
                    StickyAlertView.showSuccessMessage(result.statusMessages)
                } else if status == .alreadyRegistered || status == .invalid {
                    StickyAlertView.showErrorMessage(result.errorMessages)
                } else {
                    StickyAlertView.showErrorMessage(["Terjadi kendala pada server. Mohon coba beberapa saat lagi."])
                }
            },
            onFailure: {
                StickyAlertView.showErrorMessage(["Terjadi kendala pada server. Mohon coba beberapa saat lagi."])
            }
        )
    }
    
    @IBAction func onTapActivateButton(_ sender: Any) {
        guard let uniqueCode = self.uniqueCodeTextField.text?.replacingOccurrences(of: " ", with: ""), let email = self.email else {
            return
        }
        
        AnalyticsManager.trackEventName("clickActivation", category: GA_EVENT_CATEGORY_ACTIVATION, action: GA_EVENT_ACTION_CLICK, label: "Activate Now")
        
        self.activationButtonIsLoading.value = true
        
        UserRequest.activateAccount(
            email: email,
            uniqueCode: uniqueCode,
            onSuccess: { login in
                if login.message_error.count > 0 {
                    guard let errorMessages = login.message_error as? [String] else {
                        return
                    }
                    errorMessages.forEach({ message in
                        AnalyticsManager.trackEventName("activationError", category: GA_EVENT_CATEGORY_ACTIVATION, action: "Activation Error", label: message)
                    })
                    return
                }
                
                AnalyticsManager.trackEventName("activationSuccess", category: GA_EVENT_CATEGORY_ACTIVATION, action: "Activation Success", label: "Email Activation Success")
                self.activationButtonIsLoading.value = false
                self.onLoginSuccess(login: login)
            },
            onFailure: {
                self.activationButtonIsLoading.value = false
            }
        )
    }
    
    private func onLoginSuccess(login: Login) {
        let storageManager = SecureStorageManager()
        storageManager.storeLoginInformation(login.result)
        
        let userManager = UserAuthentificationManager()
        UserRequest.getUserInformation(
            withUserID: userManager.getUserId(),
            onSuccess: { _ in
                AnalyticsManager.moEngageTrackUserAttributes()
        },
            onFailure: {
                
        })
        
        AnalyticsManager.trackLogin(login)
        
        NotificationCenter.default.post(name: NSNotification.Name(TKPDUserDidLoginNotification), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(UPDATE_TABBAR), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name("didSuccessActivateAccount"), object: nil, userInfo: nil)
        
        guard let tabManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager else {
            return
        }
        
        tabManager.sendLoginEvent(userManager.getUserLoginData())
    }
    
    // MARK: UITextField Delegate    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = self.uniqueCodeTextField.text else {
            return false
        }
        
        var currentInput = ""
        
        if string == "" && text.characters.count >= 3 {
            currentInput = text.substring(to: text.index(text.endIndex, offsetBy: -3))
        } else {
            currentInput = text + string
        }
        
        let uniqueCode = currentInput.replacingOccurrences(of: " ", with: "")
        
        if uniqueCode.characters.count >= 5 {
            self.activationButtonEnabled.value = true
        } else {
            self.activationButtonEnabled.value = false
        }
        
        return self.uniqueCodeTextField.shouldChangeCharacters(in: range, replacementString: string)
    }
}
