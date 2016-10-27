//
//  ProductWishlistCell.swift
//  Tokopedia
//
//  Created by Tonito Acen on 3/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation
import OAStackView


class ProductWishlistCell : UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTrashButton: UIImageView!
    @IBOutlet weak var productBuyButton: UIButton!
    @IBOutlet weak var productShopName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var badgesView: TKPDStackView!
    @IBOutlet weak var labelsView: OAStackView!
    
    var imageDownloader = QueueImageDownloader()
    
    
    @IBOutlet weak var preorderPositionConstraint: NSLayoutConstraint!
    
    var tappedBuyButton: ((ProductWishlistCell) -> Void)?
    var tappedTrashButton: ((ProductWishlistCell) -> Void)?
    
    func setViewModel(viewModel : ProductModelView) {
        let url = NSURL(string: viewModel.productThumbUrl)!
        productName.text = viewModel.productName
        productPrice.text = viewModel.productPrice
        productShopName.text = viewModel.productShop
        
        locationLabel.text = viewModel.shopLocation
        
        productImage.setImageWithUrl(url, placeHolderImage: UIImage(named: "grey-bg.png"))
        
        let trashGesture = UITapGestureRecognizer.init(target: self, action: #selector(ProductWishlistCell.tapTrashButton))
        productTrashButton.addGestureRecognizer(trashGesture)
        productTrashButton.userInteractionEnabled = true
        
        if(viewModel.isProductBuyAble) {
            productBuyButton.backgroundColor = UIColor.whiteColor()
            productBuyButton.setTitle("Beli", forState: .Normal)
            productBuyButton.userInteractionEnabled = true
            productBuyButton.layer.borderWidth = 1.0
            productBuyButton.layer.borderColor = UIColor.init(red: 255/255, green: 87/255, blue: 34/255, alpha: 1.0).CGColor
            productBuyButton.setTitleColor(UIColor.init(red: 255/255, green: 87/255, blue: 34/255, alpha: 1.0), forState: .Normal)
        } else {
            productBuyButton.backgroundColor = UIColor.init(red: 231/255, green: 231/255, blue: 231/255, alpha: 0.65)
            productBuyButton.setTitle("Stok Kosong", forState: .Normal)
            productBuyButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            productBuyButton.layer.borderColor = UIColor.lightGrayColor().CGColor
            productBuyButton.userInteractionEnabled = false
        }
        setBadges(viewModel.badges)
        
    }
    
    internal func setBadges(badges: [AnyObject]) {
        //all of this is just for badges, dynamic badges
        self.badgesView .removeAllPushedView()
        let badgeSize = CGSizeMake(self.badgesView.frame.size.height, self.badgesView.frame.size.height);
        self.badgesView.orientation = .RightToLeft;
        
        
        let urls = NSMutableArray()
        badges.enumerate().map { index, badge in
            urls.addObject(badge.image_url)
        }
        
        imageDownloader.downloadImagesWithUrls(urls.copy() as! [String], onComplete: { images in
            images.enumerate().map{ index, image in
                if(image.size.width > 1){
                    
                    let badgeView = UIView(frame: CGRectMake(0, 0, badgeSize.width, badgeSize.height))
                    let badgeImageView = UIImageView(frame: CGRectMake(0, 0, badgeSize.width, badgeSize.height))
                    badgeImageView.image = image;
                    badgeView.addSubview(badgeImageView)
                    self.badgesView.pushView(badgeView)
                }
            }
        })
    }
    
    @IBAction func tapBuyButton(sender: AnyObject) {
        tappedBuyButton?(self)
    }
    
    func tapTrashButton() {
        tappedTrashButton?(self)
    }

}
