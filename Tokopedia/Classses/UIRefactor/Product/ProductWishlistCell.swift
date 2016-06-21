//
//  ProductWishlistCell.swift
//  Tokopedia
//
//  Created by Tonito Acen on 3/11/16.
//  Copyright © 2016 TOKOPEDIA. All rights reserved.
//

import Foundation


class ProductWishlistCell : UICollectionViewCell {
    
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTrashButton: UIImageView!
    @IBOutlet weak var productBuyButton: UIButton!
    @IBOutlet weak var productShopLuckyBadge: UIImageView!
    @IBOutlet weak var productShopGoldBadge: UIImageView!
    @IBOutlet weak var productShopName: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var preorderLabel: UILabel!
    @IBOutlet weak var wholesaleLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var preorderPositionConstraint: NSLayoutConstraint!
    

//    @IBOutlet weak var goldBadgeHeightConstraint: NSLayoutConstraint!
//    @IBOutlet weak var luckyBadgeTopConstraint: NSLayoutConstraint!
    var tappedBuyButton: ((ProductWishlistCell) -> Void)?
    var tappedTrashButton: ((ProductWishlistCell) -> Void)?
    
    func setViewModel(viewModel : ProductModelView) {
        let url = NSURL.init(string: viewModel.productThumbUrl)!
        let luckyBadgeUrl = NSURL.init(string: viewModel.luckyMerchantImageURL)!
        productName.text = viewModel.productName
        productPrice.text = viewModel.productPrice
        productShopName.text = viewModel.productShop
        
        preorderLabel.layer.masksToBounds = true
        wholesaleLabel.layer.masksToBounds = true
        preorderPositionConstraint.constant = !viewModel.isWholesale ? -42 : 3;
        preorderLabel.hidden = viewModel.isProductPreorder ? false : true
        wholesaleLabel.hidden = viewModel.isWholesale ? false : true
        locationLabel.text = viewModel.shopLocation
        
        productImage.setImageWithUrl(url, placeHolderImage: nil)
        productShopLuckyBadge.setImageWithUrl(luckyBadgeUrl, placeHolderImage: nil)
        productShopLuckyBadge.contentMode = .ScaleAspectFill
        
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
        
        productShopGoldBadge.hidden = viewModel.isGoldShopProduct ? false : true
//        goldBadgeHeightConstraint.constant = viewModel.isGoldShopProduct ? productShopGoldBadge.frame.size.width : 0
//        luckyBadgeTopConstraint.constant = viewModel.isGoldShopProduct ? 2 : 0
        
    }
    
    @IBAction func tapBuyButton(sender: AnyObject) {
        tappedBuyButton?(self)
    }
    
    func tapTrashButton() {
        tappedTrashButton?(self)
    }

}
