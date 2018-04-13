//
//  GroupChatGratificationCell.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/28/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

internal class GroupChatGratificationCell: UITableViewCell {
    
    @IBOutlet private weak var gratificationView: UIView!
    @IBOutlet private weak var gratificationIconImageView: UIImageView!
    @IBOutlet private weak var messageLabel: UILabel!
    internal weak var delegate: GroupChatTableViewDelegate?

    override internal func awakeFromNib() {
        super.awakeFromNib()
    }

    override internal func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    internal static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    internal func setupView(data: ChatItem?) {
        guard let item = data else {
            return
        }
        
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        if let summary = item.data?["desc"] as? String {
            let fullString = "\(summary) Cek sekarang!" as NSString
            let boldFontAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12), NSForegroundColorAttributeName: #colorLiteral(red: 0.7803921569, green: 0.4901960784, blue: 0.01960784314, alpha: 1)] as [String : Any]
            let normalFontAttribute = [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: #colorLiteral(red: 0.7803921569, green: 0.4901960784, blue: 0.01960784314, alpha: 1)] as [String : Any]
            let attributedText = NSMutableAttributedString(string: fullString as String, attributes: normalFontAttribute)
            attributedText.addAttributes(boldFontAttribute, range: fullString.range(of: " Cek sekarang!"))
            self.messageLabel.attributedText = attributedText
        }
        
        if let urlString = item.data?["applinks"] as? String {
            let tapGesture = UITapGestureRecognizer(target: self, action: nil)
            self.gratificationView.addGestureRecognizer(tapGesture)
            self.gratificationView.isUserInteractionEnabled = true
            
            tapGesture.rx.event.subscribe(onNext: { [weak self] _ in
                guard let `self` = self else {
                    return
                }
                self.delegate?.onPressItem(customType: item.customType.rawValue, data: ["url": urlString])
            }).addDisposableTo(self.rx_disposeBag)
        }
        
        if let tkpCode = item.data?["tkpCode"] as? Int {
            switch tkpCode {
            case 1401:
                self.gratificationIconImageView.image = #imageLiteral(resourceName: "icon_gratification_poin")
            case 1402:
                self.gratificationIconImageView.image = #imageLiteral(resourceName: "icon_gratification_loyalty")
            case 1403:
                self.gratificationIconImageView.image = #imageLiteral(resourceName: "icon_gratification_voucher")
            default:
                self.gratificationIconImageView.image = #imageLiteral(resourceName: "icon_gratification_loyalty")
            }
        }
    }
    
}
