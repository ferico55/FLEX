//
//  VerificationModeListViewController.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 26/01/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import SwiftOverlays
import UIKit

public protocol VerificationModeListDelegate: class {
    func didTapOtpMode(modeDetail: ModeListDetail, accountInfo: AccountInfo?)
}

public class VerificationModeListViewController: UIViewController {
    
    @IBOutlet weak private var titleLabel: UILabel!
    @IBOutlet weak private var infoLabel: UILabel!
    
    @IBOutlet weak private var isLoading: UIActivityIndicatorView!
    @IBOutlet weak private var wrapper: UIView!
    @IBOutlet weak private var contentStackView: UIStackView!
    @IBOutlet weak private var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak private var changePhoneNumberButton: UIButton!
    
    private var otpModeList: [ModeListDetail]!
    // MARK : Use this if the User is not login
    public var accountInfo: AccountInfo?
    internal var isPresent: Bool?
    
    fileprivate var oAuthToken: OAuthToken = OAuthToken()
    fileprivate var changePhoneNumberStatus: Bool = false
    
    weak internal var delegate: VerificationModeListDelegate?
    private let otpType: CentralizedOTPType
    
    public init(otpType: CentralizedOTPType) {
        self.otpType = otpType
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Verifikasi"
        
        if self.otpType == .securityChallenge && self.isPresent != nil {
            self.titleLabel.text = "Verifikasi untuk Keamanan"
            var infoLabel = "Kami ingin memastikan akun ini benar milik Anda.\nPilih salah satu metode di bawah ini\nuntuk melakukan verifikasi."
            if UI_USER_INTERFACE_IDIOM() == .pad {
                infoLabel  = "Kami ingin memastikan akun ini benar milik Anda.\nPilih salah satu metode di bawah ini untuk melakukan verifikasi."
            }
            self.infoLabel.text  = infoLabel
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "icon_close"), style: .plain, target: self, action: #selector(self.didTapCloseButton))
        }
        
        setupButton()
        setupToken()
        loadData()
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentStackView.layoutIfNeeded()
        let contentHeight = CGFloat(70 * contentStackView.subviews.count)
        let spacing = CGFloat(10 * (contentStackView.subviews.count - 1))
        stackViewHeight.constant = spacing + contentHeight
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard otpType != .registerPhoneNumber else { return }
        
        OTPRequest
            .checkChangePhoneNumberStatus(
                withToken: oAuthToken,
                onSuccess: { status in
                    self.changePhoneNumberStatus = status
            },
                onFailure: {
                    
            }
        )
    }
    
    private func loadData() {
        // use accountInfo if you haven't login (Use for SQ)
        if let userId = accountInfo?.userId {
            self.isLoading.startAnimating()
            COTPService.getOTPModeList(type: self.otpType, userId: userId, msisdn: self.accountInfo?.phoneNumber ?? "").subscribe(onNext: { [unowned self] result in
                if result.isSuccess {
                    self.otpModeList = result.modeList
                    self.setupView()
                    self.isLoading.stopAnimating()
                }
            }).addDisposableTo(self.rx_disposeBag)
        }
    }
    
    // MARK : Setup oAuthToken
    
    private func setupToken() {
        let userManager = UserAuthentificationManager()
        if userManager.isLogin {
            let dict = userManager.getUserLoginData()
            oAuthToken.tokenType = dict?["oAuthToken.tokenType"] as? String ?? ""
            oAuthToken.accessToken = dict?["oAuthToken.accessToken"] as? String ?? ""
        } else {
            let storage = TKPDSecureStorage.standardKeyChains()
            oAuthToken.tokenType = (storage?.keychainDictionary())?["oAuthToken.tokenType"] as? String ?? ""
            oAuthToken.accessToken = (storage?.keychainDictionary())?["oAuthToken.accessToken"] as? String ?? ""
        }
        
    }
    
    // MARK : Setup Button
    
    private func setupButton() {
        let userManager = UserAuthentificationManager()
        var userId = accountInfo?.userId ?? ""
        var phoneVerified = accountInfo?.phoneVerified ?? false
        
        if userManager.isLogin {
            userId = userManager.getUserId()
            phoneVerified = userManager.isUserPhoneVerified()
        }
        
        self.changePhoneNumberButton.isHidden = !phoneVerified
        
        self.changePhoneNumberButton.rx.tap.debounce(0.5, scheduler: MainScheduler.instance).subscribe(onNext: { [unowned self] _ in
            AnalyticsManager.trackEventName("clickChangePhoneNumber", category: GA_EVENT_CATEGORY_SECURITY_QUESTION, action: GA_EVENT_ACTION_CLICK, label: "Change Phone Number")
            let controller = ChangePhoneNumberSQViewController(userID: userId, token: self.oAuthToken, status: self.changePhoneNumberStatus)
            self.navigationController?.pushViewController(controller, animated: true)
        }).addDisposableTo(self.rx_disposeBag)
    }
    
    // MARK : Setup View
    private func setupView() {
        self.wrapper.isHidden = false
        for modeListDetail in otpModeList {
            let cell = setupModeCell(modeListDetail: modeListDetail)
            contentStackView.addArrangedSubview(cell)
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.heightAnchor.constraint(equalToConstant: 70).isActive = true
        }
        self.view.layoutIfNeeded()
    }
    
    private func setupModeCell(modeListDetail : ModeListDetail) -> ModeCell {
        let textToShow = modeListDetail.otpListText.replacingOccurrences(of: "<br>", with: "")
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 70)
        let cell = ModeCell(frame: frame)
        cell.modeCellData = ModeCellData(imageUrl: modeListDetail.otpListImgUrl, text: textToShow)
        let tap = UITapGestureRecognizer(target: self, action: nil)
        cell.addGestureRecognizer(tap)
        cell.isUserInteractionEnabled = true
        cell.setupView()
        tap.rx.event.subscribe(onNext: { [unowned self] _ in
            self.didSelectOtpMode(otpModeDetail: modeListDetail)
        }).addDisposableTo(self.rx_disposeBag)
        
        return cell
    }
    
    private func didSelectOtpMode(otpModeDetail: ModeListDetail) {
        let userManager = UserAuthentificationManager()
        SwiftOverlays.showBlockingWaitOverlay()
        
        var userId = accountInfo?.userId ?? ""
        var userEmail = accountInfo?.email ?? ""
        var phoneNumber = accountInfo?.phoneNumber ?? ""
        
        if userManager.isLogin {
            userId = userManager.getUserId()
            userEmail = userManager.getUserEmail()
            phoneNumber = userManager.getUserPhoneNumber() ?? "0"
        }
        
        if otpModeDetail.modeText == "email" {
            COTPService.requestCentralizedOTPToEmail(type: otpType, userId: userId, userEmail: userEmail)
                .subscribe(onNext: { [unowned self] result in
                    if let messageError = result.messageError {
                        UIViewController.showNotificationWithMessage(messageError.joined(), type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
                    } else {
                        if self.isPresent != nil {
                            self.navigationController?.dismiss(animated: true, completion: { [weak self] in
                                self?.delegate?.didTapOtpMode(modeDetail: otpModeDetail, accountInfo: self?.accountInfo)
                            })
                        } else {
                            self.navigationController?.popViewController(animated: true)
                            self.delegate?.didTapOtpMode(modeDetail: otpModeDetail, accountInfo: self.accountInfo)
                        }
                    }
                    SwiftOverlays.removeAllBlockingOverlays()
                }).addDisposableTo(self.rx_disposeBag)
        } else {
            COTPService.requestCentralizedOTP(type: otpType, modeDetail: otpModeDetail, phoneNumber: phoneNumber, userId: userId)
                .subscribe(onNext: { [unowned self] result in
                    if let messageError = result.messageError {
                        UIViewController.showNotificationWithMessage(messageError.joined(), type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
                    } else {
                        if self.isPresent != nil {
                            self.navigationController?.dismiss(animated: true, completion: { [weak self] in
                                self?.delegate?.didTapOtpMode(modeDetail: otpModeDetail, accountInfo: self?.accountInfo)
                            })
                        } else {
                            self.navigationController?.popViewController(animated: true)
                            self.delegate?.didTapOtpMode(modeDetail: otpModeDetail, accountInfo: self.accountInfo)
                        }
                    }
                    SwiftOverlays.removeAllBlockingOverlays()
                }).addDisposableTo(self.rx_disposeBag)
        }
    }
    
    
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
    
}
