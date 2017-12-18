//
//  RegisterEmailViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 9/5/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import RxSwift
import MMNumberKeyboard

class RegisterFormData: NSObject {
    var email: String = ""
    var fullName: String = ""
    var phoneNumber: String = ""
    var password: String = ""
}

@objc(RegisterEmailViewController)
class RegisterEmailViewController: UIViewController, UITextFieldDelegate, MMNumberKeyboardDelegate {
    
    var isLoginPresented = false
    
    @IBOutlet private var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet private var emailTextField: UITextField!
    @IBOutlet private var emailHorizontalLine: UIView!
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var nameHorizontalLine: UIView!
    @IBOutlet private var phoneNumberTextField: UITextField!
    @IBOutlet private var phoneNumberHorizontalLine: UIView!
    @IBOutlet private var passwordTextField: UITextField!
    @IBOutlet private var passwordHorizontalLine: UIView!
    @IBOutlet private var eyeButton: UIButton!
    @IBOutlet private var registerButton: UIButton!
    @IBOutlet private var syaratDanKetentuanButton: UIButton!
    @IBOutlet private var kebijakanPrivasiButton: UIButton!
    
    private let registerFormData = RegisterFormData()
    private var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        return activityIndicator
    }()
    
    private let registerButtonEnabled = Variable(false)
    private let registerButtonIsLoading = Variable(false)
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Daftar"
        
        self.setupRegisterButton()
        self.setupForm()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AnalyticsManager.trackScreenName("Register With Email Page")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func setupForm() {
        self.scrollView.accessibilityLabel = "registerEmailScrollView"
        
        let numberKeyboard = MMNumberKeyboard(frame: .zero)
        numberKeyboard.allowsDecimalPoint = false
        numberKeyboard.delegate = self
        
        self.emailTextField.delegate = self
        
        self.nameTextField.autocapitalizationType = .words
        self.nameTextField.delegate = self
        
        self.phoneNumberTextField.delegate = self
        self.phoneNumberTextField.inputView = numberKeyboard
        
        self.passwordTextField.delegate = self
        
        self.eyeButton.setImage(#imageLiteral(resourceName: "password_eyeClose"), for: .normal)
        self.eyeButton.setImage(#imageLiteral(resourceName: "password_eyeOpen"), for: .selected)
        
        let halfButtonHeight = self.registerButton.bounds.size.height / 2
        let buttonWidth = self.registerButton.bounds.size.width
        
        self.activityIndicator.center = CGPoint(x: buttonWidth - halfButtonHeight, y: halfButtonHeight)
        
        self.registerButton.addSubview(self.activityIndicator)
        
        self.activityIndicator.snp.makeConstraints { make in
            make.centerX.equalTo(self.registerButton.snp.centerX)
            make.centerY.equalTo(self.registerButton.snp.centerY)
        }
        
        self.updateFormViewAppearance()
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
    
    private func setupRegisterButton() {
        self.registerButtonEnabled.asObservable()
            .subscribe(onNext: { [weak self] enabled in
                guard let `self` = self else {
                    return
                }
                self.registerButton.isEnabled = enabled
                
                if enabled {
                    self.registerButton.backgroundColor = .tpGreen()
                    self.registerButton.setTitleColor(.white, for: .normal)
                } else {
                    self.registerButton.backgroundColor = .tpBorder()
                    self.registerButton.setTitleColor(UIColor.black.withAlphaComponent(0.26), for: .normal)
                }
            })
            .disposed(by: rx_disposeBag)
        
        self.registerButtonIsLoading.asObservable()
            .subscribe(onNext: { [weak self] isLoading in
                guard let `self` = self else {
                    return
                }
                
                self.registerButton.isEnabled = !isLoading
                
                isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
                
                self.registerButton.setTitle(isLoading ? "" : "Daftar", for: .normal)
            })
            .disposed(by: rx_disposeBag)
    }
    
    private func validateForm() {
        let name = self.registerFormData.fullName
        let email = self.registerFormData.email
        let phoneNumber = self.registerFormData.phoneNumber
        let password = self.registerFormData.password
        
        let validEmail = (email != "")
        
        let validName = (name != "")
        
        let validPhone = phoneNumber != ""
        
        let validPassword = password != "" && password.characters.count >= 6
        
        self.registerButtonEnabled.value = validEmail && validName && validPhone && validPassword
    }
    
    // MARK: Action Button Methods
    @IBAction private func onTapSyaratDanKetentuanButton(_ sender: Any) {
        let webViewController = WKWebViewController(urlString: "https://m.tokopedia.com/terms.pl")
        webViewController.title = "Syarat dan Ketentuan"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    @IBAction private func onTapKebijakanPrivasiButton(_ sender: Any) {
        let webViewController = WKWebViewController(urlString: "https://m.tokopedia.com/privacy.pl")
        webViewController.title = "Kebijakan Privasi"
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    @IBAction private func onTapRegisterButton(_ sender: Any) {
        AnalyticsManager.trackEventName("clickRegister", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_CLICK, label: "Email - Step 2")
        self.registerButtonIsLoading.value = true
        UserRequest.registerWithEmail(
            formData: self.registerFormData,
            onSuccess: { result in
                self.registerButtonIsLoading.value = false
                if result.smartRegisterAction == .defaultAction {
                    if let errorMessages = result.errorMessages {
                        errorMessages.forEach({ message in
                            AnalyticsManager.trackEventName("registerSuccess", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_REGISTER_SUCCESS, label: "Email - \(message)")
                        })
                        StickyAlertView.showErrorMessage(errorMessages)
                        return
                    }
                    AnalyticsManager.trackEventName("registerSuccess", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_REGISTER_SUCCESS, label: "Email")
                    let activationVC = AccountActivationViewController(email: self.registerFormData.email)
                    activationVC.isLoginPresented = self.isLoginPresented
                    self.navigationController?.pushViewController(activationVC, animated: true)
                } else if result.smartRegisterAction == .loginAutomatically {
                    if let errorMessages = result.errorMessages {
                        errorMessages.forEach({ message in
                            AnalyticsManager.trackEventName("registerSuccess", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_REGISTER_SUCCESS, label: "Email - \(message)")
                        })
                    }
                    self.loginExistingUser()
                } else if result.smartRegisterAction == .resetPassword {
                    if let errorMessages = result.errorMessages {
                        errorMessages.forEach({ message in
                            AnalyticsManager.trackEventName("registerSuccess", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_REGISTER_SUCCESS, label: "Email - \(message)")
                        })
                    }
                    self.navigateToResetPassword()
                } else if result.smartRegisterAction == .needActivation {
                    let activationVC = AccountActivationViewController(email: self.registerFormData.email)
                    activationVC.isLoginPresented = self.isLoginPresented
                    self.navigationController?.pushViewController(activationVC, animated: true)
                } else {
                    if let errorMessages = result.errorMessages {
                        errorMessages.forEach({ message in
                            AnalyticsManager.trackEventName("registerSuccess", category: GA_EVENT_CATEGORY_REGISTER, action: GA_EVENT_ACTION_REGISTER_SUCCESS, label: "Email - \(message)")
                        })
                        StickyAlertView.showErrorMessage(errorMessages)
                        return
                    }
                }
            },
            onFailure: {
                self.registerButtonIsLoading.value = false
            }
        )
    }
    
    @IBAction func onTapSeePasswordButton(_ sender: Any) {
        self.eyeButton.isSelected = !self.eyeButton.isSelected
        
        self.passwordTextField.isSecureTextEntry = !self.passwordTextField.isSecureTextEntry
        
        let tempPassword = self.passwordTextField.text
        
        self.passwordTextField.text = ""
        self.passwordTextField.text = tempPassword
        self.passwordTextField.clearsOnBeginEditing = false
        self.passwordTextField.font = nil
        self.passwordTextField.font = .systemFont(ofSize: 16)
    }
    
    // MARK: Smart Register Flow
    private func loginExistingUser() {
        AuthenticationService.shared.login(withEmail: self.registerFormData.email, password: self.registerFormData.password)
        AuthenticationService.shared.onLoginComplete = { login, _ in
            guard let login = login else {
                return
            }
            self.loginSuccess(login: login)
        }
    }
    
    private func loginSuccess(login: Login) {
        GIDSignIn.sharedInstance().signOut()
        GIDSignIn.sharedInstance().disconnect()
        
        let storageManager = SecureStorageManager()
        storageManager.storeLoginInformation(login.result)
                
        if self.isLoginPresented {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(TKPDUserDidLoginNotification), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(UPDATE_TABBAR), object: nil, userInfo: nil)
        NotificationCenter.default.post(name: NSNotification.Name(kTKPD_REDIRECT_TO_HOME), object: nil)
        
        AnalyticsManager.trackLogin(login)
    }
    
    private func navigateToResetPassword() {
        let vc = ResetPasswordSuccessViewController(email: self.registerFormData.email)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: Text Field Delegate
    @IBAction private func validateFormWhileTyping(_ textField: UITextField) {
        if textField == self.emailTextField {
            self.registerFormData.email = textField.text!
        }
        
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
        if textField == self.emailTextField {
            self.emailHorizontalLine.backgroundColor = .tpGreen()
        }
        
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
        if textField == self.emailTextField {
            self.emailTextField.resignFirstResponder()
            self.nameTextField.becomeFirstResponder()
        } else if textField == self.nameTextField {
            self.nameTextField.resignFirstResponder()
            self.phoneNumberTextField.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField == self.emailTextField {
            self.emailHorizontalLine.backgroundColor = .tpBorder()
        }
        
        if textField == self.nameTextField {
            self.nameHorizontalLine.backgroundColor = .tpBorder()
        }
        
        if textField == self.phoneNumberTextField {
            self.phoneNumberHorizontalLine.backgroundColor = .tpBorder()
        }
        
        if textField == self.passwordTextField {
            self.passwordHorizontalLine.backgroundColor = .tpBorder()
        }
        
        self.validateForm()
        
        return true
    }
    
    // MARK: MMNumberKeyboard Delegate
    func numberKeyboardShouldReturn(_ numberKeyboard: MMNumberKeyboard!) -> Bool {
        self.phoneNumberTextField.resignFirstResponder()
        self.passwordTextField.becomeFirstResponder()
        return true
    }
}
