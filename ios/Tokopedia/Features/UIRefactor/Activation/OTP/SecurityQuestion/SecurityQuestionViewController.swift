//
//  SecurityQuestionViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 4/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import RestKit
import TPKeyboardAvoiding
import TTTAttributedLabel
import UIKit
import VMaskTextField

internal class SecurityQuestionObjects: NSObject {
    var userID: String = ""
    var deviceID: String = ""
    var phoneNumber: String = ""
    var maskedPhoneNumber: String = ""
    var name: String = ""
    var token: OAuthToken = OAuthToken()
    
}

@objc(SecurityQuestionViewController)
internal class SecurityQuestionViewController: UIViewController, UITextFieldDelegate {
    /*
     questionType1 = "1" => Phone Number Question
     questionType1 = "2" => Account Number Question
     
     questionType2 = "1" => OTP to email
     questionType2 = "2" => OTP to phone
     */
    internal var questionType1: String!
    internal var questionType2: String!
    
    fileprivate let securityQuestionObject: SecurityQuestionObjects!
    
    public var successAnswerCallback: ((SecurityAnswer) -> Void)!
    
    @IBOutlet fileprivate var questionViewType1: UIView!
    @IBOutlet fileprivate var questionTitle: UILabel!
    @IBOutlet fileprivate var answerField: UITextField!
    @IBOutlet fileprivate var infoLabel: UILabel!
    
    @IBOutlet fileprivate var questionViewType2: UIView!
    @IBOutlet fileprivate var requestOTPButton: UIButton!
    @IBOutlet fileprivate var otpInfoLabel: UILabel!
    
    @IBOutlet var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet fileprivate var userNameLabel: UILabel!
    @IBOutlet fileprivate var verificationNumberLengthLabel: UILabel!
    
    @IBOutlet fileprivate var phoneNumberLabel: TTTAttributedLabel!
    
    @IBOutlet fileprivate var otpOnCallView: UIView!
    @IBOutlet fileprivate var changeNumberButton: UIButton!
    
    @IBOutlet fileprivate var otpInputField: VMaskTextField!
    
    lazy private var networkManager: TokopediaNetworkManager = {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        return networkManager
    }()
    
    fileprivate var _securityQuestion: SecurityQuestion!
    
    @IBOutlet fileprivate var resendOTPLabel: UILabel!
    
    @IBOutlet fileprivate var otpOnCallButton: UIButton!
    fileprivate var otpOnCallTimer: Timer!
    
    @IBOutlet fileprivate var resendOTPButton: UIButton!
    fileprivate var resendOTPTimer: Timer!
    
    @IBOutlet fileprivate var verifyButton: UIButton!
    
    fileprivate var resendOTPSecondsLeftDefault: Int = 90
    fileprivate var resendOTPSecondsLeftIfFailed: Int = 5
    
    fileprivate var isOTPOnCallEnabled = false
    
    fileprivate var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        return activityIndicator
    }()
    
    fileprivate var changePhoneNumberStatus: Bool = false
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Pertanyaan Keamanan"
        
        self.requestQuestionForm()
        
        self.setupView()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Kembali", style: .plain, target: self, action: #selector(self.didTapCancelButton))
    }
    
    public init(securityQuestionObject: SecurityQuestionObjects) {
        self.securityQuestionObject = securityQuestionObject
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        AnalyticsManager.trackScreenName("Security Question Page")
        OTPRequest
            .checkChangePhoneNumberStatus(
                withToken: self.securityQuestionObject.token,
                onSuccess: { status in
                    self.changePhoneNumberStatus = status
                },
                onFailure: {
                    
                }
            )
    }
    
    deinit {
        stopTimer()
    }
    
    // MARK: Dismiss View Controller
    @objc fileprivate func didTapCancelButton() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Initial View
    fileprivate func setupView() {
        self.setupInfoLabel()
        
        self.userNameLabel.text = self.securityQuestionObject.name
        
        self.otpOnCallView.isHidden = true
        
        self.otpInputField.delegate = self
        self.otpInputField.mask = "# # # # # #"
        
        let halfButtonHeight = verifyButton.bounds.size.height / 2
        let buttonWidth = verifyButton.bounds.size.width
        
        activityIndicator.center = CGPoint(x: buttonWidth - halfButtonHeight, y: halfButtonHeight)
        
        verifyButton.addSubview(activityIndicator)
        activityIndicator.mas_makeConstraints({ make in
            _ = make?.centerX.equalTo()(self.verifyButton.mas_centerX)
            _ = make?.centerY.equalTo()(self.verifyButton.mas_centerY)
        })
    }
    
    fileprivate func setupInfoLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        
        let infoAttributedString = NSMutableAttributedString(string: "Kami akan mengirimkan kode verifikasi ke nomor ponsel ")
        
        let numberAttributedString = NSMutableAttributedString(string: self.securityQuestionObject.maskedPhoneNumber)
        numberAttributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 14), range: NSMakeRange(0, self.securityQuestionObject.maskedPhoneNumber.characters.count))
        
        infoAttributedString.append(numberAttributedString)
        
        infoAttributedString.addAttributes([NSParagraphStyleAttributeName: paragraphStyle, NSForegroundColorAttributeName: UIColor.black.withAlphaComponent(0.54)], range: NSMakeRange(0, infoAttributedString.length))
        
        self.phoneNumberLabel.attributedText = infoAttributedString
    }
    
    // MARK: Request Security Question Form
    fileprivate func requestQuestionForm() {
        OTPRequest.requestQuestionForm(
            withUserCheckSecurityOne: self.questionType1,
            userCheckSecurityTwo: self.questionType2,
            userID: self.securityQuestionObject.userID,
            deviceID: self.securityQuestionObject.deviceID,
            onSuccess: { result in
                self.didReceiveSecurityForm(result)
            },
            onFailure: {
                
            }
        )
    }
    
    fileprivate func didReceiveSecurityForm(_ securityQuestion: SecurityQuestion) {
        self._securityQuestion = securityQuestion
        
        if (self._securityQuestion.message_error) != nil {
            StickyAlertView.showErrorMessage(self._securityQuestion.message_error)
        } else {
            if self.questionType1 == "0" {
                self.view.addSubview(self.questionViewType2)
                
                self.questionViewType2.mas_makeConstraints({ make in
                    _ = make?.edges.mas_equalTo()(self.view)
                })
                
                self.setupOTPBySMS()
            }
        }
    }
    
    fileprivate func setupOTPBySMS() {
        if self.shouldAutoSendOTPBySMS() {
            self.requestOTPOnSMS()
        } else {
            self.resendOTPLabel.isHidden = true
            self.disableOTPCallButton()
        }
    }
    
    fileprivate func shouldAutoSendOTPBySMS() -> Bool {
        return SecurityQuestionTweaks.autoSendOTPBySMS()
    }
    
    // MARK: Change Number Method
    @IBAction func didTapToChangePhoneNumber(_ sender: AnyObject) {
        AnalyticsManager.trackEventName("clickChangePhoneNumber", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_CLICK, label: "Change Phone Number")
        
        let controller = ChangePhoneNumberSQViewController(userID: self.securityQuestionObject.userID, token: self.securityQuestionObject.token, status: self.changePhoneNumberStatus)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: Timer Methods
    fileprivate func startTimerCountdown(_ secondsLeft: Int, onTick: ((Int) -> Void)?, onTimeout: @escaping () -> Void) -> Timer {
        var timeLeft = secondsLeft
        let buttonTimer = Timer.bk_scheduledTimer(
            withTimeInterval: 1,
            block: { _ in
                onTick?(timeLeft)
                timeLeft = timeLeft - 1
                if timeLeft < 0 {
                    onTimeout()
                }
            },
            repeats: true
        )
        
        return buttonTimer!
    }
    
    fileprivate func enableOTPOnSMSInSeconds(_ seconds: Int) {
        self.disableResendOTPButton()
        self.resendOTPTimer = self.startTimerCountdown(
            seconds,
            onTick: { [weak self] timeLeft in
                guard let `self` = self else { return }
                self.resendOTPButton.setTitle("\(timeLeft) Detik", for: UIControlState())
            },
            onTimeout: { [weak self] in
                guard let `self` = self else { return }
                self.resendOTPLabel.isHidden = true
                self.resendOTPButton.setTitle("Kirim SMS Verifikasi", for: UIControlState())
                self.enableResendOTPButton()
                self.resendOTPTimer.invalidate()
            }
        )
    }
    
    fileprivate func enableOTPOnCallInSeconds(_ seconds: Int) {
        self.disableOTPCallButton()
        self.otpOnCallTimer = self.startTimerCountdown(
            seconds,
            onTick: nil,
            onTimeout: { [weak self] in
                guard let `self` = self else { return }
                self.enableOTPCallButton()
                self.otpOnCallView.isHidden = false
                self.otpOnCallTimer.invalidate()
            }
        )
    }
    
    fileprivate func stopTimer() {
        self.otpOnCallTimer?.invalidate()
        self.resendOTPTimer?.invalidate()
    }
    
    // MARK: Verify OTP Button Methods
    fileprivate func showVerificationButtonIsLoading(_ isLoading: Bool) {
        isLoading ? self.activityIndicator.startAnimating() : self.activityIndicator.stopAnimating()
        self.verifyButton.isEnabled = !isLoading
        self.verifyButton.setTitle(isLoading ? "" : "Verifikasi", for: UIControlState())
    }
    
    @IBAction fileprivate func didSubmitOTP(_ sender: AnyObject?) {
        AnalyticsManager.trackEventName("clickOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_CLICK, label: "Verify")
        self.showVerificationButtonIsLoading(true)
        
        guard let text = otpInputField.text, !text.isEmpty else {
            StickyAlertView.showErrorMessage(["Kode Verifikasi Tidak Boleh Kosong."])
            self.showVerificationButtonIsLoading(false)
            return
        }
        
        let answer = otpInputField.text?.replacingOccurrences(of: " ", with: "")
        
        if (answer?.characters.count)! < 6 {
            AnalyticsManager.trackEventName(
                "verifyFailed",
                category: GA_EVENT_CATEGORY_SECURITY_QUESTION,
                action: GA_EVENT_ACTION_VERIFY_FAILED,
                label: "Uncomplete OTP"
            )
            self.showVerificationButtonIsLoading(false)
            StickyAlertView.showErrorMessage(["Kode OTP harus terdiri dari 6 angka"])
            return
        }
        
        self.submitSecurityAnswer(answer!)
    }
    
    fileprivate func submitSecurityAnswer(_ answer: String) {
        OTPRequest.requestVerifySecurityQuestion(
            withQuestion: self._securityQuestion.data.question,
            inputAnswer: answer,
            userCheckSecurityOne: self.questionType1,
            userCheckSecurityTwo: self.questionType2,
            userID: self.securityQuestionObject.userID,
            onSuccess: { result in
                self.didReceiveAnswerRespond(result)
            },
            onFailure: {
                self.showVerificationButtonIsLoading(false)
            }
        )
    }
    
    fileprivate func didReceiveAnswerRespond(_ answer: SecurityAnswer) {
        if answer.message_error.count > 0 {
            AnalyticsManager.trackEventName("verifyOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_VERIFY, label: "OTP Verify Failed")
            StickyAlertView.showErrorMessage(answer.message_error)
            self.showVerificationButtonIsLoading(false)
        } else if answer.data.error == "1" {
            AnalyticsManager.trackEventName("verifyOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_VERIFY, label: "OTP Verify Failed")
            StickyAlertView.showErrorMessage(["Kode Verifikasi Tidak Sesuai."])
            self.showVerificationButtonIsLoading(false)
        }
        
        if answer.data.allow_login == "1" {
            AnalyticsManager.trackEventName("verifyOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_VERIFY, label: "OTP Verify Success")
            self.stopTimer()
            self.successAnswerCallback(answer)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Resend OTP Button Methods
    fileprivate func disableResendOTPButton() {
        self.resendOTPButton.isUserInteractionEnabled = false
        self.resendOTPButton.setTitleColor(UIColor.black.withAlphaComponent(0.38), for: UIControlState())
        self.resendOTPButton.borderColor = UIColor.black.withAlphaComponent(0.38)
    }
    
    fileprivate func enableResendOTPButton() {
        self.resendOTPButton.isUserInteractionEnabled = true
        self.resendOTPButton.setTitleColor(UIColor.black.withAlphaComponent(0.54), for: UIControlState())
        self.resendOTPButton.borderColor = UIColor.black.withAlphaComponent(0.54)
    }
    
    @IBAction fileprivate func didTapRequestOTP(_ sender: AnyObject) {
        AnalyticsManager.trackEventName("clickOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_CLICK, label: "OTP SMS")
        self.disableResendOTPButton()
        self.disableOTPCallButton()
        self.requestOTPOnSMS()
    }
    
    fileprivate func requestOTPOnSMS() {
        OTPRequest.requestOTP(
            withMode: "sms",
            type: .securityQuestion,
            userID: self.securityQuestionObject.userID,
            number: self.securityQuestionObject.phoneNumber,
            token: self.securityQuestionObject.token,
            onSuccess: { otp in
                self.resendOTPLabel.isHidden = false
                
                if otp.message_error.count > 0 {
                    AnalyticsManager.trackEventName("requestOTPOnSMS", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_SMS, label: "SMS Failed")
                    
                    self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftIfFailed)
                    if self.isOTPOnCallEnabled {
                        self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftIfFailed)
                    }
                }
                
                if otp.data.is_success == "1" {
                    AnalyticsManager.trackEventName("requestOTPOnSMS", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_SMS, label: "SMS Success")
                    
                    self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftDefault)
                    self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftDefault)
                }
            },
            onFailure: {
                AnalyticsManager.trackEventName("requestOTPOnSMS", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_SMS, label: "SMS Failed")
                self.resendOTPLabel.isHidden = false
                self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftIfFailed)
                
                if self.isOTPOnCallEnabled {
                    self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftIfFailed)
                }
            }
        )
    }
    
    // MARK: OTP Call Button Methods
    fileprivate func disableOTPCallButton() {
        self.otpOnCallButton.isUserInteractionEnabled = false
        self.otpOnCallButton.setTitleColor(UIColor.gray, for: UIControlState())
    }
    
    fileprivate func enableOTPCallButton() {
        self.isOTPOnCallEnabled = true
        self.otpOnCallButton.isUserInteractionEnabled = true
        self.otpOnCallButton.setTitleColor(UIColor.fromHexString("#42B549"), for: .normal)
    }
    
    @IBAction fileprivate func didTapOTPOnCall(_ sender: AnyObject) {
        AnalyticsManager.trackEventName("clickOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_CLICK, label: "OTP on Call")
        self.disableOTPCallButton()
        self.disableResendOTPButton()
        self.requestOTPOnCall()
    }
    
    fileprivate func requestOTPOnCall() {
        OTPRequest.requestOTP(
            withMode: "call",
            type: .securityQuestion,
            userID: self.securityQuestionObject.userID,
            number: self.securityQuestionObject.phoneNumber,
            token: self.securityQuestionObject.token,
            onSuccess: { otp in
                if otp.message_error.count > 0 {
                    AnalyticsManager.trackEventName("requestOTPOnCall", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_ON_CALL, label: "On Call Failed")
                    
                    self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftIfFailed)
                    self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftIfFailed)
                }
                
                if otp.message_status.count > 0 {
                    AnalyticsManager.trackEventName("requestOTPOnCall", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_ON_CALL, label: "On Call Success")
                    
                    self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftDefault)
                    self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftDefault)
                }
            },
            onFailure: {
                AnalyticsManager.trackEventName("requestOTPOnCall", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_ON_CALL, label: "On Call Failed")
                self.resendOTPLabel.isHidden = false
                self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftIfFailed)
                self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftIfFailed)
            }
        )
    }
    
    // MARK: UITextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == "" {
            AnalyticsManager.trackEventName(
                "clickOTP",
                category: GA_EVENT_CATEGORY_SECURITY_QUESTION,
                action: GA_EVENT_ACTION_CLICK,
                label: "Fill Verification Code"
            )
        }
        return self.otpInputField.shouldChangeCharacters(in: range, replacementString: string)
    }
}
