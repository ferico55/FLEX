//
//  CentralizedOTPViewController.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 25/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxSwift
import UIKit

public protocol CentralizedOTPDelegate: class {
    func didSuccessVerificationOTP(otpType: CentralizedOTPType, otpResult: COTPResponse)
}

public class CentralizedOTPViewController: UIViewController {
    
    @IBOutlet weak fileprivate var stackViewOTP: OTPInputView!
    @IBOutlet weak fileprivate var wrapper: UIView!
    
    @IBOutlet weak fileprivate var verificationImage: UIImageView!
    @IBOutlet weak fileprivate var verificationInfo: UILabel!
    @IBOutlet weak fileprivate var clearOTPButton: UIButton!
    @IBOutlet weak fileprivate var errorLabel: UILabel!
    @IBOutlet weak fileprivate var labelInformation: UITextView!
    @IBOutlet weak fileprivate var verificationButton: UIButton!
    @IBOutlet weak fileprivate var imageTop: NSLayoutConstraint!
    @IBOutlet weak fileprivate var wrapperTop: NSLayoutConstraint!
    @IBOutlet weak private var showLoading: UIActivityIndicatorView!
    
    public weak var delegate: CentralizedOTPDelegate?
    
    private let otpFieldsCount: Int
    fileprivate let otpType: CentralizedOTPType
    fileprivate var otpEnteredText: String = ""
    fileprivate let resendCountdown = 90
    fileprivate let otpButtonEnabled = Variable(false)
    fileprivate let triggerCountdown = PublishSubject<Void>()
    
    private let regularAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
    private let boldAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
    
    public var modeDetail: ModeListDetail!
    public var accountInfo: AccountInfo? // Used for get list of otp before Login
    
    public init(otpFieldsCount: Int = 6, otpType: CentralizedOTPType) {
        self.otpFieldsCount = otpFieldsCount
        self.otpType = otpType
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Verifikasi"
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_close"), style: .plain, target: self, action: #selector(self.didTapCloseButton))
        
        setupView()
    }
    
    // MARK: Dismiss View Controller
    @objc fileprivate func didTapCloseButton() {
        if self.otpType == CentralizedOTPType.securityChallenge {
            guard UserAuthentificationManager().isLogin else {
                SecureStorageManager().removeToken()
                self.navigationController?.dismiss(animated: true, completion: nil)
                return
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "NOTIFICATION_FORCE_LOGOUT"), object: nil)
        }
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func setupView() {
        setupOTPField()
        setupOtpButton()
        setupVerification(imageUrl: modeDetail.otpListImgUrl, label: modeDetail.afterOtpListText)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.wrapperTop.constant = 40
            self.imageTop.constant = 40
            self.wrapper.layer.borderWidth = 1
            self.wrapper.layer.borderColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1).cgColor
            self.wrapper.layer.cornerRadius = 10
            self.wrapper.clipsToBounds = true
        }
        
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
        
        triggerCountdown.onNext()
    }
    
    // MARK : Setup Verification Label and Image
    fileprivate func setupVerification(imageUrl: URL?, label: String ) {
        if let imageUrl = imageUrl {
            verificationImage.setImageWith(imageUrl)
        }
        verificationInfo.text = label
    }
    
    // MARK : Setup OTP Field
    private func setupOTPField() {
        stackViewOTP.otpFieldsCount = self.otpFieldsCount
        stackViewOTP.delegate = self
        stackViewOTP.initalizeUI()
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
    
    // MARK : Setup OTP Button
    private func setButtonLoading (_ isLoading: Bool) {
        self.otpButtonEnabled.value = !isLoading
        if isLoading {
            verificationButton.setTitle("", for: .normal)
            showLoading.isHidden = false
            showLoading.startAnimating()
        } else {
            showLoading.isHidden = true
            showLoading.stopAnimating()
            verificationButton.setTitle("Verifikasi", for: .normal)
        }
    }
    
    private func setupOtpButton() {
        self.otpButtonEnabled.asObservable()
            .subscribe(onNext: { [weak self] enabled in
                guard let `self` = self else {
                    return
                }
                self.verificationButton.isEnabled = enabled
                if enabled {
                    self.verificationButton.backgroundColor = .tpGreen()
                    self.verificationButton.setTitleColor(.white, for: .normal)
                    if self.errorLabel.isHidden {
                        self.stackViewOTP.showSuccessBorder()
                    }
                } else {
                    self.verificationButton.backgroundColor = .tpBorder()
                    self.verificationButton.setTitleColor(UIColor.black.withAlphaComponent(0.26), for: .normal)
                    self.errorLabel.isHidden = true
                    self.clearOTPButton.isHidden = true
                }
            })
            .addDisposableTo(self.rx_disposeBag)
        
        let userManager = UserAuthentificationManager()
        var userId = accountInfo?.userId ?? "0"
        if userManager.isLogin {
            userId = userManager.getUserId()
        }
        
        self.verificationButton.rx.tap.debounce(0.5, scheduler: MainScheduler.instance).subscribe(onNext: { [unowned self] _ in
            self.setButtonLoading(true)
            COTPService.validateCentralizedOTP(type: self.otpType, userId: userId, code: self.otpEnteredText)
                .subscribe(onNext: { [weak self] result in
                    guard let `self` = self else {
                        return
                    }
                    if let messageError = result.messageError {
                        let isSuccess = result.isSuccess ?? false
                        if !isSuccess && messageError.joined() != "Kode verifikasi salah" {
                            UIViewController.showNotificationWithMessage(messageError.joined(), type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
                        }
                        self.stackViewOTP.showErrorBorder()
                        self.errorLabel.isHidden = false
                        self.clearOTPButton.isHidden = false
                    } else {
                        // cause of the COTP is always present, we will dismiss after success
                        self.navigationController?.dismiss(animated: true, completion: nil)
                        self.delegate?.didSuccessVerificationOTP(otpType: self.otpType, otpResult: result)
                    }
                    self.setButtonLoading(false)
                }).addDisposableTo(self.rx_disposeBag)
        }).addDisposableTo(self.rx_disposeBag)
    }
    
    // MARK : Button Action
    @IBAction private func didTapClearButton(_ sender: UIButton) {
        self.otpButtonEnabled.value = false
        self.stackViewOTP.clearField()
    }
}

// MARK: OTP View Delegate
extension CentralizedOTPViewController: OTPInputViewDelegate {
    public func shouldBecomeFirstResponderForOTP(otpFieldIndex index: Int) -> Bool {
        return true
    }
    
    public func hasEnteredAllOTP(hasEntered: Bool, otpEntered: String) {
        self.otpButtonEnabled.value = hasEntered
        if hasEntered {
            self.otpEnteredText = otpEntered
        }
        debugPrint(otpEntered)
    }
}

// MARK: Text View Delegate
extension CentralizedOTPViewController: UITextViewDelegate {
    private func setToOtherVerification() {
        let observable = Observable<Bool>.just(true)
        observable
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] _ in
                let vc = VerificationModeListViewController(otpType: self.otpType)
                vc.accountInfo = self.accountInfo
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }).addDisposableTo(self.rx_disposeBag)
    }
    
    private func resendOTP() {
        self.triggerCountdown.onNext()
        COTPService.resendOTP(type: self.otpType, modeDetail: self.modeDetail, accountInfo: self.accountInfo)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] status in
                if status {
                    self.stackViewOTP.clearField()
                    UIViewController.showNotificationWithMessage("Kode verifikasi akan dikirim ulang", type: NotificationType.success.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
                }
            })
            .addDisposableTo(self.rx_disposeBag)
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "otherverification" {
            self.setToOtherVerification()
            return false
        } else if URL.scheme == "resend" {
            self.resendOTP()
            return false
        } else {
            return true
        }
    }
}

extension CentralizedOTPViewController: VerificationModeListDelegate {
    // MARK VerificationList Delegate
    public func didTapOtpMode(modeDetail: ModeListDetail, accountInfo: AccountInfo?) {
        self.stackViewOTP.clearField()
        self.otpButtonEnabled.value = false
        self.triggerCountdown.onNext()
        self.setupVerification(imageUrl: modeDetail.otpListImgUrl, label: modeDetail.afterOtpListText)
        self.modeDetail = modeDetail
    }
}
