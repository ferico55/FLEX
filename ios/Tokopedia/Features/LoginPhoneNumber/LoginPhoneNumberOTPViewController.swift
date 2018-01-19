//
//  LoginPhoneNumberOTPViewController.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift
import VMaskTextField

private enum otpFieldStyle {
    case successStyle
    case failedStyle
    case defaultStyle
}

class LoginPhoneNumberOTPViewController: UIViewController {
    
    @IBOutlet weak var otpTextField: VMaskTextField!
    @IBOutlet weak var otpButton: UIButton!
    @IBOutlet weak var otpHorizontalLine: UIView!
    @IBOutlet weak var labelInformation: UITextView!
    @IBOutlet weak var verificationImage: UIImageView!
    @IBOutlet weak var verificationInfo: UILabel!
    @IBOutlet weak var warningLabel: UILabel!
    @IBOutlet weak var clearOTPButton: UIButton!
    
    @IBOutlet weak var imageTop: NSLayoutConstraint!
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var wrapperLeading: NSLayoutConstraint!
    @IBOutlet weak var wrapperTrailing: NSLayoutConstraint!
    @IBOutlet weak var wrapperTop: NSLayoutConstraint!
    
    fileprivate let otpButtonEnabled = Variable(false)
    fileprivate let isRunning = Variable(true)
    // MARK: To check whether we must render a phoneCall or sms screen
    fileprivate let isPhoneCall = Variable(false)
    private let resendCountdown = 90
    internal var tokoCashLoginSendOTPResponse: TokoCashLoginSendOTPResponse!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    // MARK : Setup view
    private func setupView() {
        self.setupVerificationMethod()
        self.setupOtpButton()
        self.setupTimer()
        self.navigationItem.title = "Verifikasi"
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.wrapperTop.constant = 40
            self.wrapperLeading.constant = 104
            self.wrapperTrailing.constant = 104
            self.imageTop.constant = 32
            self.wrapper.layer.borderWidth = 1
            self.wrapper.layer.borderColor = UIColor.fromHexString("#e0e0e0").cgColor
            self.wrapper.layer.cornerRadius = 10
            self.wrapper.clipsToBounds = true
        }
        
        self.otpTextField.delegate = self
        self.otpTextField.mask = "#  #  #  #  #  #"
        
        // MARK: Set TextView Attributes
        self.setupTextView(self.resendCountdown)
        
    }
    
    private func setupVerificationMethod() {
        self.isPhoneCall.asObservable()
            .subscribe(onNext:{ [unowned self] isPhoneCall in
                self.setupVerificationInfo(isPhoneCall: isPhoneCall)
            })
            .disposed(by: self.rx_disposeBag)
    }
    
    private func setupVerificationInfo(isPhoneCall: Bool) {
        let phoneNumberText = tokoCashLoginSendOTPResponse.phoneNumber
        let regularFont = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.tpSecondaryBlackText()]
        let phoneNumberFont = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.tpPrimaryBlackText()]
        
        var text = "Kode verifikasi telah dikirimkan melalui \nSMS ke \(phoneNumberText)."
        var verifyImage = UIImage(named: "greenSMS")
        if isPhoneCall {
            text = "Kode verifikasi telah dikirimkan melalui \npanggilan telepon ke \(phoneNumberText)."
             verifyImage = UIImage(named: "icon_telephone_green")
        }
        
        self.verificationImage.image = verifyImage
        let attributedString = NSMutableAttributedString(string: text, attributes: regularFont)
        attributedString.addAttributes(phoneNumberFont, range: NSRange(location: 49, length: phoneNumberText.count))
        self.verificationInfo.attributedText = attributedString
    }
    
    // MARK : Setup text view
    private func setupTextView(_ resendTimer: Int) {
        let combination = NSMutableAttributedString()
        let regularAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
        let boldAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
        let clickAbleAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpGreen()]
        
        var partOne = NSMutableAttributedString(string: "Mohon tunggu dalam ", attributes: regularAttributes)
        var partTwo = NSMutableAttributedString(string: "\(resendTimer) detik ", attributes: boldAttributes)
        var partThree = NSMutableAttributedString(string: "untuk kirim ulang", attributes: regularAttributes)
        
        if !self.isRunning.value {
            partOne = NSMutableAttributedString(string: "Tidak menerima kode?\n", attributes: regularAttributes)
            partTwo = NSMutableAttributedString(string: "Kirim ulang", attributes: clickAbleAttributes)
            partThree = NSMutableAttributedString(string: " atau ", attributes: regularAttributes)
            let partFour = NSMutableAttributedString(string: "gunakan metode verifikasi lain", attributes: clickAbleAttributes)
            
            // MARK : Set clickable
            partFour.addAttribute(NSLinkAttributeName, value: "otherverification://", range: (partFour.string as NSString).range(of: "gunakan metode verifikasi lain"))
            partTwo.addAttribute(NSLinkAttributeName, value: "resend://", range: (partTwo.string as NSString).range(of: "Kirim ulang"))
            
            combination.append(partOne)
            combination.append(partTwo)
            combination.append(partThree)
            combination.append(partFour)
        }
        else {
            combination.append(partOne)
            combination.append(partTwo)
            combination.append(partThree)
        }
        
        self.labelInformation.attributedText = combination
        self.labelInformation.textAlignment = NSTextAlignment.center
        self.labelInformation.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.tpGreen()]
        self.labelInformation.dataDetectorTypes = UIDataDetectorTypes.link
        self.labelInformation.isSelectable = true
        self.labelInformation.delegate = self
    }
    
    // MARK : Setup OTP Button
    private func setupOtpButton() {
        self.otpButtonEnabled.asObservable()
            .subscribe(onNext:{ [weak self] enabled in
                guard let `self` = self else {
                    return
                }
                
                self.otpButton.isEnabled = enabled
                
                if enabled {
                    self.otpButton.backgroundColor = .tpGreen()
                    self.otpButton.setTitleColor(.white, for: .normal)
                } else {
                    self.otpButton.backgroundColor = .tpBorder()
                    self.otpButton.setTitleColor(UIColor.black.withAlphaComponent(0.26), for: .normal)
                }
            })
            .disposed(by: rx_disposeBag)
    }
    
    // MARK : did tap Clear OTP Button
    @IBAction func didTapClearOTP(_ sender: UIButton) {
        self.validateOTPField(fieldStyle: .defaultStyle)
    }
    
    // MARK : Setup Timer
    private func setupTimer() {
        self.isRunning.asObservable()
            .subscribe(onNext:{ [weak self] isRunning in
                guard let `self` = self else {
                    return
                }
                if isRunning {
                    Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                        .takeWhile({ (n) -> Bool in
                            n < self.resendCountdown
                        })
                        .subscribe(onNext:{ timer in
                            let countdown = self.resendCountdown - (timer + 1)
                            self.setupTextView(countdown)
                        },onError: { error in
                            debugPrint("Error :", error.localizedDescription)
                        }, onCompleted: {
                            self.isRunning.value = false
                            self.setupTextView(0)
                        })
                        .addDisposableTo(self.rx_disposeBag)
                }
                
            })
            .addDisposableTo(self.rx_disposeBag)
    }
    
    @IBAction func didTapVerification(_ sender: UIButton) {
        let phoneNumberText = tokoCashLoginSendOTPResponse.phoneNumber
        let inputCode = self.otpTextField.text!
        let otpCode = (inputCode.replacingOccurrences(of: " ", with: ""))
        
        var analyticLabel = "sms"
        if self.isPhoneCall.value {
            analyticLabel = "phone"
        }
        AnalyticsManager.trackEventName("clickLogin", category: "phone verification", action: "click on verifikasi", label: analyticLabel)
        
        WalletService.verifyOTPLoginTokoCash(phoneNumber: phoneNumberText, otpCode: otpCode)
            .subscribe(onNext:{ result in
                if result.code == "200000" && result.verified {
                    guard result.userDetails.count > 0 else { self.setToNoConnectedAccount(); return }
                    self.validateOTPField(fieldStyle: .successStyle)
                    self.setToListOfAccounts(result)
                }
                else if result.code == "400131" {
                    self.validateOTPField(fieldStyle: .failedStyle)
                } else {
                    let message : String = "Terjadi kesalahan pada server, silakan coba kembali"
                    UIViewController.showNotificationWithMessage(message, type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
                }
        })
        .addDisposableTo(self.rx_disposeBag)
        self.otpTextField.resignFirstResponder()
    }
    
    fileprivate func validateOTPField(fieldStyle: otpFieldStyle) {
        if fieldStyle == .successStyle {
            self.otpHorizontalLine.backgroundColor = .tpGreen()
            self.warningLabel.isHidden = true
            self.clearOTPButton.isHidden = true
        } else if fieldStyle == .failedStyle {
            self.otpHorizontalLine.backgroundColor = .tpRed()
            self.warningLabel.isHidden = false
            self.clearOTPButton.isHidden = false
        } else {
            self.otpTextField.text = ""
            self.otpHorizontalLine.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.2)
            self.warningLabel.isHidden = true
            self.clearOTPButton.isHidden = true
        }
    }
    
    // MARK : Push to not connected account
    private func setToNoConnectedAccount() {
        let controller = NoAccountViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setToListOfAccounts(_ data: TokoCashLoginVerifyOTPResponse){
        let controller = ListAccountViewController(nibName: nil, bundle: nil)
        controller.tokocashLoginVerifyResponse = data
        controller.phoneNumber = self.tokoCashLoginSendOTPResponse.phoneNumber
        controller.onTapExit = { [weak controller] in
            controller?.dismiss(animated: true, completion: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            })
        }
        let navController = UINavigationController(rootViewController: controller)
        self.present(navController, animated: true, completion: nil)
    }
}

extension LoginPhoneNumberOTPViewController: UITextFieldDelegate {
    // MARK: Text Fied Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.otpTextField {
            if self.warningLabel.isHidden {
                self.otpHorizontalLine.backgroundColor = .tpGreen()
                self.otpTextField.tintColor = .tpGreen()
            } else {
                self.otpHorizontalLine.backgroundColor = .tpRed()
                self.otpTextField.tintColor = .tpRed()
            }
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == self.otpTextField {
            if self.warningLabel.isHidden {
                self.otpHorizontalLine.backgroundColor = .tpBorder()
            } else {
                self.otpHorizontalLine.backgroundColor = .tpRed()
            }
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var inputCode = textField.text else { return false }
        inputCode = inputCode + string
        if inputCode.characters.count > 13 && !string.isEmpty {
            self.otpButtonEnabled.value = true
        } else {
            self.otpButtonEnabled.value = false
        }
        return self.otpTextField.shouldChangeCharacters(in: range, replacementString: string)
    }
}

extension LoginPhoneNumberOTPViewController: UITextViewDelegate {
    // MARK: Did tap Resend OTP
    private func resendOTP(accept: OTPAcceptType) {
        WalletService.requestOTPLoginTokoCash(phoneNumber: self.tokoCashLoginSendOTPResponse.phoneNumber, accept: accept).subscribe(onNext:{ [weak self] result in
            guard let `self` = self else { return }
            if result.code == "200000" {
                self.isRunning.value = true
            }else if result.code == "412556" {
                let message : String = "Anda sudah 3 kali melakukan pengiriman OTP, silakan coba lagi dalam 60 menit"
                UIViewController.showNotificationWithMessage(message, type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
                
                let clickAbleAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpGreen()]
                let text = NSMutableAttributedString(string: "Gunakan metode verifikasi lain", attributes: clickAbleAttributes)
                text.addAttribute(NSLinkAttributeName, value: "otherverification://", range: (text.string as NSString).range(of: "Gunakan metode verifikasi lain"))
                self.labelInformation.attributedText = text
                self.labelInformation.textAlignment = NSTextAlignment.center
            }
        })
    }
    
    // MARK: Did tap Other Verification
    private func setToOtherVerification() {
        let controller = OtherVerificationViewController(nibName: nil, bundle: nil)
        controller.phoneNumber = self.tokoCashLoginSendOTPResponse.phoneNumber
        controller.onTapResend = { [weak self, weak controller] isPhoneCall in
            self?.isPhoneCall.value = isPhoneCall
            if isPhoneCall {
                self?.resendOTP(accept: .call)
            } else {
                self?.resendOTP(accept: .sms)
            }
            controller?.navigationController?.popViewController(animated: true)
        }
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Text View Delegate
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "otherverification" {
            self.setToOtherVerification()
            return false
        } else if URL.scheme == "resend" {
            // MARK: Set to default
            self.validateOTPField(fieldStyle: .defaultStyle)
            
            var analyticLabel: String
            
            if self.isPhoneCall.value {
                self.resendOTP(accept: .call)
                analyticLabel = "sms"
            }else {
                self.resendOTP(accept: .sms)
                analyticLabel = "phone"
            }
            
            AnalyticsManager.trackEventName("clickLogin", category: "phone verification", action: "click on kirim ulang", label: analyticLabel)
            
            return false
        }
        else {
            return true
        }
    }
}
