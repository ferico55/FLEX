//
//  GroupChatPlainMessageCell.swift
//  Tokopedia
//
//  Created by Bondan Eko Prasetyo on 23/03/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class GroupChatPlainMessageCell: UITableViewCell {
    
    @IBOutlet private weak var profileImage: UIImageView!
    @IBOutlet private weak var messageText: UILabel!
    @IBOutlet private weak var senderName: UILabel!
    @IBOutlet private weak var adminLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    
    internal override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    internal static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    internal static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    internal func setupView(data: ChatItem?, type: MsgCustomType){
        guard let item = data else {
            return
        }
        
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        if let generatedMsg = item.data?["message"] as? NSAttributedString , type == .generatedMsg {
            self.messageText.attributedText = generatedMsg
        }else{
            self.messageText.attributedText = item.message
        }
        
        self.messageText.sizeToFit()
        self.messageText.layoutIfNeeded()
        
        self.senderName.text = item.sender.nickname
        self.timeLabel.text = item.createdAt
        if let profileUrl = item.sender.profileUrl {
            self.profileImage.setImageWith(profileUrl)
        }
        
        setAdminLabel(type)
    }
    
    private func setAdminLabel(_ customType: MsgCustomType){
        if customType == .chat || customType == .generatedMsg {
            self.adminLabel.isHidden = false
            self.senderName.textColor = .tpGreen()
            self.senderName.font = .semiboldSystemFont(ofSize: 11)
        } else {
            self.adminLabel.isHidden = true
            self.senderName.textColor = .tpDisabledBlackText()
            self.senderName.font = .systemFont(ofSize: 11)
        }
    }
    
}
