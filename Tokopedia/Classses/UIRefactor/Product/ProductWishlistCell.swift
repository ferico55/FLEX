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

    @IBOutlet weak var goldBadgeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var luckyBadgeTopConstraint: NSLayoutConstraint!
    var tappedBuyButton: ((ProductWishlistCell) -> Void)?
    var tappedTrashButton: ((ProductWishlistCell) -> Void)?
    
    func setViewModel(viewModel : ProductModelView) {
        let url = NSURL.init(string: viewModel.productThumbUrl)!
        let luckyBadgeUrl = NSURL.init(string: viewModel.luckyMerchantImageURL)!
        productName.text = viewModel.productName
        productPrice.text = viewModel.productPrice
        productShopName.text = viewModel.productShop
        
        productImage.setImageWithUrl(url, placeHolderImage: nil)
        productShopLuckyBadge.setImageWithUrl(luckyBadgeUrl, placeHolderImage: nil)
        productShopLuckyBadge.contentMode = .ScaleAspectFill
        
        let trashGesture = UITapGestureRecognizer.init(target: self, action: Selector("tapTrashButton"))
        productTrashButton.addGestureRecognizer(trashGesture)
        productTrashButton.userInteractionEnabled = true
        
        if(viewModel.isProductBuyAble) {
            productBuyButton.backgroundColor = UIColor.init(red: 255/255, green: 87/255, blue: 34/255, alpha: 1.0)
            productBuyButton.setTitle("Beli", forState: .Normal)
            productBuyButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
            productBuyButton.userInteractionEnabled = true
        } else {
            productBuyButton.backgroundColor = UIColor.init(red: 231/255, green: 231/255, blue: 231/255, alpha: 0.65)
            productBuyButton.setTitle("Stok Kosong", forState: .Normal)
            productBuyButton.setTitleColor(UIColor.lightGrayColor(), forState: .Normal)
            productBuyButton.userInteractionEnabled = false
        }
        
        productShopGoldBadge.hidden = viewModel.isGoldShopProduct ? false : true
        goldBadgeHeightConstraint.constant = viewModel.isGoldShopProduct ? productShopGoldBadge.frame.size.width : 0
        luckyBadgeTopConstraint.constant = viewModel.isGoldShopProduct ? 2 : 0
        
    }
    
    @IBAction func tapBuyButton(sender: AnyObject) {
        tappedBuyButton?(self)
    }
    
    func tapTrashButton() {
        tappedTrashButton?(self)
    }

}
