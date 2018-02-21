//
//  CodeShareTableViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 06/09/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import SwiftyJSON
import UIKit
internal class CodeShareTableViewController: UITableViewController {
    @IBOutlet weak private var codeLabel: UILabel!
    @IBOutlet weak private var detailLabel: UILabel!
    @IBOutlet weak private var codeContainerView: UIView!
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak private var shareButton: UIButton!
    @IBOutlet weak private var howItWorksButton: UIButton!
    @IBOutlet weak private var copyButton: UIButton!
    private var promoContent: ReferralPromoContent?
    private var shareTitle: String?
    private var isReferralOn = false
    private var detailDescription: String?
    //    MARK:- Lifecycle
    override internal func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.getPromoCode()
        BranchAnalytics().moEngageTrackScreenEvent(name: "Referral Home")
    }
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setWhite()
    }
    //    MARK:- Setup
    private func setupUI() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70.0
        if let referralCode = ReferralManager().referralCode {
            self.codeLabel.text = referralCode
            self.copyButton.isEnabled = true
        }
        ReferralRemoteConfig.shared.getHowReferralWorksLink { (title: String) in
            self.howItWorksButton.setTitle(title, for: .normal)
        }
        ReferralRemoteConfig.shared.getAppReferralTitle { (title: String) in
            self.shareTitle = title
            self.updateUI()
        }
        ReferralRemoteConfig.shared.showReferralCode { (show: Bool) in
            self.isReferralOn = show
            self.updateUI()
        }
        ReferralRemoteConfig.shared.getShareCodeScreenContent { (description: String) in
            self.detailDescription = description
            self.updateUI()
        }
    }
    //    MARK:-
    private func showActivityIndicator(show: Bool) {
        if show {
            self.activityIndicator.startAnimating()
            self.shareButton.setTitle("", for: .normal)
        } else {
            self.activityIndicator.stopAnimating()
            self.updateUI()
        }
    }
    private func updateUI() {
        self.codeContainerView.isHidden = !self.isReferralOn
        self.howItWorksButton.isHidden = !self.isReferralOn
        if self.isReferralOn {
            self.title = self.shareTitle
            self.detailLabel.text = self.detailDescription
            self.shareButton.setTitle("Ajak Teman", for: .normal)
        } else {
            self.title = "Share ke Teman"
            self.detailLabel.text = "Sudah merasakan berbagai kemudahan dengan aplikasi Tokopedia? Ayo ajak orang-orang terdekatmu untuk ikut menikmati mudahnya beli & bayar ini itu lewat aplikasi Tokopedia"
            self.shareButton.setTitle("Share ke Teman", for: .normal)
        }
        self.tableView.reloadData()
    }
    //    MARK:- Actions
    @IBAction private func codeCopyButtonTapped(sender: UIButton) {
        guard let code = ReferralManager().referralCode else {
            StickyAlertView.showErrorMessage(["No coupan to copy"])
            return
        }
        UIPasteboard.general.string = code
        StickyAlertView.showSuccessMessage(["Tersalin"])
        BranchAnalytics().trackReferralCodeLabelEvent(action: "click copy referral code")
    }
    @IBAction private func sendInviteButtonTapped(sender: UIButton) {
        let appSharing = ReferralSharing()
        guard let promo = self.promoContent else {
            return
        }
        if self.isReferralOn {
            appSharing.coupanCode = promo.code
            appSharing.buoDescription = promo.content
            ReferralManager().share(object: appSharing, from: self, anchor: sender)
        } else {
            ReferralRemoteConfig.shared.getAppShareDescription { (description: String) in
                appSharing.buoDescription = description
                ReferralManager().share(object: appSharing, from: self, anchor: sender)
                BranchAnalytics().moEngageTrackScreenEvent(name: "Share Channel")
            }
        }
        BranchAnalytics().trackReferralCodeLabelEvent(action: "click share code")
    }
    @IBAction private func howItWorksTapped(sender: UIButton) {
        let webViewController = WKWebViewController(urlString: "https://www.tokopedia.com/referral", shouldAuthorizeRequest: false)
        self.navigationController?.pushViewController(webViewController, animated: true)
        BranchAnalytics().trackClickReferralEvent(action: "click how it works", label: "")
    }
    //    MARK:- Service
    private func getPromoCode() {
        self.showActivityIndicator(show: true)
        NetworkProvider().request(ReferralService.getVoucherCode()) { (result) in
            self.showActivityIndicator(show: false)
            switch result {
            case let .success(response):
                let json = JSON(data: response.data)
                let promoResponse = ReferralResponse(json: json)
                if let content = promoResponse.promoContent {
                    self.promoContent = content
                    self.codeLabel.text = content.code
                    self.copyButton.isEnabled = true
                    ReferralManager().referralCode = content.code
                } else if let error = promoResponse.header.message {
                    StickyAlertView.showErrorMessage([error])
                }
            case let .failure(error):
                StickyAlertView.showErrorMessage([error.localizedDescription])
            }
        }
    }
    //    MARK:- UITableViewDelegate
    override internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
