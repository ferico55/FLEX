//
//  CodeShareTableViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 06/09/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class CodeShareTableViewController: UITableViewController {
    @IBOutlet weak private var topImageView: UIImageView!
    @IBOutlet weak private var codeLabel: UILabel!
    @IBOutlet weak private var codeViewContainer: UIView!
    private var isHowItWorkLinkVisible = false
//    MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setWhite()
    }
//    MARK:- Setup
    private func setupUI() {
        self.codeViewContainer.removeAllSubviews()
    }
//    MARK:- Actions
    @IBAction private func codeCopyButtonTapped(sender: UIButton) {
        
    }
    @IBAction private func sendInviteButtonTapped(sender: UIButton) {
        ReferralRemoteConfig.shared.getAppShareDescription { (description: String) in
            if let textURL = ReferralManager().getShortUrlForHome() {
                let title = description
                let controller = UIActivityViewController.shareDialog(withTitle: title, url: URL(string: textURL), anchor: sender)
                self.present(controller!, animated: true, completion: nil)
                AnalyticsManager.trackEventName("clickReferral", category: "Referral", action: GA_EVENT_ACTION_CLICK, label: "Share")
            }
        }
    }
//    MARK:- UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0: return 50
        case 1: return 146
        case 2: return 40
        case 3: return (self.isHowItWorkLinkVisible) ? 50 : 0
        case 4: return (self.isHowItWorkLinkVisible) ? 0 : 110
        case 5: return 80
        case 6: return 73
        case 7: return 48
        default: return 0
        }
    }
}
