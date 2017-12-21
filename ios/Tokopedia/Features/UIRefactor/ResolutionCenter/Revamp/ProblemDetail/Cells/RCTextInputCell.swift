//
//  RCTextInputCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 02/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class RCTextInputCell: UITableViewCell, UITextViewDelegate {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet private weak var  dropdownImageView: UIImageView?
    @IBOutlet private weak var minimumCharacterLabel: UILabel?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.heightAnchor.constraint(equalToConstant: 40)
    }
    func updateWith(status: RCStatus) {
        if status.trouble.count > 0 {
            self.dropdownImageView?.isHidden = false
            self.textView.isUserInteractionEnabled = false
            self.textView.isExclusiveTouch = false
            if let trouble = status.selectedTrouble {
                self.textView.text = trouble.name
            } else {
                self.textView.text = "Pilih Masalah"
            }
        } else {
            self.dropdownImageView?.isHidden = true
            self.textView.isEditable = true
        }
    }
//    MARK:- UITextViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.isScrollEnabled = true
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.isScrollEnabled = false
    }
    func textViewDidChange(_ textView: UITextView) {
        if let label = self.minimumCharacterLabel {
            if textView.text.count < 30 {
                label.isHidden = false
                label.textColor = UIColor.tpRed()
            } else {
                label.isHidden = true
            }
        }
    }
}
