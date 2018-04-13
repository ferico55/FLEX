//
//  ListAccountViewController.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 08/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import Branch
import SwiftOverlays
import UIKit

internal class ListAccountViewController: UIViewController {
    
    @IBOutlet private weak var contentStackView: UIStackView!
    @IBOutlet private weak var contentStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var informationText: UILabel!
    @IBOutlet private weak var wrapperTrailing: NSLayoutConstraint!
    @IBOutlet private weak var wrapperLeading: NSLayoutConstraint!
    @IBOutlet private weak var titleLabelLeading: NSLayoutConstraint!
    
    internal var tokocashLoginVerifyResponse : TokoCashLoginVerifyOTPResponse!
    internal var phoneNumber : String!
    internal var onTapExit: ((_ login: Login?) -> Void)?
    
    override internal func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupView()
    }
    
    override internal func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override internal func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentStackView.layoutIfNeeded()
        contentStackViewHeightConstraint.constant = CGFloat(75 * contentStackView.subviews.count)
    }
    
    private func setupView() {
        if UI_USER_INTERFACE_IDIOM() == .pad {
                self.titleLabelLeading.constant = 0
                self.wrapperLeading.constant = 104
                self.wrapperTrailing.constant = 104
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Keluar", style: .plain, target: self, action:#selector(self.didTapRightBar(_:)))
        for index in tokocashLoginVerifyResponse.userDetails.indices {
            let cellData = tokocashLoginVerifyResponse.userDetails[index]
            let cell = self.setupCustomCell(cellData: cellData, index: index)
            self.contentStackView.addArrangedSubview(cell)
            cell.translatesAutoresizingMaskIntoConstraints = false
            cell.heightAnchor.constraint(equalToConstant: 71).isActive = true
        }
        self.view.layoutIfNeeded()
        self.setupAttrText()
    }
    
    private func setupAttrText() {
        let regularAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpDisabledBlackText()]
        let boldAttributes = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.tpSecondaryBlackText()]
        let totalAccounts = tokocashLoginVerifyResponse.userDetails.count
        let text = "Anda memiliki \(totalAccounts) akun dengan nomor ponsel \(self.phoneNumber ?? ""). Pilih salah satu akun untuk masuk."
        let attributedString = NSMutableAttributedString(string: text, attributes: regularAttributes)
        attributedString.addAttributes(boldAttributes, range: NSRange(location: 14, length: 6))
        
        self.informationText.attributedText = attributedString
    }
    
    @objc internal func didTapRightBar(_ sender: UIBarButtonItem) {
        self.onTapExit?(nil)
    }
    
    @objc internal func didSelectUserToLogin (_ sender: UITapGestureRecognizer) {
        guard let sender = sender.view else { return }
        let email = tokocashLoginVerifyResponse.userDetails[sender.tag].email
        SwiftOverlays.showBlockingWaitOverlay()
        AnalyticsManager.trackEventName("clickLogin", category: "login with phone", action: GA_EVENT_ACTION_CLICK, label: "Tokocash")
        WalletService.getCodeToHandshakeWithAccount(key: tokocashLoginVerifyResponse.key, email: email)
            .subscribe(onNext:{ [weak self] result in
                guard let `self` = self else { return }
                if result.responseCode == "200000" {
                    let service = AuthenticationService.shared
                    service.login(withTokocashCode : result.code)
                    service.onLoginComplete = { [weak self] (_ login: Login?, _ err: Error?) -> Void in
                        guard let strongSelf = self else {
                            return
                        }
                        if let errorString = err?.localizedDescription {
                            UIViewController.showNotificationWithMessage(errorString, type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
                        }
                        else {
                            // MARK: Success Login with Selected User
                            AnalyticsManager.trackEventName("clickLogin", category: "login with phone", action: GA_EVENT_ACTION_LOGIN_SUCCESS, label: "Tokocash")
                            strongSelf.onTapExit?(login)
                        }
                        SwiftOverlays.removeAllBlockingOverlays()
                    }
                } else {
                    let message : String = "Terjadi kesalahan pada server, silakan coba kembali"
                    UIViewController.showNotificationWithMessage(message, type: NotificationType.error.rawValue, duration: 3.0, buttonTitle: nil, dismissable: true, action: nil)
                    SwiftOverlays.removeAllBlockingOverlays()
                }
            })
            .addDisposableTo(self.rx_disposeBag)
    }
    
    private func setupCustomCell(cellData: TokoCashVerifyUserDetail, index: Int) -> UIView {
        let frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 71)
        let cell = AccountCustomCell(frame: frame)
        if UI_USER_INTERFACE_IDIOM() == .pad {
            cell.imageCell.translatesAutoresizingMaskIntoConstraints =  false
            cell.imageCell.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 0).isActive = true
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didSelectUserToLogin(_:)))
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        if let urlImage = cellData.image {
            cell.imageCell.setImageWith(URL(string: urlImage)!)
        }
        cell.fullNameLabel.text = cellData.name
        cell.emailLabel.text = cellData.email
        cell.tag = index
        cell.addGestureRecognizer(tap)
        cell.isUserInteractionEnabled = true
        return cell
    }
}
