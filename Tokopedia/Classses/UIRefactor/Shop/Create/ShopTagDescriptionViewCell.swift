//
//  ShopTagDescriptionViewCell.swift
//  Tokopedia
//
//  Created by Tokopedia on 4/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class ShopTagDescriptionViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var textView: RSKPlaceholderTextView!
    @IBOutlet weak var textCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateCounterLabel()
        textView.placeholderColor = UIColor(red: 199.0/255.0, green: 199.0/255.0, blue: 205.0/255.0, alpha: 1.0)
        textView.font = UIFont(name: "GothamBook", size: 14)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func textViewDidChange(textView: UITextView) {
        updateCounterLabel()
    }
    
    func updateCounterLabel() -> Void {
        if (self.textView.tag == 1) {
            let count: Int = 48 - self.textView.text.characters.count;
            textCountLabel.text = String(count);
        } else if (self.textView.tag == 2) {
            let count: Int = 120 - self.textView.text.characters.count;
            textCountLabel.text = String(count);
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (textView.tag == 1) {
            if (range.location == 48 && range.length == 0) {
                return false
            } else if (range.location + text.characters.count > 48) {
                return false
            }
        } else if (textView.tag == 2) {
            if (range.location == 120 && range.length == 0) {
                return false
            } else if (range.location + text.characters.count > 120) {
                return false
            }
        }
        return true
    }
    
}
