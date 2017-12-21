//
//  RCProblemTextCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 27/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class RCProblemTextCell: UITableViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet private weak var minimumCharacterLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.textView.heightAnchor.constraint(equalToConstant: 40)
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
        if self.textView.text.count < 29 {
            self.minimumCharacterLabel.isHidden = false
            self.minimumCharacterLabel.textColor = UIColor.tpRed()
        } else {
            self.minimumCharacterLabel.isHidden = true
        }
    }
}
