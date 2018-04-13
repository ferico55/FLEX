//
//  GroupChatPollingCell.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/26/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class GroupChatPollingCell: UITableViewCell {
    
    @IBOutlet private weak var adminImageView: UIImageView!
    @IBOutlet private weak var adminNameLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var pollingView: UIView!
    @IBOutlet private weak var pollingIcon: UIImageView!
    @IBOutlet private weak var pollingTitle: UILabel!
    @IBOutlet private weak var questionLabel: UILabel!

    override internal func awakeFromNib() {
        super.awakeFromNib()
    }
    
    internal static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    internal static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }

    override internal func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    internal func setupView(data: ChatItem?, pollingType: MsgCustomType) {
        guard let data = data else {
            return
        }
        
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        if let profileUrl = data.sender.profileUrl {
            self.adminImageView.setImageWith(profileUrl)
        }
        
        self.adminNameLabel.text = data.sender.nickname
        
        self.pollingIcon.image = pollingType == .pollingStart ? #imageLiteral(resourceName: "polling_green") : #imageLiteral(resourceName: "polling_grey")
        self.pollingTitle.text = pollingType == .pollingStart ? "VOTE TELAH DIMULAI" : "VOTE TELAH BERAKHIR"
        self.pollingTitle.textColor = pollingType == .pollingStart ? .tpGreen() : .tpSecondaryBlackText()
        if let question = data.data?["question"] as? NSAttributedString {
            self.questionLabel.attributedText = question
        }
        
        self.pollingView.snp.makeConstraints { (make) in
            make.width.equalTo(UIScreen.main.bounds.size.width * 3 / 4)
        }
        
        self.timestampLabel.text = data.createdAt
        
        if #available(iOS 11, *) {
            self.pollingView.layer.cornerRadius = 12
            self.pollingView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }
    
}
