//
//  RCProofViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit
import DKImagePickerController
class RCProofViewController: UIViewController {
    @IBOutlet private weak var button: UIButton!
    var selectedPhotos: [DKAsset]?
    var attchmentMessage: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.refreshUI()
    }
    //    MARK:- UI
    private func setupUI() {
        self.title = "Bukti & Keterangan"
        self.selectedPhotos = RCManager.shared.rcCreateStep1Data?.selectedPhotos
        self.attchmentMessage = RCManager.shared.rcCreateStep1Data?.attchmentMessage
    }
    func refreshUI() {
        if self.validate() {
            self.markButtonHighlighted()
        } else {
            self.markButtonDisabled()
        }
    }
    private func validate()->Bool {
        guard let data = RCManager.shared.rcCreateStep1Data  else {return false}
        if data.isProofSubmissionRequired && self.selectedPhotos == nil {
            return false
        }
        if let text = self.attchmentMessage {
            if text.count < 30 {
                return false
            }
        } else {
            return false
        }
        return true
    }
    @IBAction private func submitTapped(sender: UIButton) {
        guard self.validate() else {return}
        RCManager.shared.rcCreateStep1Data?.attchmentMessage = self.attchmentMessage
        RCManager.shared.rcCreateStep1Data?.selectedPhotos = self.selectedPhotos
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction private func endEditing(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
//    MARK:-
    func markButtonHighlighted() {
        self.button.backgroundColor = UIColor.tpGreen()
        self.button.setTitleColor(.white, for: .normal)
        self.button.layer.borderWidth = 0.0
    }
    func markButtonDisabled() {
        self.button.backgroundColor = UIColor(white: 0.0, alpha: 0.12)
        self.button.setTitleColor(UIColor(white: 0.0, alpha: 0.38), for: .normal)
        self.button.layer.borderWidth = 0.0
    }
}
