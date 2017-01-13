//
//  SecurityQuestionViewController.swift
//  Tokopedia
//
//  Created by Tonito Acen on 4/20/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import UIKit
import TPKeyboardAvoiding
import VMaskTextField

@objc(SecurityQuestionViewController)
class SecurityQuestionViewController : UIViewController, UITextFieldDelegate {
    /*
     questionType1 = "1" => Phone Number Question
     questionType1 = "2" => Account Number Question
     
     questionType2 = "1" => OTP to email
     questionType2 = "2" => OTP to phone
     */
    var questionType1 : String!
    var questionType2 : String!
    
    private let userID : String
    private let deviceID : String
    private let phoneNumber: String
    private let name: String
    private let token : OAuthToken
    
    var successAnswerCallback: ((SecurityAnswer) -> Void)!
    
    @IBOutlet private var questionViewType1: UIView!
    @IBOutlet private var questionTitle: UILabel!
    @IBOutlet private var answerField: UITextField!
    @IBOutlet private var infoLabel: UILabel!
    
    @IBOutlet private var questionViewType2: UIView!
    @IBOutlet private var requestOTPButton: UIButton!
    @IBOutlet private var otpInfoLabel: UILabel!
    
    @IBOutlet var scrollView: TPKeyboardAvoidingScrollView!
    @IBOutlet private var userNameLabel: UILabel!
    @IBOutlet private var verificationNumberLengthLabel: UILabel!
    
    @IBOutlet private var phoneNumberLabel: TTTAttributedLabel!
    
    @IBOutlet private var otpOnCallView: UIView!
    @IBOutlet private var changeNumberButton: UIButton!
    
    @IBOutlet private var otpInputField: VMaskTextField!
    
    lazy var networkManager : TokopediaNetworkManager = {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        return networkManager
    }()
    
    private var _securityQuestion : SecurityQuestion!
    
    @IBOutlet private var resendOTPLabel: UILabel!
    
    @IBOutlet private var otpOnCallButton: UIButton!
    private var otpOnCallTimer: NSTimer!
    
    @IBOutlet private var resendOTPButton: UIButton!
    private var resendOTPTimer: NSTimer!
    
    private var resendOTPSecondsLeftDefault: Int = 90
    private var resendOTPSecondsLeftIfFailed: Int = 5
    
    private var isOTPOnCallEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Verifikasi Nomor HP"
        
        self.requestQuestionForm()
        
        self.setupView()
    }
    
    init(name: String, phoneNumber: String, userID: String, deviceID: String, token: OAuthToken) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.userID = userID
        self.deviceID = deviceID
        self.token = token
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        AnalyticsManager.trackScreenName("Security Question Page")
        
    }
    
    deinit {
        stopTimer()
    }
    
    //MARK: Initial View
    private func setupView() {
        self.setupInfoLabel()
        
        self.userNameLabel.text = name
        
        self.otpOnCallView.hidden = true
        
        self.otpInputField.delegate = self
        self.otpInputField.mask = "# # # # # #"
    }
    
    private func setupInfoLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        
        let infoAttributedString = NSMutableAttributedString(string: "Kami akan mengirimkan kode verifikasi ke nomor ponsel ")
        
        let numberAttributedString = NSMutableAttributedString(string: phoneNumber)
        numberAttributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFontOfSize(14), range: NSMakeRange(0, phoneNumber.characters.count))
        
        infoAttributedString.appendAttributedString(numberAttributedString)
        
        infoAttributedString.addAttributes([NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : UIColor.blackColor().colorWithAlphaComponent(0.54)], range: NSMakeRange(0, infoAttributedString.length))
        
        self.phoneNumberLabel.attributedText = infoAttributedString
    }
    
    private func setLabelSpacing (label : UILabel) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let attrString = NSMutableAttributedString(string: label.text!)
        attrString.addAttribute(NSParagraphStyleAttributeName, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        label.attributedText = attrString
    }
    
    //MARK: Request Security Question Form
    private func requestQuestionForm() {
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                               path: "/v4/interrupt/get_question_form.pl",
                               method: .GET,
                               parameter: ["user_check_security_1" : questionType1, "user_check_security_2" : questionType2, "user_id" : userID, "device_id" : deviceID],
                               mapping: SecurityQuestion.mapping(),
                               onSuccess: { (mappingResult, operation) -> Void in
                                let result = mappingResult.dictionary()[""] as! SecurityQuestion
                                self.didReceiveSecurityForm(result)
            },
                               onFailure: { (errors) -> Void in
                                
            });
    }
    
    private func didReceiveSecurityForm(securityQuestion : SecurityQuestion) {
        _securityQuestion = securityQuestion
        
        if((_securityQuestion.message_error) != nil) {
            let stickyAlert = StickyAlertView.init(errorMessages: _securityQuestion.message_error, delegate: self)
            stickyAlert.show()
        } else {
            if questionType1 == "0" {
                self.view.addSubview(questionViewType2)
                
                questionViewType2.mas_makeConstraints({ (make) in
                    make.edges.mas_equalTo()(self.view)
                })
                
                self.setupOTPBySMS()
            }
        }
    }
    
    private func setupOTPBySMS() {
        if shouldAutoSendOTPBySMS() {
            requestOTPOnSMS()
        } else {
            self.resendOTPLabel.hidden = true
            disableOTPCallButton()
        }
    }
    
    private func shouldAutoSendOTPBySMS() -> Bool {
        return SecurityQuestionTweaks.autoSendOTPBySMS()
    }
    
    //MARK: Change Number Method
    @IBAction func didTapToChangePhoneNumber(sender: AnyObject) {
        AnalyticsManager.trackEventName("clickChangePhoneNumber", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_CLICK, label: "Change Phone Number")
        let auth = UserAuthentificationManager()
        let urlString = "\(NSString.tokopediaUrl())/contact-us?sid=54&flag_app=1&utm_source=ios&app_version=\(UIApplication.getAppVersionStringWithoutDot())"
        let controller = WKWebViewController(urlString: auth.webViewUrlFromUrl(urlString), shouldAuthorizeRequest: true)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: Timer Methods
    private func startTimerCountdown(secondsLeft: Int, onTick: ((Int) -> Void)?, onTimeout: () -> ()) -> NSTimer {
        var timeLeft = secondsLeft
        let buttonTimer = NSTimer.bk_scheduledTimerWithTimeInterval(
            1,
            block: { (timer) in
                onTick?(timeLeft)
                timeLeft = timeLeft - 1
                if timeLeft < 0 {
                    onTimeout()
                }
                
            },
            repeats: true)
        
        return buttonTimer
    }
    
    private func enableOTPOnSMSInSeconds(seconds: Int) {
        self.disableResendOTPButton()
        resendOTPTimer = startTimerCountdown(
            seconds,
            onTick: { [weak self] timeLeft in
                guard let `self` = self else { return }
                self.resendOTPButton.setTitle("\(timeLeft) Detik", forState: .Normal)
            },
            onTimeout: { [weak self] in
                guard let `self` = self else { return }
                self.resendOTPLabel.hidden = true
                self.resendOTPButton.setTitle("Kirim SMS Verifikasi", forState: .Normal)
                self.enableResendOTPButton()
                self.resendOTPTimer.invalidate()
            })
    }
    
    private func enableOTPOnCallInSeconds(seconds: Int) {
        self.disableOTPCallButton()
        otpOnCallTimer = startTimerCountdown(
            seconds,
            onTick: nil,
            onTimeout: { [weak self] in
                guard let `self` = self else { return }
                self.enableOTPCallButton()
                self.otpOnCallView.hidden = false
                self.otpOnCallTimer.invalidate()
            })
    }
    
    private func stopTimer() {
        otpOnCallTimer?.invalidate()
        resendOTPTimer?.invalidate()
    }
    
    //MARK: Verify OTP Button Methods
    @IBAction private func didSubmitOTP(sender: AnyObject?) {
        guard let text = otpInputField.text where !text.isEmpty else {
            StickyAlertView.showErrorMessage(["Harap isi Kode OTP terlebih dahulu."])
            return
        }
        
        let answer = otpInputField.text?.stringByReplacingOccurrencesOfString(" ", withString: "")
        self.submitSecurityAnswer(answer!)
    }
    
    private func submitSecurityAnswer(answer : String) {
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                           path: "/v4/action/interrupt/answer_question.pl",
                                           method: .GET,
                                           parameter: ["question" : _securityQuestion.data.question, "answer" : answer, "user_check_security_1" : questionType1, "user_check_security_2" : questionType2, "user_id" : userID],
                                           mapping: SecurityAnswer .mapping(),
                                           onSuccess: { (mappingResult, operation) -> Void in
                                            let answer = mappingResult.dictionary()[""] as! SecurityAnswer
                                            self.didReceiveAnswerRespond(answer)
            },
                                           onFailure: nil)
    }
    
    private func didReceiveAnswerRespond(answer : SecurityAnswer) {
        if answer.message_error != nil {
            AnalyticsManager.trackEventName("verifyOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_VERIFY, label: "OTP Verify Failed")
            let stickyAlert = StickyAlertView.init(errorMessages: answer.message_error, delegate: self)
            stickyAlert.show()
        } else if answer.data.error == "1" {
            AnalyticsManager.trackEventName("verifyOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_VERIFY, label: "OTP Verify Failed")
            let stickyAlert = StickyAlertView.init(errorMessages: ["Kode OTP hanya boleh diisi dengan 6 angka."], delegate: self)
            stickyAlert.show()
        }
        
        if answer.data.allow_login == "1" {
            AnalyticsManager.trackEventName("verifyOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_VERIFY, label: "OTP Verify Success")
            self.stopTimer()
            self.successAnswerCallback(answer)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    //MARK: Resend OTP Button Methods
    private func disableResendOTPButton() {
        self.resendOTPButton.userInteractionEnabled = false
        self.resendOTPButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.38), forState: .Normal)
        self.resendOTPButton.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.38)
    }
    
    private func enableResendOTPButton() {
        self.resendOTPButton.userInteractionEnabled = true
        self.resendOTPButton.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.54), forState: .Normal)
        self.resendOTPButton.borderColor = UIColor.blackColor().colorWithAlphaComponent(0.54)
    }
    
    @IBAction private func didTapRequestOTP(sender: AnyObject) {
        disableResendOTPButton()
        disableOTPCallButton()
        requestOTPOnSMS()
    }
    
    private func requestOTPOnSMS() {
        networkManager.requestWithBaseUrl(NSString.v4Url(),
                                           path: "/v4/action/interrupt/request_otp.pl",
                                           method: .GET,
                                           parameter: ["user_id" : userID, "user_check_question_2" : questionType2],
                                           mapping: SecurityRequestOTP.mapping(),
                                           onSuccess: { [unowned self](mappingResult, operation) -> Void in
                                            let otp = mappingResult.dictionary()[""] as! SecurityRequestOTP
                                            self.resendOTPLabel.hidden = false
                                            
                                            if otp.message_error != nil {
                                                AnalyticsManager.trackEventName("requestOTPOnSMS", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_SMS, label: "SMS Failed")
                                                StickyAlertView.showErrorMessage(otp.message_error)
                                                
                                                self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftIfFailed)
                                                if self.isOTPOnCallEnabled {
                                                    self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftIfFailed)
                                                }
                                            }
                                            
                                            if otp.data.is_success != nil && otp.data.is_success == "1" {
                                                AnalyticsManager.trackEventName("requestOTPOnSMS", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_SMS, label: "SMS Success")
                                                StickyAlertView.showSuccessMessage(["Kode OTP telah terkirim."])
                                                
                                                self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftDefault)
                                                self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftDefault)
                                            }
                                        },
                                           onFailure: { (error) in
                                            AnalyticsManager.trackEventName("requestOTPOnSMS", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_SMS, label: "SMS Failed")
                                            self.resendOTPLabel.hidden = false
                                            self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftIfFailed)
                                            
                                            if self.isOTPOnCallEnabled {
                                                self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftIfFailed)
                                            }
        })
    }

    
    //MARK: OTP Call Button Methods
    private func disableOTPCallButton() {
        self.otpOnCallButton.userInteractionEnabled = false
        self.otpOnCallButton.setTitleColor(UIColor.grayColor(), forState: .Normal)
    }
    
    private func enableOTPCallButton() {
        self.isOTPOnCallEnabled = true
        self.otpOnCallButton.userInteractionEnabled = true
        self.otpOnCallButton.setTitleColor(UIColor.fromHexString("#42B549"), forState: .Normal)
    }
    
    @IBAction private func didTapOTPOnCall(sender: AnyObject) {
        disableOTPCallButton()
        disableResendOTPButton()
        requestOTPOnCall()
    }
    
    private func requestOTPOnCall() {
        networkManager.requestWithBaseUrl(NSString.accountsUrl(),
                                           path: "/otp/request",
                                           method: .POST,
                                           header: ["Tkpd-UserId" : userID, "Authorization" : "\(self.token.tokenType) \(self.token.accessToken)"],
                                           parameter: ["mode" : "call"],
                                           mapping: V4Response.mappingWithData(OTPOnCall.mapping()),
                                           onSuccess: { (mappingResult, operation) in
                                            self.resendOTPLabel.hidden = false
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response = result[""] as! V4Response
                                            
                                            if response.message_error != nil && response.message_error.count > 0 {
                                                AnalyticsManager.trackEventName("requestOTPOnCall", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_ON_CALL, label: "On Call Failed")
                                                StickyAlertView.showErrorMessage(response.message_error)
                                                
                                                self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftIfFailed)
                                                self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftIfFailed)
                                            }
                                            
                                            if response.message_status != nil && response.message_status.count > 0 {
                                                AnalyticsManager.trackEventName("requestOTPOnCall", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_ON_CALL, label: "On Call Success")
                                                StickyAlertView.showSuccessMessage(response.message_status)
                                                
                                                self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftDefault)
                                                self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftDefault)
                                            }
                                            
                                            },
                                           onFailure: { (error) in
                                            AnalyticsManager.trackEventName("requestOTPOnCall", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_ON_CALL, label: "On Call Failed")
                                            self.resendOTPLabel.hidden = false
                                            self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftIfFailed)
                                            self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftIfFailed)
        })
    }
    
    
    
    //MARK: UITextField Delegate
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return otpInputField.shouldChangeCharactersInRange(range, replacementString: string)
    }
}
