//
//  PhoneVerificationViewController.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 2/14/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import TPKeyboardAvoiding
import VMaskTextField
import RxSwift

@objc(PhoneVerificationViewController)
class PhoneVerificationViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet fileprivate var scrollView: TPKeyboardAvoidingScrollView!
    
    @IBOutlet fileprivate var stackView: OAStackView!
    
    @IBOutlet fileprivate var welcomeView: UIView!
    
    @IBOutlet fileprivate var infoView: UIView!
    
    @IBOutlet fileprivate var phoneNumberView: UIView!
    @IBOutlet fileprivate var phoneNumberLabel: UILabel!
    @IBOutlet fileprivate var changePhoneNumberButton: UIButton!
    
    @IBOutlet fileprivate var sendOTPBySMSView: UIView!
    @IBOutlet fileprivate var sendOTPBySMSButton: UIButton!
    
    @IBOutlet fileprivate var resendOTPBySMSView: UIView!
    @IBOutlet fileprivate var resendOTPBySMSButton: UIButton!
    @IBOutlet fileprivate var sendOTPOnCallButton: UIButton!
    
    @IBOutlet fileprivate var verifyInfoView: UIView!
    @IBOutlet fileprivate var verifyStatusLabel: UILabel!
    @IBOutlet fileprivate var countdownLabel: UILabel!
    
    @IBOutlet fileprivate var verificationCodeFieldView: UIView!
    @IBOutlet fileprivate var inputOTPField: VMaskTextField!
    @IBOutlet fileprivate var horizontalLine: UIView!
    
    @IBOutlet fileprivate var verifyView: UIView!
    @IBOutlet fileprivate var verifyButton: UIButton!
    
    fileprivate let phoneNumber : String
    fileprivate let isFirstTimeVisit : Bool
    var didVerifiedPhoneNumber : ((Void) -> Void)?
    
    lazy var networkManager : TokopediaNetworkManager = {
        let networkManager = TokopediaNetworkManager()
        networkManager.isUsingHmac = true
        
        return networkManager
    }()
    
    fileprivate var sendButtonActivityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        return activityIndicator
    }()
    
    fileprivate var resendButtonActivityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        return activityIndicator
    }()
    
    fileprivate var verifyButtonActivityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        return activityIndicator
    }()
    
    fileprivate var timer: Timer!
    
    fileprivate var resendOTPSecondsLeftDefault: Int = 90
    fileprivate var resendOTPSecondsLeftIfFailed: Int = 5
    
    fileprivate var isFirstTimeRequest: Bool = true
    
    init(phoneNumber: String, isFirstTimeVisit: Bool) {
        self.phoneNumber = phoneNumber
        self.isFirstTimeVisit = isFirstTimeVisit
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.timer?.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = isFirstTimeVisit ? "Aktivasi Telah Berhasil" : "Verifikasi Nomor Ponsel"
        AnalyticsManager.trackScreenName("Phone Verification Page")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: isFirstTimeVisit ? "Lewati" : "Kembali",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapCancelButton))
        
        self.setupView()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AnalyticsManager.trackScreenName("Phone Verification Page")
        self.saveLastAppearInfoToCache()
    }
    
    fileprivate func saveLastAppearInfoToCache() {
        let standardUserDefaults = UserDefaults.standard
        standardUserDefaults.set(self.stringFromDate(Date()), forKey: "phone_verif_last_appear")
        standardUserDefaults.synchronize()
    }
    
    fileprivate func stringFromDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupView() {
        self.displayInitialView(whenFirstTimeVisit: isFirstTimeVisit, isFirstTimeRequest: isFirstTimeRequest)
        
        if self.phoneNumber == "" {
            PhoneVerificationRequest.getPhoneNumber(
                onSuccess: { (phoneNumber) in
                    self.phoneNumberLabel.text = phoneNumber
            },
                onFailure: {
                    self.phoneNumberLabel.text = ""
            })
        } else {
            self.phoneNumberLabel.text = self.phoneNumber
        }
                
        self.inputOTPField.delegate = self
        self.inputOTPField.mask = "#  #  #  #  #  #"
        
        self.setupActivityIndicator(onButton: self.sendOTPBySMSButton, activityIndicator: self.sendButtonActivityIndicator)
        self.setupActivityIndicator(onButton: self.resendOTPBySMSButton, activityIndicator: self.resendButtonActivityIndicator)
        self.setupActivityIndicator(onButton: self.verifyButton, activityIndicator: self.verifyButtonActivityIndicator)
        
        self.disableVerifyButton()
    }
    
    fileprivate func displayInitialView(whenFirstTimeVisit firstTimeVisit: Bool, isFirstTimeRequest: Bool) {
        self.welcomeView.isHidden = !firstTimeVisit
        self.infoView.isHidden = !firstTimeVisit
        
        self.sendOTPBySMSView.isHidden = !isFirstTimeRequest
        self.resendOTPBySMSView.isHidden = isFirstTimeRequest
        self.verifyInfoView.isHidden = isFirstTimeRequest
        self.verificationCodeFieldView.isHidden = isFirstTimeRequest
    }
    
    fileprivate func setupActivityIndicator(onButton button: UIButton, activityIndicator: UIActivityIndicatorView) {
        let halfButtonHeight = button.bounds.size.height / 2
        let buttonWidth = button.bounds.size.width
        
        activityIndicator.center = CGPoint(x: buttonWidth - halfButtonHeight, y: halfButtonHeight)
        
        button.addSubview(activityIndicator)
        activityIndicator.mas_makeConstraints({ (make) in
            _ = make?.centerX.equalTo()(button.mas_centerX)
            _ = make?.centerY.equalTo()(button.mas_centerY)
        })
    }
    
    //MARK: Requests
    fileprivate func onRequestOTPSuccess() {
        self.verifyStatusLabel.text = "Verifikasi akan dikirimkan."
        self.isFirstTimeRequest = false
        self.sendOTPBySMSView.isHidden = true
        self.verifyInfoView.isHidden = false
        self.resendOTPBySMSView.isHidden = true
        self.verificationCodeFieldView.isHidden = false
        self.showResendOTPBySMSButtonIsLoading(false)
        self.showSendOTPBySMSButtonIsLoading(false)
        self.enableVerifyButton()
        self.startSuccessTimer()
    }
    
    fileprivate func onRequestOTPFailed() {
        self.verifyStatusLabel.text = "Verifikasi gagal terkirim."
        self.sendOTPBySMSView.isHidden = true
        self.verifyInfoView.isHidden = false
        self.resendOTPBySMSView.isHidden = true
        self.verificationCodeFieldView.isHidden = self.isFirstTimeRequest
        self.showResendOTPBySMSButtonIsLoading(false)
        self.showSendOTPBySMSButtonIsLoading(false)
        self.startFailedTimer()
    }
    
    //MARK: Timer Method
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
    
    fileprivate func startSuccessTimer() {
        timer = startTimerCountdown(
            self.resendOTPSecondsLeftDefault,
            onTick : { [weak self] timeLeft in
                guard let `self` = self else { return }
                self.countdownLabel.text = "Tunggu \(timeLeft) detik untuk mengirim ulang"
            },
            onTimeout : { [weak self] timeLeft in
                guard let `self` = self else { return }
                self.verifyInfoView.isHidden = true
                self.resendOTPBySMSView.isHidden = false
                self.timer.invalidate()
            }
        )
    }
    
    fileprivate func startFailedTimer() {
        timer = startTimerCountdown(
            self.resendOTPSecondsLeftIfFailed,
            onTick : { [weak self] timeLeft in
                guard let `self` = self else { return }
                self.countdownLabel.text = "Tunggu \(timeLeft) detik untuk mengirim ulang"
            },
            onTimeout : { [weak self] timeLeft in
                guard let `self` = self else { return }
                self.verifyInfoView.isHidden = true
                self.sendOTPBySMSView.isHidden = !self.isFirstTimeRequest
                self.resendOTPBySMSView.isHidden = self.isFirstTimeRequest
                self.timer.invalidate()
            }
        )
    }
    
    //MARK: Button Actions
    fileprivate func showSendOTPBySMSButtonIsLoading(_ isLoading: Bool) {
        isLoading ? sendButtonActivityIndicator.startAnimating() : sendButtonActivityIndicator.stopAnimating()
        sendOTPBySMSButton.isEnabled = !isLoading
        sendOTPBySMSButton.setTitle(isLoading ? "" : "Kirim SMS Verifikasi", for: .normal)
    }
    
    fileprivate func showResendOTPBySMSButtonIsLoading(_ isLoading: Bool) {
        isLoading ? resendButtonActivityIndicator.startAnimating() : resendButtonActivityIndicator.stopAnimating()
        resendOTPBySMSButton.isEnabled = !isLoading
        resendOTPBySMSButton.setTitle(isLoading ? "" : "Kirim SMS Ulang", for: .normal)
        sendOTPOnCallButton.isEnabled = !isLoading
        sendOTPOnCallButton.setTitleColor(isLoading ? UIColor.tpDisabledBlackText() : UIColor.tpGreen(), for: .normal)
    }
    
    fileprivate func showVerifyButtonIsLoading(_ isLoading: Bool) {
        isLoading ? verifyButtonActivityIndicator.startAnimating() : verifyButtonActivityIndicator.stopAnimating()
        verifyButton.isEnabled = !isLoading
        verifyButton.setTitle(isLoading ? "" : "Verifikasi", for: .normal)
    }
    
    @objc fileprivate func didTapCancelButton() {
        AnalyticsManager.trackEventName("clickVerify",
                                        category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                        action: GA_EVENT_ACTION_CLICK,
                                        label: "Abandonment")
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapToChangePhoneNumberButton(_ sender: Any) {
        let controller = ChangePhoneNumberViewController(
            phoneNumber: self.phoneNumberLabel.text!,
            onPhoneNumberChanged: { [weak self] (newPhoneNumber) in
                self?.timer?.invalidate()
                self?.isFirstTimeRequest = true
                self?.displayInitialView(whenFirstTimeVisit: (self?.isFirstTimeVisit)!, isFirstTimeRequest: (self?.isFirstTimeRequest)!)
                self?.phoneNumberLabel.text = newPhoneNumber
                self?.inputOTPField.text = ""
                self?.disableVerifyButton()
        })
        
        AnalyticsManager.trackEventName("clickVerify",
                                        category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                        action: GA_EVENT_ACTION_CLICK,
                                        label: "Change Phone Number")
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func didTapSendOTPBySMSButton(_ sender: Any) {
        self.isFirstTimeRequest = true
        self.showSendOTPBySMSButtonIsLoading(true)
        AnalyticsManager.trackEventName("clickVerify",
                                        category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                        action: GA_EVENT_ACTION_CLICK,
                                        label: "OTP SMS")
        PhoneVerificationRequest.requestOTP(
            withMode: "sms",
            phoneNumber: self.phoneNumberLabel.text!,
            onSuccess: {
                AnalyticsManager.trackEventName("verifySuccess",
                                                category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                                action: GA_EVENT_ACTION_REQUEST_SUCCESS,
                                                label: "Request OTP SMS")
                self.onRequestOTPSuccess()
        },
            onFailure: {
                AnalyticsManager.trackEventName("verifyFailed",
                                                category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                                action: GA_EVENT_ACTION_REQUEST_FAILED,
                                                label: "Request OTP SMS")
                self.onRequestOTPFailed()
        })
    }
    
    @IBAction func didTapResendOTPBySMSButton(_ sender: Any) {
        self.showResendOTPBySMSButtonIsLoading(true)
        AnalyticsManager.trackEventName("clickVerify",
                                        category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                        action: GA_EVENT_ACTION_CLICK,
                                        label: "Resend OTP SMS")
        PhoneVerificationRequest.requestOTP(
            withMode: "sms",
            phoneNumber: self.phoneNumberLabel.text!,
            onSuccess: {
                AnalyticsManager.trackEventName("verifySuccess",
                                                category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                                action: GA_EVENT_ACTION_REQUEST_SUCCESS,
                                                label: "Request OTP SMS")
                self.onRequestOTPSuccess()
        },
            onFailure: {
                AnalyticsManager.trackEventName("verifyFailed",
                                                category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                                action: GA_EVENT_ACTION_REQUEST_FAILED,
                                                label: "Request OTP SMS")
                self.onRequestOTPFailed()
        })
    }
    
    @IBAction func didTapSendOTPOnCallButton(_ sender: Any) {
        self.showResendOTPBySMSButtonIsLoading(true)
        AnalyticsManager.trackEventName("clickVerify",
                                        category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                        action: GA_EVENT_ACTION_CLICK,
                                        label: "OTP On Call")
        PhoneVerificationRequest.requestOTP(
            withMode: "call",
            phoneNumber: self.phoneNumberLabel.text!,
            onSuccess: {
                AnalyticsManager.trackEventName("verifySuccess",
                                                category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                                action: GA_EVENT_ACTION_REQUEST_SUCCESS,
                                                label: "Request OTP On Call")

                self.onRequestOTPSuccess()
        },
            onFailure: {
                AnalyticsManager.trackEventName("verifyFailed",
                                                category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                                action: GA_EVENT_ACTION_REQUEST_FAILED,
                                                label: "Request OTP On Call")
                self.onRequestOTPFailed()
        })
    }
    
    @IBAction func didTapVerifyButton(_ sender: Any) {
        AnalyticsManager.trackEventName("clickVerify",
                                        category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                        action: GA_EVENT_ACTION_CLICK,
                                        label: "Verify")
        let otpCode = (self.inputOTPField.text?.replacingOccurrences(of: " ", with: ""))!
        if otpCode.characters.count < 6 {
            AnalyticsManager.trackEventName("verifyFailed",
                                            category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                            action: GA_EVENT_ACTION_VERIFY_FAILED,
                                            label: "Uncomplete OTP")
            StickyAlertView.showErrorMessage(["Kode OTP harus terdiri dari 6 angka"])
            return
        }
        
        self.showVerifyButtonIsLoading(true)
        PhoneVerificationRequest.requestVerify(
            withOTPCode: otpCode,
            phoneNumber: self.phoneNumberLabel.text!,
            onSuccess: {
                AnalyticsManager.trackEventName("verifySuccess",
                                                category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                                action: GA_EVENT_ACTION_VERIFY_SUCCESS,
                                                label: "OTP")
                self.didSuccessVerifyPhoneNumber()
        },
            onFailure: {
                AnalyticsManager.trackEventName("verifyFailed",
                                                category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                                action: GA_EVENT_ACTION_VERIFY_FAILED,
                                                label: "OTP")
                self.showVerifyButtonIsLoading(false)
        })
    }
    
    fileprivate func disableVerifyButton() {
        self.verifyButton.isEnabled = false
        self.verifyButton.backgroundColor = UIColor.tpLine()
        self.verifyButton.setTitleColor(UIColor.tpDisabledBlackText(), for: .normal)
    }
    
    fileprivate func enableVerifyButton() {
        self.verifyButton.isEnabled = true
        self.verifyButton.backgroundColor = UIColor.tpGreen()
        self.verifyButton.setTitleColor(UIColor.tpPrimaryWhiteText(), for: .normal)
    }
    
    fileprivate func didSuccessVerifyPhoneNumber() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        self.didVerifiedPhoneNumber?()
    }
    
    //MARK: UITextField Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == "" {
            AnalyticsManager.trackEventName("clickVerify",
                                            category: GA_EVENT_CATEGORY_VERIFY_PHONE_NUMBER,
                                            action: GA_EVENT_ACTION_CLICK,
                                            label: "Fill Verification Code")
        }
        return inputOTPField.shouldChangeCharacters(in: range, replacementString: string)
    }
}
