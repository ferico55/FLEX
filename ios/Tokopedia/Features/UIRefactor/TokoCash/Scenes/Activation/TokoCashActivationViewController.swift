//
//  TokoCashActivationViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 8/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import RxSwift
import UIKit

public class TokoCashActivationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak private var phoneNumberLabel: UILabel!
    @IBOutlet weak private var activationButton: UIButton!
    @IBOutlet weak private var activationButtonActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var tableViewheightConstraint: NSLayoutConstraint!
    
    private let phoneNumber = Variable("")
    private let activityIndicator = ActivityIndicator()
    private let enableActivationButton = Variable(false)
    
    private var isPhoneVerified = UserAuthentificationManager().isUserPhoneVerified()
    
    // MARK: - Lifecycle
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Aktivasi TokoCash"
        
        let nib = UINib(nibName: "TokoCashActivationTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell0")
        tableView.register(nib, forCellReuseIdentifier: "cell1")
        tableView.register(nib, forCellReuseIdentifier: "cell2")
        tableView.register(nib, forCellReuseIdentifier: "cell3")
        tableView.estimatedRowHeight = 93.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        setupPhoneNumberLabel()
        setupActivationButtonActivityIndicator()
        requestPhoneNumber()
        requestPhoneVerifiedStatus()
        didtapActivationButton()
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.5, delay: 0.3, animations: {
            self.tableView.layoutIfNeeded()
            self.tableViewheightConstraint.constant = self.tableView.contentSize.height
            self.view.setNeedsLayout()
        })
        
        AnalyticsManager.trackScreenName("Tokocash Activation - Main Page")
    }
    
    // MARK: - Setup View
    private func setupPhoneNumberLabel() {
        if let phone = UserAuthentificationManager().getUserPhoneNumber() {
            phoneNumber.value = phone
        }
        phoneNumber
            .asObservable()
            .bind(to: phoneNumberLabel.rx.text)
            .addDisposableTo(rx_disposeBag)
    }
    
    private func setupActivationButtonActivityIndicator() {
        activityIndicator.asObservable()
            .map {
                if $0 {
                    self.activationButton.setTitle("", for: .disabled)
                } else {
                    self.activationButton.setTitle("Aktivasi", for: .disabled)
                }
                return !$0
            }
            .bind(to: activationButton.rx.isEnabled)
            .addDisposableTo(rx_disposeBag)
        
        activityIndicator.asObservable()
            .bind(to: activationButtonActivityIndicator.rx.isAnimating)
            .addDisposableTo(rx_disposeBag)
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
    
    private func requestPhoneVerifiedStatus() {
        OTPRequest.checkPhoneVerifiedStatus(onSuccess: { isVerified in
            self.isPhoneVerified = isVerified == "1"
        }) {
        }
    }
    
    private func didtapActivationButton() {
        activationButton.rx.tap
            .flatMap { () -> Observable<Bool> in
                if self.isPhoneVerified {
                    return WalletService.activationTokoCash(verificationCode: "").trackActivity(self.activityIndicator)
                } else {
                    let vc = TokoCashActivationOTPViewController()
                    self.navigationController?.pushViewController(vc, animated: true)
                    return Observable.empty()
                }
            }.retry()
            .subscribe(onNext: { _ in
                let vc = TokoCashActivationSuccessViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }, onError: { error in
                let errorString = [error.localizedDescription]
                StickyAlertView.showErrorMessage(errorString)
            }, onCompleted: {
                
            })
            .disposed(by: rx_disposeBag)
    }
    
    @IBAction private func didTapTermButton(_ sender: Any) {
        let controller = WebViewController()
        controller.strTitle = "TokoCash"
        controller.strURL = "https://www.tokopedia.com/bantuan/115000145223-TokoCash/"
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Table view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell\(indexPath.row)", for: indexPath)
        return cell
    }
}
