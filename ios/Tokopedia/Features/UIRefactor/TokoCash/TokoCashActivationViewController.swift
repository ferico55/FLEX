//
//  TokoCashActivationViewController.swift
//  Tokopedia
//
//  Created by Tiara Freddy Andika on 8/7/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import RxSwift

class TokoCashActivationViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var activationButton: UIButton!
    @IBOutlet weak var activationButtonActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewheightConstraint: NSLayoutConstraint!
    
    private let phoneNumber = Variable("")
    private let isLoading = Variable(false)
    private let enableActivationButton = Variable(false)
    
    private var isPhoneVerified = UserAuthentificationManager().isUserPhoneVerified()
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 93.0
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        setupPhoneNumberLabel()
        setupActivationButtonActivityIndicator()
        requestPhoneNumber()
        requestPhoneVerifiedStatus()
        didtapActivationButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setWhite()
        UIView.animate(withDuration: 0.5, delay: 0.3, animations: {
            self.tableView.layoutIfNeeded()
            self.tableViewheightConstraint.constant = self.tableView.contentSize.height
            self.view.setNeedsLayout()
        })
        
        AnalyticsManager.trackScreenName("Tokocash Activation - Main Page")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Setup View
    private func setupPhoneNumberLabel() {
        if let phone = UserAuthentificationManager().getUserPhoneNumber() {
            phoneNumber.value = phone
        }
        phoneNumber
            .asObservable()
            .bindTo(self.phoneNumberLabel.rx.text)
            .addDisposableTo(self.rx_disposeBag)
    }
    
    private func setupActivationButtonActivityIndicator() {
        isLoading.asObservable().subscribe(onNext: { (isLoading) in
            if isLoading {
                self.activationButtonActivityIndicator.startAnimating()
                self.activationButton.isEnabled = false
            }else {
                self.activationButtonActivityIndicator.stopAnimating()
                self.activationButton.isEnabled = true
            }
        }).addDisposableTo(self.rx_disposeBag)
    }
    
    //MARK: - Action
    private func requestPhoneNumber() {
        if self.phoneNumber.value.isEmpty {
            OTPRequest.getPhoneNumber(
                onSuccess: { (phoneNumber) in
                    self.phoneNumber.value = phoneNumber
            },onFailure: {
            })
        }
    }
    
    private func requestPhoneVerifiedStatus() {
        isLoading.value = true
        OTPRequest .checkPhoneVerifiedStatus(onSuccess: { (isVerified) in
            self.isPhoneVerified = isVerified == "1"
            self.isLoading.value = false
        }) {
            self.isLoading.value = false
        }
    }
    
    private func didtapActivationButton() {
        activationButton.rx.tap
            .flatMap { () -> Observable<Bool> in
                if self.isPhoneVerified {
                    return WalletService.activationTokoCash(verificationCode: "")
                } else {
                    self.performSegue(withIdentifier: "tokoCashActivationOTPSegue", sender: nil)
                    return Observable.empty()
                }
            }
            .subscribe(onNext: { (success) in
                self.isLoading.value = false
                self.performSegue(withIdentifier: "tokoCashActivationSuccessSegue", sender: nil)
            }, onError: { (error) in
                self.isLoading.value = false
                let errorString = [error.localizedDescription]
                StickyAlertView.showErrorMessage(errorString)
            }, onCompleted: { 
                
            })
            .disposed(by: self.rx_disposeBag)

        
        /*
        
        activationButton.rx.tap.subscribe(onNext: { [unowned self] in
            if self.isPhoneVerified {
                self.isLoading.value = true
                WalletService.activationTokoCash(verificationCode: "")
                    .subscribe(onNext: { success in
                        self.isLoading.value = false
                        self.performSegue(withIdentifier: "tokoCashActivationSuccessSegue", sender: nil)
                    },onError:{ error in
                        self.isLoading.value = false
                        let errorString = [error.localizedDescription]
                        StickyAlertView.showErrorMessage(errorString)
                    },onCompleted:{
                        
                    }).disposed(by: self.rx_disposeBag)
            }else {
                self.performSegue(withIdentifier: "tokoCashActivationOTPSegue", sender: nil)
            }
        }).addDisposableTo(self.rx_disposeBag)
 
 */
    }
    
    @IBAction func didTapTermButton(_ sender: Any) {
        let controller = WebViewController()
        controller.strTitle = "TokoCash"
        controller.strURL = "https://www.tokopedia.com/bantuan/115000145223-TokoCash/"
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"cell\(indexPath.row)", for: indexPath)
        return cell
    }
}
