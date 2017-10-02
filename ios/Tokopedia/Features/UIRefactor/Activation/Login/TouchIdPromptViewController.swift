//
//  TouchIdPromptViewController.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 08/08/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class TouchIdPromptViewController: UIViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet private weak var promptLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    deinit {
        debugPrint(self)
    }
    func setupUI() {
        let attributedString = NSMutableAttributedString(string: "Baru! Masuk lebih cepat dan mudah ")
        let range = NSRange(location: 0, length: 5)
        var boldFont: UIFont!
        if #available(iOS 8.2, *) {
            boldFont = UIFont.systemFont(ofSize: 14.0, weight: UIFontWeightSemibold)
        } else {
            boldFont = UIFont.boldSystemFont(ofSize: 14.0)
        }
        attributedString.addAttribute(NSFontAttributeName, value: boldFont, range: range)
        self.promptLabel.attributedText = attributedString
    }
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
