//
//  ForbiddenViewController.swift
//  Tokopedia
//
//  Created by Samuel Edwin on 06/02/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

class ForbiddenViewController: UIViewController {
    
    @IBOutlet private var textView: UITextView!
    
    @IBAction private func buttonTap(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let text = """
                    Kami mendeteksi adanya aktivitas mencurigakan pada perangkat Anda yang melanggar Persyaratan Layanan Tokopedia.

                    Anda bisa kembali menggunakan aplikasi Tokopedia setelah aktivitas tersebut dihentikan.
                   """
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        
        let attributedText = NSMutableAttributedString(string: text, attributes: [
            NSForegroundColorAttributeName: #colorLiteral(red: 0.4834194183, green: 0.4834313393, blue: 0.483424902, alpha: 1),
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: UIFont.systemFont(ofSize: 15)
        ])
        
        let range = (text as NSString).range(of: "Persyaratan Layanan")
        attributedText.setAttributes([
            NSLinkAttributeName: "https://www.tokopedia.com/terms.pl",
            NSFontAttributeName: UIFont.systemFont(ofSize: 15)
        ], range: range)
        
        textView.delegate = self
        textView.attributedText = attributedText
    }
}

extension ForbiddenViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
}
