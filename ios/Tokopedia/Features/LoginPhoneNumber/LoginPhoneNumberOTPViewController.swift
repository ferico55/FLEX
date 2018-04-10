//
//  LoginPhoneNumberOTPViewController.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 28/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxSwift
import UIKit
import VMaskTextField

private enum OtpFieldStyle {
    case successStyle
    case failedStyle
    case defaultStyle
}

public class LoginPhoneNumberOTPViewController: UIViewController {
    
    @IBOutlet weak fileprivate var otpStackView: OTPInputView!
    @IBOutlet weak fileprivate var otpButton: UIButton!
    @IBOutlet weak fileprivate var labelInformation: UITextView! {
        didSet {
            labelInformation.isHidden = true
        }
    }
    @IBOutlet weak fileprivate var verificationImage: UIImageView!
    @IBOutlet weak fileprivate var verificationInfo: UILabel!
    @IBOutlet weak fileprivate var warningLabel: UILabel!
    @IBOutlet weak fileprivate var clearOTPButton: UIButton!
    
    @IBOutlet weak fileprivate var imageTop: NSLayoutConstraint!
    @IBOutlet weak fileprivate var wrapper: UIView!
    @IBOutlet weak fileprivate var wrapperLeading: NSLayoutConstraint!
    @IBOutlet weak fileprivate var wrapperTrailing: NSLayoutConstraint!
    @IBOutlet weak fileprivate var wrapperTop: NSLayoutConstraint!
    
    fileprivate let otpButtonEnabled = Variable(false)
    fileprivate let triggerCountdown = PublishSubject<Void>()
    // MARK: To check whether we must render a phoneCall or sms screen
    fileprivate let isPhoneCall = Variable(false)
    fileprivate var otpEnteredText: String = ""
    private let resendCountdown = 90
    
    private let regularAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
    private let boldAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
    
    internal var tokoCashLoginSendOTPResponse: TokoCashLoginSendOTPResponse!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        otpStackView.otpFieldsCount = 6
        otpStackView.delegate = self
        otpStackView.initalizeUI()
        
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
            self.wrapper.layer.borderColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1).cgColor
            self.wrapper.layer.cornerRadius = 10
            self.wrapper.clipsToBounds = true
        }
        
    }
    
    private func setupVerificationMethod() {
        self.isPhoneCall.asObservable()
            .subscribe(onNext: { [unowned self] isPhoneCall in
                self.setupVerificationInfo(isPhoneCall: isPhoneCall)
            })
            .disposed(by: self.rx_disposeBag)
    }
    
    private func setupVerificationInfo(isPhoneCall: Bool) {
        let phoneNumberText = tokoCashLoginSendOTPResponse.phoneNumber
        let regularFont = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.tpSecondaryBlackText()]
        let phoneNumberFont = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.tpPrimaryBlackText()]
        
        var text = "Kode verifikasi telah dikirimkan melalui \nSMS ke \(phoneNumberText)."
        var verifyImage = #imageLiteral(resourceName: "greenSMS")
        if isPhoneCall {
            text = "Kode verifikasi telah dikirimkan melalui \npanggilan telepon ke \(phoneNumberText)."
            verifyImage = #imageLiteral(resourceName: "icon_telephone_green")
        }
        
        self.verificationImage.image = verifyImage
        let attributedString = NSMutableAttributedString(string: text, attributes: regularFont)
        attributedString.addAttributes(phoneNumberFont, range: NSRange(location: 49, length: phoneNumberText.count))
        self.verificationInfo.attributedText = attributedString
    }
    
    // MARK : Setup Timer
    private func setupTimer() {
        self.triggerCountdown.asObservable().flatMap({ _ -> Observable<Int> in
            return Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                .takeWhile({ (num) -> Bool in
                    return (num+1) <= self.resendCountdown
                })
                .do(onNext:{ [unowned self] timer in
                    self.labelInformation.isHidden = false
                    let countdown = self.resendCountdown - (timer + 1)
                    self.showCountdownText(resendTimer: countdown + 1)
                    },onError: { error in
                        debugPrint("Error :", error.localizedDescription)
                },onCompleted: {
                    self.showCompleteText()
                })
        })
            .subscribe()
            .addDisposableTo(self.rx_disposeBag)
        
        self.triggerCountdown.onNext()
    }
    
    // MARK : Setup TextView
    private func showCountdownText(resendTimer: Int) {
        let combination = NSMutableAttributedString()
        let partOne = NSMutableAttributedString(string: "Mohon tunggu dalam ", attributes: regularAttributes)
        let partTwo = NSMutableAttributedString(string: "\(resendTimer) detik ", attributes: boldAttributes)
        let partThree = NSMutableAttributedString(string: "untuk kirim ulang", attributes: regularAttributes)
        
        combination.append(partOne)
        combination.append(partTwo)
        combination.append(partThree)
        
        labelInformation.attributedText = combination
        labelInformation.textAlignment = NSTextAlignment.center
        labelInformation.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.tpGreen()]
    }
    
    private func showCompleteText() {
        let combination = NSMutableAttributedString()
        let clickAbleAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpGreen()]
        let partOne = NSMutableAttributedString(string: "Tidak menerima kode?\n", attributes: regularAttributes)
        let partTwo = NSMutableAttributedString(string: "Kirim ulang", attributes: clickAbleAttributes)
        let partThree = NSMutableAttributedString(string: " atau ", attributes: regularAttributes)
        let partFour = NSMutableAttributedString(string: "gunakan metode verifikasi lain", attributes: clickAbleAttributes)
        
        // MARK : Set clickable
        partFour.addAttribute(NSLinkAttributeName, value: "otherverification://", range: (partFour.string as NSString).range(of: "gunakan metode verifikasi lain"))
        partTwo.addAttribute(NSLinkAttributeName, value: "resend://", range: (partTwo.string as NSString).range(of: "Kirim ulang"))
        
        combination.append(partOne)
        combination.append(partTwo)
        combination.append(partThree)
        combination.append(partFour)
        
        labelInformation.attributedText = combination
        labelInformation.textAlignment = NSTextAlignment.center
        labelInformation.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.tpGreen()]
        labelInformation.dataDetectorTypes = UIDataDetectorTypes.link
        labelInformation.isSelectable = true
        labelInformation.delegate = self
    }
    
    // MARK : Setup Text view
    //    private func setupTextView(_ resendTimer: Int) {
    //        let combination = NSMutableAttributedString()
    //        let regularAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
    //        let boldAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
    //        let clickAbleAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpGreen()]
    //
    //        var partOne = NSMutableAttributedString(string: "Mohon tunggu dalam ", attributes: regularAttributes)
    //        var partTwo = NSMutableAttributedString(string: "\(resendTimer) detik ", attributes: boldAttributes)
    //        var partThree = NSMutableAttributedString(string: "untuk kirim ulang", attributes: regularAttributes)
    //
    //        if !self.isRunning.value {
    //            partOne = NSMutableAttributedString(string: "Tidak menerima kode?\n", attributes: regularAttributes)
    //            partTwo = NSMutableAttributedString(string: "Kirim ulang", attributes: clickAbleAttributes)
    //            partThree = NSMutableAttributedString(string: " atau ", attributes: regularAttributes)
    //            let partFour = NSMutableAttributedString(string: "gunakan metode verifikasi lain", attributes: clickAbleAttributes)
    //
    //            // MARK : Set clickable
    //            partFour.addAttribute(NSLinkAttributeName, value: "otherverification://", range: (partFour.string as NSString).range(of: "gunakan metode verifikasi lain"))
    //            partTwo.addAttribute(NSLinkAttributeName, value: "resend://", range: (partTwo.string as NSString).range(of: "Kirim ulang"))
    //
    //            combination.append(partOne)
    //            combination.append(partTwo)
    //            combination.append(partThree)
    //            combination.append(partFour)
    //        } else {
    //            combination.append(partOne)
    //            combination.append(partTwo)
    //            combination.append(partThree)
    //        }
    //
    //        self.labelInformation.attributedText = combination
    //        self.labelInformation.textAlignment = NSTextAlignment.center
    //        self.labelInformation.linkTextAttributes = [NSForegroundColorAttributeName: UIColor.tpGreen()]
    //        self.labelInformation.dataDetectorTypes = UIDataDetectorTypes.link
    //        self.labelInformation.isSelectable = true
    //        self.labelInformation.delegate = self
    //    }
    
    // MARK : Setup OTP Button
    private func setupOtpButton() {
        self.otpButtonEnabled.asObservable()
            .subscribe(onNext: { [weak self] enabled in
                guard let `self` = self else {
                    return
                }
                
                self.otpButton.isEnabled = enabled
                
                if enabled {
                    self.otpButton.backgroundColor = .tpGreen()
                    self.otpButton.setTitleColor(.white, for: .normal)
                    if self.warningLabel.isHidden {
                        self.otpStackView.showSuccessBorder()
                    }
                } else {
                    self.otpButton.backgroundColor = .tpBorder()
                    self.otpButton.setTitleColor(UIColor.black.withAlphaComponent(0.26), for: .normal)
                    self.warningLabel.isHidden = true
                    self.clearOTPButton.isHidden = true
                    
                }
            })
            .disposed(by: rx_disposeBag)
    }
    
    // MARK : did tap Clear OTP Button
    @IBAction private func didTapClearOTP(_ sender: UIButton) {
        self.otpButtonEnabled.value = false
        self.otpStackView.clearField()
    }
    
    @IBAction private func didTapVerification(_ sender: UIButton) {
        let phoneNumberText = tokoCashLoginSendOTPResponse.phoneNumber
        var analyticLabel = "sms"
        if self.isPhoneCall.value {
            analyticLabel = "phone"
        }
        AnalyticsManager.trackEventName("clickLogin", category: "phone verification", action: "click on verifikasi", label: analyticLabel)
        
        WalletService.verifyOTPLoginTokoCash(phoneNumber: phoneNumberText, otpCode: otpEnteredText)
            .subscribe(onNext: { result in
                if result.code == "200000" && result.verified {
                    guard !result.userDetails.isEmpty else {
                        self.setToNoConnectedAccount()
                        return
                    }
                    self.validateOTPField(fieldStyle: .successStyle)
                    self.setToListOfAccounts(result)
                } else if result.code == "400131" {
                    self.validateOTPField(fieldStyle: .failedStyle)
                } else {
                    let message: String = "Terjadi kesalahan pada server, silakan coba kembali"
                    UIViewController.showNotificationWithMessage(message, type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
                }
            })
            .addDisposableTo(self.rx_disposeBag)
    }
    
    fileprivate func validateOTPField(fieldStyle: OtpFieldStyle) {
        if fieldStyle == .successStyle {
            self.warningLabel.isHidden = true
            self.otpStackView.showSuccessBorder()
            self.clearOTPButton.isHidden = true
        } else if fieldStyle == .failedStyle {
            self.warningLabel.isHidden = false
            self.otpStackView.showErrorBorder()
            self.clearOTPButton.isHidden = false
        } else {
            self.otpStackView.clearField()
            self.warningLabel.isHidden = true
            self.clearOTPButton.isHidden = true
        }
    }
    
    // MARK : Push to not connected account
    private func setToNoConnectedAccount() {
        let controller = NoAccountViewController(nibName: nil, bundle: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setToListOfAccounts(_ data: TokoCashLoginVerifyOTPResponse) {
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

// MARK: OTP View Delegate
extension LoginPhoneNumberOTPViewController: OTPInputViewDelegate {
    public func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    public func hasEnteredAllOTP(hasEntered: Bool, otpEntered: String) {
        self.otpButtonEnabled.value = hasEntered
        if hasEntered {
            self.otpEnteredText = otpEntered
        }
    }
}

extension LoginPhoneNumberOTPViewController: UITextViewDelegate {
    // MARK: Did tap Resend OTP
    private func resendOTP(accept: OTPAcceptType) {
        self.triggerCountdown.onNext()
        WalletService.requestOTPLoginTokoCash(phoneNumber: self.tokoCashLoginSendOTPResponse.phoneNumber, accept: accept).subscribe(onNext: { [weak self] result in
            guard let `self` = self else {
                return
            }
            if result.code == "200000" {
                self.otpStackView.clearField()
                self.otpButtonEnabled.value = false
            } else if result.code == "412556" {
                let message: String = "Anda sudah 3 kali melakukan pengiriman OTP, silakan coba lagi dalam 60 menit"
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
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
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
            } else {
                self.resendOTP(accept: .sms)
                analyticLabel = "phone"
            }
            
            AnalyticsManager.trackEventName("clickLogin", category: "phone verification", action: "click on kirim ulang", label: analyticLabel)
            
            return false
        } else {
            return true
        }
    }
}
