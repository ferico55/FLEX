//
//  RegisterSocialMediaViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/8/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import FBSDKLoginKit
import MMNumberKeyboard
import RxSwift
import TPKeyboardAvoiding
import TTTAttributedLabel
import UIKit

internal class RegisterSocialMediaViewController: UIViewController, UITextFieldDelegate, MMNumberKeyboardDelegate {
    
    private let userProfile: CreatePasswordUserProfile!
    private let token: OAuthToken!
    private let accountInfo: AccountInfo!
    private let successCallback: (() -> Void)!
    var isLoginPresented = false
    
    @IBOutlet private var headerLabel: TTTAttributedLabel!
    @IBOutlet private var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var nameHorizontalLine: UIView!
    @IBOutlet private var phoneNumberTextField: UITextField!
    @IBOutlet private var phoneNumberHorizontalLine: UIView!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var passwordHorizontalLine: UIView!
    @IBOutlet private var eyeButton: UIButton!
    @IBOutlet private var doneButton: UIButton!
    @IBOutlet private var termsAndConditionsButton: UIButton!
    @IBOutlet private var privacyPolicyButton: UIButton!
    
    private let registerFormData = RegisterFormData()
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        return activityIndicator
    }()
    
    private let doneButtonIsEnabled = Variable(false)
    private let doneButtonIsLoading = Variable(false)
    
    public init(userProfile: CreatePasswordUserProfile, token: OAuthToken, accountInfo: AccountInfo, successCallback: @escaping (() -> Void)) {
        self.userProfile = userProfile
        self.token = token
        self.accountInfo = accountInfo
        self.successCallback = successCallback
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Daftar"
        
        self.setupHeaderLabel()
        self.setupDoneButton()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .plain, target: self, action: #selector(self.didTapBackButton))
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AnalyticsManager.trackScreenName("Register With \(self.userProfile.providerName) Page")
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupForm()
    }
    
    // MARK: Setup View
    private func setupHeaderLabel() {
        guard let email = self.userProfile.email else {
            return
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 20.0
        
        let prefix = "Lengkapi informasi akun Anda untuk mendaftar dengan "
        
        let headerString = NSMutableAttributedString(string: prefix)
        headerString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black.withAlphaComponent(0.54), range: NSMakeRange(0, prefix.characters.count))
        
        let emailString = NSMutableAttributedString(string: email)
        emailString.addAttribute(NSFontAttributeName, value: UIFont.smallThemeSemibold(), range: NSMakeRange(0, email.characters.count))
        emailString.addAttribute(NSForegroundColorAttributeName, value: UIColor.black.withAlphaComponent(0.7), range: NSMakeRange(0, email.characters.count))
        
        headerString.append(emailString)
        
        self.headerLabel.attributedText = headerString
    }
    
    private func setupForm() {
        self.scrollView.isAccessibilityElement = true
        self.scrollView.accessibilityLabel = "registerSocialMediaScrollView"
        
        self.updateFormViewAppearance()
        
        let numberKeyboard = MMNumberKeyboard(frame: .zero)
        numberKeyboard.allowsDecimalPoint = false
        numberKeyboard.delegate = self
        
        if !self.accountInfo.requiredFields.contains("name") {
            self.nameTextField.text = self.userProfile.name
            self.nameTextField.isEnabled = false
            self.nameTextField.textColor = UIColor.black.withAlphaComponent(0.18)
            
            self.registerFormData.fullName = self.userProfile.name!
            self.nameHorizontalLine.addDashedLine(color: .fromHexString("#e0e0e0"), lineWidth: 1.0)
        }
        
        self.nameTextField.autocapitalizationType = .words
        self.nameTextField.delegate = self
        
        self.phoneNumberTextField.delegate = self
        self.phoneNumberTextField.inputView = numberKeyboard
        
        self.passwordTextField.delegate = self
        
        self.eyeButton.setImage(#imageLiteral(resourceName: "password_eyeClose"), for: .normal)
        self.eyeButton.setImage(#imageLiteral(resourceName: "password_eyeOpen"), for: .selected)
        
        let halfButtonHeight = self.doneButton.bounds.size.height / 2
        let buttonWidth = self.doneButton.bounds.size.width
        
        self.activityIndicator.center = CGPoint(x: buttonWidth - halfButtonHeight, y: halfButtonHeight)
        
        self.doneButton.addSubview(self.activityIndicator)
        
        self.activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(self.doneButton.snp.centerX)
            make.centerY.equalTo(self.doneButton.snp.centerY)
        }
        
        self.validateForm()
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
    
    private func setupDoneButton() {
        self.doneButtonIsEnabled.asObservable()
            .subscribe(onNext: { [weak self] enabled in
                guard let `self` = self else {
                    return
                }
                self.doneButton.isEnabled = enabled
                
                if enabled {
                    self.doneButton.backgroundColor = .tpGreen()
                    self.doneButton.setTitleColor(.white, for: .normal)
                } else {
                    self.doneButton.backgroundColor = .tpBorder()
                    self.doneButton.setTitleColor(UIColor.black.withAlphaComponent(0.26), for: .normal)
                }
            })
            .disposed(by: rx_disposeBag)
        
        self.doneButtonIsLoading.asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                guard let `self` = self else {
                    return
                }
                
                self.doneButton.isEnabled = !isLoading
                
                isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
                
                self.doneButton.setTitle(isLoading ? "" : "Selesai", for: .normal)
            })
            .disposed(by: rx_disposeBag)
    }
    
    private func validateForm() {
        let name = self.registerFormData.fullName
        let phoneNumber = self.registerFormData.phoneNumber
        let password = self.registerFormData.password
        
        let nameTest = NSPredicate(format: "SELF MATCHES %@", "[A-Za-z ]*")
        let validName = (name != "") && nameTest.evaluate(with: name)
        
        let validPhone = phoneNumber != ""
        
        let validPassword = password != "" && password.characters.count >= 6
        
        self.doneButtonIsEnabled.value = validName && validPhone && validPassword
    }
    
    // MARK: Action Button Methods
    @objc private func didTapBackButton() {
        AnalyticsManager.trackEventName("registerAbandon", category: GA_EVENT_CATEGORY_REGISTER, action: "Register Abandon", label: "\(self.userProfile.providerName)")
        let facebookLoginManager = FBSDKLoginManager()
        facebookLoginManager.logOut()
        
        FBSDKAccessToken.setCurrent(nil)
        
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onTapTermsAndConditionsButton(_ sender: Any) {
        let webViewController = WKWebViewController(urlString: "https://m.tokopedia.com/terms.pl")
        webViewController.title = "Syarat dan Ketentuan"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    @IBAction func onTapPrivacyPolicyButton(_ sender: Any) {
        let webViewController = WKWebViewController(urlString: "https://m.tokopedia.com/privacy.pl")
        webViewController.title = "Kebijakan Privasi"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    @IBAction func onTapEyeButton(_ sender: Any) {
        self.eyeButton.isSelected = !self.eyeButton.isSelected
        
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
        
        let tempPassword = self.passwordTextField.text
        
        self.passwordTextField.text = ""
        self.passwordTextField.text = tempPassword
        self.passwordTextField.clearsOnBeginEditing = false
        self.passwordTextField.font = nil
        self.passwordTextField.font = .systemFont(ofSize: 16)
        
        self.passwordTextField.resignFirstResponder()
    }
    
    @IBAction func onTapDoneButton(_ sender: Any) {
        AnalyticsManager.trackEventName("clickRegister", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_CLICK, label: "\(self.userProfile.providerName) - Step 2")
        UserRequest.createPassword(
            name: self.registerFormData.fullName,
            gender: self.userProfile.gender ?? "3",
            phoneNumber: self.registerFormData.phoneNumber,
            password: self.registerFormData.password,
            token: self.token,
            accountInfo: self.accountInfo,
            onSuccess: { result in
                if result.result.is_success == "1" {
                    AnalyticsManager.trackEventName("clickRegister", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_REGISTER_SUCCESS, label: self.userProfile.providerName)
                    self.dismiss(animated: true, completion: nil)
                    self.successCallback()
                } else {
                    result.message_error.forEach({ message in
                        AnalyticsManager.trackEventName("registerSuccess", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_REGISTER_SUCCESS, label: "\(self.userProfile.providerName) - \(message)")
                    })
                    StickyAlertView.showErrorMessage(result.message_error)
                }
            },
            onFailure: {
                
            }
        )
    }
    
    // MARK: UITextField Delegate
    @IBAction private func validateFormWhileTyping(_ textField: UITextField) {
        if textField == self.nameTextField {
            self.registerFormData.fullName = textField.text!
        }
        
        if textField == self.phoneNumberTextField {
            self.registerFormData.phoneNumber = textField.text!
        }
        
        if textField == self.passwordTextField {
            self.registerFormData.password = textField.text!
        }
        
        self.validateForm()
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            self.nameHorizontalLine.backgroundColor = .tpGreen()
        }
        
        if textField == self.phoneNumberTextField {
            self.phoneNumberHorizontalLine.backgroundColor = .tpGreen()
        }
        
        if textField == self.passwordTextField {
            self.passwordHorizontalLine.backgroundColor = .tpGreen()
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameTextField {
            self.nameTextField.resignFirstResponder()
            self.phoneNumberTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == self.nameTextField {
            self.nameHorizontalLine.backgroundColor = .tpBorder()
        }
        
        if textField == self.phoneNumberTextField {
            self.phoneNumberHorizontalLine.backgroundColor = .tpBorder()
        }
        
        if textField == self.passwordTextField {
            self.passwordHorizontalLine.backgroundColor = .tpBorder()
        }
        
        return true
    }
    
    // MARK: MMNumberKeyboard Delegate
    func numberKeyboardShouldReturn(_ numberKeyboard: MMNumberKeyboard!) -> Bool {
        self.phoneNumberTextField.resignFirstResponder()
        self.passwordTextField.becomeFirstResponder()
        return true
    }
}
