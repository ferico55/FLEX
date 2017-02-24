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
    
    fileprivate let userID : String
    fileprivate let deviceID : String
    fileprivate let phoneNumber: String
    fileprivate let name: String
    fileprivate let token : OAuthToken
    
    var successAnswerCallback: ((SecurityAnswer) -> Void)!
    
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
    
    lazy var networkManager : TokopediaNetworkManager = {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        return networkManager
    }()
    
    fileprivate var _securityQuestion : SecurityQuestion!
    
    @IBOutlet fileprivate var resendOTPLabel: UILabel!
    
    @IBOutlet fileprivate var otpOnCallButton: UIButton!
    fileprivate var otpOnCallTimer: Timer!
    
    @IBOutlet fileprivate var resendOTPButton: UIButton!
    fileprivate var resendOTPTimer: Timer!
    
    @IBOutlet fileprivate var verifyButton: UIButton!
    
    fileprivate var resendOTPSecondsLeftDefault: Int = 90
    fileprivate var resendOTPSecondsLeftIfFailed: Int = 5
    
    fileprivate var isOTPOnCallEnabled = false
    
    fileprivate var activityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        return activityIndicator
    }()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AnalyticsManager.trackScreenName("Security Question Page")
        
    }
    
    deinit {
        stopTimer()
    }
    
    //MARK: Initial View
    fileprivate func setupView() {
        self.setupInfoLabel()
        
        self.userNameLabel.text = name
        
        self.otpOnCallView.isHidden = true
        
        self.otpInputField.delegate = self
        self.otpInputField.mask = "# # # # # #"
        
        let halfButtonHeight = verifyButton.bounds.size.height / 2
        let buttonWidth = verifyButton.bounds.size.width
        
        activityIndicator.center = CGPoint(x: buttonWidth - halfButtonHeight, y: halfButtonHeight)
        
        verifyButton.addSubview(activityIndicator)
        activityIndicator.mas_makeConstraints({ (make) in
            make?.centerX.equalTo()(self.verifyButton.mas_centerX)
            make?.centerY.equalTo()(self.verifyButton.mas_centerY)
        })
    }
    
    fileprivate func setupInfoLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0
        
        let infoAttributedString = NSMutableAttributedString(string: "Kami akan mengirimkan kode verifikasi ke nomor ponsel ")
        
        let numberAttributedString = NSMutableAttributedString(string: phoneNumber)
        numberAttributedString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 14), range: NSMakeRange(0, phoneNumber.characters.count))
        
        infoAttributedString.append(numberAttributedString)
        
        infoAttributedString.addAttributes([NSParagraphStyleAttributeName : paragraphStyle, NSForegroundColorAttributeName : UIColor.black.withAlphaComponent(0.54)], range: NSMakeRange(0, infoAttributedString.length))
        
        self.phoneNumberLabel.attributedText = infoAttributedString
    }
    
    //MARK: Request Security Question Form
    fileprivate func requestQuestionForm() {
        networkManager.request(withBaseUrl: NSString.v4Url(),
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
    
    fileprivate func didReceiveSecurityForm(_ securityQuestion : SecurityQuestion) {
        _securityQuestion = securityQuestion
        
        if((_securityQuestion.message_error) != nil) {
            StickyAlertView.showErrorMessage(_securityQuestion.message_error)
        } else {
            if questionType1 == "0" {
                self.view.addSubview(questionViewType2)
                
                questionViewType2.mas_makeConstraints({ (make) in
                    make?.edges.mas_equalTo()(self.view)
                })
                
                self.setupOTPBySMS()
            }
        }
    }
    
    fileprivate func setupOTPBySMS() {
        if shouldAutoSendOTPBySMS() {
            requestOTPOnSMS()
        } else {
            self.resendOTPLabel.isHidden = true
            disableOTPCallButton()
        }
    }
    
    fileprivate func shouldAutoSendOTPBySMS() -> Bool {
        return SecurityQuestionTweaks.autoSendOTPBySMS()
    }
    
    //MARK: Change Number Method
    @IBAction func didTapToChangePhoneNumber(_ sender: AnyObject) {
        AnalyticsManager.trackEventName("clickChangePhoneNumber", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_CLICK, label: "Change Phone Number")
        let auth = UserAuthentificationManager()
        let urlString = "\(NSString.tokopediaUrl())/contact-us?sid=54&flag_app=1&utm_source=ios&app_version=\(UIApplication.getAppVersionStringWithoutDot())"
        let controller = WKWebViewController(urlString: auth.webViewUrl(fromUrl: urlString), shouldAuthorizeRequest: true)

        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: Timer Methods
    fileprivate func startTimerCountdown(_ secondsLeft: Int, onTick: ((Int) -> Void)?, onTimeout: @escaping () -> ()) -> Timer {
        var timeLeft = secondsLeft
        let buttonTimer = Timer.bk_scheduledTimer(
            withTimeInterval: 1,
            block: { (timer) in
                onTick?(timeLeft)
                timeLeft = timeLeft - 1
                if timeLeft < 0 {
                    onTimeout()
                }
                
            },
            repeats: true)
        
        return buttonTimer!
    }
    
    fileprivate func enableOTPOnSMSInSeconds(_ seconds: Int) {
        self.disableResendOTPButton()
        resendOTPTimer = startTimerCountdown(
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
            })
    }
    
    fileprivate func enableOTPOnCallInSeconds(_ seconds: Int) {
        self.disableOTPCallButton()
        otpOnCallTimer = startTimerCountdown(
            seconds,
            onTick: nil,
            onTimeout: { [weak self] in
                guard let `self` = self else { return }
                self.enableOTPCallButton()
                self.otpOnCallView.isHidden = false
                self.otpOnCallTimer.invalidate()
            })
    }
    
    fileprivate func stopTimer() {
        otpOnCallTimer?.invalidate()
        resendOTPTimer?.invalidate()
    }
    
    //MARK: Verify OTP Button Methods
    fileprivate func showVerificationButtonIsLoading(_ isLoading: Bool) {
        isLoading ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
        verifyButton.isEnabled = !isLoading
        verifyButton.setTitle(isLoading ? "" : "Verifikasi", for: UIControlState())
    }
    
    @IBAction fileprivate func didSubmitOTP(_ sender: AnyObject?) {
        showVerificationButtonIsLoading(true)
        
        guard let text = otpInputField.text, !text.isEmpty else {
            StickyAlertView.showErrorMessage(["Kode Verifikasi Tidak Boleh Kosong."])
            showVerificationButtonIsLoading(false)
            return
        }
        
        let answer = otpInputField.text?.replacingOccurrences(of:" ", with: "")
        self.submitSecurityAnswer(answer!)
    }
    
    fileprivate func submitSecurityAnswer(_ answer : String) {
        networkManager.request(
            withBaseUrl: NSString.v4Url(),
            path: "/v4/action/interrupt/answer_question.pl",
            method: .GET,
            parameter: ["question" : _securityQuestion.data.question, "answer" : answer, "user_check_security_1" : questionType1, "user_check_security_2" : questionType2, "user_id" : userID],
            mapping: SecurityAnswer .mapping(),
            onSuccess: { (mappingResult, operation) -> Void in
                let answer = mappingResult.dictionary()[""] as! SecurityAnswer
                self.didReceiveAnswerRespond(answer)
            },
            onFailure: { (error) in
                self.showVerificationButtonIsLoading(false)
        })
    }
    
    fileprivate func didReceiveAnswerRespond(_ answer : SecurityAnswer) {
        if answer.message_error != nil {
            AnalyticsManager.trackEventName("verifyOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_VERIFY, label: "OTP Verify Failed")
            StickyAlertView.showErrorMessage(answer.message_error)
            showVerificationButtonIsLoading(false)
        } else if answer.data.error == "1" {
            AnalyticsManager.trackEventName("verifyOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_VERIFY, label: "OTP Verify Failed")
            StickyAlertView.showErrorMessage(["Kode Verifikasi Tidak Sesuai."])
            showVerificationButtonIsLoading(false)
        }
        
        if answer.data.allow_login == "1" {
            AnalyticsManager.trackEventName("verifyOTP", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_VERIFY, label: "OTP Verify Success")
            self.stopTimer()
            self.successAnswerCallback(answer)
        }
    }
    
    //MARK: Resend OTP Button Methods
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
        disableResendOTPButton()
        disableOTPCallButton()
        requestOTPOnSMS()
    }
    
    fileprivate func requestOTPOnSMS() {
        networkManager.request(withBaseUrl: NSString.v4Url(),
                                           path: "/v4/action/interrupt/request_otp.pl",
                                           method: .GET,
                                           parameter: ["user_id" : userID, "user_check_question_2" : questionType2],
                                           mapping: SecurityRequestOTP.mapping(),
                                           onSuccess: { [unowned self](mappingResult, operation) -> Void in
                                            let otp = mappingResult.dictionary()[""] as! SecurityRequestOTP
                                            self.resendOTPLabel.isHidden = false
                                            
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
                                                
                                                if otp.message_status != nil && otp.message_status.count > 0 {
                                                    StickyAlertView.showSuccessMessage(otp.message_status)
                                                } else {
                                                    StickyAlertView.showSuccessMessage(["Kode Verifikasi Telah Terkirim."])
                                                }
                                                
                                                
                                                self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftDefault)
                                                self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftDefault)
                                            }
                                        },
                                           onFailure: { (error) in
                                            AnalyticsManager.trackEventName("requestOTPOnSMS", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_OTP_SMS, label: "SMS Failed")
                                            self.resendOTPLabel.isHidden = false
                                            self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftIfFailed)
                                            
                                            if self.isOTPOnCallEnabled {
                                                self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftIfFailed)
                                            }
        })
    }

    
    //MARK: OTP Call Button Methods
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
        disableOTPCallButton()
        disableResendOTPButton()
        requestOTPOnCall()
    }
    
    fileprivate func requestOTPOnCall() {
        networkManager.request(withBaseUrl: NSString.accountsUrl(),
                                           path: "/otp/request",
                                           method: .POST,
                                           header: ["Tkpd-UserId" : userID, "Authorization" : "\(self.token.tokenType) \(self.token.accessToken)"],
                                           parameter: ["mode" : "call"],
                                           mapping: V4Response<OTPOnCall>.mapping(withData: OTPOnCall.mapping()) as RKObjectMapping,
                                           onSuccess: { (mappingResult, operation) in
                                            self.resendOTPLabel.isHidden = false
                                            let result : Dictionary = mappingResult.dictionary() as Dictionary
                                            let response: V4Response<OTPOnCall> = result[""] as! V4Response
                                            
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
                                            self.resendOTPLabel.isHidden = false
                                            self.enableOTPOnSMSInSeconds(self.resendOTPSecondsLeftIfFailed)
                                            self.enableOTPOnCallInSeconds(self.resendOTPSecondsLeftIfFailed)
        })
    }
    
    
    
    //MARK: UITextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return otpInputField.shouldChangeCharacters(in: range, replacementString: string)
    }
}
