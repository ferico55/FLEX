//
//  GroupChatSprintSaleCell.swift
//  Tokopedia
//
//  Created by Kenneth Vincent on 3/27/18.
//  Copyright © 2018 TOKOPEDIA. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

internal class GroupChatSprintSaleCell: UITableViewCell {
    
    @IBOutlet private weak var adminImageView: UIImageView!
    @IBOutlet private weak var adminNameLabel: UILabel!
    @IBOutlet private weak var timestampLabel: UILabel!
    
    @IBOutlet private weak var sprintSaleView: UIView!
    @IBOutlet private weak var sprintSaleLabel: UILabel!
    @IBOutlet private weak var sprintSaleIcon: UIImageView!
    
    @IBOutlet private weak var firstProductView: UIView!
    @IBOutlet private weak var firstProductImageView: UIImageView!
    @IBOutlet private weak var firstProductPercentageLabel: UILabel!
    @IBOutlet private weak var firstProductOriginalPriceLabel: UILabel!
    @IBOutlet private weak var firstProductDiscountedPriceLabel: UILabel!
    @IBOutlet private weak var firstProductStockProgressView: UIProgressView!
    @IBOutlet private weak var firstProductStockLabel: UILabel!
    
    @IBOutlet private weak var secondProductView: UIView!
    @IBOutlet private weak var secondProductImageView: UIImageView!
    @IBOutlet private weak var secondProductPercentageLabel: UILabel!
    @IBOutlet private weak var secondProductOriginalPriceLabel: UILabel!
    @IBOutlet private weak var secondProductDiscountedPriceLabel: UILabel!
    @IBOutlet private weak var secondProductStockProgressView: UIProgressView!
    @IBOutlet private weak var secondProductStockLabel: UILabel!
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
    
    internal func setupView(data: ChatItem?, type: MsgCustomType) {
        guard let item = data else {
            return
        }
        
        if let profileUrl = item.sender.profileUrl {
            self.adminImageView.setImageWith(profileUrl)
        }
        
        self.adminNameLabel.text = item.sender.nickname
        self.timestampLabel.text = item.createdAt
        
        let firstTap = UITapGestureRecognizer(target: self, action: nil)
        self.firstProductView.addGestureRecognizer(firstTap)
        self.firstProductView.isUserInteractionEnabled = true
        
        let secondTap = UITapGestureRecognizer(target: self, action: nil)
        self.secondProductView.addGestureRecognizer(secondTap)
        self.secondProductView.isUserInteractionEnabled = true
        
        self.sprintSaleLabel.text = type == .flashsaleEnd ? "SPRINT SALE TELAH BERAKHIR" : "SPRINT SALE TELAH DIMULAI"
        self.sprintSaleLabel.textColor = type == .flashsaleEnd ? .tpSecondaryBlackText() : .tpGreen()
        self.sprintSaleIcon.image = type == .flashsaleEnd ? #imageLiteral(resourceName: "icon_sprint_sale_gray") : #imageLiteral(resourceName: "icon_sprint_sale_green")
        
        // MARK: Data always Two
        if let products = item.data?["products"] as? NSArray, products.count == 2 {
            let productItem = SprintSaleProductObject(data: products)
            
            //First
            if let firstData = productItem.list.first {
                if let firstImageUrl = firstData.imageUrl {
                    self.firstProductImageView.setImageWith(firstImageUrl)
                }
                
                self.firstProductPercentageLabel.text = "\(firstData.discountPercentage)% OFF"
                self.firstProductStockProgressView.setProgress(firstData.stockPercentage, animated: false)
                self.firstProductStockLabel.text = firstData.stockText
                
                let originalPriceText = NSMutableAttributedString(string:"\(firstData.originalPrice)")
                originalPriceText.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSRange(location: 0, length: originalPriceText.length))
                self.firstProductOriginalPriceLabel.attributedText = originalPriceText
                
                self.firstProductDiscountedPriceLabel.text = "\(firstData.discountPrice)"
                firstTap.rx.event.subscribe(onNext: { [weak self] _ in
                    guard let `self` = self else {
                        return
                    }
                    self.delegate?.onPressItem(customType: item.customType.rawValue, data: ["index": 0, "campaign_id":item.data?["campaign_id"]])
                }).addDisposableTo(self.rx_disposeBag)
            }
            
            //Second
            if let secondData = productItem.list.last {
                if let secondImageUrl = secondData.imageUrl {
                    self.secondProductImageView.setImageWith(secondImageUrl)
                }
                self.secondProductPercentageLabel.text = "\(secondData.discountPercentage)% OFF"
                self.secondProductStockProgressView.setProgress(secondData.stockPercentage, animated: false)
                self.secondProductStockLabel.text = secondData.stockText
                
                let originalPriceText = NSMutableAttributedString(string:"\(secondData.originalPrice)")
                originalPriceText.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSRange(location: 0, length: originalPriceText.length))
                self.secondProductOriginalPriceLabel.attributedText = originalPriceText
                
                self.secondProductDiscountedPriceLabel.text = "\(secondData.discountPrice)"
                secondTap.rx.event.subscribe(onNext: { [weak self] _ in
                    guard let `self` = self else {
                        return
                    }
                    self.delegate?.onPressItem(customType: item.customType.rawValue, data: ["index": 1, "campaign_id":item.data?["campaign_id"]])
                }).addDisposableTo(self.rx_disposeBag)
            }
        }
        
        self.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.selectionStyle = UITableViewCellSelectionStyle.none
        if #available(iOS 11, *) {
            self.sprintSaleView.layer.cornerRadius = 12
            self.sprintSaleView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        }
    }
}
