//
//  GroupChatAnnouncementCell.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/28/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

internal class GroupChatAnnouncementCell: UITableViewCell {
    
    @IBOutlet private weak var adminImageView: UIImageView!
    @IBOutlet private weak var adminNameLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    @IBOutlet private weak var contentImageView: UIImageView!

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
        
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        if let profileUrl = item.sender.profileUrl {
            self.adminImageView.setImageWith(profileUrl)
        }
        
        self.adminNameLabel.text = item.sender.nickname
        
        if let imageURL = item.data?["image_url"] as? String, let url = URL(string: imageURL) {
            self.contentImageView.setImageWith(url)
        }
        
        if let redirectUrlString = item.data?["redirect_url"] as? String, let url = URL(string: redirectUrlString), let imageURL = item.data?["image_url"] as? String {
            let imageTap = UITapGestureRecognizer(target: self, action: nil)
            self.contentImageView.addGestureRecognizer(imageTap)
            self.contentImageView.isUserInteractionEnabled = true
            imageTap.rx.event.subscribe(onNext: { _ in
                AnalyticsManager.trackEventName("clickGroupChat", category: "groupchat room", action: "click on image thumbnail", label: imageURL)
                TPRoutes.routeURL(url)
            }).addDisposableTo(self.rx_disposeBag)
        }
        
        self.timestampLabel.text = item.createdAt
        
        self.contentImageView.layer.borderWidth = 1
        self.contentImageView.layer.borderColor = #colorLiteral(red: 0.8784313725, green: 0.8784313725, blue: 0.8784313725, alpha: 1)
        
        if #available(iOS 11, *) {
            self.contentImageView.layer.cornerRadius = 12
            self.contentImageView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }
}
