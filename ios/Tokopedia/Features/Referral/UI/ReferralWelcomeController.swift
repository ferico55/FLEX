//
//  ReferralWelcomeController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 04/12/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
internal class ReferralWelcomeController: UITableViewController {
    @IBOutlet weak private var codeLabel: UILabel!
    @IBOutlet weak private var messageLabel: UILabel!
    internal var promoCode: String?
    internal var ownerName: String?
    private var howItWorksUrl: String?
    internal var dismisHandler: (()->Void)?
    //    MARK:- Lifecycle
    override internal func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        BranchAnalytics().moEngageTrackScreenEvent(name: "Friend View After Install")
    }
    override internal func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setWhite()
    }
    //    MARK:- Setup
    private func setupUI() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70.0
        self.title = "Bonus TokoCash Untukmu!"
        self.codeLabel.text = self.promoCode
        ReferralRemoteConfig.shared.getWelcomeScreenContent { (description: String) in
            let owner = self.ownerName ?? ""
            var name = UserAuthentificationManager().getUserShortName() ?? ""
            if !name.isEmpty {
                name = " " + name
            }
            let message = description.replacingOccurrences(of: "%s", with: "%@")
            self.messageLabel.text = String(format:message,name,owner)
        }
        ReferralRemoteConfig.shared.getHowReferralWorksLink { (url: String) in
            self.howItWorksUrl = url
        }
    }
    //    MARK:- Actions
    @IBAction private func codeCopyButtonTapped(sender: UIButton) {
        UIPasteboard.general.string = self.promoCode
        StickyAlertView.showSuccessMessage(["Tersalin"])
        BranchAnalytics().trackReferralCodeLabelEvent(action: "click copy referral code")
    }
    @IBAction private func dismissButtonTapped(sender: UIButton) {
        if let handler = self.dismisHandler {
            handler()
        }
        BranchAnalytics().trackClickReferralEvent(action: "click explore tokopedia", label: "landing url")
    }
    @IBAction private func howItWorksTapped(sender: UIButton) {
        let webViewController = WKWebViewController(urlString: "https://www.tokopedia.com/referral", shouldAuthorizeRequest: false)
        self.navigationController?.pushViewController(webViewController, animated: true)
        BranchAnalytics().trackClickReferralEvent(action: "click how it works", label: "")
   }
    //    MARK:- UITableViewDelegate
    override internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
