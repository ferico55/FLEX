//
//  VerifyPhoneTableViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 13/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
internal class VerifyPhoneTableViewController: UITableViewController {
    @IBOutlet weak private var phoneNumberField: UITextField!
//    MARK:- Lifecycle
    override internal func viewDidLoad() {
        super.viewDidLoad()
        self.phoneNumberField.text = UserAuthentificationManager().getUserPhoneNumber()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70.0
        self.title = "Mau Bonus TokoCash?"
        BranchAnalytics().moEngageTrackScreenEvent(name: "Phone Number Verification")
    }
    //    MARK:- Actions
    @IBAction private func verifyButtonTapped(sender: UIButton) {
        guard let number = self.phoneNumberField.text else { return }
        let controller = PhoneVerificationViewController(phoneNumber: number, isFirstTimeVisit: false, didVerifiedPhoneNumber: showTokoCashActivation)
        let navigationController = UINavigationController(rootViewController: controller)
        self.navigationController?.present(navigationController, animated: true, completion: nil)
        BranchAnalytics().trackClickReferralEvent(action: "click verify number", label: "phone number")
    }
    private func showTokoCashActivation() {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {            
            let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TokoCashActivationViewController")
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
//    MARK:- UITextFieldDelegate
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //    MARK:- UITableViewDelegate
    override internal func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
