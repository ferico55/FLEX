//
//  RCProofViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import DKImagePickerController
import UIKit

internal class RCProofViewController: UIViewController {
    @IBOutlet private weak var button: UIButton!
    internal var selectedPhotos: [DKAsset]?
    internal var attchmentMessage: String?
    internal override func viewDidLoad() {
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
    internal func refreshUI() {
        if self.validate() {
            self.markButtonHighlighted()
        } else {
            self.markButtonDisabled()
        }
    }
    private func validate(_ showError: Bool = false)->Bool {
        guard let data = RCManager.shared.rcCreateStep1Data  else {return false}
        if data.isProofSubmissionRequired {
            guard let selectedPhotos = self.selectedPhotos else {
                return false
            }
            for photo in selectedPhotos {
                if let asset = photo.originalAsset, asset.pixelWidth < 300 || asset.pixelHeight < 300 {
                    if showError {
                        StickyAlertView.showErrorMessage(["Gambar terlalu kecil, minimal 300 pixel"])
                    }
                    return false
                }
            }
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
        guard self.validate(true) else {return}
        RCManager.shared.rcCreateStep1Data?.attchmentMessage = self.attchmentMessage
        RCManager.shared.rcCreateStep1Data?.selectedPhotos = self.selectedPhotos
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction private func endEditing(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
//    MARK:-
    internal func markButtonHighlighted() {
        self.button.backgroundColor = UIColor.tpGreen()
        self.button.setTitleColor(.white, for: .normal)
        self.button.layer.borderWidth = 0.0
    }
    internal func markButtonDisabled() {
        self.button.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
        self.button.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.38), for: .normal)
        self.button.layer.borderWidth = 0.0
    }
}
