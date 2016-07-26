//
//  AnnouncementTickerView.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 7/26/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import UIKit

class AnnouncementTickerView: UIView {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: TTTAttributedLabel!
    
    var onTapMessageWithUrl : ((NSURL) -> Void) = {_ in }
    
    func newView() -> AnyObject? {
        let views = NSBundle.mainBundle().loadNibNamed(String(AnnouncementTickerView), owner: nil, options: nil)
        
        for view in views {
            if view.isKindOfClass(AnnouncementTickerView) {
                return view
            }
        }
        
        return nil
    }
    
    // MARK: - Setter Methods    
    func setTitleLabel(text: String) {
        titleLabel.text = text
    }
    
    func setMessageLabel(text: String) {
        let attributedString = self.attributedMessage(text)
        messageLabel.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue
        messageLabel.attributedText = attributedString
        messageLabel.delegate = self
        
        let linkDetector = try! NSDataDetector(types: NSTextCheckingType.Link.rawValue)
        let matches = linkDetector.matchesInString(attributedString.string, options: [], range: NSMakeRange(0, attributedString.length))
        
        for match in matches {
            messageLabel.addLinkToURL(match.URL, withRange: match.range)
        }
        
        messageLabel.preferredMaxLayoutWidth = UIScreen.mainScreen().bounds.size.width - 72
        messageLabel.frame.size = TTTAttributedLabel.sizeThatFitsAttributedString(attributedString, withConstraints: CGSizeMake(UIScreen.mainScreen().bounds.size.width - 72, 9999.0), limitedToNumberOfLines: 100)
        
        
    }
    
    // MARK: - Methods
    func attributedMessage(text: String) -> NSAttributedString {
        let font = UIFont(name: "GothamBook", size: 14.0)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 4.0
        style.alignment = .Left
        
        let attributes: NSDictionary = [NSForegroundColorAttributeName : UIColor.blackColor(),
                                        NSFontAttributeName : font!,
                                        NSParagraphStyleAttributeName : style]
        let string = NSString(replaceAhrefWithUrl: text)
        let attributedString = NSAttributedString(string: string as String, attributes: attributes as? [String : AnyObject])
        
        return attributedString
    }
    
    // MARK: - TTTAttributedLabel Delegate
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        let tkpMeUrlString = NSString(format: "https://tkp.me/r?url=%@", url.absoluteString.stringByReplacingOccurrencesOfString("*", withString: "."))
        let url = NSURL(string: tkpMeUrlString.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)
        self.onTapMessageWithUrl(url!)
    }

}
