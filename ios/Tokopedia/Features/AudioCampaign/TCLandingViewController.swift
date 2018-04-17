//
//  TCLandingViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 12/04/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal struct TCErrorMessage {
    internal var title = ""
    internal var message = ""
    internal var buttonTitle = ""
    internal var deeplink = "tokopedia://home"
    internal init(params:[String:Any] = [:]) {
        if let value = params["title"] as? String {
            self.title = value
        }
        if let value = params["message"] as? String {
            self.message = value
        }
        if let value = params["button"] as? String {
            self.buttonTitle = value
        }
        if let value = params["applink"] as? String {
            self.deeplink = value
        }
    }
}
internal class TCLandingViewController: UITableViewController {
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var actionButton: UIButton!
    internal var message:TCErrorMessage = TCErrorMessage()
    internal class func controller(params:[String:Any]) -> TCLandingViewController {
        let storyboard = UIStoryboard(name: "AudioRecorder", bundle: nil)
        guard let controller = storyboard.instantiateViewController(withIdentifier: "TCLandingViewController") as? TCLandingViewController else {
            fatalError("TCLandingViewController.controller not found")
        }
        controller.message = TCErrorMessage(params: params)
        return controller
    }
    internal override func viewDidLoad() {
        super.viewDidLoad()
        self.updateUI()
    }
    private func updateUI() {
        self.errorLabel.text = self.message.title
        self.detailLabel.text = self.message.message
        self.actionButton.setTitle(self.message.buttonTitle, for: .normal)
    }
    @IBAction private func actionButtonTap(sender:UIButton)  {
        self.navigationController?.popViewController(animated: true)
        if let url = URL(string: self.message.deeplink) {
            TPRoutes.routeURL(url)
        }
    }
}
