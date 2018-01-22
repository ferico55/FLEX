//
//  SolutionFreeReturnCell.swift
//  Tokopedia
//
//  Created by Vishun Dayal on 16/11/17.
//  Copyright © 2017 TOKOPEDIA. All rights reserved.
//

import UIKit

class SolutionFreeReturnCell: UITableViewCell {
    @IBOutlet private weak var returnInfoView: UITextView!
    func updateWith(returnInfo: RCFreeReturn) {
        let attribute = [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType]
        let info = returnInfo.info.replacingOccurrences(of: "\n", with: "")
        let htmlString = "<html><head><style>body{font-family: -apple-system; font-weight: lighter; font-size:12; color: rgba(0, 0, 0, 0.38); margin: 0px; padding: 0px;} a{color:rgb(66, 181, 73)}</style></head><body>\(info)</body></html>"
        if let htmlData = NSString(string: htmlString).data(using: String.Encoding.unicode.rawValue) {
            do {
                let attributedString = try NSAttributedString(data: htmlData, options: attribute, documentAttributes: nil)
                self.returnInfoView.attributedText = attributedString
            } catch {
                
            }
        }
        
//        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        
    }
}
