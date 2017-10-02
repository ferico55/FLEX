//
//  LoginTableViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 04/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class LoginTableViewController: UITableViewController {

    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var emailErrorLabel: UILabel!
    @IBOutlet private weak var emailUnderlineView: UIView!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var passwordErrorLabel: UILabel!
    @IBOutlet private weak var passwordUnderlineView: UIView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var eyeButton: UIButton!
    @IBOutlet private weak var loginButton: UIButton!
    weak var parentController: LoginViewController!
    var isPasswordVisible = false
    var providersListViewHeight: CGFloat = 0.0 {
        didSet {
            self.tableView.reloadData()
        }
    }
    //    MARK: - Lifecycle
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if let parent = parent as? LoginViewController {
            self.parentController = parent
            self.setupUI()
            self.parentController.loadingUIHandler = { (isLoading: Bool) in
                self.makeActivityIndicator(toShow: isLoading)
            }
        }
    }
    //    MARK: - Field Setter
    func setField(email: String) {
        self.emailTextField.text = email
    }
    func setField(password: String) {
        self.passwordTextField.text = password
    }
    //    MARK: - Setup
    func setupUI() {
        self.eyeButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    //    MARK: - Actions
    @IBAction func forgotPasswordButtonTapped(sender: UIButton) {
        let viewController = ForgotPasswordViewController()
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    @IBAction func loginButtonTapped(sender: UIButton) {
        self.view.endEditing(true)
        let trimmedEmail = self.emailTextField.text?.replacingOccurrences(of: " ", with: "")
        self.emailTextField.text = trimmedEmail
        LoginAnalytics().trackLoginClickEvent(label: "CTA")
        self.emailErrorLabel.text = ""
        self.emailUnderlineView.backgroundColor = UIColor.tpBorder()
        self.passwordErrorLabel.text = ""
        self.passwordUnderlineView.backgroundColor = UIColor.tpBorder()
        if self.validateEmailPassword(showError: false) == false {
            self.makeActivityIndicator(toShow: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                _ = self.validateEmailPassword(showError: true)
                self.makeActivityIndicator(toShow: false)
            })
            return
        }
        self.parentController.doLoginWithEmail(email: self.emailTextField.text!, password: self.passwordTextField.text!)
    }
    @IBAction func showHidePassword(sender: UIButton) {
        self.isPasswordVisible = !self.isPasswordVisible
        if self.isPasswordVisible {
            sender.setImage(UIImage(named: "eyeOpen"), for: .normal)
            self.passwordTextField.isSecureTextEntry = false
        } else {
            sender.setImage(UIImage(named: "eyeClosed"), for: .normal)
            self.passwordTextField.isSecureTextEntry = true
        }
        if #available(iOS 10.0, *) {
            // Above ios 10.0 there is no issue in cursor repositioning
        } else {
            // Handle cursor repositioning after textField type changes
            self.repositionCursorOfTextField()
        }
    }
    //    MARK: - Private
    func validateEmailPassword(showError: Bool) -> Bool {
        var isValid = true
        let email = self.emailTextField.text
        let password = self.passwordTextField.text
        if email == nil || email?.isEmpty == true {
            if showError {
                self.emailErrorLabel.text = "Email harus diisi"
                self.emailUnderlineView.backgroundColor = UIColor.tpRedError()
                LoginAnalytics().trackLoginErrorEvent(label: "Email")
            }
            isValid = false
        } else if (NSString(string: email!)).isEmail() == nil {
            if showError {
                self.emailErrorLabel.text = "Format email salah"
                self.emailUnderlineView.backgroundColor = UIColor.tpRedError()
                LoginAnalytics().trackLoginErrorEvent(label: "Email")
            }
            isValid = false
        }
        if password == nil || password?.isEmpty == true {
            if showError {
                self.passwordErrorLabel.text = "Password harus diisi"
                self.passwordUnderlineView.backgroundColor = UIColor.tpRedError()
                LoginAnalytics().trackLoginErrorEvent(label: "Kata Sandi")
            }
            isValid = false
        }
        return isValid
    }
    func repositionCursorOfTextField() {
        var length = (self.passwordTextField.text?.lengthOfBytes(using: .utf8))! - 1
        let newPosition = self.passwordTextField.position(from: self.passwordTextField.beginningOfDocument, offset: length)
        if let newPosition = newPosition {
            self.passwordTextField.selectedTextRange = self.passwordTextField.textRange(from: newPosition, to: newPosition)
            length += 1
            let newPosition1 = self.passwordTextField.position(from: self.passwordTextField.beginningOfDocument, offset: length)
            if let newPosition1 = newPosition1 {
                self.passwordTextField.selectedTextRange = self.passwordTextField.textRange(from: newPosition1, to: newPosition1)
            }
        }
    }
    func makeActivityIndicator(toShow: Bool) {
        if toShow {
            self.activityIndicator.startAnimating()
            self.loginButton.setTitle("", for: .normal)
        } else {
            self.activityIndicator.stopAnimating()
            self.loginButton.setTitle("Masuk", for: .normal)
        }
        self.tableView.isUserInteractionEnabled = !toShow
    }
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    //    MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 3: return 60.0
        case 4: return self.providersListViewHeight

        default:
            return 94.0
        }
    }
    //    MARK: - UITextFieldDelegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.emailTextField.isFirstResponder {
            self.emailErrorLabel.text = ""
            self.emailUnderlineView.backgroundColor = UIColor.tpGreen()
        } else if self.passwordTextField.isFirstResponder {
            self.passwordErrorLabel.text = ""
            self.passwordUnderlineView.backgroundColor = UIColor.tpGreen()
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.emailTextField.isFirstResponder {
            self.passwordTextField.becomeFirstResponder()
        } else if self.passwordTextField.isFirstResponder {
            self.passwordTextField.resignFirstResponder()
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.emailTextField {
            self.emailUnderlineView.backgroundColor = UIColor.tpBorder()
        } else {
            self.passwordUnderlineView.backgroundColor = UIColor.tpBorder()
        }
    }

}
