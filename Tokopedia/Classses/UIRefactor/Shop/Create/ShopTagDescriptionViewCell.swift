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
    
}
