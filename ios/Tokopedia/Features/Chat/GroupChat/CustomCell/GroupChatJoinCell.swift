//
//  GroupChatJoinCell.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/26/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import UIKit

internal class GroupChatJoinCell: UITableViewCell {
    
    @IBOutlet private weak var userImageView: UIImageView!
    @IBOutlet private weak var joinLabel: UILabel!

    override internal func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override internal func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    internal static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    internal static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    internal func setupView(data: ChatItem?) {
        guard let data = data else {
            return
        }
        
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        self.joinLabel.text = "\(data.sender.nickname) bergabung"
        
        if let profileURL = data.sender.profileUrl {
            self.userImageView.setImageWith(profileURL)
        }
    }
}
