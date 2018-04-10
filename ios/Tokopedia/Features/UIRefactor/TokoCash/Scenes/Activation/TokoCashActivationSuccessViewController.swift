//
//  TokoCashActivationSuccessViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 8/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import NativeNavigation
import RxSwift
import UIKit

public class TokoCashActivationSuccessViewController: UIViewController {
    
    @IBOutlet weak private var successLabel: UILabel!
    
    private let phoneNumber = Variable("")
    
    // MARK: - Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Aktivasi TokoCash Berhasil"
        
        setupPhoneNumber()
        requestPhoneNumber()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.setHidesBackButton(true, animated: true)
        
        AnalyticsManager.trackScreenName("Tokocash Activation - Success Page")
    }
    
    // MARK: - Setup View
    private func setupPhoneNumber() {
        if let phone = UserAuthentificationManager().getUserPhoneNumber() {
            phoneNumber.value = phone
        }
        phoneNumber.asObservable()
            .subscribe(onNext: { _ in
                let regularAttributes: [String: Any] = [NSFontAttributeName: UIFont.largeTheme()]
                let boldAttributes: [String: Any] = [NSFontAttributeName: UIFont.largeThemeSemibold()]
                
                let partOne = NSMutableAttributedString(string: "Selamat Anda berhasil melakukan aktivasi TokoCash dengan nomor ", attributes: regularAttributes)
                let partTwo = NSMutableAttributedString(string: self.phoneNumber.value, attributes: boldAttributes)
                let partThree = NSMutableAttributedString(string: "\nKini Anda bisa bertransaksi dengan lebih mudah di Tokopedia.", attributes: regularAttributes)
                
                let combination = NSMutableAttributedString()
                
                combination.append(partOne)
                combination.append(partTwo)
                combination.append(partThree)
                
                self.successLabel.attributedText = combination
                
            }).addDisposableTo(rx_disposeBag)
    }
    
    // MARK: - Action
    private func requestPhoneNumber() {
        if phoneNumber.value.isEmpty {
            OTPRequest.getPhoneNumber(
                onSuccess: { phoneNumber in
                    self.phoneNumber.value = phoneNumber
                }, onFailure: {
            })
        }
    }
    
    @IBAction private func didTapBackToHomeButton(_ sender: Any) {
        if let tabManager = UIApplication.shared.reactBridge.module(for: ReactEventManager.self) as? ReactEventManager {
            tabManager.sendRedirectHomeTabEvent()
        }
        navigationController?.popToRootViewController(animated: true)
    }
}
