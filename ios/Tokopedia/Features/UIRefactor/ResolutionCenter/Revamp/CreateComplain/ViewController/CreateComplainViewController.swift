//
//  CreateComplainViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 10/10/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class CreateComplainViewController: UIViewController {
    var order: TxOrderStatusList!
    //    MARK:- IBoutlets
    @IBOutlet private weak var createButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    var isAllChecksPassed: Bool {
        guard let data = RCManager.shared.rcCreateStep1Data else {return false}
        return (data.selectedProblemItem.count > 0) && data.isSolutionAdded && data.isProofAdded
    }
    //  MARK:- Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Buat Komplain"
        RCManager.shared.order = self.order
        AnalyticsManager.trackScreenName("Resolution Center Create Problem Page")
    }
    deinit {
        RCManager.shared.rcCreateStep1Data = nil
    }
    //    MARK:- Update UI
    func updateCreateButton() {
        if self.isAllChecksPassed {
            self.createButton.backgroundColor = UIColor.tpGreen()
            self.createButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            self.createButton.backgroundColor = UIColor(white: 0.0, alpha: 0.12)
            self.createButton.setTitleColor(UIColor(white: 0.0, alpha: 0.38), for: .normal)
        }
    }
    func makeActivityIndicator(toShow: Bool) {
        if toShow {
            self.activityIndicator.startAnimating()
            self.createButton.setTitle("", for: .normal)
        } else {
            self.activityIndicator.stopAnimating()
            self.createButton.setTitle("Buat Komplain", for: .normal)
        }
        self.view.isUserInteractionEnabled = !toShow
    }
    private func showConfirmationAlert() {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ConfirmAlertViewController") as? ConfirmAlertViewController {
            viewController.complainButtonHandler = self.createComplaint
            self.navigationController?.present(viewController, animated: false, completion: nil)
        }
    }
    //    MARK:- Action
    @IBAction private func createButtonTapped(sender: UIButton) {
        self.showConfirmationAlert()
        if self.isAllChecksPassed {
        }
    }
    //    MARK:- Display pages
    func showSelectProblemScreen() {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ProblemsListViewController") as? ProblemsListViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    func showSolutionsListScreen() {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SolutionListViewController") as? SolutionListViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    func showProofSubmissionScreen() {
        if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "RCProofViewController") as? RCProofViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    private func showComplaintDetail(resolutionId: Int) {
        AnalyticsManager.moEngageTrackEvent(withName: "Shipping_Received_Confirmation", attributes: ["is_received" : RCManager.shared.isRecieved])
        let url = String(format:"%@/resolution/%d/mobile",NSString.mobileSiteUrl(),resolutionId)
        let authenticatedUrl = UserAuthentificationManager().webViewUrl(fromUrl: url)
        let webViewController = WKWebViewController(urlString:authenticatedUrl, shouldAuthorizeRequest: true)
        if var controllers = self.navigationController?.viewControllers {
            controllers.removeLast()
            controllers.removeLast()
            controllers.append(webViewController)
            self.navigationController?.setViewControllers(controllers, animated: true)
        }
    }
    //    MARK:- Web Services
    private func createComplaint() {
        self.makeActivityIndicator(toShow: true)
        RCManager.shared.createComplaint { (response: RCCreateComplaintResponse?, error: Error?) in
            self.makeActivityIndicator(toShow: false)
            if let error = error {
                StickyAlertView.showErrorMessage([error.localizedDescription])
            } else {
                if let successMessge = response?.data?.succesMessage {
                    StickyAlertView.showSuccessMessage([successMessge])
                } else if let errorMessage = response?.message_error.first {
                    StickyAlertView.showErrorMessage([errorMessage])
                }
                if let resolutionId = response?.data?.resolutionId {
                    self.showComplaintDetail(resolutionId: resolutionId)
                }
            }
        }
    }
}
